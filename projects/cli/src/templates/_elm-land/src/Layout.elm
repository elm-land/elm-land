module Layout exposing
    ( Layout, new
    , init, update, view, subscriptions
    )

{-|

@docs Layout, new
@docs withParentSettings

@docs init, update, view, subscriptions

-}

import Effect exposing (Effect)
import View exposing (View)


type Layout parentSettings model msg contentMsg
    = Layout
        { init : () -> ( model, Effect msg )
        , update : msg -> model -> ( model, Effect msg )
        , subscriptions : model -> Sub msg
        , view : { model : model, toContentMsg : msg -> contentMsg, content : View contentMsg } -> View contentMsg
        , parentSettings : parentSettings
        }


new :
    { init : () -> ( model, Effect msg )
    , update : msg -> model -> ( model, Effect msg )
    , subscriptions : model -> Sub msg
    , view : { model : model, toContentMsg : msg -> contentMsg, content : View contentMsg } -> View contentMsg
    }
    -> Layout () model msg contentMsg
new options =
    Layout
        { init = options.init
        , update = options.update
        , subscriptions = options.subscriptions
        , view = options.view
        , parentSettings = ()
        }


withParentSettings :
    parentSettings
    -> Layout () model msg contentMsg
    -> Layout parentSettings model msg contentMsg
withParentSettings settings (Layout layout) =
    Layout
        { init = layout.init
        , update = layout.update
        , subscriptions = layout.subscriptions
        , view = layout.view
        , parentSettings = settings
        }


init : Layout parentSettings model msg contentMsg -> () -> ( model, Effect msg )
init (Layout layout) =
    layout.init


update : Layout parentSettings model msg contentMsg -> msg -> model -> ( model, Effect msg )
update (Layout layout) =
    layout.update


view :
    Layout parentSettings model msg contentMsg
    -> { model : model, toContentMsg : msg -> contentMsg, content : View contentMsg }
    -> View contentMsg
view (Layout layout) =
    layout.view


subscriptions : Layout parentSettings model msg contentMsg -> model -> Sub msg
subscriptions (Layout layout) =
    layout.subscriptions


parentSettings : Layout parentSettings model msg contentMsg -> parentSettings
parentSettings (Layout layout) =
    layout.parentSettings
