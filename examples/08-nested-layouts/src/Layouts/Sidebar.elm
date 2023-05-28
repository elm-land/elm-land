module Layouts.Sidebar exposing (Model, Msg, Settings, layout)

import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes exposing (style)
import Layout exposing (Layout)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


type alias Settings =
    {}


layout : Settings -> Shared.Model -> Route () -> Layout () Model Msg contentMsg
layout settings shared route =
    Layout.new
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init _ =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model
            , Effect.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view { toContentMsg, model, content } =
    { title = content.title
    , body =
        [ Html.node "style"
            []
            [ Html.text """
            html, body { height: 100%; }
            body {
              margin: 0;
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
            }
            * { box-sizing: border-box; color: inherit; }
            """ ]
        , Html.div [ style "display" "flex", style "height" "100%" ]
            [ Html.aside
                [ style "display" "flex"
                , style "flex-direction" "column"
                , style "gap" "2rem"
                , style "background" "#333"
                , style "color" "white"
                , style "padding" "2rem"
                , style "width" "240px"
                , style "justify-content" "space-between"
                ]
                [ Html.div
                    [ style "display" "flex"
                    , style "flex-direction" "column"
                    , style "gap" "2rem"
                    ]
                    [ Html.strong [ style "font-size" "1.5rem" ] [ Html.text "MyCoolApp" ]
                    , [ ( "Dashboard", Route.Path.Home_ )
                      , ( "Settings", Route.Path.Settings )
                      , ( "Account", Route.Path.Settings_Account )
                      , ( "Notifications", Route.Path.Settings_Notifications )
                      ]
                        |> List.map viewSidebarLink
                        |> Html.div
                            [ style "display" "flex"
                            , style "flex-direction" "column"
                            , style "gap" "1rem"
                            ]
                    ]
                , Html.a [ Route.Path.href Route.Path.SignIn ]
                    [ Html.text "Sign out"
                    ]
                ]
            , Html.main_ [ style "flex" "1" ] content.body
            ]
        ]
    }


viewSidebarLink : ( String, Route.Path.Path ) -> Html msg
viewSidebarLink ( label, routePath ) =
    Html.a
        [ Route.Path.href routePath ]
        [ Html.text label ]
