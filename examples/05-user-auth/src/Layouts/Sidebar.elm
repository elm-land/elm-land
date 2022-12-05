module Layouts.Sidebar exposing (Model, Msg, Settings, layout)

import Auth
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes exposing (alt, class, classList, src, style)
import Html.Events
import Layout exposing (Layout)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


type alias Settings =
    { title : String
    , user : Auth.User
    }


layout : Settings -> Shared.Model -> Route () -> Layout Model Msg mainMsg
layout settings shared route =
    Layout.new
        { init = init
        , update = update
        , view = view settings route
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
    = UserClickedSignOut


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserClickedSignOut ->
            ( model
            , Effect.signOut
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view :
    Settings
    -> Route ()
    ->
        { fromMsg : Msg -> mainMsg
        , content : View mainMsg
        , model : Model
        }
    -> View mainMsg
view settings route { fromMsg, model, content } =
    { title = content.title ++ " | My Cool App"
    , body =
        [ Html.div [ class "is-flex", style "height" "100vh" ]
            [ viewSidebar
                { user = settings.user
                , route = route
                }
                |> Html.map fromMsg
            , viewMainContent
                { title = settings.title
                , content = content
                }
            ]
        ]
    }


viewSidebar : { user : Auth.User, route : Route () } -> Html Msg
viewSidebar { user, route } =
    Html.aside
        [ class "is-flex is-flex-direction-column p-2"
        , style "min-width" "200px"
        , style "border-right" "solid 1px #eee"
        ]
        [ viewAppNameAndLogo
        , viewSidebarLinks route
        , viewSignOutButton user
        ]


viewAppNameAndLogo : Html msg
viewAppNameAndLogo =
    Html.div [ class "is-flex p-3" ]
        [ Html.figure []
            [ Html.img
                [ src "https://bulma.io/images/placeholders/24x24.png"
                , alt "My Cool App's logo"
                ]
                []
            ]
        , Html.span [ class "has-text-weight-bold pl-2" ]
            [ Html.text "My Cool App" ]
        ]


viewSidebarLinks : Route () -> Html msg
viewSidebarLinks route =
    let
        viewSidebarLink : ( String, Route.Path.Path ) -> Html msg
        viewSidebarLink ( label, path ) =
            Html.li []
                [ Html.a
                    [ Route.Path.href path
                    , classList
                        [ ( "is-active", route.path == path )
                        ]
                    ]
                    [ Html.text label ]
                ]
    in
    Html.div [ class "menu is-flex-grow-1" ]
        [ Html.ul [ class "menu-list" ]
            (List.map viewSidebarLink
                [ ( "Dashboard", Route.Path.Home_ )
                , ( "Settings", Route.Path.Settings )
                , ( "Profile", Route.Path.Profile_Me )
                ]
            )
        ]


viewSignOutButton : Auth.User -> Html Msg
viewSignOutButton user =
    Html.button
        [ class "button is-text is-fullwidth"
        , Html.Events.onClick UserClickedSignOut
        ]
        [ Html.div [ class "is-flex is-align-items-center" ]
            [ Html.figure [ class "image is-24x24" ]
                [ Html.img
                    [ class "is-rounded "
                    , src user.profileImageUrl
                    , alt user.name
                    ]
                    []
                ]
            , Html.span [ class "pl-2" ] [ Html.text "Sign out" ]
            ]
        ]


viewMainContent : { title : String, content : View msg } -> Html msg
viewMainContent { title, content } =
    Html.main_ [ class "is-flex is-flex-direction-column is-flex-grow-1" ]
        [ Html.section [ class "hero is-info" ]
            [ Html.div [ class "hero-body" ]
                [ Html.h1 [ class "title" ] [ Html.text title ]
                ]
            ]
        , Html.div [ class "p-4" ] content.body
        ]
