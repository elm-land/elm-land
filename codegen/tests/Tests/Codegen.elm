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
    Test.describe "CodeGen.Module"
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
                                                    , CodeGen.Expression.operator "++"
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
        , Test.test "Route.elm example" <|
            \_ ->
                runTestFor
                    { actual =
                        CodeGen.Module.new
                            { name = [ "Route" ]
                            , exposing_ = [ "Route(..)", "fromUrl" ]
                            , imports =
                                [ CodeGen.Import.new [ "Url" ]
                                    |> CodeGen.Import.withExposing [ "Url" ]
                                , CodeGen.Import.new [ "Url.Parser" ]
                                    |> CodeGen.Import.withExposing [ "(</>)" ]
                                ]
                            , declarations =
                                [ CodeGen.Declaration.customType
                                    { name = "Route"
                                    , variants =
                                        [ ( "Home_", [] )
                                        , ( "SignIn", [] )
                                        , ( "Settings__Account", [] )
                                        , ( "Profile__Username_"
                                          , [ CodeGen.Annotation.record
                                                [ ( "username", CodeGen.Annotation.string )
                                                ]
                                            ]
                                          )
                                        , ( "NotFound_", [] )
                                        ]
                                    }
                                , CodeGen.Declaration.function
                                    { name = "fromUrl"
                                    , annotation =
                                        CodeGen.Annotation.function
                                            [ CodeGen.Annotation.type_ "Url"
                                            , CodeGen.Annotation.type_ "Route"
                                            ]
                                    , arguments = [ CodeGen.Argument.new "url" ]
                                    , expression =
                                        CodeGen.Expression.pipeline
                                            [ CodeGen.Expression.function
                                                { name = "Url.Parser.parse"
                                                , arguments =
                                                    [ CodeGen.Expression.value "parser"
                                                    , CodeGen.Expression.value "url"
                                                    ]
                                                }
                                            , CodeGen.Expression.function
                                                { name = "Maybe.withDefault"
                                                , arguments =
                                                    [ CodeGen.Expression.value "NotFound_"
                                                    ]
                                                }
                                            ]
                                    }
                                , CodeGen.Declaration.function
                                    { name = "parser"
                                    , annotation = CodeGen.Annotation.type_ "Url.Parser.Parser (Route -> a) a"
                                    , arguments = []
                                    , expression =
                                        CodeGen.Expression.multilineFunction
                                            { name = "Url.Parser.oneOf"
                                            , arguments =
                                                [ CodeGen.Expression.multilineList
                                                    [ CodeGen.Expression.function
                                                        { name = "Url.Parser.map"
                                                        , arguments =
                                                            [ CodeGen.Expression.value "Home_"
                                                            , CodeGen.Expression.value "Url.Parser.top"
                                                            ]
                                                        }
                                                    , CodeGen.Expression.function
                                                        { name = "Url.Parser.map"
                                                        , arguments =
                                                            [ CodeGen.Expression.value "SignIn"
                                                            , CodeGen.Expression.parens
                                                                [ CodeGen.Expression.value "Url.Parser.s"
                                                                , CodeGen.Expression.string "sign-in"
                                                                ]
                                                            ]
                                                        }
                                                    , CodeGen.Expression.function
                                                        { name = "Url.Parser.map"
                                                        , arguments =
                                                            [ CodeGen.Expression.value "Settings__Account"
                                                            , CodeGen.Expression.parens
                                                                [ CodeGen.Expression.value "Url.Parser.s"
                                                                , CodeGen.Expression.string "settings"
                                                                , CodeGen.Expression.operator "</>"
                                                                , CodeGen.Expression.value "Url.Parser.s"
                                                                , CodeGen.Expression.string "account"
                                                                ]
                                                            ]
                                                        }
                                                    , CodeGen.Expression.function
                                                        { name = "Url.Parser.map"
                                                        , arguments =
                                                            [ CodeGen.Expression.lambda
                                                                { arguments = [ CodeGen.Argument.new "param1" ]
                                                                , expression =
                                                                    CodeGen.Expression.function
                                                                        { name = "Profile__Username_"
                                                                        , arguments =
                                                                            [ CodeGen.Expression.record
                                                                                [ ( "username", CodeGen.Expression.value "param1" )
                                                                                ]
                                                                            ]
                                                                        }
                                                                }
                                                            , CodeGen.Expression.parens
                                                                [ CodeGen.Expression.value "Url.Parser.s"
                                                                , CodeGen.Expression.string "profile"
                                                                , CodeGen.Expression.operator "</>"
                                                                , CodeGen.Expression.value "Url.Parser.string"
                                                                ]
                                                            ]
                                                        }
                                                    ]
                                                ]
                                            }
                                    }
                                ]
                            }
                    , expected = """
                        module Route exposing (Route(..), fromUrl)

                        import Url exposing (Url)
                        import Url.Parser exposing ((</>))


                        type Route
                            = Home_
                            | SignIn
                            | Settings__Account
                            | Profile__Username_ { username : String }
                            | NotFound_


                        fromUrl : Url -> Route
                        fromUrl url =
                            Url.Parser.parse parser url
                                |> Maybe.withDefault NotFound_


                        parser : Url.Parser.Parser (Route -> a) a
                        parser =
                            Url.Parser.oneOf
                                [ Url.Parser.map Home_ Url.Parser.top
                                , Url.Parser.map SignIn (Url.Parser.s "sign-in")
                                , Url.Parser.map Settings__Account (Url.Parser.s "settings" </> Url.Parser.s "account")
                                , Url.Parser.map (\\param1 -> Profile__Username_ { username = param1 }) (Url.Parser.s "profile" </> Url.Parser.string)
                                ]
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
