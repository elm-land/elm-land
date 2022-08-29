module Route.Query exposing (fromUrl, toStringFromList)

import Dict exposing (Dict)
import Url exposing (Url)
import Url.Parser exposing (query)


fromUrl : Url -> Dict String (Maybe String)
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
                                            Just ( decode key, Nothing )

                                        key :: value :: _ ->
                                            Just ( decode key, Just (decode value) )
                               )
                        )
                    |> Dict.fromList


toStringFromList : List ( String, Maybe String ) -> Maybe String
toStringFromList queryParameterList =
    if List.isEmpty queryParameterList then
        Nothing

    else
        queryParameterList
            |> List.map
                (\( key, maybeValue ) ->
                    case maybeValue of
                        Nothing ->
                            Url.percentEncode key

                        Just value ->
                            String.join "="
                                [ Url.percentEncode key
                                , Url.percentEncode value
                                ]
                )
            |> String.join "&"
            |> String.append "?"
            |> Just
