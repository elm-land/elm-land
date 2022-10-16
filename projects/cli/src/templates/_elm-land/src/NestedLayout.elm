module NestedLayout exposing
    ( NestedLayout, new
    , sandbox, element
    , init, update, view, subscriptions
    )

{-|

@docs NestedLayout, new
@docs sandbox, element

@docs init, update, view, subscriptions

-}

import Effect exposing (Effect)
import View exposing (View)


type NestedLayout parentSettings model msg mainMsg
    = NestedLayout
        { init : () -> ( model, Effect msg )
        , update : msg -> model -> ( model, Effect msg )
        , subscriptions : model -> Sub msg
        , view : { model : model, toMainMsg : msg -> mainMsg, content : View mainMsg } -> View mainMsg
        , parentSettings : parentSettings
        }


new :
    { init : () -> ( model, Effect msg )
    , update : msg -> model -> ( model, Effect msg )
    , subscriptions : model -> Sub msg
    , view : { model : model, toMainMsg : msg -> mainMsg, content : View mainMsg } -> View mainMsg
    , parentSettings : parentSettings
    }
    -> NestedLayout parentSettings model msg mainMsg
new options =
    NestedLayout
        { init = options.init
        , update = options.update
        , subscriptions = options.subscriptions
        , view = options.view
        , parentSettings = options.parentSettings
        }


sandbox :
    { init : model
    , update : msg -> model -> model
    , view : { model : model, toMainMsg : msg -> mainMsg, content : View mainMsg } -> View mainMsg
    , parentSettings : parentSettings
    }
    -> NestedLayout parentSettings model msg mainMsg
sandbox options =
    NestedLayout
        { init = \_ -> ( options.init, Effect.none )
        , update = \msg model -> ( options.update msg model, Effect.none )
        , subscriptions = \model -> Sub.none
        , view = options.view
        , parentSettings = options.parentSettings
        }


element :
    { init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : { model : model, toMainMsg : msg -> mainMsg, content : View mainMsg } -> View mainMsg
    , parentSettings : parentSettings
    }
    -> NestedLayout parentSettings model msg mainMsg
element options =
    NestedLayout
        { init =
            \_ ->
                options.init
                    |> Tuple.mapSecond Effect.fromCmd
        , update =
            \msg model ->
                options.update msg model
                    |> Tuple.mapSecond Effect.fromCmd
        , subscriptions = options.subscriptions
        , view = options.view
        , parentSettings = options.parentSettings
        }


init : NestedLayout parentSettings model msg mainMsg -> () -> ( model, Effect msg )
init (NestedLayout page) =
    page.init


update : NestedLayout parentSettings model msg mainMsg -> msg -> model -> ( model, Effect msg )
update (NestedLayout page) =
    page.update


view :
    NestedLayout parentSettings model msg mainMsg
    -> { model : model, toMainMsg : msg -> mainMsg, content : View mainMsg }
    -> View mainMsg
view (NestedLayout page) =
    page.view


subscriptions : NestedLayout parentSettings model msg mainMsg -> model -> Sub msg
subscriptions (NestedLayout page) =
    page.subscriptions


parentSettings : NestedLayout parentSettings model msg mainMsg -> parentSettings
parentSettings (NestedLayout page) =
    page.parentSettings
