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
                { filepath = Page.filepath page
                }
            )

    else
        Nothing



-- CATALOG OF POSSIBLE ELM LAND ERRORS


missingPageFunctionError : { filepath : Filepath } -> Error
missingPageFunctionError options =
    let
        moduleName : String
        moduleName =
            Filepath.toModuleName options.filepath
    in
    Error.new
        { path = Filepath.toRelativeFilepath options.filepath
        , title = "Missing page function"
        , message =
            [ Error.text "In order for Elm Land to build, every page needs to expose a "
            , Error.yellow "`page`"
            , Error.text " function.\n"
            , Error.text """Please be sure to include "page" in your exposing list like this:

1|  module """
            , Error.text moduleName
            , Error.text " exposing (page)\n"
            , Error.text (String.repeat (22 + String.length moduleName) " ")
            , Error.green """^^^^"""
            , Error.text "\n"
            , Error.underline "Hint:"
            , Error.text " Read https://elm.land/errors/missing-page-function to learn more"
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
