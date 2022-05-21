module CodeGen.Expression exposing
    ( Expression
    , function, value
    , string
    , plusPlusOperator
    , parens
    , toString
    )

{-|

@docs Expression
@docs function, value
@docs string
@docs plusPlusOperator
@docs parens

@docs toString

-}

import Util.String


{-| Represents a value in your Elm code.
-}
type Expression
    = FunctionExpression
        { name : String
        , arguments : List Expression
        }
    | StringExpression String
    | OperatorExpression String
    | WrappedInParens (List Expression)


{-| Create a function that has arguments

    -- Html.text "Hello, world!"
    CodeGen.Expression.function
        { name = "Html.text"
        , arguments =
            [ CodeGen.Expression.string "Hello, world!"
            ]
        }

-}
function :
    { name : String
    , arguments : List Expression
    }
    -> Expression
function options =
    FunctionExpression options


{-| Create a value that does not take arguments

    -- params
    CodeGen.Expression.value "params"

    -- params.username
    CodeGen.Expression.value "params.username"

-}
value : String -> Expression
value name =
    FunctionExpression { name = name, arguments = [] }


{-| Create a `String` value

    -- "Hey!"
    CodeGen.Expression.string "Hey!"

    -- "How are you?"
    CodeGen.Expression.string "How are you?"

-}
string : String -> Expression
string str =
    StringExpression str


{-| Create the `++` operator, used when appending `List` or `String` values

    -- ++
    CodeGen.Expression.plusPlusOperator

-}
plusPlusOperator : Expression
plusPlusOperator =
    OperatorExpression "++"


{-| Wrap a list of expressions in parentheses

    -- (Html.text "Hello!")
    CodeGen.Expression.parens
        [ CodeGen.Expression.value "Html.text"
        , CodeGen.Expression.string "Hello!"
        ]

    -- ("Hello, " ++ name ++ "!")
    CodeGen.Expression.parens
        [ CodeGen.Expression.string "Hello, "
        , CodeGen.Expression.plusPlusOperator
        , CodeGen.Expression.value "name"
        , CodeGen.Expression.plusPlusOperator
        , CodeGen.Expression.string "!"
        ]

-}
parens : List Expression -> Expression
parens expressions =
    WrappedInParens expressions


{-| Render an `Expression` value as a `String`.

( This is used internally by `CodeGen.Module.toString` )

-}
toString : Expression -> String
toString expression =
    case expression of
        OperatorExpression str ->
            str

        StringExpression str ->
            Util.String.quote str

        FunctionExpression options ->
            fromFunctionExpressionToString options

        WrappedInParens expressions ->
            expressions
                |> List.map toString
                |> String.join " "
                |> (\str -> "(" ++ str ++ ")")


fromFunctionExpressionToString :
    { name : String
    , arguments : List Expression
    }
    -> String
fromFunctionExpressionToString options =
    "{{name}}{{arguments}}"
        |> String.replace "{{name}}" options.name
        |> String.replace "{{arguments}}"
            (case options.arguments of
                [] ->
                    ""

                first :: [] ->
                    " " ++ toString first

                args ->
                    "\n"
                        ++ (List.map toString args |> String.join "\n" |> Util.String.indent 4)
            )
