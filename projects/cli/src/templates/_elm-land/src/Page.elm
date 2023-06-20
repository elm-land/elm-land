module Page exposing
    ( Page, new
    , sandbox, element
    , withLayout
    , withOnUrlChanged, withOnQueryParameterChanged, withOnHashChanged
    , init, update, view, subscriptions, layout, toUrlMessages
    )

{-|

@docs Page, new
@docs sandbox, element
@docs withLayout
@docs withOnUrlChanged, withOnQueryParameterChanged, withOnHashChanged

@docs init, update, view, subscriptions, layout, toUrlMessages

-}

import Dict exposing (Dict)
import Effect exposing (Effect)
import Layouts exposing (Layout)
import Route exposing (Route)
import View exposing (View)


type Page model msg
    = Page
        { init : () -> ( model, Effect msg )
        , update : msg -> model -> ( model, Effect msg )
        , subscriptions : model -> Sub msg
        , view : model -> View msg
        , toLayout : Maybe (model -> Layout msg)
        , onUrlChanged : Maybe ({ from : Route (), to : Route () } -> msg)
        , onHashChanged : Maybe ({ from : Maybe String, to : Maybe String } -> msg)
        , onQueryParameterChangedDict : Dict String ({ from : Maybe String, to : Maybe String } -> msg)
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
        , toLayout = Nothing
        , onUrlChanged = Nothing
        , onHashChanged = Nothing
        , onQueryParameterChangedDict = Dict.empty
        }


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
        , toLayout = Nothing
        , onUrlChanged = Nothing
        , onHashChanged = Nothing
        , onQueryParameterChangedDict = Dict.empty
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
        , toLayout = Nothing
        , onUrlChanged = Nothing
        , onHashChanged = Nothing
        , onQueryParameterChangedDict = Dict.empty
        }



-- LAYOUTS


withLayout : (model -> Layout msg) -> Page model msg -> Page model msg
withLayout toLayout_ (Page page) =
    Page { page | toLayout = Just toLayout_ }



-- URL CHANGES


withOnUrlChanged :
    ({ from : Route ()
     , to : Route ()
     }
     -> msg
    )
    -> Page model msg
    -> Page model msg
withOnUrlChanged onChange (Page page) =
    Page { page | onUrlChanged = Just onChange }


withOnHashChanged :
    ({ from : Maybe String
     , to : Maybe String
     }
     -> msg
    )
    -> Page model msg
    -> Page model msg
withOnHashChanged onChange (Page page) =
    Page { page | onHashChanged = Just onChange }


withOnQueryParameterChanged :
    { key : String
    , onChange :
        { from : Maybe String
        , to : Maybe String
        }
        -> msg
    }
    -> Page model msg
    -> Page model msg
withOnQueryParameterChanged { key, onChange } (Page page) =
    Page { page | onQueryParameterChangedDict = Dict.insert key onChange page.onQueryParameterChangedDict }



-- USED INTERNALLY BY ELM LAND


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


layout : model -> Page model msg -> Maybe (Layouts.Layout msg)
layout model (Page page) =
    Maybe.map (\fn -> fn model) page.toLayout


toUrlMessages : { from : Route (), to : Route () } -> Page model msg -> List msg
toUrlMessages routes (Page page) =
    List.concat
        [ case page.onUrlChanged of
            Just onUrlChanged ->
                [ onUrlChanged routes ]

            Nothing ->
                []
        , case page.onHashChanged of
            Just onHashChanged ->
                if routes.from.hash == routes.to.hash then
                    []

                else
                    [ onHashChanged
                        { from = routes.from.hash
                        , to = routes.to.hash
                        }
                    ]

            Nothing ->
                []
        , let
            toQueryParameterMessage :
                ( String
                , { from : Maybe String, to : Maybe String } -> msg
                )
                -> Maybe msg
            toQueryParameterMessage ( key, onChange ) =
                let
                    from =
                        Dict.get key routes.from.query

                    to =
                        Dict.get key routes.to.query
                in
                if from == to then
                    Nothing

                else
                    Just (onChange { from = from, to = to })
          in
          Dict.toList page.onQueryParameterChangedDict
            |> List.filterMap toQueryParameterMessage
        ]
