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
        , Test.test "Main.elm Browser.application example" <|
            \_ ->
                runTestFor
                    { actual =
                        CodeGen.Module.new
                            { name = [ "Main" ]
                            , exposing_ = [ "main" ]
                            , imports =
                                [ CodeGen.Import.new [ "Browser" ]
                                , CodeGen.Import.new [ "Browser", "Navigation" ]
                                , CodeGen.Import.new [ "Html" ]
                                    |> CodeGen.Import.withExposing [ "Html" ]
                                , CodeGen.Import.new [ "Json", "Decode" ]
                                , CodeGen.Import.new [ "Pages", "Home_" ]
                                , CodeGen.Import.new [ "Pages", "SignIn" ]
                                , CodeGen.Import.new [ "Pages", "Settings", "Account" ]
                                , CodeGen.Import.new [ "Pages", "Profile", "Username_" ]
                                , CodeGen.Import.new [ "Pages", "NotFound_" ]
                                , CodeGen.Import.new [ "Route" ]
                                , CodeGen.Import.new [ "Url" ]
                                    |> CodeGen.Import.withExposing [ "Url" ]
                                ]
                            , declarations =
                                [ CodeGen.Declaration.typeAlias
                                    { name = "Flags"
                                    , annotation = CodeGen.Annotation.type_ "Json.Decode.Value"
                                    }
                                , CodeGen.Declaration.function
                                    { name = "main"
                                    , annotation = CodeGen.Annotation.type_ "Program Flags Model Msg"
                                    , arguments = []
                                    , expression =
                                        CodeGen.Expression.multilineFunction
                                            { name = "Browser.application"
                                            , arguments =
                                                [ CodeGen.Expression.multilineRecord
                                                    [ ( "init", CodeGen.Expression.value "init" )
                                                    , ( "update", CodeGen.Expression.value "update" )
                                                    , ( "view", CodeGen.Expression.value "view" )
                                                    , ( "subscriptions", CodeGen.Expression.value "subscriptions" )
                                                    , ( "onUrlChange", CodeGen.Expression.value "UrlChanged" )
                                                    , ( "onUrlRequest", CodeGen.Expression.value "UrlRequested" )
                                                    ]
                                                ]
                                            }
                                    }
                                , CodeGen.Declaration.comment [ "INIT" ]
                                , CodeGen.Declaration.typeAlias
                                    { name = "Model"
                                    , annotation =
                                        CodeGen.Annotation.multilineRecord
                                            [ ( "flags", CodeGen.Annotation.type_ "Flags" )
                                            , ( "key", CodeGen.Annotation.type_ "Browser.Navigation.Key" )
                                            , ( "url", CodeGen.Annotation.type_ "Url" )
                                            ]
                                    }
                                , CodeGen.Declaration.function
                                    { name = "init"
                                    , annotation =
                                        CodeGen.Annotation.function
                                            [ CodeGen.Annotation.type_ "Flags"
                                            , CodeGen.Annotation.type_ "Url"
                                            , CodeGen.Annotation.type_ "Browser.Navigation.Key"
                                            , CodeGen.Annotation.type_ "( Model, Cmd Msg )"
                                            ]
                                    , arguments =
                                        [ CodeGen.Argument.new "flags"
                                        , CodeGen.Argument.new "url"
                                        , CodeGen.Argument.new "key"
                                        ]
                                    , expression =
                                        CodeGen.Expression.multilineTuple
                                            [ CodeGen.Expression.multilineRecord
                                                [ ( "flags", CodeGen.Expression.value "flags" )
                                                , ( "url", CodeGen.Expression.value "url" )
                                                , ( "key", CodeGen.Expression.value "key" )
                                                ]
                                            , CodeGen.Expression.value "Cmd.none"
                                            ]
                                    }
                                , CodeGen.Declaration.comment [ "UPDATE" ]
                                , CodeGen.Declaration.customType
                                    { name = "Msg"
                                    , variants =
                                        [ ( "UrlRequested", [ CodeGen.Annotation.type_ "Browser.UrlRequest" ] )
                                        , ( "UrlChanged", [ CodeGen.Annotation.type_ "Url" ] )
                                        ]
                                    }
                                , CodeGen.Declaration.function
                                    { name = "update"
                                    , annotation =
                                        CodeGen.Annotation.function
                                            [ CodeGen.Annotation.type_ "Msg"
                                            , CodeGen.Annotation.type_ "Model"
                                            , CodeGen.Annotation.type_ "( Model, Cmd Msg )"
                                            ]
                                    , arguments =
                                        [ CodeGen.Argument.new "msg"
                                        , CodeGen.Argument.new "model"
                                        ]
                                    , expression =
                                        CodeGen.Expression.caseExpression
                                            { value = CodeGen.Argument.new "msg"
                                            , branches =
                                                [ { name = "UrlRequested"
                                                  , arguments = [ CodeGen.Argument.new "(Browser.Internal url)" ]
                                                  , expression =
                                                        CodeGen.Expression.multilineTuple
                                                            [ CodeGen.Expression.value "model"
                                                            , CodeGen.Expression.function
                                                                { name = "Browser.Navigation.pushUrl"
                                                                , arguments =
                                                                    [ CodeGen.Expression.value "model.key"
                                                                    , CodeGen.Expression.value "(Url.toString url)"
                                                                    ]
                                                                }
                                                            ]
                                                  }
                                                , { name = "UrlRequested"
                                                  , arguments = [ CodeGen.Argument.new "(Browser.External url)" ]
                                                  , expression =
                                                        CodeGen.Expression.multilineTuple
                                                            [ CodeGen.Expression.value "model"
                                                            , CodeGen.Expression.function
                                                                { name = "Browser.Navigation.load"
                                                                , arguments =
                                                                    [ CodeGen.Expression.value "url"
                                                                    ]
                                                                }
                                                            ]
                                                  }
                                                , { name = "UrlChanged"
                                                  , arguments = [ CodeGen.Argument.new "url" ]
                                                  , expression =
                                                        CodeGen.Expression.multilineTuple
                                                            [ CodeGen.Expression.recordUpdate
                                                                { value = "model"
                                                                , fields =
                                                                    [ ( "url", CodeGen.Expression.value "url" )
                                                                    ]
                                                                }
                                                            , CodeGen.Expression.value "Cmd.none"
                                                            ]
                                                  }
                                                ]
                                            }
                                    }
                                , CodeGen.Declaration.function
                                    { name = "subscriptions"
                                    , annotation =
                                        CodeGen.Annotation.function
                                            [ CodeGen.Annotation.type_ "Model"
                                            , CodeGen.Annotation.type_ "Sub Msg"
                                            ]
                                    , arguments = [ CodeGen.Argument.new "model" ]
                                    , expression = CodeGen.Expression.value "Sub.none"
                                    }
                                , CodeGen.Declaration.comment [ "VIEW" ]
                                , CodeGen.Declaration.function
                                    { name = "view"
                                    , annotation =
                                        CodeGen.Annotation.function
                                            [ CodeGen.Annotation.type_ "Model"
                                            , CodeGen.Annotation.type_ "Browser.Document Msg"
                                            ]
                                    , arguments = [ CodeGen.Argument.new "model" ]
                                    , expression =
                                        CodeGen.Expression.multilineRecord
                                            [ ( "title", CodeGen.Expression.string "App" )
                                            , ( "body"
                                              , CodeGen.Expression.list
                                                    [ CodeGen.Expression.function
                                                        { name = "viewPage"
                                                        , arguments =
                                                            [ CodeGen.Expression.value "model"
                                                            ]
                                                        }
                                                    ]
                                              )
                                            ]
                                    }
                                , CodeGen.Declaration.function
                                    { name = "viewPage"
                                    , annotation =
                                        CodeGen.Annotation.function
                                            [ CodeGen.Annotation.type_ "Model"
                                            , CodeGen.Annotation.type_ "Html Msg"
                                            ]
                                    , arguments = [ CodeGen.Argument.new "model" ]
                                    , expression =
                                        CodeGen.Expression.caseExpression
                                            { value = CodeGen.Argument.new "Route.fromUrl model.url"
                                            , branches =
                                                [ { name = "Route.Home_"
                                                  , arguments = []
                                                  , expression = CodeGen.Expression.value "Pages.Home_.page"
                                                  }
                                                , { name = "Route.SignIn"
                                                  , arguments = []
                                                  , expression = CodeGen.Expression.value "Pages.SignIn.page"
                                                  }
                                                , { name = "Route.Settings__Account"
                                                  , arguments = []
                                                  , expression = CodeGen.Expression.value "Pages.Settings.Account.page"
                                                  }
                                                , { name = "Route.Profile__Username_"
                                                  , arguments = [ CodeGen.Argument.new "params" ]
                                                  , expression =
                                                        CodeGen.Expression.function
                                                            { name = "Pages.Profile.Username_.page"
                                                            , arguments =
                                                                [ CodeGen.Expression.value "params"
                                                                ]
                                                            }
                                                  }
                                                , { name = "Route.NotFound_"
                                                  , arguments = []
                                                  , expression = CodeGen.Expression.value "Pages.NotFound_.page"
                                                  }
                                                ]
                                            }
                                    }
                                ]
                            }
                    , expected = """

                        module Main exposing (main)

                        import Browser
                        import Browser.Navigation
                        import Html exposing (Html)
                        import Json.Decode
                        import Pages.Home_
                        import Pages.SignIn
                        import Pages.Settings.Account
                        import Pages.Profile.Username_
                        import Pages.NotFound_
                        import Route
                        import Url exposing (Url)


                        type alias Flags =
                            Json.Decode.Value


                        main : Program Flags Model Msg
                        main =
                            Browser.application
                                { init = init
                                , update = update
                                , view = view
                                , subscriptions = subscriptions
                                , onUrlChange = UrlChanged
                                , onUrlRequest = UrlRequested
                                }



                        -- INIT


                        type alias Model =
                            { flags : Flags
                            , key : Browser.Navigation.Key
                            , url : Url
                            }


                        init : Flags -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
                        init flags url key =
                            ( { flags = flags
                              , url = url
                              , key = key
                              }
                            , Cmd.none
                            )



                        -- UPDATE


                        type Msg
                            = UrlRequested Browser.UrlRequest
                            | UrlChanged Url


                        update : Msg -> Model -> ( Model, Cmd Msg )
                        update msg model =
                            case msg of
                                UrlRequested (Browser.Internal url) ->
                                    ( model
                                    , Browser.Navigation.pushUrl model.key (Url.toString url)
                                    )

                                UrlRequested (Browser.External url) ->
                                    ( model
                                    , Browser.Navigation.load url
                                    )

                                UrlChanged url ->
                                    ( { model | url = url }
                                    , Cmd.none
                                    )


                        subscriptions : Model -> Sub Msg
                        subscriptions model =
                            Sub.none



                        -- VIEW


                        view : Model -> Browser.Document Msg
                        view model =
                            { title = "App"
                            , body = [ viewPage model ]
                            }


                        viewPage : Model -> Html Msg
                        viewPage model =
                            case Route.fromUrl model.url of
                                Route.Home_ ->
                                    Pages.Home_.page

                                Route.SignIn ->
                                    Pages.SignIn.page

                                Route.Settings__Account ->
                                    Pages.Settings.Account.page

                                Route.Profile__Username_ params ->
                                    Pages.Profile.Username_.page params

                                Route.NotFound_ ->
                                    Pages.NotFound_.page


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
