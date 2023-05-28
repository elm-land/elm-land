module Main_ exposing (..)

import Auth
import Auth.Action
import Browser
import Browser.Navigation
import Effect exposing (Effect)
import Html exposing (Html)
import Json.Decode
import Layout
import Layouts
import Layouts.Sidebar
import Layouts.Sidebar.Header
import Main.Layouts.Model
import Main.Layouts.Msg
import Main.Pages.Model
import Main.Pages.Msg
import Page
import Pages.Home_
import Pages.NotFound_
import Route exposing (Route)
import Route.Path
import Shared
import Task
import Url exposing (Url)
import View exposing (View)


main : Program Json.Decode.Value Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }



-- INIT


type alias Model =
    { key : Browser.Navigation.Key
    , url : Url
    , page : Main.Pages.Model.Model
    , layout : Maybe Main.Layouts.Model.Model
    , shared : Shared.Model
    }


init : Json.Decode.Value -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init json url key =
    let
        flagsResult : Result Json.Decode.Error Shared.Flags
        flagsResult =
            Json.Decode.decodeValue Shared.decoder json

        ( sharedModel, sharedEffect ) =
            Shared.init flagsResult (Route.fromUrl () url)

        { page, layout } =
            initPageAndLayout { key = key, url = url, shared = sharedModel, layout = Nothing }
    in
    ( { url = url
      , key = key
      , page = Tuple.first page
      , layout = layout |> Maybe.map Tuple.first
      , shared = sharedModel
      }
    , Cmd.batch
        [ Tuple.second page
        , layout |> Maybe.map Tuple.second |> Maybe.withDefault Cmd.none
        , fromSharedEffect { key = key, url = url, shared = sharedModel } sharedEffect
        ]
    )


initLayout : { key : Browser.Navigation.Key, url : Url, shared : Shared.Model, layout : Maybe Main.Layouts.Model.Model } -> Layouts.Layout Msg -> ( Main.Layouts.Model.Model, Cmd Msg )
initLayout model layout =
    case ( layout, model.layout ) of
        ( Layouts.Sidebar settings, Just (Main.Layouts.Model.Sidebar existing) ) ->
            ( Main.Layouts.Model.Sidebar existing
            , Cmd.none
            )

        ( Layouts.Sidebar settings, Just (Main.Layouts.Model.Sidebar_Header existing) ) ->
            ( Main.Layouts.Model.Sidebar { sidebar = existing.sidebar }
            , Cmd.none
            )

        ( Layouts.Sidebar settings, _ ) ->
            let
                route : Route ()
                route =
                    Route.fromUrl () model.url

                sidebarLayout =
                    Layouts.Sidebar.layout settings model.shared route

                ( sidebarLayoutModel, sidebarLayoutEffect ) =
                    Layout.init sidebarLayout ()
            in
            ( Main.Layouts.Model.Sidebar { sidebar = sidebarLayoutModel }
            , fromLayoutEffect model (Effect.map Main.Layouts.Msg.Sidebar sidebarLayoutEffect)
            )

        ( Layouts.Sidebar_Header settings, Just (Main.Layouts.Model.Sidebar existing) ) ->
            let
                route : Route ()
                route =
                    Route.fromUrl () model.url

                sidebarHeaderLayout =
                    Layouts.Sidebar.Header.layout settings model.shared route

                ( headerLayoutModel, headerLayoutEffect ) =
                    Layout.init sidebarHeaderLayout ()
            in
            ( Main.Layouts.Model.Sidebar_Header { sidebar = existing.sidebar, header = headerLayoutModel }
            , fromLayoutEffect model (Effect.map Main.Layouts.Msg.Sidebar_Header headerLayoutEffect)
            )

        ( Layouts.Sidebar_Header settings, Just (Main.Layouts.Model.Sidebar_Header existing) ) ->
            ( Main.Layouts.Model.Sidebar_Header existing
            , Cmd.none
            )

        ( Layouts.Sidebar_Header settings, _ ) ->
            let
                route : Route ()
                route =
                    Route.fromUrl () model.url

                sidebarHeaderLayout =
                    Layouts.Sidebar.Header.layout settings model.shared route

                sidebarLayout =
                    Layouts.Sidebar.layout (Layout.parentSettings sidebarHeaderLayout) model.shared route

                ( headerLayoutModel, headerLayoutEffect ) =
                    Layout.init sidebarHeaderLayout ()

                ( sidebarLayoutModel, sidebarLayoutEffect ) =
                    Layout.init sidebarLayout ()
            in
            ( Main.Layouts.Model.Sidebar_Header { sidebar = sidebarLayoutModel, header = headerLayoutModel }
            , Cmd.batch
                [ fromLayoutEffect model (Effect.map Main.Layouts.Msg.Sidebar_Header headerLayoutEffect)
                , fromLayoutEffect model (Effect.map Main.Layouts.Msg.Sidebar sidebarLayoutEffect)
                ]
            )


