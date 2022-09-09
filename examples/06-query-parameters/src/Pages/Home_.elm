module Pages.Home_ exposing (Model, Msg, page)

import Dict
import Effect exposing (Effect)
import Fruit.Color
import Fruit.Column
import Html exposing (..)
import Html.Attributes exposing (alt, attribute, class, classList, disabled, placeholder, selected, src, style, type_, value)
import Html.Events
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Sort.Direction
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init route
        , update = update route
        , subscriptions = subscriptions
        , view = view route
        }



-- INIT


type alias Model =
    { searchInput : String
    }


init : Route () -> () -> ( Model, Effect Msg )
init route () =
    ( { searchInput = toSearchQuery route |> Maybe.withDefault "" }
    , Effect.none
    )


toMaybeColor : Route () -> Maybe Fruit.Color.Color
toMaybeColor route =
    case Dict.get "color" route.query of
        Just name ->
            Fruit.Color.fromString name

        Nothing ->
            Nothing


toSort : Route () -> Sort
toSort route =
    Dict.get "sort" route.query
        |> Maybe.andThen Fruit.Column.fromQueryParameter
        |> Maybe.withDefault
            { column = Fruit.Column.ID
            , direction = Sort.Direction.Ascending
            }


toSearchQuery : Route () -> Maybe String
toSearchQuery route =
    Dict.get "search" route.query


type alias Sort =
    { column : Fruit.Column.Column
    , direction : Sort.Direction.Direction
    }



-- UPDATE


