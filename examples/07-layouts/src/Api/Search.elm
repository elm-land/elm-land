module Api.Search exposing (Item, sendHttpRequest)

import Effect exposing (Effect)
import Http
import Route.Path
import Task


type alias Item =
    { label : String
    , path : Route.Path.Path
    }


sendHttpRequest :
    { query : String
    , onResponse : Result Http.Error (List Item) -> msg
    }
    -> Effect msg
sendHttpRequest options =
    let
        searchableThings : List Item
        searchableThings =
            [ { label = "Dashboard", path = Route.Path.Home_ }
            , { label = "Authors", path = Route.Path.Authors }
            , { label = "Blog posts", path = Route.Path.BlogPosts }
            ]

        matchingSearchResults : List Item
        matchingSearchResults =
            List.filter (containsCaseInsensitive options.query) searchableThings
    in
    matchingSearchResults
        |> Ok
        |> Task.succeed
        |> Task.perform options.onResponse
        |> Effect.fromCmd


containsCaseInsensitive : String -> Item -> Bool
containsCaseInsensitive query item =
    String.contains
        (String.toLower query)
        (String.toLower item.label)
