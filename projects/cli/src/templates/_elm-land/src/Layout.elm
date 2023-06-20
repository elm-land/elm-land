module Layout exposing
    ( Layout, new
    , withParentProps
    , withOnUrlChanged, withOnQueryParameterChanged, withOnHashChanged
    , init, update, view, subscriptions
    , parentProps, toUrlMessages
    )

{-|

@docs Layout, new
@docs withParentProps
@docs withOnUrlChanged, withOnQueryParameterChanged, withOnHashChanged

@docs init, update, view, subscriptions
@docs parentProps, toUrlMessages

-}

import Dict exposing (Dict)
import Effect exposing (Effect)
import Route exposing (Route)
import View exposing (View)


type Layout parentProps model msg contentMsg
    = Layout
        { init : () -> ( model, Effect msg )
        , update : msg -> model -> ( model, Effect msg )
        , subscriptions : model -> Sub msg
        , view : { model : model, toContentMsg : msg -> contentMsg, content : View contentMsg } -> View contentMsg
        , parentProps : parentProps
        , onUrlChanged : Maybe ({ from : Route (), to : Route () } -> msg)
        , onHashChanged : Maybe ({ from : Maybe String, to : Maybe String } -> msg)
        , onQueryParameterChangedDict : Dict String ({ from : Maybe String, to : Maybe String } -> msg)
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
        , onUrlChanged = Nothing
        , onHashChanged = Nothing
        , onQueryParameterChangedDict = Dict.empty
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
        , onUrlChanged = layout.onUrlChanged
        , onHashChanged = layout.onHashChanged
        , onQueryParameterChangedDict = layout.onQueryParameterChangedDict
        }



-- URL CHANGES


withOnUrlChanged :
    ({ from : Route ()
     , to : Route ()
     }
     -> msg
    )
    -> Layout parentProps model msg contentMsg
    -> Layout parentProps model msg contentMsg
withOnUrlChanged onChange (Layout layout) =
    Layout { layout | onUrlChanged = Just onChange }


withOnHashChanged :
    ({ from : Maybe String
     , to : Maybe String
     }
     -> msg
    )
    -> Layout parentProps model msg contentMsg
    -> Layout parentProps model msg contentMsg
withOnHashChanged onChange (Layout layout) =
    Layout { layout | onHashChanged = Just onChange }


withOnQueryParameterChanged :
    { key : String
    , onChange :
        { from : Maybe String
        , to : Maybe String
        }
        -> msg
    }
    -> Layout parentProps model msg contentMsg
    -> Layout parentProps model msg contentMsg
withOnQueryParameterChanged { key, onChange } (Layout layout) =
    Layout { layout | onQueryParameterChangedDict = Dict.insert key onChange layout.onQueryParameterChangedDict }


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


toUrlMessages :
    { from : Route (), to : Route () }
    -> Layout parentProps model msg contentMsg
    -> List msg
toUrlMessages routes (Layout layout) =
    List.concat
        [ case layout.onUrlChanged of
            Just onUrlChanged ->
                [ onUrlChanged routes ]

            Nothing ->
                []
        , case layout.onHashChanged of
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
          Dict.toList layout.onQueryParameterChangedDict
            |> List.filterMap toQueryParameterMessage
        ]
