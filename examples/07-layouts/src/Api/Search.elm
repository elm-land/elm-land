module Api.Search exposing (Item, sendHttpRequest)

import Effect exposing (Effect)


type Item
    = Item


sendHttpRequest : a -> Effect msg
sendHttpRequest _ =
    Effect.none
        |> Debug.log "Fix this"
