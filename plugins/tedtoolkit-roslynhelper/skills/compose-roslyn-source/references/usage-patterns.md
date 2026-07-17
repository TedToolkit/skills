# TedToolkit.RoslynHelper usage patterns

Use the public syntax model to represent generated C# until the final emission step. The library writes
the generated-file header, warning pragma, imports, namespaces, indentation, delimiters, and members.

## Source generator pipeline

1. Read `ITypeSymbol`, `IParameterSymbol`, `AttributeData`, and type-parameter data from Roslyn.
2. Convert them with `DataType.FromSymbol`, `SourceComposer.Parameter`, `SourceComposer.Attribute`,
   and `SourceComposer.TypeParameter`.
3. Compose `SourceFile` → `NameSpace` → declarations → members → statements.
4. Emit once with `source.Generate(context, hintName)`; use a stable, collision-free hint name.

```csharp
using TedToolkit.RoslynHelper;
using TedToolkit.RoslynHelper.Syntaxes;

using static TedToolkit.RoslynHelper.SourceComposer;
using static TedToolkit.RoslynHelper.SourceComposer<MyGenerator>;

var property = Property(DataType.FromSymbol(propertySymbol.Type, compilation), propertySymbol.Name)
    .Public
    .AddAccessor(new Accessor(AccessorType.GET));

var source = File()
    .AddUsing(Using("System"))
    .AddNameSpace(NameSpace("Generated")
        .AddMember(Class("GeneratedModel").Public.AddMember(property)));

source.Generate(context, "GeneratedModel");
```

`SourceComposer<TGenerator>` factories (`Class`, `Method`, `Property`, `Field`, and related members)
attach `GeneratedCodeAttribute`. Use them for declarations that originate from the current generator.
Use non-generic `SourceComposer` factories for file, namespace, imports, and Roslyn-symbol conversion.

## Choose syntax objects over text

| Required output | Use |
| --- | --- |
| Type declaration | `Class`, `Struct`, `Record`, `RecordStruct`, or `Interface` |
| Members | `Method`, `Property`, `Field`, `Event`, `Indexer`, `Constructor`, `Enum`, or `Delegate` |
| Types and values | `DataType`, `DataType.FromSymbol`, `ToSimpleName()`, `ToLiteral()` |
| Control flow | `IfStatement`, `ForEachStatement`, `SwitchStatement`, `TryStatement`, `UsingStatement` |
| Preprocessor structure | `ConditionalCompilationStatement` and `PreprocessorExpression` |
| Documentation | `DescriptionSummary`, `DescriptionParam`, `DescriptionReturns`, and related description items |

Add structure through fluent methods such as `AddMember`, `AddParameter`, `AddAccessor`,
`AddStatement`, `AddAttribute`, `AddTypeParameter`, and `AddCondition`.

```csharp
var method = Method("Create")
    .Public
    .Static
    .AddParameter(Parameter(DataType.String, "name"))
    .AddStatement(new ObjectCreationExpression(DataType.String).Return);

var guarded = new ConditionalCompilationStatement(PreprocessorExpression.Debug)
    .AddStatement("Trace".ToSimpleName());
```

Do not render a Roslyn symbol with a display-string format, concatenate generic arguments, or manually
write punctuation, braces, indentation, or conditional-compilation directives. Do not use
`SourceBuilder` directly for normal generated code; it is the library's low-level writer. Use `Custom`
only after confirming no public syntax object can express the required construct, and keep the custom
fragment minimal.

After emitting, build the generator project and run its generator or snapshot tests. Confirm the
generated source compiles and retains the intended global qualification, nullability, attributes,
generic constraints, and conditional-compilation behavior.
