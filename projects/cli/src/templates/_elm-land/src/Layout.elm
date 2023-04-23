module Layout exposing
    ( Layout, new
    , init, update, view, subscriptions
    )

{-|

@docs Layout, new

@docs init, update, view, subscriptions

-}

import Effect exposing (Effect)
import View exposing (View)


type Layout model msg contentMsg
    = Layout
        { init : () -> ( model, Effect msg )
        , update : msg -> model -> ( model, Effect msg )
        , subscriptions : model -> Sub msg
        , view : { model : model, toContentMsg : msg -> contentMsg, content : View contentMsg } -> View contentMsg
        }


new :
    { init : () -> ( model, Effect msg )
    , update : msg -> model -> ( model, Effect msg )
    , subscriptions : model -> Sub msg
    , view : { model : model, toContentMsg : msg -> contentMsg, content : View contentMsg } -> View contentMsg
    }
    -> Layout model msg contentMsg
new options =
    Layout
        { init = options.init
        , update = options.update
        , subscriptions = options.subscriptions
        , view = options.view
        }


init : Layout model msg contentMsg -> () -> ( model, Effect msg )
init (Layout page) =
    page.init


update : Layout model msg contentMsg -> msg -> model -> ( model, Effect msg )
update (Layout page) =
    page.update


view :
    Layout model msg contentMsg
    -> { model : model, toContentMsg : msg -> contentMsg, content : View contentMsg }
    -> View contentMsg
view (Layout page) =
    page.view


subscriptions : Layout model msg contentMsg -> model -> Sub msg
subscriptions (Layout page) =
    page.subscriptions
