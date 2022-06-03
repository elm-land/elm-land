module CodeGen.Expression exposing
    ( Expression
    , function, multilineFunction
    , value
    , letIn
    , record, multilineRecord
    , recordUpdate
    , lambda
    , Branch, caseExpression
    , list, multilineList
    , multilineTuple
    , string
    , operator
    , parens, pipeline
    , toString
    )

{-|

@docs Expression
@docs function, multilineFunction
@docs value
@docs letIn
@docs record, multilineRecord
@docs recordUpdate
@docs lambda
@docs Branch, caseExpression
@docs list, multilineList
@docs multilineTuple
@docs string
@docs operator
@docs parens, pipeline

@docs toString

-}

import CodeGen.Annotation
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
    | LetInExpression
        { let_ : List LetDeclaration
        , in_ : Expression
        }
    | RecordExpression (List ( String, Expression ))
    | MultilineRecordExpression (List ( String, Expression ))
    | RecordUpdateExpression
        { value : String
        , fields : List ( String, Expression )
        }
    | ListExpression (List Expression)
    | MultiLineListExpression (List Expression)
    | MultiLineTupleExpression (List Expression)
    | StringExpression String
    | OperatorExpression String
    | WrappedInParens (List Expression)
    | Pipeline (List Expression)
    | CaseExpression
        { value : CodeGen.Argument.Argument
        , branches :
            List
                { name : String
                , arguments : List CodeGen.Argument.Argument
                , expression : Expression
                }
        }
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


type alias LetDeclaration =
    { argument : CodeGen.Argument.Argument
    , annotation : Maybe CodeGen.Annotation.Annotation
    , expression : Expression
    }


{-| Create a let-in expression to allow locally scoped values

    {-
        "Hello!"
    -}
    CodeGen.Expression.letIn
        { let_ = []
        , in = CodeGen.Expression.string "Hello!"
        }

    {-
        let
            name : String
            name =
                "Steve"

        in
        ("Hello, " ++ name ++ "!")
    -}
    CodeGen.Expression.letIn
        { let_ = [
            { argument = CodeGen.Argument.new "name"
            , annotation = CodeGen.Annotation.string
            , expression =
                CodeGen.Expression.string "Steve"
            }
        ]
        , in = CodeGen.Expression.parens
            [ CodeGen.Expression.string "Hello, "
            , CodeGen.Expreession.operator "++"
            , CodeGen.Expression.value "name"
            , CodeGen.Expreession.operator "++"
            , CodeGen.Expression.string "!"
            ]
        }

-}
letIn :
    { let_ :
        List
            { argument : CodeGen.Argument.Argument
            , annotation : Maybe CodeGen.Annotation.Annotation
            , expression : Expression
            }
    , in_ : Expression
    }
    -> Expression
letIn options =
    LetInExpression options


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


{-| Create a record value with a list of fields

    -- {}
    CodeGen.Expression.multilineRecord []

    {-

       { username = "ryan"
       }

    -}
    CodeGen.Expression.multilineRecord
        [ ( "username", CodeGen.Expression.string "ryan" )
        ]

    {-

       { username = "ryan"
       , email = "ryan@elm.land"
       }

    -}
    CodeGen.Expression.multilineRecord
        [ ( "username", CodeGen.Expression.string "ryan" )
        , ( "email", CodeGen.Expression.string "ryan@elm.land" )
        ]

-}
multilineRecord : List ( String, Expression ) -> Expression
multilineRecord fields =
    MultilineRecordExpression fields


{-| Represent a record getting updated

    -- model
    CodeGen.Expression.recordUpdate
        { value = "model"
        , fields = []
        }

    -- { model | url = url }
    CodeGen.Expression.recordUpdate
        { value = "model"
        , fields =
            [ ( "url", CodeGen.Expression.value "url" )
            ]
        }

    -- { model | url = url, key = key }
    CodeGen.Expression.recordUpdate
        { value = "model"
        , fields =
            [ ( "url", CodeGen.Expression.value "url" )
            , ( "key", CodeGen.Expression.value "key" )
            ]
        }

-}
recordUpdate : { value : String, fields : List ( String, Expression ) } -> Expression
recordUpdate options =
    RecordUpdateExpression options


{-| Create a list, where each item is on a new line

    -- [ "Hello", "darkness", "my old friend" ]
    Elm.CodeGen.Expression.list
        [ Elm.CodeGen.Expression "Hello"
        , Elm.CodeGen.Expression "darkness"
        , Elm.CodeGen.Expression "my old friend"
        ]

-}
list : List Expression -> Expression
list expressions =
    ListExpression expressions


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


{-| Create a tuple, where each item is on a new line

    {-

        ( "Hello"
        , "darkness"
        , "my old friend"
        )

    -}
    Elm.CodeGen.Expression.multilineTuple
        ( Elm.CodeGen.Expression "Hello"
        , Elm.CodeGen.Expression "darkness"
        , Elm.CodeGen.Expression "my old friend"
        )

-}
multilineTuple : List Expression -> Expression
multilineTuple expressions =
    MultiLineTupleExpression expressions


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


