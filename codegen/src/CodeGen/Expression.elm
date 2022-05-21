module CodeGen.Expression exposing
    ( Expression
    , function, multilineFunction
    , value
    , record, lambda
    , multilineList
    , string
    , operator
    , parens, pipeline
    , toString
    )

{-|

@docs Expression
@docs function, multilineFunction
@docs value
@docs record, lambda
@docs multilineList
@docs string
@docs operator
@docs parens, pipeline

@docs toString

-}

import CodeGen.Argument
import Util.String


{-| Represents a value in your Elm code.
-}
type Expression
    = FunctionExpression
        { name : String
        , arguments : List Expression
        }
    | MultilineFunctionExpression
        { name : String
        , arguments : List Expression
        }
    | RecordExpression (List ( String, Expression ))
    | MultiLineListExpression (List Expression)
    | StringExpression String
    | OperatorExpression String
    | WrappedInParens (List Expression)
    | Pipeline (List Expression)
    | LambdaExpression
        { arguments : List CodeGen.Argument.Argument
        , expression : Expression
        }


{-| Create a function with its arguments on one line

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


{-| Create a function that has arguments on many lines

    {-

        Html.h1
            []
            [ Html.text "Hey!" ]

    -}
    CodeGen.Expression.multilineFunction
        { name = "Html.h1"
        , arguments =
            [ CodeGen.Expression.list []
            , CodeGen.Expression.list
                [ CodeGen.Expression.function
                    { name = "Html.text"
                    , arguments = [ CodeGen.Expression.string "Hey!" ]
                    }
                ]
            ]
        }

-}
multilineFunction :
    { name : String
    , arguments : List Expression
    }
    -> Expression
multilineFunction options =
    MultilineFunctionExpression options


{-| Create a value that does not take arguments

    -- params
    CodeGen.Expression.value "params"

    -- params.username
    CodeGen.Expression.value "params.username"

-}
value : String -> Expression
value name =
    FunctionExpression { name = name, arguments = [] }


{-| Create a record value with a list of fields

    -- {}
    CodeGen.Expression.record []

    -- { username = "ryan" }
    CodeGen.Expression.record
        [ ( "username", CodeGen.Expression.string "ryan" )
        ]

-}
record : List ( String, Expression ) -> Expression
record fields =
    RecordExpression fields


{-| Create a list, where each item is on a new line

    {-

        [ "Hello"
        , "darkness"
        , "my old friend"
        ]

    -}
    Elm.CodeGen.Expression.multilineList
        [ Elm.CodeGen.Expression "Hello"
        , Elm.CodeGen.Expression "darkness"
        , Elm.CodeGen.Expression "my old friend"
        ]

-}
multilineList : List Expression -> Expression
multilineList expressions =
    MultiLineListExpression expressions


{-| Create an inline lambda function, always wrapped in parens.

    {-

        (\params -> { username = params })

    -}
    CodeGen.Expression.lambda
        { arguments =
            [ CodeGen.Argument.new "params"
            ]
        , expression =
            CodeGen.Expression.record
                [ ( "username", CodeGen.Expression.value "params" )
                ]
        }

-}
lambda :
    { arguments : List CodeGen.Argument.Argument
    , expression : Expression
    }
    -> Expression
lambda options =
    LambdaExpression options


{-| Create a `String` value

    -- "Hey!"
    CodeGen.Expression.string "Hey!"

    -- "How are you?"
    CodeGen.Expression.string "How are you?"

-}
string : String -> Expression
string str =
    StringExpression str


{-| Create an Elm operator, like `++`, `</>`, or `*`

    -- ++
    CodeGen.Expression.operator "++"

    -- </>
    CodeGen.Expression.operator "</>"

    -- *
    CodeGen.Expression.operator "*"

-}
operator : String -> Expression
operator str =
    OperatorExpression str


{-| Wrap a list of expressions in parentheses

    -- (Html.text "Hello!")
    CodeGen.Expression.parens
        [ CodeGen.Expression.value "Html.text"
        , CodeGen.Expression.string "Hello!"
        ]

    -- ("Hello, " ++ name ++ "!")
    CodeGen.Expression.parens
        [ CodeGen.Expression.string "Hello, "
        , CodeGen.Expression.operator
        , CodeGen.Expression.value "name"
        , CodeGen.Expression.operator
        , CodeGen.Expression.string "!"
        ]

-}
parens : List Expression -> Expression
parens expressions =
    WrappedInParens expressions


{-| Apply function arguments in a pipeline style

    {-

        people
            |> List.filter Person.isMember
            |> List.map Person.name

    -}
    CodeGen.Expression.pipeline
        [ CodeGen.Expression.value "people"
        , CodeGen.Expression.function
            { name = "List.filter"
            , arguments = [ CodeGen.Expression.value "Person.isMember" ]
            }
        , CodeGen.Expression.function
            { name = "List.map"
            , arguments = [ CodeGen.Expression.value "Person.name" ]
            }
        ]

-}
pipeline : List Expression -> Expression
pipeline expressions =
    Pipeline expressions


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

        RecordExpression fields ->
            Util.String.toRecord
                { joinWith = "="
                , toKey = Tuple.first
                , toValue = \( _, expr ) -> toString expr
                , items = fields
                }

        MultiLineListExpression expressions ->
            Util.String.toMultilineList
                { toString = toString
                , items = expressions
                }

        FunctionExpression options ->
            fromFunctionExpressionToString options

        MultilineFunctionExpression options ->
            fromMultilineFunctionExpressionToString options

        WrappedInParens expressions ->
            expressions
                |> List.map toString
                |> String.join " "
                |> Util.String.wrapInParentheses

        Pipeline expressions ->
            expressions
                |> List.map toString
                |> String.join "\n    |> "

        LambdaExpression options ->
            "(\\{{args}} -> {{expression}})"
                |> String.replace "{{args}}" (String.join " " (List.map CodeGen.Argument.toString options.arguments))
                |> String.replace "{{expression}}" (toString options.expression)


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

                args ->
                    " " ++ String.join " " (List.map toString args)
            )


fromMultilineFunctionExpressionToString :
    { name : String
    , arguments : List Expression
    }
    -> String
fromMultilineFunctionExpressionToString options =
    "{{name}}{{arguments}}"
        |> String.replace "{{name}}" options.name
        |> String.replace "{{arguments}}"
            (case options.arguments of
                [] ->
                    ""

                args ->
                    "\n"
                        ++ (List.map toString args |> String.join "\n" |> Util.String.indent 4)
            )
