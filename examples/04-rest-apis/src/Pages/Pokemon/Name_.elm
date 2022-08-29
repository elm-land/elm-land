module Pages.Pokemon.Name_ exposing (Model, Msg, page)

import Api
import Api.PokemonDetail exposing (Pokemon)
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
        , onResponse = PokeApiResponded
        }
    )



-- UPDATE


type Msg
    = PokeApiResponded (Result Http.Error Pokemon)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PokeApiResponded (Ok pokemon) ->
            ( { model | pokemonData = Api.Success pokemon }
            , Cmd.none
            )

        PokeApiResponded (Err httpError) ->
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
        [ Html.div [ class "hero is-danger py-6 has-text-centered" ]
            [ Html.h1 [ class "title is-1" ] [ Html.text params.name ]
            , Html.h2 [ class "subtitle is-6 is-underlined" ]
                [ Html.a [ Route.Path.href Route.Path.Home_ ]
                    [ Html.text "Back to pokemon" ]
                ]
            ]
        , case model.pokemonData of
            Api.Loading ->
                Html.div [ class "has-text-centered p-6" ]
                    [ Html.text "Loading..." ]

            Api.Success pokemon ->
                viewPokemon pokemon

            Api.Failure httpError ->
                Html.div [ class "has-text-centered p-6" ]
                    [ Html.text (Api.toUserFriendlyMessage httpError) ]
        ]
    }


viewPokemon : Pokemon -> Html msg
viewPokemon pokemon =
    Html.div [ class "container p-6 has-text-centered" ]
        [ viewPokemonImage pokemon
        , Html.p [] [ Html.text ("Pokedex No. " ++ String.fromInt pokemon.pokedexId) ]
        , viewPokemonTypes pokemon.types
        ]


viewPokemonImage : Pokemon -> Html msg
viewPokemonImage pokemon =
    Html.figure
        [ class "image my-5 mx-auto"
        , style "width" "256px"
        , style "height" "256px"
        ]
        [ Html.img [ src pokemon.spriteUrl, alt pokemon.name ] []
        ]


viewPokemonTypes : List String -> Html msg
viewPokemonTypes pokemonTypes =
    Html.div [ class "tags is-centered py-4" ]
        (List.map viewPokemonType pokemonTypes)


viewPokemonType : String -> Html msg
viewPokemonType pokemonType =
    Html.span [ class "tag" ] [ Html.text pokemonType ]
