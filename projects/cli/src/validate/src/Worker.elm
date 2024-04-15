port module Worker exposing (main)

import CustomizableFile exposing (CustomizableFile)
import Error exposing (Error)
import Filepath exposing (Filepath)
import Json.Decode
import Json.Encode
import Layout exposing (Layout)
import Page exposing (Page)
import Platform


port onComplete : List Json.Encode.Value -> Cmd msg


main : Program Json.Decode.Value Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    {}


type alias CustomizedFiles =
    { auth : Maybe CustomizableFile
    , shared : Maybe CustomizableFile
    , sharedModel : Maybe CustomizableFile
    , sharedMsg : Maybe CustomizableFile
    , effect : Maybe CustomizableFile
    , view : Maybe CustomizableFile
    }


customizedFilesDecoder : Json.Decode.Decoder CustomizedFiles
customizedFilesDecoder =
    Json.Decode.map6 CustomizedFiles
        (CustomizableFile.decoder ( "Auth", [] )
            |> Json.Decode.field "auth"
            |> Json.Decode.maybe
        )
        (CustomizableFile.decoder ( "Shared", [] )
            |> Json.Decode.field "shared"
            |> Json.Decode.maybe
        )
        (CustomizableFile.decoder ( "Shared", [ "Model" ] )
            |> Json.Decode.field "sharedModel"
            |> Json.Decode.maybe
        )
        (CustomizableFile.decoder ( "Shared", [ "Msg" ] )
            |> Json.Decode.field "sharedMsg"
            |> Json.Decode.maybe
        )
        (CustomizableFile.decoder ( "Effect", [] )
            |> Json.Decode.field "effect"
            |> Json.Decode.maybe
        )
        (CustomizableFile.decoder ( "View", [] )
            |> Json.Decode.field "view"
            |> Json.Decode.maybe
        )


init : Json.Decode.Value -> ( Model, Cmd Msg )
init flags =
    let
        layouts : List Layout
        layouts =
            flags
                |> Json.Decode.decodeValue
                    (Json.Decode.field "layouts"
                        (Json.Decode.list Layout.decoder)
                    )
                |> Result.withDefault []

        errorsFromLayouts : List Error
        errorsFromLayouts =
            layouts
                |> List.filterMap fromLayoutToError

        pages : List Page
        pages =
            flags
                |> Json.Decode.decodeValue
                    (Json.Decode.field "pages"
                        (Json.Decode.list Page.decoder)
                    )
                |> Result.withDefault []

        errorsFromPages : List Error
        errorsFromPages =
            pages
                |> List.filterMap fromPageToError

        customizedFiles : CustomizedFiles
        customizedFiles =
            flags
                |> Json.Decode.decodeValue customizedFilesDecoder
                |> Result.withDefault
                    { auth = Nothing
                    , shared = Nothing
                    , sharedModel = Nothing
                    , sharedMsg = Nothing
                    , effect = Nothing
                    , view = Nothing
                    }

        errorsFromCustomizedFiles : List Error
        errorsFromCustomizedFiles =
            List.filterMap identity
                [ toCustomizableErrors customizedFiles.auth
                    { types = [ "User" ]
                    , functions =
                        [ ( "onPageLoad", "Shared.Model -> Route () -> Auth.Action.Action User" )
                        , ( "viewCustomPage", "Shared.Model -> Route () -> View Never" )
                        ]
                    }
                , toCustomizableErrors customizedFiles.shared
                    { types = [ "Flags", "Model", "Msg" ]
                    , functions =
                        [ ( "decoder", "Json.Decode.Decoder Flags" )
                        , ( "init", "Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )" )
                        , ( "update", "Route () -> Msg -> Model -> ( Model, Effect Msg )" )
                        , ( "subscriptions", "Route () -> Model -> Sub Msg" )
                        ]
                    }
                , toCustomizableErrors customizedFiles.sharedModel
                    { types = [ "Model" ]
                    , functions = []
                    }
                , toCustomizableErrors customizedFiles.sharedMsg
                    { types = [ "Msg" ]
                    , functions = []
                    }
                , toCustomizableErrors customizedFiles.effect
                    { types = [ "Effect" ]
                    , functions =
                        [ ( "none", "Effect msg" )
                        , ( "map", "(msg1 -> msg2) -> Effect msg1 -> Effect msg2" )
                        , ( "toCmd", "{ key : Browser.Navigation.Key, url : Url, shared : Shared.Model.Model, fromSharedMsg : Shared.Msg.Msg -> msg, batch : List msg -> msg, toCmd : msg -> Cmd msg } -> Effect msg -> Cmd msg" )
                        , ( "sendCmd", "Cmd msg -> Effect msg" )
                        , ( "replaceRoute", "{ path : Route.Path.Path, query : Dict String String, hash : Maybe String } -> Effect msg" )
                        , ( "pushRoute", "{ path : Route.Path.Path, query : Dict String String, hash : Maybe String } -> Effect msg" )
                        ]
                    }
                , toCustomizableErrors customizedFiles.view
                    { types = [ "View" ]
                    , functions =
                        [ ( "toBrowserDocument", "{ shared : Shared.Model.Model, route : Route (), view : View msg } -> Browser.Document msg" )
                        , ( "map", "(msg1 -> msg2) -> View msg1 -> View msg2" )
                        , ( "none", "View msg" )
                        , ( "fromString", "String -> View msg" )
                        ]
                    }
                ]
    in
    ( {}
    , (errorsFromPages ++ errorsFromLayouts ++ errorsFromCustomizedFiles)
        |> List.map Error.toJson
        |> onComplete
    )


