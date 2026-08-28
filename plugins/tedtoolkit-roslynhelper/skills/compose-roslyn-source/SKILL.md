---
name: compose-roslyn-source
description: >-
  Compose structurally generated C# with TedToolkit.RoslynHelper. Use when a project that references
  the library creates or changes a Roslyn source generator, analyzer output, or another C# code-
  generation pipeline.
---

# Compose Roslyn Source

Keep generated syntax **structural** until one final emission.

Keep this skill as the owner of source composition. When available, let
`write-csharp-api-comments` own caller-facing XML contract prose, `tunit-testing` own TUnit
generator-test mechanics, and `fix-csharp-diagnostics` own a diagnostics-only cleanup phase.

1. Inspect the active project, central package file, and reference graph. Continue only when
   `TedToolkit.RoslynHelper` is available; otherwise report the failed package gate. Match examples
   to the referenced package version; the composition path below is executable against `2026.7.15`
   with its declared `Microsoft.CodeAnalysis.CSharp` `5.0.0` dependency.
2. Read [usage-patterns.md](references/usage-patterns.md) and map every required declaration,
   member, statement, expression, symbol conversion, and preprocessor construct to a public syntax
   object. Complete when only genuinely unsupported fragments remain custom.
3. Present the syntax-object map, proposed target files, custom fragments, and verification command.
   Wait for explicit approval before editing generator code.
4. Compose the file, namespace, declarations, members, and statements with syntax objects. Emit once
   through `ToCode()` or `SourceFile.Generate(...)`.
5. Build the affected project, execute generation, and compile the emitted source (or run an
   equivalent generator/snapshot test that performs both). Keyword or text-shape checks are
   supplementary only. Complete when generator code and generated consumer source both compile and
   preserve qualification, nullability, attributes, generic constraints, and conditional
   compilation.

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

Use `Custom` only after the reference confirms that no public syntax object represents the required
construct; keep that fragment minimal.