{-| Used by `CodeGen.Expression.caseExpression`, helpful for type annotations

    expression : CodeGen.Expression
    expression =
        CodeGen.Expression.caseExpression
            { value = CodeGen.Argument.new "maybeUsername"
            , branches = branches
            }

    branches : List CodeGen.Expression.Branch
    branches =
        [ { name = "Nothing"
          , arguments = []
          , expression = CodeGen.Expression.string "Missing!"
          }
        , { name = "Just"
          , arguments =
                [ CodeGen.Argument.new "username"
                ]
          , expression = CodeGen.Expression.value "username"
          }
        ]

-}
type alias Branch =
    { name : String
    , arguments : List CodeGen.Argument.Argument
    , expression : Expression
    }


{-|

    {-

        case color of
            Red ->
                "red"

            Blue ->
                "blue"

            Custom hex ->
                hex

    -}
    CodeGen.Expression.caseExpression
        { value = CodeGen.Argument.new "color"
        , branches =
            [ { name = "Red"
              , arguments = []
              , expression = CodeGen.Expression.string "red"
              }
            , { name = "Blue"
              , arguments = []
              , expression = CodeGen.Expression.string "blue"
              }
            , { name = "Custom"
              , arguments = [ CodeGen.Argument.new "hex" ]
              , expression = CodeGen.Expression.value "hex"
              }
            ]
        }

-}
caseExpression :
    { value : CodeGen.Argument.Argument
    , branches :
        List
            { name : String
            , arguments : List CodeGen.Argument.Argument
            , expression : Expression
            }
    }
    -> Expression
caseExpression options =
    CaseExpression options


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

        LetInExpression options ->
            case options.let_ of
                [] ->
                    toString options.in_

                _ ->
                    "let\n{{letExpressions}}\nin\n{{finalExpression}}"
                        |> String.replace "{{letExpressions}}"
                            (options.let_
                                |> List.map fromLetDeclarationToString
                                |> String.join "\n\n"
                                |> Util.String.indent 4
                            )
                        |> String.replace "{{finalExpression}}" (toString options.in_)

        RecordExpression fields ->
            Util.String.toRecord
                { joinWith = "="
                , toKey = Tuple.first
                , toValue = \( _, expr ) -> toString expr
                , items = fields
                }

        MultilineRecordExpression fields ->
            Util.String.toMultilineRecord
                { joinWith = "="
                , toKey = Tuple.first
                , toValue = \( _, expr ) -> toString expr
                , items = fields
                }

        RecordUpdateExpression options ->
            Util.String.toRecordUpdate
                { value = options.value
                , toKey = Tuple.first
                , toValue = \( _, expr ) -> toString expr
                , fields = options.fields
                }

        ListExpression expressions ->
            Util.String.toSinglelineList
                { toString = toString
                , items = expressions
                }

        MultiLineListExpression expressions ->
            Util.String.toMultilineList
                { toString = toString
                , items = expressions
                }

        MultiLineTupleExpression expressions ->
            Util.String.toMultilineTuple
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

        CaseExpression options ->
            "case {{value}} of\n{{branches}}"
                |> String.replace "{{value}}" (CodeGen.Argument.toString options.value)
                |> String.replace "{{branches}}"
                    (options.branches
                        |> List.map (fromBranchToString >> Util.String.indent 4)
                        |> String.join "\n\n"
                    )


fromBranchToString : { name : String, arguments : List CodeGen.Argument.Argument, expression : Expression } -> String
fromBranchToString branch =
    "{{name}}{{args}} ->\n{{expression}}"
        |> String.replace "{{name}}" branch.name
        |> String.replace "{{args}}"
            (if List.isEmpty branch.arguments then
                ""

             else
                " " ++ (branch.arguments |> List.map CodeGen.Argument.toString |> String.join " ")
            )
        |> String.replace "{{expression}}"
            (branch.expression
                |> toString
                |> Util.String.indent 4
            )


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


fromLetDeclarationToString : LetDeclaration -> String
fromLetDeclarationToString declaration =
    case declaration.annotation of
        Nothing ->
            "{{argument}} =\n{{expression}}"
                |> String.replace "{{argument}}" (CodeGen.Argument.toString declaration.argument)
                |> String.replace "{{expression}}"
                    (declaration.expression
                        |> toString
                        |> Util.String.indent 4
                    )

        Just annotation ->
            "{{argument}} : {{annotation}}\n{{argument}} =\n{{expression}}"
                |> String.replace "{{argument}}" (CodeGen.Argument.toString declaration.argument)
                |> String.replace "{{annotation}}" (CodeGen.Annotation.toString annotation)
                |> String.replace "{{expression}}"
                    (declaration.expression
                        |> toString
                        |> Util.String.indent 4
                    )