type Msg
    = UserSelectedColor (Maybe Fruit.Color.Color)
    | UserClickedColumn Fruit.Column.Column
    | UserChangedSearchInput String
    | UserSubmittedSearch
    | UserClickedClearFilters


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        UserSelectedColor maybeColor ->
            ( model
            , Effect.replaceRoute
                { path = route.path
                , query =
                    case maybeColor of
                        Just color ->
                            route.query
                                |> Dict.insert "color" (Fruit.Color.toString color)

                        Nothing ->
                            route.query
                                |> Dict.remove "color"
                , hash = Nothing
                }
            )

        UserClickedColumn column ->
            let
                oldSort : Sort
                oldSort =
                    toSort route

                newSort : Sort
                newSort =
                    { column = column
                    , direction =
                        if oldSort.column == column then
                            Sort.Direction.flip oldSort.direction

                        else
                            Sort.Direction.Ascending
                    }
            in
            ( model
            , Effect.replaceRoute
                { path = route.path
                , query =
                    route.query
                        |> Dict.insert "sort" (Fruit.Column.toQueryParameter newSort)
                , hash = Nothing
                }
            )

        UserChangedSearchInput str ->
            ( { model | searchInput = str }
            , Effect.none
            )

        UserSubmittedSearch ->
            ( model
            , Effect.replaceRoute
                { path = route.path
                , query =
                    if String.isEmpty model.searchInput then
                        route.query
                            |> Dict.remove "search"

                    else
                        route.query
                            |> Dict.insert "search" model.searchInput
                , hash = Nothing
                }
            )

        UserClickedClearFilters ->
            ( { model | searchInput = "" }
            , Effect.replaceRoute
                { path = route.path
                , query =
                    route.query
                        |> Dict.remove "search"
                        |> Dict.remove "color"
                , hash = Nothing
                }
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Route () -> Model -> View Msg
view route model =
    let
        _ =
            Debug.log "query" route.query
    in
    { title = "Fruit vibes"
    , body =
        [ div [ class "container p-6" ]
            [ h1 [ class "title is-1" ] [ text "Fruit vibes 😎" ]
            , h2 [ class "subtitle is-4" ] [ text "Find your favorite fruity snacks" ]
            , viewFilters route model
            , viewTable route
            ]
        ]
    }


viewFilters : Route () -> Model -> Html Msg
viewFilters route model =
    let
        hasNoActiveFilters : Bool
        hasNoActiveFilters =
            List.all (\condition -> condition == True)
                [ toSearchQuery route == Nothing
                , toMaybeColor route == Nothing
                ]
    in
    div [ class "level" ]
        [ div [ class "level-left" ]
            [ div [ class "level-item" ]
                [ div [ class "is-flex" ]
                    [ viewSearchbar model
                    , viewColorFilter route
                    ]
                ]
            ]
        , div [ class "level-right" ]
            [ div [ class "level-item" ]
                [ button
                    [ class "button is-light is-small"
                    , disabled hasNoActiveFilters
                    , Html.Events.onClick UserClickedClearFilters
                    ]
                    [ span [] [ text "Clear filters" ]
                    , span [ class "icon is-small" ] [ i [ class "fas fa-times" ] [] ]
                    ]
                ]
            ]
        ]


viewSearchbar : Model -> Html Msg
viewSearchbar model =
    form [ class "mr-4", Html.Events.onSubmit UserSubmittedSearch ]
        [ label [ class "field" ]
            [ span [ class "label" ] [ text "Search by name" ]
            , div [ class "control" ]
                [ input
                    [ class "input"
                    , type_ "search"
                    , Html.Events.onInput UserChangedSearchInput
                    , value model.searchInput
                    ]
                    []
                ]
            ]
        ]


viewColorFilter : Route () -> Html Msg
viewColorFilter route =
    let
        selectedColor : Maybe Fruit.Color.Color
        selectedColor =
            toMaybeColor route

        viewSelectOption : Fruit.Color.Color -> Html Msg
        viewSelectOption choice =
            option
                [ selected (Just choice == selectedColor) ]
                [ text (Fruit.Color.toString choice)
                ]

        fromStringToChoice : String -> Maybe Fruit.Color.Color
        fromStringToChoice selectedLabel =
            Fruit.Color.list
                |> List.filter (\color -> Fruit.Color.toString color == selectedLabel)
                |> List.head

        onInput : String -> Msg
        onInput selectedLabel =
            UserSelectedColor (fromStringToChoice selectedLabel)
    in
    label [ class "field" ]
        [ span [ class "label" ] [ text "Filter by color" ]
        , div [ class "control" ]
            [ div [ class "select" ]
                [ select [ Html.Events.onInput onInput ]
                    ([ option [] [ text "Select a color..." ]
                     ]
                        ++ List.map viewSelectOption Fruit.Color.list
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
    , { id = 9, emoji = "🍇", name = "Grapes", color = Fruit.Color.Purple }
    , { id = 10, emoji = "🥑", name = "Avocado", color = Fruit.Color.Green }
    ]


viewTable : Route () -> Html Msg
viewTable route =
    let
        maybeColor : Maybe Fruit.Color.Color
        maybeColor =
            toMaybeColor route

        sort : Sort
        sort =
            toSort route

        fruits : List Fruit
        fruits =
            allFruits
                |> List.filter passesColorFilter
                |> List.filter passesSearchFilter
                |> List.sortWith toSortOrder
                |> reverseIfDescending

        toSortOrder : Fruit -> Fruit -> Basics.Order
        toSortOrder fruit1 fruit2 =
            case sort.column of
                Fruit.Column.ID ->
                    Basics.compare fruit1.id fruit2.id

                Fruit.Column.Name ->
                    Basics.compare fruit1.name fruit2.name

                Fruit.Column.Color ->
                    Fruit.Color.compare fruit1.color fruit2.color

        reverseIfDescending : List Fruit -> List Fruit
        reverseIfDescending list =
            case sort.direction of
                Sort.Direction.Ascending ->
                    list

                Sort.Direction.Descending ->
                    List.reverse list

        passesColorFilter : Fruit -> Bool
        passesColorFilter fruit =
            case maybeColor of
                Nothing ->
                    True

                Just color ->
                    fruit.color == color

        passesSearchFilter : Fruit -> Bool
        passesSearchFilter fruit =
            case toSearchQuery route of
                Nothing ->
                    True

                Just searchQuery ->
                    String.contains
                        (String.toLower searchQuery)
                        (String.toLower fruit.name)

        viewHeaderCell : Fruit.Column.Column -> Html Msg
        viewHeaderCell column =
            th [ class "p-1" ]
                [ button
                    [ Html.Events.onClick (UserClickedColumn column)
                    , class "button is-ghost is-fullwidth is-justify-content-start"
                    ]
                    [ span [] [ text (Fruit.Column.toString column) ]
                    , if column == sort.column then
                        span [ class "icon is-small" ]
                            [ Fruit.Column.viewSortIcon sort ]

                      else
                        span [ class "icon is-small" ]
                            [ i [ class "fa fa-sort is-invisible" ] [] ]
                    ]
                ]
    in
    case fruits of
        [] ->
            div [ class "py-4" ]
                [ p [] [ text "Couldn't find any fruit matching those filters." ]
                ]

        _ ->
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
