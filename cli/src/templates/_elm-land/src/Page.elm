module Page exposing
    ( Page, new
    , sandbox, element
    , init, update, view, subscriptions
    )

{-|

@docs Page, new
@docs sandbox, element
@docs init, update, view, subscriptions

-}

import Effect exposing (Effect)
import View exposing (View)


type Page model msg
    = Internals
        { init : () -> ( model, Effect msg )
        , update : msg -> model -> ( model, Effect msg )
        , subscriptions : model -> Sub msg
        , view : model -> View msg
        }


new : 
    { init : () -> ( model, Effect msg )
    , update : msg -> model -> ( model, Effect msg )
    , subscriptions : model -> Sub msg
    , view : model -> View msg
    }
    -> Page model msg
new options =
    Internals options


sandbox :
    { init : model
    , update : msg -> model -> model
    , view : model -> View msg
    }
    -> Page model msg
sandbox options =
    Internals
        { init = \_ -> ( options.init, Effect.none )
        , update = \msg model -> ( options.update msg model, Effect.none )
        , subscriptions = \model -> Sub.none
        , view = options.view
        }


element :
    { init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : model -> View msg
    }
    -> Page model msg
element options =
    Internals
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
        }


init : Page model msg -> () -> ( model, Effect msg )
init (Internals page) =
    page.init


update : Page model msg -> msg -> model -> ( model, Effect msg )
update (Internals page) =
    page.update


view : Page model msg -> model -> View msg
view (Internals page) =
    page.view


subscriptions : Page model msg -> model -> Sub msg
subscriptions (Internals page) =
    page.subscriptions