toCustomizableErrors :
    Maybe CustomizableFile
    ->
        { types : List String
        , functions : List ( String, String )
        }
    -> Maybe Error
toCustomizableErrors maybe options =
    case maybe of
        Nothing ->
            Nothing

        Just file ->
            let
                firstTypeNotExposed : Maybe String
                firstTypeNotExposed =
                    options.types
                        |> List.filter (\typeName -> CustomizableFile.isNotExposing typeName file)
                        |> List.head

                firstFunctionNotExposed : Maybe String
                firstFunctionNotExposed =
                    options.functions
                        |> List.filter (\( name, _ ) -> CustomizableFile.isNotExposing name file)
                        |> List.head
                        |> Maybe.map Tuple.first

                firstFunctionWithMissingAnnotation : Maybe ( ( String, String ), CustomizableFile.Problem )
                firstFunctionWithMissingAnnotation =
                    options.functions
                        |> List.filterMap
                            (\( name, anno ) ->
                                CustomizableFile.findProblemWithFunctionAnnotation
                                    { name = name
                                    , expected = anno
                                    , file = file
                                    }
                                    |> Maybe.map (Tuple.pair ( name, anno ))
                            )
                        |> List.head
            in
            [ firstTypeNotExposed
                |> Maybe.map
                    (\typeName ->
                        missingTypeError
                            { name = typeName
                            , kind = "customized"
                            , filepath = CustomizableFile.filepath file
                            }
                    )
            , firstFunctionNotExposed
                |> Maybe.map
                    (\name ->
                        missingFunctionError
                            { name = name
                            , kind = "customized"
                            , filepath = CustomizableFile.filepath file
                            }
                    )
            , firstFunctionWithMissingAnnotation
                |> Maybe.map
                    (\( ( name, anno ), problem ) ->
                        case problem of
                            CustomizableFile.MissingTypeAnnotation ->
                                missingFunctionAnnotationError
                                    { functionName = name
                                    , validAnnotations = [ anno ]
                                    }
                                    { filepath = CustomizableFile.filepath file }

                            CustomizableFile.InvalidTypeAnnotation actual ->
                                unexpectedAnnotationError
                                    { functionName = name
                                    , validAnnotations = [ anno ]
                                    }
                                    { detectedTypeAnnotation = actual
                                    , filepath = CustomizableFile.filepath file
                                    }
                    )
            ]
                |> List.filterMap identity
                |> List.head


fromLayoutToError : Layout -> Maybe Error
fromLayoutToError layout =
    if Layout.isNotExposingLayoutFunction layout then
        Just
            (missingFunctionError
                { name = "layout"
                , kind = "layout"
                , filepath = Layout.filepath layout
                }
            )

    else if Layout.isNotExposingPropsType layout then
        Just
            (missingTypeError
                { name = "Props"
                , kind = "layout"
                , filepath = Layout.filepath layout
                }
            )

    else if Layout.isNotExposingModelType layout then
        Just
            (missingTypeError
                { name = "Model"
                , kind = "layout"
                , filepath = Layout.filepath layout
                }
            )

    else if Layout.isNotExposingMsgType layout then
        Just
            (missingTypeError
                { name = "Msg"
                , kind = "layout"
                , filepath = Layout.filepath layout
                }
            )

    else
        case Layout.toProblem layout of
            Just Layout.MissingTypeAnnotation ->
                Just
                    (missingLayoutAnnotationError
                        { filepath = Layout.filepath layout
                        }
                    )

            Just problem ->
                Just
                    (unexpectedLayoutAnnotationError
                        { detectedTypeAnnotation = Layout.toAnnotationForLayoutFunction layout |> Maybe.withDefault "???"
                        , filepath = Layout.filepath layout
                        }
                    )

            Nothing ->
                Nothing


