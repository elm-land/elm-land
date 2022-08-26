module Pages.Pokemon.Name_ exposing (Model, Msg, page)

import Api
import Api.PokemonDetail exposing (Pokemon)
import Components.Hero
import Domain.PokemonType
import Html exposing (Html)
import Html.Attributes exposing (alt, class, src, style)
import Http
import Page exposing (Page)
import Route.Path
import View exposing (View)


page : { name : String } -> Page Model Msg
page params =
    Page.element
        { init = init params
        , update = update
        , subscriptions = subscriptions
        , view = view params
        }



-- INIT


type alias Model =
    { pokemonData : Api.Data Pokemon
    }


init : { name : String } -> ( Model, Cmd Msg )
init params =
    ( { pokemonData = Api.Loading }
    , Api.PokemonDetail.get
        { name = params.name
        , onSuccess = PokeApiSucceeded
        , onFailure = PokeApiFailed
        }
    )



-- UPDATE


type Msg
    = PokeApiSucceeded Pokemon
    | PokeApiFailed Http.Error


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PokeApiSucceeded pokemon ->
            ( { model | pokemonData = Api.Success pokemon }
            , Cmd.none
            )

        PokeApiFailed httpError ->
            ( { model | pokemonData = Api.Failure httpError }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : { name : String } -> Model -> View Msg
view params model =
    { title = params.name ++ " | Pokemon"
    , body =
        case model.pokemonData of
            Api.Loading ->
                [ Components.Hero.view
                    { title = params.name
                    , subtitle = "Loading..."
                    }
                ]

            Api.Failure _ ->
                [ Components.Hero.view
                    { title = params.name
                    , subtitle = "We couldn't find that one..."
                    }
                ]

            Api.Success pokemon ->
                [ Components.Hero.view
                    { title = pokemon.name
                    , subtitle = "No. " ++ String.fromInt pokemon.number
                    }
                , Html.div [ class "container p-6 has-text-centered" ]
                    [ viewPokemonImage pokemon
                    , Domain.PokemonType.viewTags pokemon.types
                    , Html.a [ class "link", Route.Path.href Route.Path.Home_ ] [ Html.text "Back to all Pokemon" ]
                    ]
                ]
    }


viewPokemonImage : Pokemon -> Html msg
viewPokemonImage pokemon =
    Html.figure [ class "image my-5 mx-auto", style "width" "256px", style "height" "256px" ]
        [ Html.img [ src pokemon.imageUrl, alt pokemon.name ] []
        ]