initPageAndLayout : { key : Browser.Navigation.Key, url : Url, shared : Shared.Model, layout : Maybe Main.Layouts.Model.Model } -> { page : ( Main.Pages.Model.Model, Cmd Msg ), layout : Maybe ( Main.Layouts.Model.Model, Cmd Msg ) }
initPageAndLayout model =
    case Route.Path.fromUrl model.url of
        Route.Path.Home_ ->
            let
                page : Page.Page Pages.Home_.Model Pages.Home_.Msg
                page =
                    Pages.Home_.page model.shared (Route.fromUrl () model.url)

                ( pageModel, pageEffect ) =
                    Page.init page ()
            in
            { page =
                Tuple.mapBoth
                    Main.Pages.Model.Home_
                    (Effect.map Main.Pages.Msg.Home_ >> fromPageEffect model)
                    ( pageModel, pageEffect )
            , layout =
                Page.layout pageModel page
                    |> Maybe.map (Layouts.map (Main.Pages.Msg.Home_ >> PageSent))
                    |> Maybe.map (initLayout model)
            }

        Route.Path.NotFound_ ->
            let
                page : Page.Page Pages.NotFound_.Model Pages.NotFound_.Msg
                page =
                    Pages.NotFound_.page model.shared (Route.fromUrl () model.url)

                ( pageModel, pageEffect ) =
                    Page.init page ()
            in
            { page =
                Tuple.mapBoth
                    Main.Pages.Model.NotFound_
                    (Effect.map Main.Pages.Msg.NotFound_ >> fromPageEffect model)
                    ( pageModel, pageEffect )
            , layout =
                Page.layout pageModel page
                    |> Maybe.map (Layouts.map (Main.Pages.Msg.NotFound_ >> PageSent))
                    |> Maybe.map (initLayout model)
            }


runWhenAuthenticated : { model | shared : Shared.Model, url : Url, key : Browser.Navigation.Key } -> (Auth.User -> ( Main.Pages.Model.Model, Cmd Msg )) -> ( Main.Pages.Model.Model, Cmd Msg )
runWhenAuthenticated model toTuple =
    let
        record =
            runWhenAuthenticatedWithLayout model (\user -> { page = toTuple user, layout = Nothing })
    in
    record.page


runWhenAuthenticatedWithLayout : { model | shared : Shared.Model, url : Url, key : Browser.Navigation.Key } -> (Auth.User -> { page : ( Main.Pages.Model.Model, Cmd Msg ), layout : Maybe ( Main.Layouts.Model.Model, Cmd Msg ) }) -> { page : ( Main.Pages.Model.Model, Cmd Msg ), layout : Maybe ( Main.Layouts.Model.Model, Cmd Msg ) }
runWhenAuthenticatedWithLayout model toRecord =
    let
        authAction : Auth.Action.Action Auth.User
        authAction =
            Auth.onPageLoad model.shared (Route.fromUrl () model.url)

        toCmd : Effect Msg -> Cmd Msg
        toCmd =
            Effect.toCmd
                { key = model.key
                , url = model.url
                , shared = model.shared
                , fromSharedMsg = SharedSent
                , batch = Batch
                , toCmd = Task.succeed >> Task.perform identity
                }
    in
    case authAction of
        Auth.Action.LoadPageWithUser user ->
            toRecord user

        Auth.Action.ShowLoadingPage loadingView ->
            { page =
                ( Main.Pages.Model.Loading_
                , Cmd.none
                )
            , layout = Nothing
            }

        Auth.Action.ReplaceRoute options ->
            { page =
                ( Main.Pages.Model.Redirecting_
                , toCmd (Effect.replaceRoute options)
                )
            , layout = Nothing
            }

        Auth.Action.PushRoute options ->
            { page =
                ( Main.Pages.Model.Redirecting_
                , toCmd (Effect.pushRoute options)
                )
            , layout = Nothing
            }

        Auth.Action.LoadExternalUrl externalUrl ->
            { page =
                ( Main.Pages.Model.Redirecting_
                , Browser.Navigation.load externalUrl
                )
            , layout = Nothing
            }



