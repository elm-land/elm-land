module Pages.Home_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html
import Html.Attributes
import Http
import Json.Decode
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
    { response : Response
    }


type Response
    = Loading
    | Success Data
    | Failure Http.Error


type alias Data =
    List Dog


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.field "dogs" (Json.Decode.list dogDecoder)


type alias Dog =
    { id : Int
    , name : String
    }


dogDecoder : Json.Decode.Decoder Dog
dogDecoder =
    Json.Decode.map2 Dog
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)


init : () -> ( Model, Effect Msg )
init () =
    ( { response = Loading }
    , Effect.sendHttpGet
        { url = "/dogs.json"
        , decoder = decoder
        , onResult = ApiResponded
        }
    )



-- UPDATE


type Msg
    = ApiResponded (Result Http.Error Data)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ApiResponded (Ok data) ->
            ( { model | response = Success data }
            , Effect.none
            )

        ApiResponded (Err httpError) ->
            ( { model | response = Failure httpError }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Dogs"
    , body =
        [ Html.h1 [] [ Html.text "Dogs" ]
        , case model.response of
            Loading ->
                Html.p [] [ Html.text "Loading..." ]

            Success data ->
                Html.p [] [ Html.text "Dogs successfully fetched!" ]

            Failure httpError ->
                let
                    rawErrorMessage : String
                    rawErrorMessage =
                        case httpError of
                            Http.BadBody message ->
                                message

                            Http.Timeout ->
                                "Request timed out"

                            Http.BadUrl _ ->
                                "Bad URL provided"

                            Http.NetworkError ->
                                "Could not connect to API"

                            Http.BadStatus _ ->
                                "Bad status code"
                in
                Html.div []
                    [ Html.p [] [ Html.text "The HTTP error was reported to Sentry!" ]
                    , Html.pre
                        [ Html.Attributes.style "background" "#f4f4f4"
                        , Html.Attributes.style "border" "solid 2px red"
                        , Html.Attributes.style "padding" "16px"
                        , Html.Attributes.style "border-radius" "8px"
                        ]
                        [ Html.code [] [ Html.text rawErrorMessage ]
                        ]
                    ]
        ]
    }
