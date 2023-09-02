port module Main exposing (main)

import CodeGen
import CodeGen.Module
import GraphQL.CliError exposing (CliError)
import GraphQL.Input
import GraphQL.Introspection.Document as Document exposing (Document)
import GraphQL.Introspection.Schema as Schema exposing (Schema)
import GraphQL.Introspection.Schema.TypeRef as TypeRef exposing (TypeRef)
import GraphQL.Operation
import Json.Decode
import Result.Extra
import Set exposing (Set)


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
                findInputTypesUsedIn : Document -> Set String -> Set String
                findInputTypesUsedIn document set =
                    GraphQL.Input.findInputTypesUsed
                        { schema = flags.schema
                        , document = document
                        }
                        |> Set.union set

                inputTypeNames : Set String
                inputTypeNames =
                    Set.union
                        (List.foldl findInputTypesUsedIn Set.empty flags.queries)
                        (List.foldl findInputTypesUsedIn Set.empty flags.mutations)

                inputTypes : List Schema.InputObjectType
                inputTypes =
                    Schema.findInputTypes
                        inputTypeNames
                        flags.schema

                generatedInputFiles : List CodeGen.Module
                generatedInputFiles =
                    if List.isEmpty inputTypes then
                        []

                    else
                        List.append
                            [ GraphQL.Input.toRootInputModule
                                { namespace = flags.namespace
                                , schema = flags.schema
                                , inputTypes = inputTypes
                                }
                            , GraphQL.Input.toRootInternalInputModule
                                { namespace = flags.namespace
                                , schema = flags.schema
                                , inputTypes = inputTypes
                                }
                            ]
                            (List.map toInputModule inputTypes)

                toInputModule : Schema.InputObjectType -> CodeGen.Module
                toInputModule input =
                    GraphQL.Input.toInputModule
                        { moduleName = [ flags.namespace, "Input", input.name ]
                        , inputTypeName = input.name
                        , namespace = flags.namespace
                        , schema = flags.schema
                        , variables = input.inputFields
                        , isRequired = .type_ >> TypeRef.isRequired
                        , toVarName = .name
                        , toTypeNameUnwrappingFirstMaybe =
                            \var ->
                                Schema.toTypeRefNameUnwrappingFirstMaybe
                                    var.type_
                                    flags.schema
                        , toTypeName = .type_ >> TypeRef.toName
                        , toEncoderString =
                            \var ->
                                Schema.toTypeRefEncoderStringUnwrappingFirstMaybe
                                    var.type_
                                    flags.schema
                        , isInputObject = True
                        }

                generatedFilesFromQueries : Result CliError (List CodeGen.Module)
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

                generatedFilesFromMutations : Result CliError (List CodeGen.Module)
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

                generatedFilesResult : Result CliError (List CodeGen.Module)
                generatedFilesResult =
                    Result.map2 (++)
                        generatedFilesFromQueries
                        generatedFilesFromMutations

                fromModuleToFile : CodeGen.Module -> File
                fromModuleToFile module_ =
                    { filepath =
                        CodeGen.Module.toFilepath module_
                            |> String.split "/"
                    , contents =
                        CodeGen.Module.toString module_
                    }
              in
              case generatedFilesResult of
                Ok files ->
                    success
                        { files =
                            (generatedInputFiles ++ files)
                                |> List.map fromModuleToFile
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
