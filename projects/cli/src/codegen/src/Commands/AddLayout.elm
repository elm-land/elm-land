module Commands.AddLayout exposing (run)

import CodeGen
import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Declaration
import CodeGen.Expression
import CodeGen.Import
import CodeGen.Module
import Json.Decode


run : Json.Decode.Value -> List CodeGen.Module
run json =
    case Json.Decode.decodeValue decoder json of
        Ok data ->
            [ newLayoutModule data ]

        Err _ ->
            []



-- DATA


type alias Data =
    { moduleSegments : List String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "moduleSegments" (Json.Decode.list Json.Decode.string))



-- CODEGEN


newLayoutModule : Data -> CodeGen.Module
newLayoutModule data =
    let
        {- Example:

           type alias Settings =
               ()

        -}
        settingsTypeAlias : CodeGen.Declaration
        settingsTypeAlias =
            CodeGen.Declaration.typeAlias
                { name = "Settings"
                , annotation = CodeGen.Annotation.type_ "()"
                }

        {- Example:

           layout : Settings -> Shared.Model -> Route () -> Layout Model Msg mainMsg
           layout settings shared route =
               Layout.new
                   { init = init
                   , update = update
                   , view = view
                   , subscriptions = subscriptions
                   }

        -}
        layoutFunction : CodeGen.Declaration
        layoutFunction =
            CodeGen.Declaration.function
                { name = "layout"
                , annotation = CodeGen.Annotation.type_ "Settings -> Shared.Model -> Route () -> Layout Model Msg mainMsg"
                , arguments =
                    [ CodeGen.Argument.new "settings"
                    , CodeGen.Argument.new "shared"
                    , CodeGen.Argument.new "route"
                    ]
                , expression =
                    CodeGen.Expression.multilineFunction
                        { name = "Layout.new"
                        , arguments =
                            [ CodeGen.Expression.multilineRecord
                                [ ( "init", CodeGen.Expression.value "init" )
                                , ( "update", CodeGen.Expression.value "update" )
                                , ( "view", CodeGen.Expression.value "view" )
                                , ( "subscriptions", CodeGen.Expression.value "subscriptions" )
                                ]
                            ]
                        }
                }

        {- Example:

           type alias Model =
               {}

        -}
        modelTypeAlias : CodeGen.Declaration
        modelTypeAlias =
            CodeGen.Declaration.typeAlias
                { name = "Model"
                , annotation = CodeGen.Annotation.record []
                }

        {- Example:

           init : () -> ( Model, Effect Msg )
           init _ =
               ( {}
               , Effect.none
               )

        -}
        initFunction : CodeGen.Declaration
        initFunction =
            CodeGen.Declaration.function
                { name = "init"
                , annotation = CodeGen.Annotation.type_ "() -> ( Model, Effect Msg )"
                , arguments = [ CodeGen.Argument.new "_" ]
                , expression =
                    CodeGen.Expression.multilineTuple
                        [ CodeGen.Expression.record []
                        , CodeGen.Expression.value "Effect.none"
                        ]
                }

        {- Example:

           type Msg
               = ReplaceMe

        -}
        msgCustomType : CodeGen.Declaration
        msgCustomType =
            CodeGen.Declaration.customType
                { name = "Msg"
                , variants = [ ( "ReplaceMe", [] ) ]
                }

        {- Example:

           update : Msg -> Model -> ( Model, Effect Msg )
           update msg model =
               case msg of
                   ReplaceMe ->
                       ( model
                       , Effect.none
                       )

        -}
        updateFunction =
            CodeGen.Declaration.function
                { name = "update"
                , annotation = CodeGen.Annotation.type_ "Msg -> Model -> ( Model, Effect Msg )"
                , arguments = [ CodeGen.Argument.new "msg", CodeGen.Argument.new "model" ]
                , expression =
                    CodeGen.Expression.caseExpression
                        { value = CodeGen.Argument.new "msg"
                        , branches =
                            [ { name = "ReplaceMe"
                              , arguments = []
                              , expression =
                                    CodeGen.Expression.multilineTuple
                                        [ CodeGen.Expression.record []
                                        , CodeGen.Expression.value "Effect.none"
                                        ]
                              }
                            ]
                        }
                }

        {- Example:

           subscriptions : Model -> Sub Msg
           subscriptions model =
               Sub.none
        -}
        subscriptionsFunction =
            CodeGen.Declaration.function
                { name = "subscriptions"
                , annotation = CodeGen.Annotation.type_ "Model -> Sub Msg"
                , arguments = [ CodeGen.Argument.new "model" ]
                , expression = CodeGen.Expression.value "Sub.none"
                }

        {- Example:

           view :
               { fromMsg : Msg -> mainMsg
               , content : View mainMsg
               , model : Model
               }
               -> View mainMsg
           view { fromMsg, model, content } =
               { title = content.title
               , body =
                   [ Html.text "Header"
                   , Html.div [ class "page" ] content.body
                   ]
               }

        -}
        viewFunction =
            CodeGen.Declaration.function
                { name = "view"
                , annotation = CodeGen.Annotation.type_ "{ fromMsg : Msg -> mainMsg, content : View mainMsg, model : Model } -> View mainMsg"
                , arguments = [ CodeGen.Argument.new "{ fromMsg, model, content }" ]
                , expression =
                    CodeGen.Expression.multilineRecord
                        [ ( "title", CodeGen.Expression.value "content.title" )
                        , ( "body"
                          , CodeGen.Expression.multilineList
                                [ CodeGen.Expression.function
                                    { name = "Html.text "
                                    , arguments =
                                        [ CodeGen.Expression.string (String.join "." data.moduleSegments)
                                        ]
                                    }
                                , CodeGen.Expression.value "Html.div [ class \"page\" ] content.body"
                                ]
                          )
                        ]
                }
    in
    CodeGen.Module.new
        { name = "Layouts" :: data.moduleSegments
        , exposing_ = [ "Model", "Msg", "Settings", "layout" ]
        , imports =
            [ CodeGen.Import.new [ "Effect" ]
                |> CodeGen.Import.withExposing [ "Effect" ]
            , CodeGen.Import.new [ "Html" ]
                |> CodeGen.Import.withExposing [ "Html" ]
            , CodeGen.Import.new [ "Html", "Attributes" ]
                |> CodeGen.Import.withExposing [ "class" ]
            , CodeGen.Import.new [ "Layout" ]
                |> CodeGen.Import.withExposing [ "Layout" ]
            , CodeGen.Import.new [ "Route" ]
                |> CodeGen.Import.withExposing [ "Route" ]
            , CodeGen.Import.new [ "Shared" ]
            , CodeGen.Import.new [ "View" ]
                |> CodeGen.Import.withExposing [ "View" ]
            ]
        , declarations =
            [ settingsTypeAlias
            , layoutFunction
            , CodeGen.Declaration.comment [ "MODEL" ]
            , modelTypeAlias
            , initFunction
            , CodeGen.Declaration.comment [ "UPDATE" ]
            , msgCustomType
            , updateFunction
            , subscriptionsFunction
            , CodeGen.Declaration.comment [ "VIEW" ]
            , viewFunction
            ]
        }
