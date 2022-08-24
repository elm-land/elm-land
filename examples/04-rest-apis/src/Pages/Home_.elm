module Pages.Home_ exposing (Model, Msg, page)

import Api
import Api.Pokemon exposing (Pokemon)
import Components.Hero
import Html exposing (Html)
import Html.Attributes exposing (alt, class, href, src)
import Page exposing (Page)
import Route.Path
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
    , Api.Pokemon.getFirst150
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
        [ Components.Hero.view
            { title = "Pokemon"
            , subtitle = "Gotta fetch 'em all!"
            }
        , viewPageContent model.pokemonData
        ]
    }


viewPageContent : Api.Data (List Pokemon) -> Html Msg
viewPageContent pokemonData =
    case pokemonData of
        Api.Loading ->
            Html.div [ class "has-text-centered p-6" ] [ Html.text "Loading..." ]

        Api.Success pokemon ->
            viewPokemonList pokemon

        Api.Failure httpError ->
            Html.div [ class "has-text-centered p-6" ] [ Html.text "Something went wrong..." ]


viewPokemonList : List Pokemon -> Html Msg
viewPokemonList listOfPokemon =
    Html.div [ class "container py-6 p-5" ]
        [ Html.div [ class "columns is-multiline" ]
            (List.indexedMap viewPokemon listOfPokemon)
        ]


viewPokemon : Int -> Pokemon -> Html Msg
viewPokemon index pokemon =
    let
        pokedexNumber : Int
        pokedexNumber =
            index + 1

        pokemonDetailPage : Route.Path.Path
        pokemonDetailPage =
            Route.Path.Pokemon__Name_
                { name = pokemon.name
                }

        pokemonImageUrl : String
        pokemonImageUrl =
            "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/"
                ++ String.fromInt pokedexNumber
                ++ ".png"
    in
    Html.div [ class "column is-4-desktop is-6-tablet" ]
        [ Html.a [ Route.Path.href pokemonDetailPage ]
            [ Html.div [ class "card" ]
                [ Html.div [ class "card-content" ]
                    [ Html.div [ class "media" ]
                        [ Html.div [ class "media-left" ]
                            [ Html.figure [ class "image is-64x64" ]
                                [ Html.img [ src pokemonImageUrl, alt pokemon.name ] []
                                ]
                            ]
                        , Html.div [ class "media-content" ]
                            [ Html.p [ class "title is-4" ] [ Html.text pokemon.name ]
                            , Html.p [ class "subtitle is-6" ] [ Html.text ("No. " ++ String.fromInt pokedexNumber) ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
