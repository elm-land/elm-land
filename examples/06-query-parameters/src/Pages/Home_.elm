module Pages.Home_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Fruit.Color
import Fruit.Column
import Html exposing (..)
import Html.Attributes exposing (alt, attribute, class, classList, disabled, placeholder, selected, src, style, value)
import Html.Events
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Sort.Direction
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
    { color : Maybe Fruit.Color.Color
    , sort : Sort
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { color = Nothing
      , sort =
            { column = Fruit.Column.ID
            , direction = Sort.Direction.Ascending
            }
      }
    , Effect.none
    )


type alias Sort =
    { column : Fruit.Column.Column
    , direction : Sort.Direction.Direction
    }



-- UPDATE


type Msg
    = UserSelectedColor (Maybe Fruit.Color.Color)
    | UserClickedColumn Fruit.Column.Column


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserSelectedColor color ->
            ( { model | color = color }
            , Effect.none
            )

        UserClickedColumn column ->
            ( { model
                | sort =
                    { column = column
                    , direction =
                        if model.sort.column == column then
                            Sort.Direction.flip model.sort.direction

                        else
                            Sort.Direction.Ascending
                    }
              }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Fruit vibes"
    , body =
        [ div [ class "container p-6" ]
            [ h1 [ class "title is-1" ] [ text "Fruit vibes 😎" ]
            , h2 [ class "subtitle is-4" ] [ text "Find your favorite fruity snacks" ]
            , viewFilters model
            , viewTable model
            ]
        ]
    }


viewFilters : Model -> Html Msg
viewFilters model =
    div [ class "is-flex" ]
        [ viewFilter
            { label = "Filter by color"
            , placeholder = "Select a color..."
            , toLabel = Fruit.Color.toString
            , choices = Fruit.Color.list
            , selected = model.color
            , onItemSelect = UserSelectedColor
            }
        ]


viewFilter :
    { label : String
    , placeholder : String
    , choices : List choice
    , toLabel : choice -> String
    , selected : Maybe choice
    , onItemSelect : Maybe choice -> Msg
    }
    -> Html Msg
viewFilter options =
    let
        viewSelectOption : choice -> Html Msg
        viewSelectOption choice =
            option
                [ selected (Just choice == options.selected) ]
                [ text (options.toLabel choice)
                ]

        fromStringToChoice : String -> Maybe choice
        fromStringToChoice selectedLabel =
            options.choices
                |> List.filter (\choice -> options.toLabel choice == selectedLabel)
                |> List.head

        onInput : String -> Msg
        onInput selectedLabel =
            options.onItemSelect (fromStringToChoice selectedLabel)
    in
    label [ class "field" ]
        [ span [ class "label" ] [ text options.label ]
        , div [ class "control" ]
            [ div [ class "select" ]
                [ select [ Html.Events.onInput onInput ]
                    ([ option []
                        [ text options.placeholder ]
                     ]
                        ++ List.map viewSelectOption options.choices
                    )
                ]
            ]
        ]


type alias Fruit =
    { id : Int
    , emoji : String
    , name : String
    , color : Fruit.Color.Color
    }


allFruits : List Fruit
allFruits =
    [ { id = 1, emoji = "🍎", name = "Apple", color = Fruit.Color.Red }
    , { id = 2, emoji = "🍌", name = "Banana", color = Fruit.Color.Yellow }
    , { id = 3, emoji = "🍒", name = "Cherry", color = Fruit.Color.Red }
    , { id = 4, emoji = "🥝", name = "Kiwi", color = Fruit.Color.Green }
    , { id = 5, emoji = "\u{1FAD0}", name = "Blueberry", color = Fruit.Color.Blue }
    , { id = 6, emoji = "🍋", name = "Lemon", color = Fruit.Color.Yellow }
    , { id = 7, emoji = "🍐", name = "Pear", color = Fruit.Color.Green }
    , { id = 8, emoji = "🍓", name = "Strawberry", color = Fruit.Color.Red }
    ]


viewTable : Model -> Html Msg
viewTable model =
    let
        fruits : List Fruit
        fruits =
            allFruits
                |> List.filter passesColorFilter
                |> List.sortWith toSortOrder
                |> reverseIfDescending

        toSortOrder : Fruit -> Fruit -> Basics.Order
        toSortOrder fruit1 fruit2 =
            case model.sort.column of
                Fruit.Column.ID ->
                    Basics.compare fruit1.id fruit2.id

                Fruit.Column.Name ->
                    Basics.compare fruit1.name fruit2.name

                Fruit.Column.Color ->
                    Fruit.Color.compare fruit1.color fruit2.color

        reverseIfDescending : List Fruit -> List Fruit
        reverseIfDescending list =
            case model.sort.direction of
                Sort.Direction.Ascending ->
                    list

                Sort.Direction.Descending ->
                    List.reverse list

        passesColorFilter : Fruit -> Bool
        passesColorFilter fruit =
            case model.color of
                Nothing ->
                    True

                Just color ->
                    fruit.color == color

        viewHeaderCell : Fruit.Column.Column -> Html Msg
        viewHeaderCell column =
            th [ class "p-1" ]
                [ button
                    [ Html.Events.onClick (UserClickedColumn column)
                    , class "button is-ghost is-fullwidth is-justify-content-start"
                    ]
                    [ span [] [ text (Fruit.Column.toString column) ]
                    , if column == model.sort.column then
                        span [ class "icon is-small" ]
                            [ Fruit.Column.viewSortIcon model.sort ]

                      else
                        span [ class "icon is-small" ]
                            [ i [ class "fa fa-sort is-invisible" ] [] ]
                    ]
                ]
    in
    div [ class "py-4" ]
        [ table [ class "table is-fullwidth" ]
            [ thead []
                [ tr []
                    (List.map viewHeaderCell
                        [ Fruit.Column.ID
                        , Fruit.Column.Name
                        , Fruit.Column.Color
                        ]
                    )
                ]
            , tbody [] (List.map viewFruitTableRow fruits)
            ]
        ]


viewFruitTableRow : Fruit -> Html Msg
viewFruitTableRow fruit =
    tr []
        [ td [] [ text (String.fromInt fruit.id) ]
        , td [] [ text (fruit.emoji ++ " " ++ fruit.name) ]
        , td [] [ Fruit.Color.viewBadge fruit.color ]
        ]
