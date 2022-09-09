module Route.Query exposing (fromUrl, toString)

import Dict exposing (Dict)
import Url exposing (Url)
import Url.Parser exposing (query)


fromUrl : Url -> Dict String String
fromUrl url =
    case url.query of
        Nothing ->
            Dict.empty

        Just query ->
            if String.isEmpty query then
                Dict.empty

            else
                let
                    decode val =
                        Url.percentDecode val
                            |> Maybe.withDefault val
                in
                query
                    |> String.split "&"
                    |> List.filterMap
                        (String.split "="
                            >> (\pieces ->
                                    case pieces of
                                        [] ->
                                            Nothing

                                        key :: [] ->
                                            Just ( decode key, "" )

                                        key :: value :: _ ->
                                            Just ( decode key, decode value )
                               )
                        )
                    |> Dict.fromList


toString : Dict String String -> Maybe String
toString queryParameterList =
    if Dict.isEmpty queryParameterList then
        Nothing

    else
        queryParameterList
            |> Dict.toList
            |> List.map
                (\( key, value ) ->
                    if String.isEmpty value then
                        Url.percentEncode key

                    else
                        String.join "="
                            [ Url.percentEncode key
                            , Url.percentEncode value
                            ]
                )
            |> String.join "&"
            |> String.append "?"
            |> Just
