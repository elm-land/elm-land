module Pages.Home_ exposing (Model, Msg, page)

import Api
import Api.Pokemon exposing (Pokemon)
import Html exposing (Html)
import Page exposing (Page)
import View exposing (View)



-- PAGE


page : Page Model Msg
page =
    Page.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { pokemonData : Api.Data (List Pokemon)
    }


init : ( Model, Cmd Msg )
init =
    ( { pokemonData = Api.Loading
      }
    , Api.Pokemon.getAll
        { onResponse = PokeApiResponded
        }
    )



-- UPDATE


type Msg
    = PokeApiResponded (Api.Data (List Pokemon))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PokeApiResponded data ->
            ( { model | pokemonData = data }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pokemon"
    , body =
        [ case model.pokemonData of
            Api.Loading ->
                Html.text "Loading..."

            Api.Success pokemon ->
                Html.ul []
                    (List.map viewPokemonName pokemon)

            Api.Failure httpError ->
                Html.text "Something went wrong..."
        ]
    }


viewPokemonName : Pokemon -> Html Msg
viewPokemonName pokemon =
    Html.li [] [ Html.text pokemon.name ]
