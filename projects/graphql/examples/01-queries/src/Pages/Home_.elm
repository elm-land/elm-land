module Pages.Home_ exposing (Model, Msg, page)

import Api.Data
import Effect exposing (Effect)
import GraphQL.Http
import GraphQL.Http.Error
import GraphQL.Queries.FetchCurrentUser
import Html
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
    { currentUser : Api.Data.Data GraphQL.Queries.FetchCurrentUser.Data
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { currentUser = Api.Data.Loading }
    , Effect.sendQuery
        { query = GraphQL.Queries.FetchCurrentUser.new
        , onResponse = GithubApiResponded
        }
    )



-- UPDATE


type Msg
    = GithubApiResponded
        (Result
            GraphQL.Http.Error
            GraphQL.Queries.FetchCurrentUser.Data
        )


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        GithubApiResponded result ->
            ( { model | currentUser = Api.Data.fromResult result }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pages.Home_"
    , body =
        case model.currentUser of
            Api.Data.Loading ->
                [ Html.text "Loading..." ]

            Api.Data.Success { viewer } ->
                [ Html.text (viewer.name |> Maybe.withDefault "???")
                ]

            Api.Data.Failure error ->
                [ Html.text (GraphQL.Http.Error.toUserFriendlyString error)
                ]
    }
