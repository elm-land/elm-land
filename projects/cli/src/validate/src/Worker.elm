port module Worker exposing (main)

import Error exposing (Error)
import Filepath exposing (Filepath)
import Json.Decode
import Json.Encode
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


init : Json.Decode.Value -> ( Model, Cmd Msg )
init flags =
    let
        pages : List Page
        pages =
            flags
                |> Json.Decode.decodeValue (Json.Decode.field "pages" (Json.Decode.list Page.decoder))
                |> Result.withDefault []

        errorsFromPages : List Error
        errorsFromPages =
            pages
                |> List.filterMap fromPageToError
    in
    ( {}
    , errorsFromPages
        |> List.map Error.toJson
        |> onComplete
    )


fromPageToError : Page -> Maybe Error
fromPageToError page =
    if Page.isNotExposingPageFunction page then
        Just
            (missingPageFunctionError
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
                    (invalidPageFunctionError
                        { detectedTypeAnnotation = Page.toAnnotationForPageFunction page |> Maybe.withDefault "???"
                        , filepath = Page.filepath page
                        }
                    )

            Nothing ->
                if Page.isStatefulPage page && Page.isNotExposingModelType page then
                    Just
                        (missingPageFunctionError
                            { name = "Model"
                            , kind = "type"
                            , filepath = Page.filepath page
                            }
                        )

                else if Page.isStatefulPage page && Page.isNotExposingMsgType page then
                    Just
                        (missingPageFunctionError
                            { name = "Msg"
                            , kind = "type"
                            , filepath = Page.filepath page
                            }
                        )

                else
                    Nothing



-- CATALOG OF POSSIBLE ELM LAND ERRORS


missingPageFunctionError :
    { name : String
    , kind : String
    , filepath : Filepath
    }
    -> Error
missingPageFunctionError options =
    let
        moduleName : String
        moduleName =
            Filepath.toModuleName options.filepath
    in
    Error.new
        { path = Filepath.toRelativeFilepath options.filepath
        , title = "Missing {{name}} function" |> String.replace "{{name}}" options.name
        , message =
            [ Error.text ("For Elm Land to build, this page file needs to expose a " |> String.replace "{{name}}" options.name)
            , Error.yellow ("`{{name}}`" |> String.replace "{{name}}" options.name)
            , Error.text (" {{kind}}.\n" |> String.replace "{{kind}}" options.kind)
            , Error.text ("""Please be sure to include "{{name}}" in your exposing list like this:

1|  module """ |> String.replace "{{name}}" options.name)
            , Error.text moduleName
            , Error.text (" exposing ({{name}})\n" |> String.replace "{{name}}" options.name)
            , Error.text (String.repeat (22 + String.length moduleName) " ")
            , Error.green (String.repeat (String.length options.name) "^")
            , Error.text "\n"
            , Error.underline "Hint:"
            , Error.text
                (" Read https://elm.land/problems#missing-{{name}}-{{kind}} to learn more"
                    |> String.replace "{{name}}" (String.toLower options.name)
                    |> String.replace "{{kind}}" (String.toLower options.kind)
                )
            ]
        }


invalidPageFunctionError : { detectedTypeAnnotation : String, filepath : Filepath } -> Error
invalidPageFunctionError options =
    let
        params : String
        params =
            Filepath.toRouteParamsRecordString options.filepath
    in
    Error.new
        { path = Filepath.toRelativeFilepath options.filepath
        , title = "Invalid page function"
        , message =
            [ Error.text "Elm Land ran into an unexpected page function value.\n\nIt looks like `page` has the type annotation:\n\n"
            , Error.text "    page : "
            , Error.text options.detectedTypeAnnotation
            , Error.text ("\n" ++ String.repeat 11 " ")
            , Error.red (String.repeat (String.length options.detectedTypeAnnotation) "^")
            , Error.text "\nBut Elm Land expected one of these four options:\n\n"
            , Error.text "    page : "
            , case params of
                "()" ->
                    Error.yellow "View msg\n\n"

                _ ->
                    Error.yellow
                        ("{{params}} -> View msg\n\n"
                            |> String.replace "{{params}}" params
                        )
            , Error.text "    page : "
            , Error.yellow "Page Model Msg\n\n"
            , Error.text "    page : "
            , Error.yellow
                ("Shared.Model -> Route {{params}} -> Page Model Msg\n\n"
                    |> String.replace "{{params}}" params
                )
            , Error.text "    page : "
            , Error.yellow
                ("Auth.User -> Shared.Model -> Route {{params}} -> Page Model Msg\n\n"
                    |> String.replace "{{params}}" params
                )
            , Error.text "Without one of those four annotations, Elm Land can't connect this page to\n"
            , Error.text "the rest of your web application.\n\n"
            , Error.underline "Hint:"
            , Error.text " Read https://elm.land/problems#invalid-page-function to learn more"
            ]
        }


missingPageAnnotationError : { filepath : Filepath } -> Error
missingPageAnnotationError options =
    let
        params : String
        params =
            Filepath.toRouteParamsRecordString options.filepath
    in
    Error.new
        { path = Filepath.toRelativeFilepath options.filepath
        , title = "Missing page annotation"
        , message =
            [ Error.text "Elm Land could not find a type annotation for your `page` function. Please add\n"
            , Error.text "a type annotation above your page function. Here are some examples:\n\n"
            , Error.text "    page : "
            , case params of
                "()" ->
                    Error.yellow "View msg\n\n"

                _ ->
                    Error.yellow
                        ("{{params}} -> View msg\n\n"
                            |> String.replace "{{params}}" params
                        )
            , Error.text "    page : "
            , Error.yellow "Page Model Msg\n\n"
            , Error.text "    page : "
            , Error.yellow
                ("Shared.Model -> Route {{params}} -> Page Model Msg\n\n"
                    |> String.replace "{{params}}" params
                )
            , Error.text "    page : "
            , Error.yellow
                ("Auth.User -> Shared.Model -> Route {{params}} -> Page Model Msg\n\n"
                    |> String.replace "{{params}}" params
                )
            , Error.text "Without one of those four annotations, Elm Land can't connect this page to\n"
            , Error.text "the rest of your web application.\n\n"
            , Error.underline "Hint:"
            , Error.text " Read https://elm.land/problems#missing-page-annotation to learn more"
            ]
        }



-- UPDATE


type Msg
    = DoNothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
