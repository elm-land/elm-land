module CodeGen.Declaration exposing
    ( Declaration, function
    , toString
    )

{-|

@docs Declaration, function

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


{-| Render a `Declaration` value as a `String`.

( This is used internally by `CodeGen.Module.toString` )

-}
toString : Declaration -> String
toString declaration =
    case declaration of
        FunctionDeclaration options ->
            fromFunctionDeclarationToString options



-- INTERNALS


fromFunctionDeclarationToString :
    { name : String
    , annotation : CodeGen.Annotation.Annotation
    , arguments : List CodeGen.Argument.Argument
    , expression : CodeGen.Expression.Expression
    }
    -> String
fromFunctionDeclarationToString options =
    Util.String.dedent
        """
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
