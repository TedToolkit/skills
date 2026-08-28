using Microsoft.CodeAnalysis;
using TedToolkit.RoslynHelper;
using TedToolkit.RoslynHelper.Syntaxes;

using static TedToolkit.RoslynHelper.SourceComposer;
using static TedToolkit.RoslynHelper.SourceComposer<DemoGenerator>;

public sealed class DemoGenerator
{
    public static string Generate(IPropertySymbol propertySymbol, Compilation compilation)
    {
        var property = Property(
                DataType.FromSymbol(propertySymbol.Type, compilation),
                propertySymbol.Name)
            .Public
            .AddAccessor(new Accessor(AccessorType.GET));

        return File()
            .AddNameSpace(NameSpace("Generated")
                .AddMember(Class("GeneratedModel").Public.AddMember(property)))
            .ToCode();
    }
}
