module Pages.SignIn exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { username : String
    , password : String
    , isSigningIn : Bool
    , usernameError : Maybe String
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { username = ""
      , password = ""
      , isSigningIn = False
      , usernameError = Nothing
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = UserChangedUsernameField String
    | UserChangedPasswordField String
    | UserSubmittedSignInForm


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserChangedUsernameField username ->
            ( { model | username = username }
            , Effect.none
            )

        UserChangedPasswordField password ->
            ( { model | password = password }
            , Effect.none
            )

        UserSubmittedSignInForm ->
            if String.isEmpty (String.trim model.username) then
                ( { model | usernameError = Just "Username is required" }
                , Effect.none
                )

            else
                ( { model | isSigningIn = True }
                , Effect.signInAs { username = model.username }
                )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Sign in | Twooter"
    , body =
        [ Html.div
            [ Attr.style "height" "100%"
            , Attr.class "is-flex is-flex-direction-column is-align-items-center is-justify-content-center"
            ]
            [ Html.div [ Attr.class "card p-5" ]
                [ Html.h1 [ Attr.class "title is-3 has-text-centered" ] [ Html.text "Twooter" ]
                , Html.h2 [ Attr.class "subtitle is-6 has-text-centered" ] [ Html.text "Get twootin'" ]
                , Html.form
                    [ Html.Events.onSubmit UserSubmittedSignInForm
                    , Attr.class "fields pt-2"
                    ]
                    [ viewUsernameField model
                    , viewPasswordField model.password
                    , viewSignInButton model.isSigningIn
                    ]
                ]
            ]
        ]
    }


viewUsernameField : Model -> Html Msg
viewUsernameField model =
    Html.div [ Attr.class "field" ]
        [ Html.label [ Attr.class "label", Attr.for "username" ] [ Html.text "Username" ]
        , Html.div [ Attr.class "control" ]
            [ Html.input
                [ Html.Events.onInput UserChangedUsernameField
                , Attr.id "username"
                , Attr.class "input"
                , Attr.autocomplete False
                , Attr.classList [ ( "is-danger", model.usernameError /= Nothing ) ]
                , Attr.type_ "text"
                , Attr.value model.username
                ]
                []
            ]
        , case model.usernameError of
            Just reason ->
                Html.p [ Attr.class "help is-danger" ] [ Html.text reason ]

            Nothing ->
                Html.text ""
        ]


viewPasswordField : String -> Html Msg
viewPasswordField value =
    Html.div [ Attr.class "field" ]
        [ Html.label [ Attr.class "label", Attr.for "password" ] [ Html.text "Password" ]
        , Html.div [ Attr.class "control" ]
            [ Html.input
                [ Html.Events.onInput UserChangedPasswordField
                , Attr.id "password"
                , Attr.autocomplete False
                , Attr.class "input"
                , Attr.type_ "password"
                , Attr.value value
                ]
                []
            ]
        ]


viewSignInButton : Bool -> Html Msg
viewSignInButton isSigningIn =
    Html.div [ Attr.class "button-group pt-4" ]
        [ Html.button
            [ Attr.class "button is-link"
            , Attr.disabled isSigningIn
            , Attr.classList
                [ ( "is-loading", isSigningIn )
                ]
            , Attr.type_ "submit"
            ]
            [ Html.text "Sign in" ]
        ]
