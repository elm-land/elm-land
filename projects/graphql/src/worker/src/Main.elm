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
                        { files =
                            List.concat
                                [ [ graphqlOperationFile ]
                                , generatedFilesFromQuery
                                ]
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


graphqlOperationFile : File
graphqlOperationFile =
    { filepath = [ "GraphQL", "Operation.elm" ]
    , contents = String.trim """
module GraphQL.Operation exposing
    ( Operation, new
    , map
    , toHttpCmd
    )

{-|

@docs Operation, new
@docs map

@docs toHttpCmd

-}

import GraphQL.Decode
import GraphQL.Encode
import GraphQL.Http
import Http
import Json.Decode


type Operation data
    = Operation
        { name : String
        , query : String
        , variables : List ( String, GraphQL.Encode.Value )
        , decoder : GraphQL.Decode.Decoder data
        }


new :
    { name : String
    , query : String
    , variables : List ( String, GraphQL.Encode.Value )
    , decoder : GraphQL.Decode.Decoder data
    }
    -> Operation data
new options =
    Operation options



-- MAP


map : (a -> b) -> Operation a -> Operation b
map fn (Operation operation) =
    Operation
        { name = operation.name
        , query = operation.query
        , variables = operation.variables
        , decoder =
            operation.decoder
                |> GraphQL.Decode.toJsonDecoder
                |> Json.Decode.map fn
                |> GraphQL.Decode.scalar
        }



-- CMD


toHttpCmd :
    { method : String
    , url : String
    , headers : List Http.Header
    , timeout : Maybe Float
    , tracker : Maybe String
    , operation : Operation data
    , onResponse : Result Http.Error data -> msg
    }
    -> Cmd msg
toHttpCmd options =
    let
        (Operation operation) =
            options.operation
    in
    Http.request
        { method = options.method
        , url = options.url
        , headers = options.headers
        , body =
            GraphQL.Http.body
                { operationName = Just operation.name
                , query = operation.query
                , variables = operation.variables
                }
        , expect =
            GraphQL.Http.expect
                options.onResponse
                operation.decoder
        , timeout = options.timeout
        , tracker = options.tracker
        }

"""
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