fromPageToError : Page -> Maybe Error
fromPageToError page =
    if Page.isNotExposingPageFunction page then
        Just
            (missingFunctionError
                { name = "page"
                , kind = "function"
                , filepath = Page.filepath page
                }
            )

    else
        case Page.toProblem page of
            Just Page.PageFunctionMissingTypeAnnotation ->
                Just
                    (missingPageAnnotationError
                        { filepath = Page.filepath page
                        }
                    )

            Just problem ->
                Just
                    (unexpectedPageAnnotationError
                        { detectedTypeAnnotation = Page.toAnnotationForPageFunction page |> Maybe.withDefault "???"
                        , filepath = Page.filepath page
                        }
                    )

            Nothing ->
                if Page.isStatefulPage page && Page.isNotExposingModelType page then
                    Just
                        (missingTypeError
                            { name = "Model"
                            , kind = "page"
                            , filepath = Page.filepath page
                            }
                        )

                else if Page.isStatefulPage page && Page.isNotExposingMsgType page then
                    Just
                        (missingTypeError
                            { name = "Msg"
                            , kind = "page"
                            , filepath = Page.filepath page
                            }
                        )

                else
                    Nothing



-- CATALOG OF POSSIBLE ELM LAND ERRORS


missingFunctionError :
    { name : String
    , kind : String
    , filepath : Filepath
    }
    -> Error
missingFunctionError options =
    missingFunctionOrTypeError
        { name = options.name
        , kind = options.kind
        , typeOrFunction = "function"
        , filepath = options.filepath
        }


missingTypeError :
    { name : String
    , kind : String
    , filepath : Filepath
    }
    -> Error
missingTypeError options =
    missingFunctionOrTypeError
        { name = options.name
        , kind = options.kind
        , typeOrFunction = "type"
        , filepath = options.filepath
        }



-- PAGE FILE ERRORS


toValidPageFunctionAnnotations : Filepath -> List String
toValidPageFunctionAnnotations filepath =
    let
        params : String
        params =
            Filepath.toRouteParamsRecordString filepath
    in
    [ case params of
        "()" ->
            "View msg"

        _ ->
            "{{params}} -> View msg"
                |> String.replace "{{params}}" params
    , "Page Model Msg"
    , "Shared.Model -> Route {{params}} -> Page Model Msg"
        |> String.replace "{{params}}" params
    , "Auth.User -> Shared.Model -> Route {{params}} -> Page Model Msg"
        |> String.replace "{{params}}" params
    ]


missingPageAnnotationError : { filepath : Filepath } -> Error
missingPageAnnotationError options =
    missingFunctionAnnotationError
        { functionName = "page"
        , validAnnotations = toValidPageFunctionAnnotations options.filepath
        }
        options


unexpectedPageAnnotationError :
    { detectedTypeAnnotation : String
    , filepath : Filepath
    }
    -> Error
unexpectedPageAnnotationError options =
    unexpectedAnnotationError
        { functionName = "page"
        , validAnnotations = toValidPageFunctionAnnotations options.filepath
        }
        options



-- LAYOUT FILE ERRORS


validLayoutFunctionAnnotations : Filepath -> List String
validLayoutFunctionAnnotations filepath =
    Filepath.toParentLayoutModuleName filepath
        |> Layout.toValidLayoutFunctionAnnotations


missingLayoutAnnotationError : { filepath : Filepath } -> Error
missingLayoutAnnotationError options =
    missingFunctionAnnotationError
        { functionName = "layout"
        , validAnnotations = validLayoutFunctionAnnotations options.filepath
        }
        options


unexpectedLayoutAnnotationError :
    { detectedTypeAnnotation : String
    , filepath : Filepath
    }
    -> Error
unexpectedLayoutAnnotationError options =
    unexpectedAnnotationError
        { functionName = "layout"
        , validAnnotations = validLayoutFunctionAnnotations options.filepath
        }
        options



-- COMMON ANNOTATION ERRORS


missingFunctionOrTypeError :
    { name : String
    , kind : String
    , typeOrFunction : String
    , filepath : Filepath
    }
    -> Error
