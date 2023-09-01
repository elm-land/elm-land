port module Main exposing (main)

import GraphQL.CliError exposing (CliError)
import GraphQL.Introspection.Document as Document exposing (Document)
import GraphQL.Introspection.Schema as Schema exposing (Schema)
import GraphQL.Operation
import Json.Decode
import Result.Extra


main : Platform.Program Json.Decode.Value Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    {}


port success : { files : List File } -> Cmd msg


port failure : { reason : String } -> Cmd msg


type alias Flags =
    { namespace : String
    , schema : Schema
    , queries : List Document
    , mutations : List Document
    }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map4 Flags
        (Json.Decode.oneOf
            [ Json.Decode.field "namespace" Json.Decode.string
            , Json.Decode.succeed "Api"
            ]
        )
        (Json.Decode.at [ "introspection", "data", "__schema" ] Schema.decoder)
        (Json.Decode.at [ "queries" ] (Json.Decode.list Document.decoder))
        (Json.Decode.at [ "mutations" ] (Json.Decode.list Document.decoder))


init : Json.Decode.Value -> ( Model, Cmd Msg )
init json =
    case Json.Decode.decodeValue decoder json of
        Ok flags ->
            ( {}
            , let
                generatedFilesFromQueries : Result CliError (List File)
                generatedFilesFromQueries =
                    flags.queries
                        |> List.map
                            (\document ->
                                GraphQL.Operation.generate
                                    { kind = GraphQL.Operation.Query
                                    , namespace = flags.namespace
                                    , schema = flags.schema
                                    , document = document
                                    }
                            )
                        |> Result.Extra.combine
                        |> Result.map List.concat

                generatedFilesFromMutations : Result CliError (List File)
                generatedFilesFromMutations =
                    flags.mutations
                        |> List.map
                            (\document ->
                                GraphQL.Operation.generate
                                    { kind = GraphQL.Operation.Mutation
                                    , namespace = flags.namespace
                                    , schema = flags.schema
                                    , document = document
                                    }
                            )
                        |> Result.Extra.combine
                        |> Result.map List.concat

                generatedFilesResult : Result CliError (List File)
                generatedFilesResult =
                    Result.map2 (++)
                        generatedFilesFromQueries
                        generatedFilesFromMutations
              in
              case generatedFilesResult of
                Ok files ->
                    success
                        { files = files
                        }

                Err cliError ->
                    failure
                        { reason = GraphQL.CliError.toString cliError
                        }
            )

        Err jsonDecodeError ->
            ( {}
            , failure { reason = Json.Decode.errorToString jsonDecodeError }
            )



-- UPDATE


type alias Msg =
    Never


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HARD CODED MODULES


type alias File =
    { filepath : List String
    , contents : String
    }
