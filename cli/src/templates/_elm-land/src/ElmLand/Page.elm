module ElmLand.Page exposing
    ( Page
    , sandbox, element
    , init, update, view, subscriptions
    )

{-|

@docs Page
@docs sandbox, element
@docs init, update, view, subscriptions

-}

import Html exposing (Html)


type Page model msg
    = Internals
        { init : ( model, Cmd msg )
        , update : msg -> model -> ( model, Cmd msg )
        , subscriptions : model -> Sub msg
        , view : model -> Html msg
        }


sandbox :
    { init : model
    , update : msg -> model -> model
    , view : model -> Html msg
    }
    -> Page model msg
sandbox options =
    Internals
        { init = ( options.init, Cmd.none )
        , update = \msg model -> ( options.update msg model, Cmd.none )
        , subscriptions = \model -> Sub.none
        , view = options.view
        }


element :
    { init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : model -> Html msg
    }
    -> Page model msg
element options =
    Internals
        { init = options.init
        , update = options.update
        , subscriptions = options.subscriptions
        , view = options.view
        }


init : Page model msg -> ( model, Cmd msg )
init (Internals page) =
    page.init


update : Page model msg -> msg -> model -> ( model, Cmd msg )
update (Internals page) =
    page.update


view : Page model msg -> model -> Html msg
view (Internals page) =
    page.view


subscriptions : Page model msg -> model -> Sub msg
subscriptions (Internals page) =
    page.subscriptions
