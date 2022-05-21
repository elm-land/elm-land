module Tests.Codegen exposing (suite)

import CodeGen
import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Declaration
import CodeGen.Expression
import CodeGen.Import
import CodeGen.Module
import Expect
import Test exposing (Test)
import Util.String


suite : Test
suite =
    Test.describe "CodeGen"
        [ Test.test "Hello world example" <|
            \_ ->
                runTestFor
                    { actual =
                        CodeGen.Module.new
                            { name = [ "Main" ]
                            , exposing_ = [ "main" ]
                            , imports =
                                [ CodeGen.Import.new [ "Html" ]
                                    |> CodeGen.Import.withExposing [ "Html" ]
                                ]
                            , declarations =
                                [ CodeGen.Declaration.function
                                    { name = "main"
                                    , annotation = CodeGen.Annotation.type_ "Html msg"
                                    , arguments = []
                                    , expression =
                                        CodeGen.Expression.function
                                            { name = "Html.text"
                                            , arguments = [ CodeGen.Expression.string "Hello, world!" ]
                                            }
                                    }
                                ]
                            }
                    , expected = """
                    module Main exposing (main)

                    import Html exposing (Html)


                    main : Html msg
                    main =
                        Html.text "Hello, world!"
                    """
                    }
        , Test.test "Pages.SignIn example" <|
            \_ ->
                runTestFor
                    { actual =
                        CodeGen.Module.new
                            { name = [ "Pages", "SignIn" ]
                            , exposing_ = [ "page" ]
                            , imports =
                                [ CodeGen.Import.new [ "Html" ]
                                    |> CodeGen.Import.withExposing [ "Html" ]
                                ]
                            , declarations =
                                [ CodeGen.Declaration.function
                                    { name = "page"
                                    , arguments = []
                                    , annotation = CodeGen.Annotation.type_ "Html msg"
                                    , expression =
                                        CodeGen.Expression.function
                                            { name = "Html.text"
                                            , arguments = [ CodeGen.Expression.string "/sign-in" ]
                                            }
                                    }
                                ]
                            }
                    , expected = """
                    module Pages.SignIn exposing (page)

                    import Html exposing (Html)


                    page : Html msg
                    page =
                        Html.text "/sign-in"
                    """
                    }
        , Test.test "Pages.Profile.Username_ example" <|
            \_ ->
                runTestFor
                    { actual =
                        CodeGen.Module.new
                            { name = [ "Pages", "Profile", "Username_" ]
                            , exposing_ = [ "page" ]
                            , imports =
                                [ CodeGen.Import.new [ "Html" ]
                                    |> CodeGen.Import.withExposing [ "Html" ]
                                ]
                            , declarations =
                                [ CodeGen.Declaration.function
                                    { name = "page"
                                    , arguments =
                                        [ CodeGen.Argument.new "params"
                                        ]
                                    , annotation =
                                        CodeGen.Annotation.function
                                            [ CodeGen.Annotation.record
                                                [ ( "username", CodeGen.Annotation.string )
                                                ]
                                            , CodeGen.Annotation.type_ "Html msg"
                                            ]
                                    , expression =
                                        CodeGen.Expression.function
                                            { name = "Html.text"
                                            , arguments =
                                                [ CodeGen.Expression.parens
                                                    [ CodeGen.Expression.string "/profile/"
                                                    , CodeGen.Expression.plusPlusOperator
                                                    , CodeGen.Expression.value "params.username"
                                                    ]
                                                ]
                                            }
                                    }
                                ]
                            }
                    , expected = """
                    module Pages.Profile.Username_ exposing (page)

                    import Html exposing (Html)


                    page : { username : String } -> Html msg
                    page params =
                        Html.text ("/profile/" ++ params.username)
                    """
                    }
        ]


runTestFor :
    { actual : CodeGen.Module
    , expected : String
    }
    -> Expect.Expectation
runTestFor options =
    CodeGen.Module.toString options.actual
        |> Expect.equal (Util.String.dedent options.expected)
