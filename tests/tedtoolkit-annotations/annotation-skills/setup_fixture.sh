#!/usr/bin/env bash
set -euo pipefail

package="$1"
cat > Sample.csproj <<EOF
<Project Sdk="Microsoft.NET.Sdk">
  <ItemGroup>
    <PackageReference Include="TedToolkit.Annotations.${package}" Version="0.1.0" />
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

  behavior-case)
cat > Sample.cs <<'EOF'
using System;

public sealed class BatchFactory
{
    public int[] Create(int count)
    {
        ArgumentOutOfRangeException.ThrowIfNegative(count);
        return count == 0 ? [] : new int[count];
    }
}
EOF

cat > SampleTests.cs <<'EOF'
using System;

public sealed class BatchFactoryTests
{
    public void Create_negative_count_throws_before_allocating()
    {
        var factory = new BatchFactory();
        _ = factory;
        // The real test framework assertion is intentionally omitted from this fixture.
        // The scenario describes the passing test contract for the skill to document.
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

  *)
    echo "Unknown fixture case: ${2}" >&2
    exit 2
    ;;
esac
