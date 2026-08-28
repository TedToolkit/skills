#!/usr/bin/env bash
set -euo pipefail

fixture="$1"

if [[ "$fixture" == "with-reference" || "$fixture" == "reference-proof" ]]; then
cat > Generator.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.CodeAnalysis.CSharp" Version="5.0.0" />
    <PackageReference Include="TedToolkit.RoslynHelper" Version="2026.7.15" />
  </ItemGroup>
</Project>
EOF
cat > Generator.cs <<'EOF'
using Microsoft.CodeAnalysis;

public sealed class DemoGenerator
{
    public static string Generate(IPropertySymbol propertySymbol, Compilation compilation)
    {
        throw new NotImplementedException("Compose the generated source with RoslynHelper.");
    }
}
EOF
cat > Program.cs <<'EOF'
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;

var references = ((string?)AppContext.GetData("TRUSTED_PLATFORM_ASSEMBLIES") ?? "")
    .Split(Path.PathSeparator, StringSplitOptions.RemoveEmptyEntries)
    .Select(path => MetadataReference.CreateFromFile(path));
var input = CSharpSyntaxTree.ParseText("namespace Input; public sealed class Source { public int Value { get; } }");
var compilation = CSharpCompilation.Create(
    "Input", [input], references,
    new CSharpCompilationOptions(OutputKind.DynamicallyLinkedLibrary));
var property = compilation.GetTypeByMetadataName("Input.Source")!
    .GetMembers("Value").OfType<IPropertySymbol>().Single();

var generated = DemoGenerator.Generate(property, compilation);
var consumer = CSharpCompilation.Create(
    "Consumer", [CSharpSyntaxTree.ParseText(generated)], references,
    new CSharpCompilationOptions(OutputKind.DynamicallyLinkedLibrary));
var errors = consumer.GetDiagnostics().Where(diagnostic => diagnostic.Severity == DiagnosticSeverity.Error).ToArray();
if (errors.Length != 0)
{
    Console.Error.WriteLine(string.Join(Environment.NewLine, errors.Select(error => error.ToString())));
    Environment.Exit(1);
}

Console.WriteLine("GENERATED_COMPILES");
EOF
  dotnet restore Generator.csproj --nologo
  if [[ "$fixture" == "reference-proof" ]]; then
    cp ExpectedGenerator.cs Generator.cs
  fi
else
cat > Generator.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
  </PropertyGroup>
</Project>
EOF
cat > Generator.cs <<'EOF'
using Microsoft.CodeAnalysis;

public sealed class DemoGenerator
{
    public void Generate(SourceProductionContext context, IPropertySymbol propertySymbol, Compilation compilation)
    {
    }
}
EOF
fi

printf 'bin/\nobj/\n' > .gitignore
rm setup_fixture.sh
rm -f ExpectedGenerator.cs
git init -q -b main
git config user.name "RoslynHelper fixture"
git config user.email "fixture@example.com"
git add -A
git commit -qm "fixture"
