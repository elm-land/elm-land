module Page exposing
    ( Page, new
    , sandbox, element
    , withLayout
    , init, update, view, subscriptions, layout
    )

{-|

@docs Page, new
@docs sandbox, element
@docs withLayout
@docs init, update, view, subscriptions, layout

-}

import Effect exposing (Effect)
import Layouts exposing (Layout)
import View exposing (View)


type Page model msg
    = Page
        { init : () -> ( model, Effect msg )
        , update : msg -> model -> ( model, Effect msg )
        , subscriptions : model -> Sub msg
        , view : model -> View msg
        , layout : Maybe Layout
        }


new :
    { init : () -> ( model, Effect msg )
    , update : msg -> model -> ( model, Effect msg )
    , subscriptions : model -> Sub msg
    , view : model -> View msg
    }
    -> Page model msg
new options =
    Page
        { init = options.init
        , update = options.update
        , subscriptions = options.subscriptions
        , view = options.view
        , layout = Nothing
        }


withLayout : Layout -> Page model msg -> Page model msg
withLayout layout_ (Page page) =
    Page { page | layout = Just layout_ }


sandbox :
    { init : model
    , update : msg -> model -> model
    , view : model -> View msg
    }
    -> Page model msg
sandbox options =
    Page
        { init = \_ -> ( options.init, Effect.none )
        , update = \msg model -> ( options.update msg model, Effect.none )
        , subscriptions = \_ -> Sub.none
        , view = options.view
        , layout = Nothing
        }


element :
    { init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : model -> View msg
    }
    -> Page model msg
element options =
    Page
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
        , layout = Nothing
        }


init : Page model msg -> () -> ( model, Effect msg )
init (Page page) =
    page.init


update : Page model msg -> msg -> model -> ( model, Effect msg )
update (Page page) =
    page.update


view : Page model msg -> model -> View msg
view (Page page) =
    page.view


subscriptions : Page model msg -> model -> Sub msg
subscriptions (Page page) =
    page.subscriptions


layout : Page model msg -> Maybe Layouts.Layout
layout (Page page) =
    page.layout
