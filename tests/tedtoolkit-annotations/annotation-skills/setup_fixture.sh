#!/usr/bin/env bash
set -euo pipefail

package="$1"
if [[ "$package" == "Contracts" ]]; then
  references='    <PackageReference Include="TedToolkit.Annotations.Documentations" Version="2026.7.16.2" />
    <PackageReference Include="TedToolkit.Annotations.Maintenance" Version="2026.7.16.2" />'
else
  references="    <PackageReference Include=\"TedToolkit.Annotations.${package}\" Version=\"2026.7.16.2\" />"
fi
cat > Sample.csproj <<EOF
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
${references}
  </ItemGroup>
</Project>
EOF

case "${2:-default}" in
  default)
cat > Sample.cs <<'EOF'
using System;

public sealed class Sample
{
    public int MaxConcurrency { get; set; }

    public IDisposable Create() => throw new NotImplementedException();
}
EOF
    ;;

  behavior-pass|behavior-fail|behavior-unexecuted|behavior-zero)
cat > Sample.cs <<'EOF'
using System;

public sealed class BatchFactory
{
    public int AllocationCount { get; private set; }

    public int[] Create(int count)
    {
        ArgumentOutOfRangeException.ThrowIfNegative(count);
        AllocationCount++;
        return new int[count];
    }
}
EOF

cat > SampleTests.cs <<'EOF'
using System;
using System.Threading.Tasks;
using TUnit.Assertions;
using TUnit.Core;

public sealed class BatchFactoryTests
{
    [Test]
    public async Task Create_negative_count_throws_before_allocating()
    {
        var factory = new BatchFactory();

        await Assert.That(() => factory.Create(-1)).Throws<ArgumentOutOfRangeException>();
        await Assert.That(factory.AllocationCount).IsEqualTo(0);
    }
}
EOF
    if [[ "${2}" == "behavior-fail" ]]; then
      sed -i 's/IsEqualTo(0)/IsEqualTo(1)/' SampleTests.cs
    fi
cat > Sample.Tests.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net10.0</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="TUnit" Version="1.63.0" />
  </ItemGroup>
</Project>
EOF
cat > global.json <<'EOF'
{
  "test": {
    "runner": "Microsoft.Testing.Platform"
  }
}
EOF
    ;;

  operational)
cat > Sample.cs <<'EOF'
using System;
using System.IO;

public sealed class SettingsRefresher
{
    private readonly object _gate = new();
    private string _current = "";

    public void Refresh(Stream source, Action<string> changed)
    {
        lock (_gate)
        {
            _current = new StreamReader(source).ReadToEnd();
        }

        changed(_current);
    }
}
EOF
    ;;

  boxing)
cat > Sample.cs <<'EOF'
public sealed class ObjectCache
{
    private object? _cached;

    public void Store(int value) => _cached = value;
}
EOF
    ;;

  comment-scope|comment-policy)
cat > Sample.cs <<'EOF'
using System;

public sealed class Calculator
{
    public int Add(int left, int right) => left + right;

    public string Unrelated(string value) => value.Trim();

    public IDisposable OpenLease() => throw new NotImplementedException();
}
EOF
    if [[ "${2}" == "comment-policy" ]]; then
cat > AGENTS.md <<'EOF'
# Documentation policy

When a public declaration in Sample.cs changes, document every public declaration in that file.
EOF
    fi
    ;;

  comment-examples)
cat > Sample.cs <<'EOF'
using System;

public sealed class Calculator
{
    public int Add(int left, int right) => left + right;

    public IDisposable OpenLease() => new Lease();

    private sealed class Lease : IDisposable
    {
        public void Dispose() { }
    }
}
EOF
    ;;

  compile-contracts)
cat > Sample.cs <<'EOF'
using System;
using TedToolkit.Annotations.Documentations;
using TedToolkit.Annotations.Maintenance;

public sealed class ContractSample
{
    [BehaviorCase<ArgumentOutOfRangeException>("count is negative", "Throws before allocation", true)]
    [MayBlock(MayBlockKind.SYNCHRONIZATION, "Waits for the instance gate.")]
    [SideEffect(SideEffectKind.INSTANCE_STATE_MUTATION, "Updates the allocation counter.")]
    [TechnicalDebt(TechnicalDebtKind.PERFORMANCE,
        "The tracked #123 linear scan is intentionally retained while collections remain small.",
        RemoveWhen = "The collection can exceed 1,000 items.")]
    public int[] Create(int count) => count < 0 ? throw new ArgumentOutOfRangeException(nameof(count)) : new int[count];
}
EOF
    ;;

  *)
    echo "Unknown fixture case: ${2}" >&2
    exit 2
    ;;
esac

case "${2:-default}" in
  behavior-pass|behavior-fail|behavior-zero)
    dotnet restore Sample.Tests.csproj --nologo
    filter='/*/*/BatchFactoryTests/Create_negative_count_throws_before_allocating'
    if [[ "${2}" == "behavior-zero" ]]; then
      filter='/*/*/BatchFactoryTests/Missing_test'
    fi
    set +e
    dotnet run --project Sample.Tests.csproj -c Release --no-restore -- --treenode-filter "$filter" >test-output.txt 2>&1
    test_exit=$?
    set -e
    total=$(sed -n 's/^[[:space:]]*total:[[:space:]]*//p' test-output.txt | tail -n 1)
    passed=$(sed -n 's/^[[:space:]]*succeeded:[[:space:]]*//p' test-output.txt | tail -n 1)
    failed=$(sed -n 's/^[[:space:]]*failed:[[:space:]]*//p' test-output.txt | tail -n 1)
    skipped=$(sed -n 's/^[[:space:]]*skipped:[[:space:]]*//p' test-output.txt | tail -n 1)
    {
      printf 'Focused test command: dotnet run --project Sample.Tests.csproj -c Release --no-restore -- --treenode-filter "%s"\n' "$filter"
      printf 'Focused test exit: %s\n' "$test_exit"
      printf 'Tests: %s\nPassed: %s\nFailed: %s\nSkipped: %s\n' "${total:-0}" "${passed:-0}" "${failed:-0}" "${skipped:-0}"
    } >test-proof.txt
    ;;
  behavior-unexecuted)
    printf '%s\n' 'Focused test command: not executed' 'Focused test exit: not available' 'Tests: 0' 'Passed: 0' 'Failed: 0' 'Skipped: 0' >test-proof.txt
    ;;
  compile-contracts)
    dotnet restore Sample.csproj --nologo
    dotnet build Sample.csproj -c Release --no-restore --nologo
    printf '%s\n' 'ANNOTATION_CONTRACTS_COMPILE' >compile-proof.txt
    ;;
esac
