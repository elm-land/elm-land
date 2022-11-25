module Pages.SignIn exposing (Model, Msg, page)

import Api.Me
import Api.SignIn
import Auth
import Dict
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Http
import Json.Decode
import Json.Encode
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view route
        }



-- INIT


type alias Model =
    { email : String
    , password : String
    , errors : List Api.SignIn.FormError
    , isSubmittingForm : Bool
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { email = ""
      , password = ""
      , errors = []
      , isSubmittingForm = False
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = UserUpdatedInput Api.SignIn.Field String
    | UserSubmittedForm
    | SignInApiResponded (Result (List Api.SignIn.FormError) String)
    | ApiMeResponded (Result Http.Error Auth.User)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserUpdatedInput Api.SignIn.Email value ->
            ( { model
                | email = value
                , errors = clearErrorsFor Api.SignIn.Email model.errors
              }
            , Effect.none
            )

        UserUpdatedInput Api.SignIn.Password value ->
            ( { model
                | password = value
                , errors = clearErrorsFor Api.SignIn.Password model.errors
              }
            , Effect.none
            )

        UserSubmittedForm ->
            ( { model
                | isSubmittingForm = True
                , errors = []
              }
            , Api.SignIn.post
                { email = model.email
                , password = model.password
                , onResponse = SignInApiResponded
                }
            )

        SignInApiResponded (Err formErrors) ->
            ( { model | errors = formErrors, isSubmittingForm = False }
            , Effect.none
            )

        SignInApiResponded (Ok token) ->
            ( model
            , Effect.batch
                [ Effect.saveUserToken token
                , Api.Me.get
                    { token = token
                    , onResponse = ApiMeResponded
                    }
                ]
            )

        ApiMeResponded result ->
            ( model
            , Effect.signIn result
            )


clearErrorsFor : Api.SignIn.Field -> List Api.SignIn.FormError -> List Api.SignIn.FormError
clearErrorsFor field errors =
    errors
        |> List.filter (\error -> error.field /= Just field)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Route () -> Model -> View Msg
view route model =
    { title = "Sign in"
    , body =
        [ viewPage route model
        ]
    }


viewPage : Route () -> Model -> Html Msg
viewPage route model =
    Html.div [ Attr.class "is-flex hero is-light is-align-items-center is-justify-content-center", Attr.style "height" "100vh" ]
        [ Html.div [ Attr.class "p-4 pb-6" ]
            [ Html.h1 [ Attr.class "title" ] [ Html.text "Sign in" ]
            , case Dict.get "from" route.query of
                Just originalUrl ->
                    Html.h2 [ Attr.class "subtitle is-danger is-size-6" ]
                        [ Html.text ("Redirected from " ++ originalUrl) ]

                _ ->
                    Html.text ""
            , viewForm model
            ]
        ]


viewForm : Model -> Html Msg
viewForm model =
    let
        firstErrorForField : Api.SignIn.Field -> Maybe String
        firstErrorForField field =
            case List.filter (\err -> err.field == Just field) model.errors of
                [] ->
                    Nothing

                error :: _ ->
                    Just error.message

        viewFormInput : { field : Api.SignIn.Field, value : String } -> Html Msg
        viewFormInput options =
            let
                error : Maybe String
                error =
                    firstErrorForField options.field
            in
            Html.div [ Attr.class "field" ]
                [ Html.label [ Attr.class "label" ] [ Html.text (fromFieldToLabel options.field) ]
                , Html.div [ Attr.class "control" ]
                    [ Html.input
                        [ Attr.class "input"
                        , Attr.classList [ ( "is-danger", error /= Nothing ) ]
                        , Attr.disabled model.isSubmittingForm
                        , Attr.type_ (fromFieldToInputType options.field)
                        , Attr.value options.value
                        , Html.Events.onInput (UserUpdatedInput options.field)
                        ]
                        []
                    ]
                , case error of
                    Just message ->
                        Html.p [ Attr.class "help is-danger" ] [ Html.text message ]

                    Nothing ->
                        Html.text ""
                ]
    in
    Html.form [ Attr.class "box", Html.Events.onSubmit UserSubmittedForm ]
        [ viewFormInput
            { field = Api.SignIn.Email
            , value = model.email
            }
        , viewFormInput
            { field = Api.SignIn.Password
            , value = model.password
            }
        , viewFormControls model
        ]


fromFieldToLabel : Api.SignIn.Field -> String
fromFieldToLabel field =
    case field of
        Api.SignIn.Email ->
            "Email address"

        Api.SignIn.Password ->
            "Password"


fromFieldToInputType : Api.SignIn.Field -> String
fromFieldToInputType field =
    case field of
        Api.SignIn.Email ->
            "email"

        Api.SignIn.Password ->
            "password"


viewFormControls : Model -> Html Msg
viewFormControls model =
    Html.div []
        [ Html.div [ Attr.class "field is-grouped" ]
            [ Html.div
                [ Attr.class "control" ]
                [ Html.button
                    [ Attr.class "button is-link"
                    , Attr.disabled model.isSubmittingForm
                    , Attr.classList [ ( "is-loading", model.isSubmittingForm ) ]
                    ]
                    [ Html.text "Sign in" ]
                ]
            ]
        , case toFormError model.errors of
            Just reason ->
                Html.p [ Attr.class "help content is-danger" ] [ Html.text reason ]

            Nothing ->
                Html.text ""
        ]


toFormError : List Api.SignIn.FormError -> Maybe String
toFormError formErrors =
    let
        maybeFirstError : Maybe Api.SignIn.FormError
        maybeFirstError =
            formErrors
                |> List.filter (\error -> error.field == Nothing)
                |> List.head
    in
    case maybeFirstError of
        Nothing ->
            Nothing

        Just firstError ->
            Just firstError.message
