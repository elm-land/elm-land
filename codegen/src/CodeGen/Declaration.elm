module CodeGen.Declaration exposing
    ( Declaration
    , function, customType, typeAlias
    , comment
    , toString
    )

{-|

@docs Declaration
@docs function, customType, typeAlias
@docs comment

@docs toString

-}

import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Expression
import Util.String


{-| A top-level custom type, type alias, or function in your Elm module.
-}
type Declaration
    = FunctionDeclaration
        { name : String
        , annotation : CodeGen.Annotation.Annotation
        , arguments : List CodeGen.Argument.Argument
        , expression : CodeGen.Expression.Expression
        }
    | CustomTypeDeclaration
        { name : String
        , variants : List ( String, List CodeGen.Annotation.Annotation )
        }
    | TypeAliasDeclaration
        { name : String
        , annotation : CodeGen.Annotation.Annotation
        }
    | CommentDeclaration (List String)


{-| Define a new function in your Elm module.

    {-

        main : Html msg
        main =
            Html.text "Hello, world!"

    -}
    CodeGen.Declaration.function
        { name = "main"
        , annotation = CodeGen.Annotation.value "Html msg"
        , arguments = []
        , expression =
            CodeGen.Expression.function
                { name = "Html.text"
                , arguments =
                    [ CodeGen.Expression.string "Hello, world!"
                    ]
                }
        }

-}
function :
    { name : String
    , annotation : CodeGen.Annotation.Annotation
    , arguments : List CodeGen.Argument.Argument
    , expression : CodeGen.Expression.Expression
    }
    -> Declaration
function options =
    FunctionDeclaration options


{-| Create a custom type in your Elm module

    {-

        type Color
            = Red
            | Green
            | Blue
            | CustomHexValue String

    -}
    CodeGen.Declaration.customType
        { name = "Color"
        , variants =
            [ ( "Red", [] )
            , ( "Green", [] )
            , ( "Blue", [] )
            , ( "CustomHexValue"
              , [ CodeGen.Annotation.string ]
              )
            ]
        }

-}
customType :
    { name : String
    , variants : List ( String, List CodeGen.Annotation.Annotation )
    }
    -> Declaration
customType options =
    CustomTypeDeclaration options


{-| Create a type alias in your Elm module

    {-

        type alias Email =
            String

    -}
    CodeGen.Declaration.typeAlias
        { name = "Email"
        , annotation = CodeGen.Annotation.string
        }

-}
typeAlias :
    { name : String
    , annotation : CodeGen.Annotation.Annotation
    }
    -> Declaration
typeAlias options =
    TypeAliasDeclaration options


{-| Add a comment to the file, using the `--` notation

    {-

        -- INIT

    -}
    CodeGen.Declaration.comment [ "INIT" ]

    {-

        -- These can be
        -- multiple lines!

    -}
    CodeGen.Declaration.comment
        [ "These can be"
        , "multiple lines!"
        ]

-}
comment : List String -> Declaration
comment options =
    CommentDeclaration options


{-| Render a `Declaration` value as a `String`.

( This is used internally by `CodeGen.Module.toString` )

-}
toString : Declaration -> String
toString declaration =
    case declaration of
        FunctionDeclaration options ->
            fromFunctionDeclarationToString options

        CustomTypeDeclaration options ->
            fromCustomTypeDeclarationToString options

        TypeAliasDeclaration options ->
            fromTypeAliasDeclarationToString options

        CommentDeclaration lines ->
            "\n" ++ (lines |> List.map (\line -> "-- " ++ line) |> String.join "\n")



-- INTERNALS


fromFunctionDeclarationToString :
    { name : String
    , annotation : CodeGen.Annotation.Annotation
    , arguments : List CodeGen.Argument.Argument
    , expression : CodeGen.Expression.Expression
    }
    -> String
fromFunctionDeclarationToString options =
    Util.String.dedent """

        {{name}} : {{annotation}}
        {{name}}{{arguments}} =
        {{expression}}

    """
        |> String.replace "{{name}}" options.name
        |> String.replace "{{annotation}}" (CodeGen.Annotation.toString options.annotation)
        |> String.replace "{{arguments}}"
            (case options.arguments of
                [] ->
                    ""

                args ->
                    " " ++ String.join " " (List.map CodeGen.Argument.toString args)
            )
        |> String.replace "{{expression}}"
            (CodeGen.Expression.toString options.expression
                |> Util.String.indent 4
            )
        |> Util.String.removeTrailingWhitespaceFromEmptyLines


fromCustomTypeDeclarationToString :
    { name : String
    , variants : List ( String, List CodeGen.Annotation.Annotation )
    }
    -> String
fromCustomTypeDeclarationToString options =
    "type {{name}}\n    = {{variants}}"
        |> String.replace "{{name}}" options.name
        |> String.replace "{{variants}}"
            (options.variants
                |> List.map fromCustomTypeVariantToString
                |> String.join "\n    | "
            )


fromTypeAliasDeclarationToString :
    { name : String
    , annotation : CodeGen.Annotation.Annotation
    }
    -> String
fromTypeAliasDeclarationToString options =
    "type alias {{name}} =\n{{annotation}}"
        |> String.replace "{{name}}" options.name
        |> String.replace "{{annotation}}"
            (options.annotation
                |> CodeGen.Annotation.toString
                |> Util.String.indent 4
            )


fromCustomTypeVariantToString : ( String, List CodeGen.Annotation.Annotation ) -> String
fromCustomTypeVariantToString ( variantName, args ) =
    (variantName :: List.map CodeGen.Annotation.toString args)
        |> String.join " "
