module CodeGen.Module exposing
    ( Module, new
    , toFilepath, toString
    )

{-|

@docs Module, new

@docs toFilepath, toString

-}

import CodeGen.Declaration
import CodeGen.Import


{-| Represents an Elm module, which has a one-to-one mapping with a file in your project.
-}
type Module
    = Module
        { name : List String
        , exposing_ : List String
        , imports : List CodeGen.Import.Import
        , declarations : List CodeGen.Declaration.Declaration
        }


{-| Create a new Elm module by describing its basic components

    nicePeopleModule : CodeGen.Module
    nicePeopleModule =
        CodeGen.Module.new
            { name = [ "Nice", "People" ]
            , exposing_ = [ "name" ]
            , imports = []
            , declarations =
                [ CodeGen.Declaration.value
                    { name = "name"
                    , annotation = CodeGen.Annotation.string
                    , expression = CodeGen.Expression.string "Greg"
                    }
                ]
            }

-}
new :
    { name : List String
    , exposing_ : List String
    , imports : List CodeGen.Import.Import
    , declarations : List CodeGen.Declaration.Declaration
    }
    -> Module
new options =
    Module options


{-| The name of the new Elm file, including folders

    CodeGen.Module.toFilepath nicePeopleModule == "Nice/People.elm"

-}
toFilepath : Module -> String
toFilepath (Module options) =
    String.join "/" options.name ++ ".elm"


{-| Renders an Elm module to a `String`, so you can use the generated code!

    CodeGen.Module.toString nicePeopleModule

Renders the following:

    module Nice.People exposing (name)

    name : String
    name =
        "Greg"

-}
toString : Module -> String
toString (Module options) =
    "module {{name}} exposing ({{exposing}}){{imports}}{{declarations}}"
        |> String.replace "{{name}}" (String.join "." options.name)
        |> String.replace "{{exposing}}" (String.join ", " options.exposing_)
        |> String.replace "{{imports}}"
            (if List.isEmpty options.imports then
                ""

             else
                "\n\n" ++ String.join "\n" (List.map CodeGen.Import.toString options.imports)
            )
        |> String.replace "{{declarations}}"
            (if List.isEmpty options.declarations then
                ""

             else
                "\n\n\n" ++ String.join "\n\n\n" (List.filterMap CodeGen.Declaration.toString options.declarations)
            )
