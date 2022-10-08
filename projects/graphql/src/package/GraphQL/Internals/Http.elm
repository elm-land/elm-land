module GraphQL.Internals.Http exposing
    ( Operation, operation
    , Query, Mutation, Subscription
    , request
    , Decoder
    , scalars
    , object, field
    , union, interface, variant
    , none, maybe, list
    , succeed
    , Input, input, with, null
    , encode
    , mapOperation
    )

{-|


## For generated code only

This module is used by the code generated from the
`@elm-land/graphql` CLI tool, and should not be
used directly in your project.

See the `GraphQL.Http` module for how to send GraphQL
requests from your application.

---

@docs Operation, operation
@docs Query, Mutation, Subscription
@docs request

@docs Decoder
@docs scalars
@docs object, field
@docs union, interface, variant

@docs none, maybe, list
@docs succeed

@docs Input, input, with, null
@docs encode

-}

import Dict exposing (Dict)
import GraphQL.Http.Error
import Http
import Json.Decode as Json
import Json.Encode as Encode
import Task


type Operation data
    = Operation
        { name : String
        , query : String
        , variables : Maybe Input
        , decoder : Decoder data
        }


operation :
    { name : String
    , query : String
    , variables : Maybe Input
    , decoder : Decoder data
    }
    -> Operation data
operation =
    Operation


mapOperation : (data1 -> data2) -> Operation data1 -> Operation data2
mapOperation fn (Operation data) =
    Operation
        { name = data.name
        , query = data.query
        , variables = data.variables
        , decoder = mapDecoder fn data.decoder
        }


type alias Query data =
    Operation data


type alias Mutation data =
    Operation data


type alias Subscription data =
    Operation data



-- DECODER


type Decoder data
    = Decoder { decoder : Json.Decoder data }



-- SCALARS


scalar : Json.Decoder value -> Decoder value
scalar decoder =
    Decoder { decoder = decoder }


scalars :
    { string : Decoder String
    , float : Decoder Float
    , int : Decoder Int
    , custom : Json.Decoder value -> Decoder value
    , enum : List ( String, enum ) -> Decoder enum
    }
scalars =
    { string = Decoder { decoder = Json.string }
    , float = Decoder { decoder = Json.float }
    , int = Decoder { decoder = Json.int }
    , custom = scalar
    , enum = enum
    }



-- ENUMS


enum : List ( String, enum ) -> Decoder enum
enum lookup =
    Decoder
        { decoder =
            Json.string
                |> Json.andThen
                    (\str ->
                        case List.filter (\( key, _ ) -> key == str) lookup of
                            [] ->
                                Json.fail ("Unexpected enum value: " ++ str)

                            ( _, value ) :: _ ->
                                Json.succeed value
                    )
        }



-- OBJECTS & FIELDS


object : (a -> b) -> Decoder (a -> b)
object value =
    Decoder { decoder = Json.succeed value }


field :
    String
    ->
        { wrapper : Decoder selection -> Decoder value
        , decoder : Decoder selection
        }
    -> Decoder (value -> output)
    -> Decoder output
field name options (Decoder fn) =
    let
        (Decoder selection) =
            options.decoder

        (Decoder value) =
            Decoder
                { decoder = Json.field name selection.decoder
                }
                |> options.wrapper
    in
    Decoder
        { decoder =
            Json.map2 (|>)
                value.decoder
                fn.decoder
        }



-- UNIONS & INTERFACES


union :
    List { typename : String, decoder : Decoder union }
    -> Decoder union
union variants =
    Decoder
        { decoder =
            Json.field "__typename" Json.string
                |> Json.andThen
                    (\typename ->
                        let
                            decoder : Maybe (Decoder union)
                            decoder =
                                variants
                                    |> List.filter (\v -> v.typename == typename)
                                    |> List.head
                                    |> Maybe.map .decoder
                        in
                        case decoder of
                            Just (Decoder json) ->
                                json.decoder

                            Nothing ->
                                Json.fail ("Unexpected __typename: " ++ typename)
                    )
        }


interface :
    List { typename : String, decoder : Decoder interface }
    -> Decoder interface
interface =
    union


variant :
    (variant -> union)
    -> Decoder variant
    -> Decoder union
variant =
    mapDecoder



-- HTTP


request :
    { url : String
    , headers : List Http.Header
    , timeout : Maybe Float
    , method : String
    , operation : Operation data
    , onResult : Result GraphQL.Http.Error.Error data -> msg
    }
    -> Cmd msg
