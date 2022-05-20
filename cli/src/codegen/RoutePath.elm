module RoutePath exposing
    ( RoutePath, decoder, fromList
    , home, notFound
    , hasDynamicParameters, toDynamicParameterRecord
    , toRouteVariantName, toUrlParser
    , toList
    )

{-|

@docs RoutePath, decoder, fromList
@docs home, notFound

@docs hasDynamicParameters, toDynamicParameterRecord
@docs toRouteVariantName, toUrlParser
@docs toList

-}

import Elm
import Elm.Annotation
import Gen.Url.Parser
import Json.Decode


type RoutePath
    = RoutePath (List String)


decoder : Json.Decode.Decoder RoutePath
decoder =
    Json.Decode.map fromList
        (Json.Decode.list Json.Decode.string)


fromList : List String -> RoutePath
fromList =
    RoutePath


home : RoutePath
home =
    fromList [ "Home_" ]


notFound : RoutePath
notFound =
    fromList [ "NotFound_" ]


toList : RoutePath -> List String
toList (RoutePath list) =
    list


hasDynamicParameters : RoutePath -> Bool
hasDynamicParameters routePath =
    not (List.isEmpty (toDynamicParameterNames routePath))


toRouteVariantName : RoutePath -> String
toRouteVariantName (RoutePath list) =
    String.join "__" list


toUrlParser : RoutePath -> Elm.Expression
toUrlParser routePath =
    let
        toRouteSegmentParser : String -> Elm.Expression
        toRouteSegmentParser pathSegment =
            if String.endsWith "_" pathSegment then
                Gen.Url.Parser.string

            else
                Gen.Url.Parser.s (fromPascalCaseToKebabCase pathSegment)

        fromPascalCaseToKebabCase : String -> String
        fromPascalCaseToKebabCase str =
            str
                |> String.toList
                |> List.concatMap
                    (\char ->
                        if Char.isUpper char then
                            [ '-', Char.toLower char ]

                        else
                            [ char ]
                    )
                |> String.fromList
                |> String.dropLeft 1

        joinWithUrlSlash : Elm.Expression -> Maybe Elm.Expression -> Maybe Elm.Expression
        joinWithUrlSlash expr1 maybeExpr =
            case maybeExpr of
                Nothing ->
                    Just expr1

                Just expr2 ->
                    Just (Elm.slash expr2 expr1)

        toRouteConstructor : Elm.Expression
        toRouteConstructor =
            let
                dynamicValues : List String
                dynamicValues =
                    routePath
                        |> toList
                        |> List.filter (String.endsWith "_")

                numberOfDynamicValues : Int
                numberOfDynamicValues =
                    List.length dynamicValues
            in
            if numberOfDynamicValues > 0 then
                Elm.function
                    (( "param", Nothing )
                        |> List.repeat numberOfDynamicValues
                        |> List.indexedMap
                            (\i ( str, maybe ) ->
                                ( str ++ String.fromInt (i + 1), maybe )
                            )
                    )
                    (\exprs ->
                        Elm.apply
                            (Elm.value
                                { importFrom = []
                                , name = toRouteVariantName routePath
                                , annotation = Nothing
                                }
                            )
                            [ Elm.record
                                (List.map2
                                    (\nameWithUnderscore expr ->
                                        Elm.field
                                            (fromPascalCaseToCamelCase (String.dropRight 1 nameWithUnderscore))
                                            expr
                                    )
                                    dynamicValues
                                    exprs
                                )
                            ]
                    )

            else
                Elm.value
                    { importFrom = []
                    , name = toRouteVariantName routePath
                    , annotation = Nothing
                    }
    in
    if routePath == home then
        Gen.Url.Parser.map
            (Elm.value
                { importFrom = []
                , name = "Home_"
                , annotation = Nothing
                }
            )
            Gen.Url.Parser.top

    else
        Gen.Url.Parser.map
            toRouteConstructor
            (routePath
                |> toList
                |> List.map toRouteSegmentParser
                |> List.foldl joinWithUrlSlash Nothing
                |> Maybe.withDefault Gen.Url.Parser.top
            )


toDynamicParameterRecord : RoutePath -> Elm.Annotation.Annotation
toDynamicParameterRecord routePath =
    toDynamicParameterNames routePath
        |> List.map (\name -> ( name, Elm.Annotation.string ))
        |> Elm.Annotation.record



-- INTERNALS


fromPascalCaseToCamelCase : String -> String
fromPascalCaseToCamelCase str =
    case String.toList str of
        [] ->
            ""

        first :: rest ->
            String.fromList (Char.toLower first :: rest)


{-|

    RoutePath.fromList [ "Home_" ] == []

    RoutePath.fromList [ "SignIn" ] == []

    RoutePath.fromList [ "Profile", "Username_" ] == [ "username" ]

    RoutePath.fromList [ "SomethingVery_", "Fancy_" ] == [ "somethingVery", "fancy" ]

-}
toDynamicParameterNames : RoutePath -> List String
toDynamicParameterNames (RoutePath list) =
    case list of
        [ "Home_" ] ->
            []

        [ "NotFound_" ] ->
            []

        _ ->
            list
                |> List.filter (String.endsWith "_")
                |> List.map (String.dropRight 1)
                |> List.map fromPascalCaseToCamelCase
