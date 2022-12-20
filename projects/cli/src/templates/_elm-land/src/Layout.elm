module Layout exposing
    ( Layout, new
    , sandbox, element
    , init, update, view, subscriptions
    )

{-|

@docs Layout, new
@docs sandbox, element

@docs init, update, view, subscriptions

-}

import Effect exposing (Effect)
import View exposing (View)


type Layout model msg mainMsg
    = Layout
        { init : () -> ( model, Effect msg )
        , update : msg -> model -> ( model, Effect msg )
        , subscriptions : model -> Sub msg
        , view : { model : model, fromMsg : msg -> mainMsg, content : View mainMsg } -> View mainMsg
        }


new :
    { init : () -> ( model, Effect msg )
    , update : msg -> model -> ( model, Effect msg )
    , subscriptions : model -> Sub msg
    , view : { model : model, fromMsg : msg -> mainMsg, content : View mainMsg } -> View mainMsg
    }
    -> Layout model msg mainMsg
new options =
    Layout
        { init = options.init
        , update = options.update
        , subscriptions = options.subscriptions
        , view = options.view
        }


sandbox :
    { init : model
    , update : msg -> model -> model
    , view : { model : model, fromMsg : msg -> mainMsg, content : View mainMsg } -> View mainMsg
    }
    -> Layout model msg mainMsg
sandbox options =
    Layout
        { init = \_ -> ( options.init, Effect.none )
        , update = \msg model -> ( options.update msg model, Effect.none )
        , subscriptions = \model -> Sub.none
        , view = options.view
        }


element :
    { init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : { model : model, fromMsg : msg -> mainMsg, content : View mainMsg } -> View mainMsg
    }
    -> Layout model msg mainMsg
element options =
    Layout
        { init =
            \_ ->
                options.init
                    |> Tuple.mapSecond Effect.sendCmd
        , update =
            \msg model ->
                options.update msg model
                    |> Tuple.mapSecond Effect.sendCmd
        , subscriptions = options.subscriptions
        , view = options.view
        }


init : Layout model msg mainMsg -> () -> ( model, Effect msg )
init (Layout page) =
    page.init


update : Layout model msg mainMsg -> msg -> model -> ( model, Effect msg )
update (Layout page) =
    page.update


view :
    Layout model msg mainMsg
    -> { model : model, fromMsg : msg -> mainMsg, content : View mainMsg }
    -> View mainMsg
view (Layout page) =
    page.view


subscriptions : Layout model msg mainMsg -> model -> Sub msg
subscriptions (Layout page) =
    page.subscriptions