request options =
    let
        (Operation operation_) =
            options.operation

        (Decoder json) =
            operation_.decoder

        variables : Json.Value
        variables =
            case operation_.variables of
                Just input_ ->
                    encode input_

                Nothing ->
                    Encode.object []

        body : Http.Body
        body =
            Http.jsonBody
                (Encode.object
                    [ ( "operationName", Encode.string operation_.name )
                    , ( "query", Encode.string (dedent operation_.query) )
                    , ( "variables", variables )
                    ]
                )

        resolver : Http.Resolver GraphQL.Http.Error.Error data
        resolver =
            Http.stringResolver fromResponseToResult

        fromResponseToResult : Http.Response String -> Result GraphQL.Http.Error.Error data
        fromResponseToResult httpResponse =
            case httpResponse of
                Http.BadUrl_ url ->
                    Err (GraphQL.Http.Error.BadUrl url)

                Http.Timeout_ ->
                    Err GraphQL.Http.Error.Timeout

                Http.NetworkError_ ->
                    Err GraphQL.Http.Error.NetworkError

                Http.BadStatus_ metadata body_ ->
                    Err
                        (GraphQL.Http.Error.BadStatus
                            { url = metadata.url
                            , headers = metadata.headers
                            , statusCode = metadata.statusCode
                            , statusText = metadata.statusText
                            , body = body_
                            }
                        )

                Http.GoodStatus_ metadata body_ ->
                    case Json.decodeString (Json.field "data" json.decoder) body_ of
                        Ok data ->
                            Ok data

                        Err jsonDecodeError ->
                            Err
                                (GraphQL.Http.Error.UnexpectedJson
                                    { url = metadata.url
                                    , headers = metadata.headers
                                    , statusCode = metadata.statusCode
                                    , statusText = metadata.statusText
                                    , body = body_
                                    }
                                    jsonDecodeError
                                )
    in
    Http.task
        { method = options.method
        , headers = List.reverse options.headers
        , url = options.url
        , body = body
        , timeout = options.timeout
        , resolver = resolver
        }
        |> Task.attempt options.onResult


none : Decoder value -> Decoder value
none =
    identity


maybe : Decoder value -> Decoder (Maybe value)
maybe (Decoder value) =
    Decoder { decoder = Json.maybe value.decoder }


list : Decoder value -> Decoder (List value)
list (Decoder value) =
    Decoder { decoder = Json.list value.decoder }


succeed : value -> Decoder value
succeed value =
    Decoder { decoder = Json.succeed value }



-- INPUT


type Input
    = Input (Dict String Json.Value)


input : Input
input =
    Input Dict.empty


with : String -> Json.Value -> Input -> Input
with key value (Input dict) =
    Input (Dict.insert key value dict)


null : String -> Input -> Input
null key (Input dict) =
    Input (Dict.remove key dict)


encode : Input -> Json.Value
encode (Input dict) =
    Encode.object (Dict.toList dict)



-- INTERNALS


mapDecoder : (a -> b) -> Decoder a -> Decoder b
mapDecoder fn (Decoder a) =
    Decoder { decoder = Json.map fn a.decoder }


{-| Removes excess spaces from the GraphQL queries provided

    """
            query {
              me
            }
    """

    -- becomes
    """
    query {
      me
    }
    """

-}
dedent : String -> String
dedent indentedString =
    let
        lines : List String
        lines =
            String.lines indentedString

        nonBlankLines : List String
        nonBlankLines =
            List.filter isNonBlank lines

        isNonBlank : String -> Bool
        isNonBlank =
            not << String.isEmpty << String.trimLeft

        countInitialSpacesFor : String -> Int
        countInitialSpacesFor str =
            String.length str - String.length (String.trimLeft str)

        numberOfSpacesToRemove : Int
        numberOfSpacesToRemove =
            List.foldl
                (\line maybeMin ->
                    let
                        count =
                            countInitialSpacesFor line
                    in
                    case maybeMin of
                        Nothing ->
                            Just count

                        Just min ->
                            if min < count then
                                Just min

                            else
                                Just count
                )
                Nothing
                nonBlankLines
                |> Maybe.withDefault 0
    in
    nonBlankLines
        |> List.map (String.dropLeft numberOfSpacesToRemove)
        |> String.join "\n"
