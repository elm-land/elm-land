module Pages.SignIn exposing (Model, Msg, page)

import Api.Me
import Api.SignIn
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Http
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
    { email : String
    , password : String
    , isSubmittingForm : Bool
    , errors : List Api.SignIn.Error
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { email = ""
      , password = ""
      , isSubmittingForm = False
      , errors = []
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = UserUpdatedInput Field String
    | UserSubmittedForm
    | SignInApiResponded (Result (List Api.SignIn.Error) Api.SignIn.Data)
    | MeApiResponded String (Result Http.Error Api.Me.User)


type Field
    = Email
    | Password


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserUpdatedInput Email value ->
            ( { model | email = value }
            , Effect.none
            )

        UserUpdatedInput Password value ->
            ( { model | password = value }
            , Effect.none
            )

        UserSubmittedForm ->
            ( { model
                | isSubmittingForm = True
                , errors = []
              }
            , Api.SignIn.post
                { onResponse = SignInApiResponded
                , email = model.email
                , password = model.password
                }
            )

        SignInApiResponded (Ok { token }) ->
            ( model
            , Api.Me.get
                { token = token
                , onResponse = MeApiResponded token
                }
            )

        SignInApiResponded (Err errors) ->
            ( { model
                | isSubmittingForm = False
                , errors = errors
              }
            , Effect.none
            )

        MeApiResponded token (Ok user) ->
            ( { model | isSubmittingForm = False }
            , Effect.signIn
                { id = user.id
                , name = user.name
                , profileImageUrl = user.profileImageUrl
                , email = user.email
                , token = token
                }
            )

        MeApiResponded _ (Err httpError) ->
            let
                error : Api.SignIn.Error
                error =
                    { field = Nothing
                    , message = "User couldn't be found"
                    }
            in
            ( { model
                | isSubmittingForm = False
                , errors = [ error ]
              }
            , Effect.signOut
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Sign in"
    , body =
        [ viewPage model
        ]
    }


viewPage : Model -> Html Msg
viewPage model =
    Html.div [ Attr.class "columns is-mobile is-centered" ]
        [ Html.div [ Attr.class "column is-narrow" ]
            [ Html.div [ Attr.class "section" ]
                [ Html.h1 [ Attr.class "title" ] [ Html.text "Sign in" ]
                , viewForm model
                ]
            ]
        ]


viewForm : Model -> Html Msg
viewForm model =
    Html.form [ Attr.class "box", Html.Events.onSubmit UserSubmittedForm ]
        [ viewFormInput
            { field = Email
            , value = model.email
            , error = findFieldError "email" model
            }
        , viewFormInput
            { field = Password
            , value = model.password
            , error = findFieldError "password" model
            }
        , viewFormControls model
        ]


viewFormInput :
    { field : Field
    , value : String
    , error : Maybe Api.SignIn.Error
    }
    -> Html Msg
viewFormInput options =
    Html.div [ Attr.class "field" ]
        [ Html.label [ Attr.class "label" ] [ Html.text (fromFieldToLabel options.field) ]
        , Html.div [ Attr.class "control" ]
            [ Html.input
                [ Attr.class "input"
                , Attr.classList
                    [ ( "is-danger", options.error /= Nothing )
                    ]
                , Attr.type_ (fromFieldToInputType options.field)
                , Attr.autocomplete True
                , Attr.value options.value
                , Html.Events.onInput (UserUpdatedInput options.field)
                ]
                []
            ]
        , case options.error of
            Just error ->
                Html.p
                    [ Attr.class "help is-danger" ]
                    [ Html.text error.message ]

            Nothing ->
                Html.text ""
        ]


fromFieldToLabel : Field -> String
fromFieldToLabel field =
    case field of
        Email ->
            "Email address"

        Password ->
            "Password"


fromFieldToInputType : Field -> String
fromFieldToInputType field =
    case field of
        Email ->
            "email"

        Password ->
            "password"


viewFormControls : Model -> Html Msg
viewFormControls model =
    Html.div []
        [ Html.div [ Attr.class "field is-grouped is-grouped-right" ]
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
        , case findFormError model of
            Just error ->
                Html.p
                    [ Attr.class "help content is-danger" ]
                    [ Html.text error.message ]

            Nothing ->
                Html.text ""
        ]



-- ERRORS


findFieldError : String -> Model -> Maybe Api.SignIn.Error
findFieldError field model =
    let
        hasMatchingField : Api.SignIn.Error -> Bool
        hasMatchingField error =
            error.field == Just field
    in
    model.errors
        |> List.filter hasMatchingField
        |> List.head


findFormError : Model -> Maybe Api.SignIn.Error
findFormError model =
    let
        doesntHaveField : Api.SignIn.Error -> Bool
        doesntHaveField error =
            error.field == Nothing
    in
    model.errors
        |> List.filter doesntHaveField
        |> List.head
