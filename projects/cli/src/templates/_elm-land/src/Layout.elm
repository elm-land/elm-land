module Layout exposing
    ( Layout, new
    , withParentProps
    , init, update, view, subscriptions
    , parentProps
    )

{-|

@docs Layout, new
@docs withParentProps

@docs init, update, view, subscriptions
@docs parentProps

-}

import Effect exposing (Effect)
import View exposing (View)


type Layout parentProps model msg contentMsg
    = Layout
        { init : () -> ( model, Effect msg )
        , update : msg -> model -> ( model, Effect msg )
        , subscriptions : model -> Sub msg
        , view : { model : model, toContentMsg : msg -> contentMsg, content : View contentMsg } -> View contentMsg
        , parentProps : parentProps
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
        , parentProps = ()
        }


withParentProps :
    parentProps
    -> Layout () model msg contentMsg
    -> Layout parentProps model msg contentMsg
withParentProps props (Layout layout) =
    Layout
        { init = layout.init
        , update = layout.update
        , subscriptions = layout.subscriptions
        , view = layout.view
        , parentProps = props
        }


init : Layout parentProps model msg contentMsg -> () -> ( model, Effect msg )
init (Layout layout) =
    layout.init


update : Layout parentProps model msg contentMsg -> msg -> model -> ( model, Effect msg )
update (Layout layout) =
    layout.update


view :
    Layout parentProps model msg contentMsg
    -> { model : model, toContentMsg : msg -> contentMsg, content : View contentMsg }
    -> View contentMsg
view (Layout layout) =
    layout.view


subscriptions : Layout parentProps model msg contentMsg -> model -> Sub msg
subscriptions (Layout layout) =
    layout.subscriptions


parentProps : Layout parentProps model msg contentMsg -> parentProps
parentProps (Layout layout) =
    layout.parentProps