-- UPDATE


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url
    | PageSent Main.Pages.Msg.Msg
    | LayoutSent Main.Layouts.Msg.Msg
    | SharedSent Shared.Msg
    | Batch (List Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested (Browser.Internal url) ->
            ( model
            , Browser.Navigation.pushUrl model.key (Url.toString url)
            )

        UrlRequested (Browser.External url) ->
            ( model
            , Browser.Navigation.load url
            )

        UrlChanged url ->
            if Route.Path.fromUrl url == Route.Path.fromUrl model.url then
                ( { model | url = url }
                , Cmd.none
                )

            else
                let
                    { page, layout } =
                        initPageAndLayout { key = model.key, shared = model.shared, layout = model.layout, url = url }

                    ( pageModel, pageCmd ) =
                        page

                    ( layoutModel, layoutCmd ) =
                        case layout of
                            Just ( layoutModel_, layoutCmd_ ) ->
                                ( Just layoutModel_, layoutCmd_ )

                            Nothing ->
                                ( Nothing, Cmd.none )
                in
                ( { model | url = url, page = pageModel, layout = layoutModel }
                , Cmd.batch [ pageCmd, layoutCmd ]
                )

        PageSent pageMsg ->
            let
                ( pageModel, pageCmd ) =
                    updateFromPage pageMsg model
            in
            ( { model | page = pageModel }
            , pageCmd
            )

        LayoutSent layoutMsg ->
            let
                ( layoutModel, layoutCmd ) =
                    updateFromLayout layoutMsg model
            in
            ( { model | layout = layoutModel }
            , layoutCmd
            )

        SharedSent sharedMsg ->
            let
                ( sharedModel, sharedEffect ) =
                    Shared.update (Route.fromUrl () model.url) sharedMsg model.shared

                ( oldAction, newAction ) =
                    ( Auth.onPageLoad model.shared (Route.fromUrl () model.url)
                    , Auth.onPageLoad sharedModel (Route.fromUrl () model.url)
                    )
            in
            case oldAction /= newAction of
                True ->
                    let
                        { layout, page } =
                            initPageAndLayout { key = model.key, shared = sharedModel, url = model.url, layout = model.layout }

                        ( pageModel, pageCmd ) =
                            page

                        ( layoutModel, layoutCmd ) =
                            ( layout |> Maybe.map Tuple.first
                            , layout |> Maybe.map Tuple.second |> Maybe.withDefault Cmd.none
                            )
                    in
                    ( { model | shared = sharedModel, page = pageModel, layout = layoutModel }
                    , Cmd.batch
                        [ pageCmd
                        , layoutCmd
                        , fromSharedEffect { model | shared = sharedModel } sharedEffect
                        ]
                    )

                False ->
                    ( { model | shared = sharedModel }
                    , fromSharedEffect { model | shared = sharedModel } sharedEffect
                    )

        Batch messages ->
            ( model
            , messages
                |> List.map (Task.succeed >> Task.perform identity)
                |> Cmd.batch
            )


updateFromPage : Main.Pages.Msg.Msg -> Model -> ( Main.Pages.Model.Model, Cmd Msg )
updateFromPage msg model =
    case ( msg, model.page ) of
        ( Main.Pages.Msg.Home_ pageMsg, Main.Pages.Model.Home_ pageModel ) ->
            Tuple.mapBoth
                Main.Pages.Model.Home_
                (Effect.map Main.Pages.Msg.Home_ >> fromPageEffect model)
                (Page.update (Pages.Home_.page model.shared (Route.fromUrl () model.url)) pageMsg pageModel)

        ( Main.Pages.Msg.NotFound_ pageMsg, Main.Pages.Model.NotFound_ pageModel ) ->
            Tuple.mapBoth
                Main.Pages.Model.NotFound_
                (Effect.map Main.Pages.Msg.NotFound_ >> fromPageEffect model)
                (Page.update (Pages.NotFound_.page model.shared (Route.fromUrl () model.url)) pageMsg pageModel)

        _ ->
            ( model.page
            , Cmd.none
            )


updateFromLayout : Main.Layouts.Msg.Msg -> Model -> ( Maybe Main.Layouts.Model.Model, Cmd Msg )
updateFromLayout msg model =
    let
        route : Route ()
        route =
            Route.fromUrl () model.url
    in
    case ( toLayoutFromPage model, model.layout, msg ) of
        ( Just (Layouts.Sidebar settings), Just (Main.Layouts.Model.Sidebar layoutModel), Main.Layouts.Msg.Sidebar layoutMsg ) ->
            Tuple.mapBoth
                (\newModel -> Just (Main.Layouts.Model.Sidebar { layoutModel | sidebar = newModel }))
                (Effect.map Main.Layouts.Msg.Sidebar >> fromLayoutEffect model)
                (Layout.update (Layouts.Sidebar.layout settings model.shared route) layoutMsg layoutModel.sidebar)

        ( Just (Layouts.Sidebar_Header settings), Just (Main.Layouts.Model.Sidebar_Header layoutModel), Main.Layouts.Msg.Sidebar layoutMsg ) ->
            let
                sidebarSettings =
                    Layouts.Sidebar.Header.layout settings model.shared route
                        |> Layout.parentSettings
            in
            Tuple.mapBoth
                (\newModel -> Just (Main.Layouts.Model.Sidebar_Header { layoutModel | sidebar = newModel }))
                (Effect.map Main.Layouts.Msg.Sidebar >> fromLayoutEffect model)
                (Layout.update (Layouts.Sidebar.layout sidebarSettings model.shared route) layoutMsg layoutModel.sidebar)

        ( Just (Layouts.Sidebar_Header settings), Just (Main.Layouts.Model.Sidebar_Header layoutModel), Main.Layouts.Msg.Sidebar_Header layoutMsg ) ->
            Tuple.mapBoth
                (\newModel -> Just (Main.Layouts.Model.Sidebar_Header { layoutModel | header = newModel }))
                (Effect.map Main.Layouts.Msg.Sidebar_Header >> fromLayoutEffect model)
                (Layout.update (Layouts.Sidebar.Header.layout settings model.shared route) layoutMsg layoutModel.header)

        _ ->
            ( model.layout
            , Cmd.none
            )


toLayoutFromPage : Model -> Maybe (Layouts.Layout Msg)
toLayoutFromPage model =
    case model.page of
        Main.Pages.Model.Home_ pageModel ->
            Route.fromUrl () model.url
                |> Pages.Home_.page model.shared
                |> Page.layout pageModel
                |> Maybe.map (Layouts.map (Main.Pages.Msg.Home_ >> PageSent))

        Main.Pages.Model.NotFound_ pageModel ->
            Route.fromUrl () model.url
                |> Pages.NotFound_.page model.shared
                |> Page.layout pageModel
                |> Maybe.map (Layouts.map (Main.Pages.Msg.NotFound_ >> PageSent))

        Main.Pages.Model.Redirecting_ ->
            Nothing

        Main.Pages.Model.Loading_ ->
            Nothing


toAuthProtectedPage : Model -> (Auth.User -> Shared.Model -> Route params -> Page.Page model msg) -> Route params -> Maybe (Page.Page model msg)
toAuthProtectedPage model toPage route =
    case Auth.onPageLoad model.shared (Route.fromUrl () model.url) of
        Auth.Action.LoadPageWithUser user ->
            Just (toPage user model.shared route)

        _ ->
            Nothing


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        subscriptionsFromPage : Sub Msg
        subscriptionsFromPage =
            case model.page of
                Main.Pages.Model.Home_ pageModel ->
                    Page.subscriptions (Pages.Home_.page model.shared (Route.fromUrl () model.url)) pageModel
                        |> Sub.map Main.Pages.Msg.Home_
                        |> Sub.map PageSent

                Main.Pages.Model.NotFound_ pageModel ->
                    Page.subscriptions (Pages.NotFound_.page model.shared (Route.fromUrl () model.url)) pageModel
                        |> Sub.map Main.Pages.Msg.NotFound_
                        |> Sub.map PageSent

                Main.Pages.Model.Redirecting_ ->
                    Sub.none

                Main.Pages.Model.Loading_ ->
                    Sub.none

        maybeLayout : Maybe (Layouts.Layout Msg)
        maybeLayout =
            toLayoutFromPage model

        route : Route ()
        route =
            Route.fromUrl () model.url

        subscriptionsFromLayout : Sub Msg
        subscriptionsFromLayout =
            case ( maybeLayout, model.layout ) of
                ( Just (Layouts.Sidebar settings), Just (Main.Layouts.Model.Sidebar layoutModel) ) ->
                    Layout.subscriptions (Layouts.Sidebar.layout settings model.shared route) layoutModel.sidebar
                        |> Sub.map Main.Layouts.Msg.Sidebar
                        |> Sub.map LayoutSent

                ( Just (Layouts.Sidebar_Header settings), Just (Main.Layouts.Model.Sidebar_Header layoutModel) ) ->
                    let
                        sidebarSettings =
                            Layouts.Sidebar.Header.layout settings model.shared route
                                |> Layout.parentSettings
                    in
                    Sub.batch
                        [ Layout.subscriptions (Layouts.Sidebar.layout sidebarSettings model.shared route) layoutModel.sidebar
                            |> Sub.map Main.Layouts.Msg.Sidebar
                            |> Sub.map LayoutSent
                        , Layout.subscriptions (Layouts.Sidebar.Header.layout settings model.shared route) layoutModel.header
                            |> Sub.map Main.Layouts.Msg.Sidebar_Header
                            |> Sub.map LayoutSent
                        ]

                _ ->
                    Sub.none
    in
    Sub.batch
        [ Shared.subscriptions route model.shared
            |> Sub.map SharedSent
        , subscriptionsFromPage
        , subscriptionsFromLayout
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        view_ : View Msg
        view_ =
            toView model
    in
    View.toBrowserDocument
        { shared = model.shared
        , route = Route.fromUrl () model.url
        , view = view_
        }


toView : Model -> View Msg
toView model =
    let
        route : Route ()
        route =
            Route.fromUrl () model.url
    in
    case ( toLayoutFromPage model, model.layout ) of
        ( Just (Layouts.Sidebar settings), Just (Main.Layouts.Model.Sidebar layoutModel) ) ->
            Layout.view
                (Layouts.Sidebar.layout settings model.shared route)
                { model = layoutModel.sidebar
                , toContentMsg = Main.Layouts.Msg.Sidebar >> LayoutSent
                , content = viewPage model
                }

        ( Just (Layouts.Sidebar_Header settings), Just (Main.Layouts.Model.Sidebar_Header layoutModel) ) ->
            let
                sidebarSettings =
                    Layouts.Sidebar.Header.layout settings model.shared route
                        |> Layout.parentSettings
            in
            Layout.view
                (Layouts.Sidebar.layout sidebarSettings model.shared route)
                { model = layoutModel.sidebar
                , toContentMsg = Main.Layouts.Msg.Sidebar >> LayoutSent
                , content =
                    Layout.view
                        (Layouts.Sidebar.Header.layout settings model.shared route)
                        { model = layoutModel.header
                        , toContentMsg = Main.Layouts.Msg.Sidebar_Header >> LayoutSent
                        , content = viewPage model
                        }
                }

        _ ->
            viewPage model


viewPage : Model -> View Msg
viewPage model =
    case model.page of
        Main.Pages.Model.Home_ pageModel ->
            Page.view (Pages.Home_.page model.shared (Route.fromUrl () model.url)) pageModel
                |> View.map Main.Pages.Msg.Home_
                |> View.map PageSent

        Main.Pages.Model.NotFound_ pageModel ->
            Page.view (Pages.NotFound_.page model.shared (Route.fromUrl () model.url)) pageModel
                |> View.map Main.Pages.Msg.NotFound_
                |> View.map PageSent

        Main.Pages.Model.Redirecting_ ->
            View.none

        Main.Pages.Model.Loading_ ->
            Auth.viewLoadingPage model.shared (Route.fromUrl () model.url)
                |> View.map never



-- INTERNALS


fromPageEffect : { model | key : Browser.Navigation.Key, url : Url, shared : Shared.Model } -> Effect Main.Pages.Msg.Msg -> Cmd Msg
fromPageEffect model effect =
    Effect.toCmd
        { key = model.key
        , url = model.url
        , shared = model.shared
        , fromSharedMsg = SharedSent
        , batch = Batch
        , toCmd = Task.succeed >> Task.perform identity
        }
        (Effect.map PageSent effect)


fromLayoutEffect : { model | key : Browser.Navigation.Key, url : Url, shared : Shared.Model } -> Effect Main.Layouts.Msg.Msg -> Cmd Msg
fromLayoutEffect model effect =
    Effect.toCmd
        { key = model.key
        , url = model.url
        , shared = model.shared
        , fromSharedMsg = SharedSent
        , batch = Batch
        , toCmd = Task.succeed >> Task.perform identity
        }
        (Effect.map LayoutSent effect)


fromSharedEffect : { model | key : Browser.Navigation.Key, url : Url, shared : Shared.Model } -> Effect Shared.Msg -> Cmd Msg
fromSharedEffect model effect =
    Effect.toCmd
        { key = model.key
        , url = model.url
        , shared = model.shared
        , fromSharedMsg = SharedSent
        , batch = Batch
        , toCmd = Task.succeed >> Task.perform identity
        }
        (Effect.map SharedSent effect)
