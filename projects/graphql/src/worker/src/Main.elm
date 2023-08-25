port module Main exposing (main)

import GraphQL.CliError
import GraphQL.Introspection.Document as Document exposing (Document)
import GraphQL.Introspection.Schema as Schema exposing (Schema)
import GraphQL.Query
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
    { schema : Schema
    , queries : List Document
    , mutations : List Document
    }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map3 Flags
        (Json.Decode.at [ "introspection", "data", "__schema" ] Schema.decoder)
        (Json.Decode.at [ "queries" ] (Json.Decode.list Document.decoder))
        (Json.Decode.at [ "mutations" ] (Json.Decode.list Document.decoder))


init : Json.Decode.Value -> ( Model, Cmd Msg )
init json =
    case Json.Decode.decodeValue decoder json of
        Ok flags ->
            ( {}
            , case
                flags.queries
                    |> List.map
                        (\query ->
                            GraphQL.Query.generate
                                { schema = flags.schema
                                , document = query
                                }
                        )
                    |> Result.Extra.combine
              of
                Ok generatedFilesFromQuery ->
                    success
                        { files = List.concat generatedFilesFromQuery
                        }

                Err cliError ->
                    failure { reason = GraphQL.CliError.toString cliError }
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


generateQueryFile : Document -> File
generateQueryFile doc =
    { filepath =
        [ "GraphQL"
        , "Queries"
        , Document.toName doc ++ ".elm"
        ]
    , contents =
        String.trim """
module GraphQL.Queries.${name} exposing (Data, new)

{-|

@docs Data, new

-}

import GraphQL.Decode
import GraphQL.Operation


type alias Data =
    { hello : String
    }


new : GraphQL.Operation.Operation Data
new =
    GraphQL.Operation.new
        { name = "${name}"
        , query = \"\"\"
${contents}
          \"\"\"
        , variables = []
        , decoder = decoder
        }


decoder : GraphQL.Decode.Decoder Data
decoder =
    GraphQL.Decode.object Data
        |> GraphQL.Decode.field
            { name = "hello"
            , decoder = GraphQL.Decode.string
            }
"""
            |> String.replace "${name}" (Document.toName doc)
            |> String.replace "${contents}"
                (Document.toContents doc
                    |> String.replace "\"\"\"" "\\\"\\\"\\\""
                    |> String.split "\n"
                    |> String.join "\n            "
                    |> String.append "            "
                )
    }
