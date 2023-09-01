module CodeGen.Module exposing
    ( Module, new
    , withOrderedExposingList
    , toFilepath, toString
    )

{-|

@docs Module, new
@docs withOrderedExposingList

@docs toFilepath, toString

-}

import CodeGen.Declaration
import CodeGen.Import


{-| Represents an Elm module, which has a one-to-one mapping with a file in your project.
-}
type Module
    = Module
        { name : List String
        , exposing_ : ExposingList
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
    Module
        { name = options.name
        , exposing_ = OrderedByList options.exposing_
        , imports = options.imports
        , declarations = options.declarations
        }


type ExposingList
    = OrderedByDocsComment (List (List String))
    | OrderedByList (List String)


{-| Provide this module with a series of `@docs`
that control how exposed values are organized.

This overrides `exposing`

-}
withOrderedExposingList :
    List (List String)
    -> Module
    -> Module
withOrderedExposingList docs (Module options) =
    Module { options | exposing_ = OrderedByDocsComment docs }


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
    let
        exposing_ : String
        exposing_ =
            case options.exposing_ of
                OrderedByList list ->
                    "(" ++ String.join ", " list ++ ")"

                OrderedByDocsComment listOfLists ->
                    String.join ""
                        [ "\n    ( "
                        , listOfLists
                            |> List.filter (List.length >> (<) 0)
                            |> List.map (String.join ", ")
                            |> String.join "\n    , "
                        , "\n    )\n\n{-|\n\n"
                        , listOfLists
                            |> List.filter (List.length >> (<) 0)
                            |> List.map (String.join ", ")
                            |> List.map (String.append "@docs ")
                            |> String.join "\n"
                        , "\n\n-}"
                        ]
    in
    "module {{name}} exposing {{exposing}}{{imports}}{{declarations}}\n"
        |> String.replace "{{name}}" (String.join "." options.name)
        |> String.replace "{{exposing}}" exposing_
        |> String.replace "{{imports}}"
            (if List.isEmpty options.imports then
                ""

             else
                options.imports
                    |> List.sortBy CodeGen.Import.toString
                    |> List.map CodeGen.Import.toString
                    |> String.join "\n"
                    |> String.append "\n\n"
            )
        |> String.replace "{{declarations}}"
            (if List.isEmpty options.declarations then
                ""

             else
                "\n\n\n" ++ String.join "\n\n\n" (List.filterMap CodeGen.Declaration.toString options.declarations)
            )
