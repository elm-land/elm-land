module Pages.SignIn exposing (Model, Msg, page)

import Api.User
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
page shared req =
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
    , errors : List FormError
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
    = UserUpdatedInput Field String
    | UserSubmittedForm
    | SignInApiResponded (Result (List FormError) String)
    | UserApiResponded (Result Http.Error Api.User.User)


type Field
    = Email
    | Password


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserUpdatedInput Email value ->
            ( { model
                | email = value
                , errors = clearErrorsFor Email model.errors
              }
            , Effect.none
            )

        UserUpdatedInput Password value ->
            ( { model
                | password = value
                , errors = clearErrorsFor Password model.errors
              }
            , Effect.none
            )

        UserSubmittedForm ->
            ( { model
                | isSubmittingForm = True
                , errors = []
              }
            , Effect.fromCmd
                (callSignInApi
                    { email = model.email
                    , password = model.password
                    }
                )
            )

        SignInApiResponded (Err formErrors) ->
            ( { model | errors = formErrors, isSubmittingForm = False }
            , Effect.none
            )

        SignInApiResponded (Ok token) ->
            ( model
            , Effect.batch
                [ Effect.save
                    { key = "token"
                    , value = Json.Encode.string token
                    }
                , Effect.fromCmd
                    (Api.User.getCurrentUser
                        { token = token
                        , onResponse = UserApiResponded
                        }
                    )
                ]
            )

        UserApiResponded result ->
            ( model
            , Effect.fromEffectMsg (Effect.SignInPageSignedInUser result)
            )


clearErrorsFor : Field -> List FormError -> List FormError
clearErrorsFor field errors =
    errors
        |> List.filter (\error -> error.field /= Just field)


callSignInApi : { email : String, password : String } -> Cmd Msg
callSignInApi form =
    let
        json : Json.Encode.Value
        json =
            Json.Encode.object
                [ ( "email", Json.Encode.string form.email )
                , ( "password", Json.Encode.string form.password )
                ]

        tokenDecoder : Json.Decode.Decoder String
        tokenDecoder =
            Json.Decode.field "token" Json.Decode.string
    in
    Http.post
        { url = "http://localhost:5000/api/sign-in"
        , body = Http.jsonBody json
        , expect = expectApiResponse SignInApiResponded tokenDecoder
        }


expectApiResponse :
    (Result (List FormError) value -> msg)
    -> Json.Decode.Decoder value
    -> Http.Expect msg
expectApiResponse toMsg decoder =
    Http.expectStringResponse toMsg (toFormApiResult decoder)


type alias FormError =
    { field : Maybe Field
    , message : String
    }


formErrorsDecoder : Json.Decode.Decoder (List FormError)
formErrorsDecoder =
    let
        formErrorDecoder : Json.Decode.Decoder FormError
        formErrorDecoder =
            Json.Decode.map2 FormError
                (Json.Decode.field "field" Json.Decode.string
                    |> Json.Decode.map fromStringToMaybeField
                )
                (Json.Decode.field "message" Json.Decode.string)

        fromStringToMaybeField : String -> Maybe Field
        fromStringToMaybeField field =
            case field of
                "email" ->
                    Just Email

                "password" ->
                    Just Password

                _ ->
                    Nothing
    in
    Json.Decode.field "errors" (Json.Decode.list formErrorDecoder)


toFormApiResult : Json.Decode.Decoder value -> Http.Response String -> Result (List FormError) value
toFormApiResult decoder response =
    case response of
        Http.BadUrl_ _ ->
            Err [ { field = Nothing, message = "Unexpected URL format" } ]

        Http.Timeout_ ->
            Err [ { field = Nothing, message = "Server did not respond" } ]

        Http.NetworkError_ ->
            Err [ { field = Nothing, message = "Could not connect to server" } ]

        Http.BadStatus_ { statusCode } rawJson ->
            case Json.Decode.decodeString formErrorsDecoder rawJson of
                Ok errors ->
                    Err errors

                Err _ ->
                    Err [ { field = Nothing, message = "Received status code " ++ String.fromInt statusCode } ]

        Http.GoodStatus_ _ rawJson ->
            case Json.Decode.decodeString decoder rawJson of
                Ok value ->
                    Ok value

                Err _ ->
                    Err [ { field = Nothing, message = "Received unexpected API response" } ]



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
    let
        firstErrorForField : Field -> Maybe String
        firstErrorForField field =
            case List.filter (\err -> err.field == Just field) model.errors of
                [] ->
                    Nothing

                error :: _ ->
                    Just error.message

        viewFormInput : { field : Field, value : String } -> Html Msg
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
            { field = Email
            , value = model.email
            }
        , viewFormInput
            { field = Password
            , value = model.password
            }
        , viewFormControls model.isSubmittingForm
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


viewFormControls : Bool -> Html Msg
viewFormControls isSubmitting =
    Html.div [ Attr.class "field is-grouped is-grouped-right" ]
        [ Html.div
            [ Attr.class "control" ]
            [ Html.button
                [ Attr.class "button is-link"
                , Attr.disabled isSubmitting
                , Attr.classList [ ( "is-loading", isSubmitting ) ]
                ]
                [ Html.text "Sign in" ]
            ]
        ]