missingFunctionOrTypeError options =
    let
        moduleName : String
        moduleName =
            Filepath.toModuleName options.filepath
    in
    Error.new
        { path = Filepath.toRelativeFilepath options.filepath
        , title =
            "Missing exposed {{typeOrFunction}}"
                |> String.replace "{{name}}" options.name
                |> String.replace "{{typeOrFunction}}" options.typeOrFunction
        , message =
            [ "I expected this module to expose a "
                |> Error.text
            , "{{name}}"
                |> String.replace "{{name}}" options.name
                |> Error.yellow
            , " {{typeOrFunction}}:\n\n"
                |> String.replace "{{typeOrFunction}}" options.typeOrFunction
                |> Error.text
            , Error.text "1|  module "
            , Error.yellow moduleName
            , " exposing ({{name}})\n"
                |> String.replace "{{name}}" options.name
                |> Error.text
            , Error.text (String.repeat (22 + String.length moduleName) " ")
            , Error.green (String.repeat (String.length options.name) "^")
            , Error.text "\nThis value is used internally by Elm Land, so it will need to be accessible\noutside of the current module.\n\n"
            , Error.underline "Hint:"
            , " Read https://elm.land/problems#missing-exposed-{{typeOrFunction}} to learn more"
                |> String.replace "{{typeOrFunction}}" (String.toLower options.typeOrFunction)
                |> Error.text
            ]
        }


missingFunctionAnnotationError :
    { functionName : String
    , validAnnotations : List String
    }
    ->
        { filepath : Filepath
        }
    -> Error
missingFunctionAnnotationError { functionName, validAnnotations } options =
    let
        params : String
        params =
            Filepath.toRouteParamsRecordString options.filepath

        units : String
        units =
            if List.length validAnnotations == 1 then
                "this annotation"

            else
                "one of these annotations"
    in
    Error.new
        { path = Filepath.toRelativeFilepath options.filepath
        , title = "Missing type annotation"
        , message =
            List.concat
                [ [ Error.text "I could not find a type annotation for your "
                  , Error.yellow functionName
                  , " function.\n\nI recommend {{units}}:\n\n"
                        |> String.replace "{{units}}" units
                        |> Error.text
                  ]
                , validAnnotations
                    |> List.concatMap
                        (\anno ->
                            [ "  {{functionName}} : "
                                |> String.replace "{{functionName}}" functionName
                                |> Error.text
                            , Error.yellow (anno ++ "\n\n")
                            ]
                        )
                , [ "Although Elm annotations are optional, Elm Land requires an annotation for\nthis particular function to avoid showing errors in generated code.\n\n"
                        |> Error.text
                  , Error.underline "Hint:"
                  , Error.text " Read https://elm.land/problems#missing-type-annotation to learn more"
                  ]
                ]
        }


unexpectedAnnotationError :
    { functionName : String
    , validAnnotations : List String
    }
    -> { detectedTypeAnnotation : String, filepath : Filepath }
    -> Error
unexpectedAnnotationError { functionName, validAnnotations } options =
    let
        params : String
        params =
            Filepath.toRouteParamsRecordString options.filepath

        units : String
        units =
            if List.length validAnnotations == 1 then
                "this annotation"

            else
                "one of these annotations"
    in
    Error.new
        { path = Filepath.toRelativeFilepath options.filepath
        , title = "Unexpected type annotation"
        , message =
            List.concat
                [ [ Error.text "I found an unexpected type annotation on this "
                  , Error.yellow functionName
                  , Error.text " function.\n\n"
                  , Error.text
                        ("  {{functionName}} : "
                            |> String.replace "{{functionName}}" functionName
                        )
                  , Error.text options.detectedTypeAnnotation
                  , Error.text ("\n" ++ String.repeat (5 + String.length functionName) " ")
                  , Error.red (String.repeat (String.length options.detectedTypeAnnotation) "^")
                  , "\nI recommend {{units}}:\n\n"
                        |> String.replace "{{units}}" units
                        |> Error.text
                  ]
                , validAnnotations
                    |> List.concatMap
                        (\anno ->
                            [ Error.text
                                ("  {{functionName}} : "
                                    |> String.replace "{{functionName}}" functionName
                                )
                            , Error.yellow (anno ++ "\n\n")
                            ]
                        )
                , [ "Although Elm annotations are optional, Elm Land requires an annotation for\nthis particular function to avoid showing errors in generated code.\n\n"
                        |> Error.text
                  , Error.underline "Hint:"
                  , Error.text
                        " Read https://elm.land/problems#unexpected-type-annotation to learn more"
                  ]
                ]
        }



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
