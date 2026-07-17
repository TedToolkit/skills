---
name: compose-roslyn-source
description: >-
  Compose generated C# source with TedToolkit.RoslynHelper instead of System.Text.StringBuilder.
  Trigger only when the active C# project directly references TedToolkit.RoslynHelper through a
  PackageReference or ProjectReference (or a transitive project reference exposes its public API),
  and the task creates or changes generated source, a Roslyn source generator, analyzer output, or
  another code-generation pipeline. Do not trigger for projects where TedToolkit.RoslynHelper is unavailable.
---

# Compose Roslyn Source

First inspect the active `.csproj`, `Directory.Packages.props`, and project-reference graph. Continue
only if `TedToolkit.RoslynHelper` is available to the active project. Otherwise, do not recommend or
use this skill's APIs.

When generating C# source, do not use `System.Text.StringBuilder`, interpolated source fragments, or
manual indentation. Model the generated syntax with this library and emit it through `ToCode()` or
`SourceFile.Generate(...)`. Use `Custom` only for syntax the library cannot model.

For every implementation, read [the usage patterns](references/usage-patterns.md). Select the smallest
pattern that represents the required generated syntax; do not reimplement formatting, type rendering,
or symbol conversion by hand.

## Compose a source file

Import `TedToolkit.RoslynHelper`, `TedToolkit.RoslynHelper.Syntaxes`, and static `SourceComposer`.
Create a file, add imports and namespaces, then compose declaration objects with fluent members:

```csharp
using TedToolkit.RoslynHelper;
using TedToolkit.RoslynHelper.Syntaxes;

using static TedToolkit.RoslynHelper.SourceComposer;

var source = File()
    .AddUsing(Using("System"))
    .AddNameSpace(NameSpace("Generated")
        .AddMember(Class("Sample").Public
            .AddMember(
                new Method("Run")
                    .Public
                    .Static
                    .AddStatement(1.ToLiteral().Return))));

source.Generate(context, "Sample");
```

Use the concrete syntax types for types and members (`TypeDeclaration`, `Method`, `Property`, `Field`,
`Event`, `Indexer`, `Constructor`, `Enum`, and `Delegate`), and their fluent `AddMember`,
`AddParameter`, `AddStatement`, `AddAccessor`, `AddAttribute`, and `AddTypeParameter` methods. Build
expressions and statements with syntax objects and extensions such as `ToSimpleName()`, `ToLiteral()`,
`Return`, `IfStatement`, `ForEachStatement`, `TryStatement`, and `SwitchStatement`.

## Prefer generator-aware factories

Inside a source generator, import static `SourceComposer<TGenerator>` and construct generated members
with its factories, such as `Class`, `Method`, `Property`, and `Field`. They add the generator's
`GeneratedCodeAttribute` automatically. Convert symbols with `SourceComposer.Parameter`,
`SourceComposer.Attribute`, `SourceComposer.TypeParameter`, and `DataType.FromSymbol` rather than
rendering symbol display strings manually.

Keep the generated code structurally represented until the final `ToCode()` or `Generate()` call, then
build the affected project or generator tests after editing.
