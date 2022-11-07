module Main_ exposing (main)

import Auth
import Auth.Action
import Browser
import Browser.Navigation
import Effect exposing (Effect)
import Html exposing (Html)
import Json.Decode
import Layout
import Layouts
import Layouts.Header
import Layouts.Sidebar
import Layouts.Sidebar.Header
import Layouts.Sidebar.Header.Tabs
import Main.Layouts.Model
import Main.Layouts.Msg
import Main.Pages.Model
import Main.Pages.Msg
import Page
import Pages.Authors
import Pages.BlogPosts
import Pages.Home_
import Pages.NotFound_
import Route exposing (Route)
import Route.Path
import Shared
import Url exposing (Url)
import View exposing (View)


main : Program Json.Decode.Value Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = View.toBrowserDocument << view
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


initLayout : { key : Browser.Navigation.Key, url : Url, shared : Shared.Model, layout : Maybe Main.Layouts.Model.Model } -> Layouts.Layout -> ( Main.Layouts.Model.Model, Cmd Msg )
initLayout model layout =
    case ( layout, model.layout ) of
        ( Layouts.Header settings, Just (Main.Layouts.Model.Header existing) ) ->
            ( Main.Layouts.Model.Header existing
            , Cmd.none
            )

        ( Layouts.Header settings, _ ) ->
            let
                route : Route ()
                route =
                    Route.fromUrl () model.url

                ( headerLayoutModel, headerLayoutEffect ) =
                    Layout.init (Layouts.Header.layout settings.header model.shared route) ()
            in
            ( Main.Layouts.Model.Header { header = headerLayoutModel }
            , fromLayoutEffect model (Effect.map Main.Layouts.Msg.Header headerLayoutEffect)
            )

        ( Layouts.Sidebar settings, Just (Main.Layouts.Model.Sidebar existing) ) ->
            ( Main.Layouts.Model.Sidebar existing
            , Cmd.none
            )

        ( Layouts.Sidebar settings, Just (Main.Layouts.Model.Sidebar_Header existing) ) ->
            ( Main.Layouts.Model.Sidebar { sidebar = existing.sidebar }
            , Cmd.none
            )

        ( Layouts.Sidebar settings, Just (Main.Layouts.Model.Sidebar_Header_Tabs existing) ) ->
            ( Main.Layouts.Model.Sidebar { sidebar = existing.sidebar }
            , Cmd.none
            )

        ( Layouts.Sidebar settings, _ ) ->
            let
                route : Route ()
                route =
                    Route.fromUrl () model.url

                ( sidebarLayoutModel, sidebarLayoutEffect ) =
                    Layout.init (Layouts.Sidebar.layout settings.sidebar model.shared route) ()
            in
            ( Main.Layouts.Model.Sidebar { sidebar = sidebarLayoutModel }
            , fromLayoutEffect model (Effect.map Main.Layouts.Msg.Sidebar sidebarLayoutEffect)
            )

        ( Layouts.Sidebar_Header settings, Just (Main.Layouts.Model.Sidebar existing) ) ->
            let
                route : Route ()
                route =
                    Route.fromUrl () model.url

                ( headerLayoutModel, headerLayoutEffect ) =
                    Layout.init (Layouts.Sidebar.Header.layout settings.header model.shared route) ()
            in
            ( Main.Layouts.Model.Sidebar_Header { sidebar = existing.sidebar, header = headerLayoutModel }
            , fromLayoutEffect model (Effect.map Main.Layouts.Msg.Sidebar_Header headerLayoutEffect)
            )

        ( Layouts.Sidebar_Header settings, Just (Main.Layouts.Model.Sidebar_Header existing) ) ->
            ( Main.Layouts.Model.Sidebar_Header existing
            , Cmd.none
            )

        ( Layouts.Sidebar_Header settings, Just (Main.Layouts.Model.Sidebar_Header_Tabs existing) ) ->
            ( Main.Layouts.Model.Sidebar_Header { sidebar = existing.sidebar, header = existing.header }
            , Cmd.none
            )

        ( Layouts.Sidebar_Header settings, _ ) ->
            let
                route : Route ()
                route =
                    Route.fromUrl () model.url

                ( headerLayoutModel, headerLayoutEffect ) =
                    Layout.init (Layouts.Sidebar.Header.layout settings.header model.shared route) ()

                ( sidebarLayoutModel, sidebarLayoutEffect ) =
                    Layout.init (Layouts.Sidebar.layout settings.sidebar model.shared route) ()
            in
            ( Main.Layouts.Model.Sidebar_Header { sidebar = sidebarLayoutModel, header = headerLayoutModel }
            , Cmd.batch
                [ fromLayoutEffect model (Effect.map Main.Layouts.Msg.Sidebar_Header headerLayoutEffect)
                , fromLayoutEffect model (Effect.map Main.Layouts.Msg.Sidebar sidebarLayoutEffect)
                ]
            )

        ( Layouts.Sidebar_Header_Tabs settings, Just (Main.Layouts.Model.Sidebar existing) ) ->
            let
                route : Route ()
                route =
                    Route.fromUrl () model.url

                ( tabsLayoutModel, tabsLayoutEffect ) =
                    Layout.init (Layouts.Sidebar.Header.Tabs.layout settings.tabs model.shared route) ()

                ( headerLayoutModel, headerLayoutEffect ) =
                    Layout.init (Layouts.Sidebar.Header.layout settings.header model.shared route) ()
            in
            ( Main.Layouts.Model.Sidebar_Header_Tabs { sidebar = existing.sidebar, header = headerLayoutModel, tabs = tabsLayoutModel }
            , Cmd.batch
                [ fromLayoutEffect model (Effect.map Main.Layouts.Msg.Sidebar_Header_Tabs tabsLayoutEffect)
                , fromLayoutEffect model (Effect.map Main.Layouts.Msg.Sidebar_Header headerLayoutEffect)
                ]
            )

        ( Layouts.Sidebar_Header_Tabs settings, Just (Main.Layouts.Model.Sidebar_Header existing) ) ->
            let
                route : Route ()
                route =
                    Route.fromUrl () model.url

                ( tabsLayoutModel, tabsLayoutEffect ) =
                    Layout.init (Layouts.Sidebar.Header.Tabs.layout settings.tabs model.shared route) ()
            in
            ( Main.Layouts.Model.Sidebar_Header_Tabs { sidebar = existing.sidebar, header = existing.header, tabs = tabsLayoutModel }
            , fromLayoutEffect model (Effect.map Main.Layouts.Msg.Sidebar_Header_Tabs tabsLayoutEffect)
            )

        ( Layouts.Sidebar_Header_Tabs settings, Just (Main.Layouts.Model.Sidebar_Header_Tabs existing) ) ->
            ( Main.Layouts.Model.Sidebar_Header_Tabs existing
            , Cmd.none
            )

        ( Layouts.Sidebar_Header_Tabs settings, _ ) ->
            let
                route : Route ()
                route =
                    Route.fromUrl () model.url

                ( tabsLayoutModel, tabsLayoutEffect ) =
                    Layout.init (Layouts.Sidebar.Header.Tabs.layout settings.tabs model.shared route) ()

                ( headerLayoutModel, headerLayoutEffect ) =
                    Layout.init (Layouts.Sidebar.Header.layout settings.header model.shared route) ()

                ( sidebarLayoutModel, sidebarLayoutEffect ) =
                    Layout.init (Layouts.Sidebar.layout settings.sidebar model.shared route) ()
            in
            ( Main.Layouts.Model.Sidebar_Header_Tabs { sidebar = sidebarLayoutModel, header = headerLayoutModel, tabs = tabsLayoutModel }
            , Cmd.batch
                [ fromLayoutEffect model (Effect.map Main.Layouts.Msg.Sidebar_Header_Tabs tabsLayoutEffect)
                , fromLayoutEffect model (Effect.map Main.Layouts.Msg.Sidebar_Header headerLayoutEffect)
                , fromLayoutEffect model (Effect.map Main.Layouts.Msg.Sidebar sidebarLayoutEffect)
                ]
            )


initPageAndLayout : { key : Browser.Navigation.Key, url : Url, shared : Shared.Model, layout : Maybe Main.Layouts.Model.Model } -> { page : ( Main.Pages.Model.Model, Cmd Msg ), layout : Maybe ( Main.Layouts.Model.Model, Cmd Msg ) }
initPageAndLayout model =
    case Route.Path.fromUrl model.url of
        Route.Path.Authors ->
            let
                page : Page.Page Pages.Authors.Model Pages.Authors.Msg
                page =
                    Pages.Authors.page model.shared (Route.fromUrl () model.url)
            in
            { page =
                Tuple.mapBoth
                    Main.Pages.Model.Authors
                    (Effect.map Main.Pages.Msg.Authors >> fromPageEffect model)
                    (Page.init page ())
            , layout = Page.layout page |> Maybe.map (initLayout model)
            }

        Route.Path.BlogPosts ->
            let
                page : Page.Page Pages.BlogPosts.Model Pages.BlogPosts.Msg
                page =
                    Pages.BlogPosts.page model.shared (Route.fromUrl () model.url)
            in
            { page =
                Tuple.mapBoth
                    Main.Pages.Model.BlogPosts
                    (Effect.map Main.Pages.Msg.BlogPosts >> fromPageEffect model)
                    (Page.init page ())
            , layout = Page.layout page |> Maybe.map (initLayout model)
            }

        Route.Path.Home_ ->
            let
                page : Page.Page Pages.Home_.Model Pages.Home_.Msg
                page =
                    Pages.Home_.page model.shared (Route.fromUrl () model.url)
            in
            { page =
                Tuple.mapBoth
                    Main.Pages.Model.Home_
                    (Effect.map Main.Pages.Msg.Home_ >> fromPageEffect model)
                    (Page.init page ())
            , layout = Page.layout page |> Maybe.map (initLayout model)
            }

        Route.Path.NotFound_ ->
            { page = ( Main.Pages.Model.NotFound_, Cmd.none )
            , layout = Nothing
            }


runWhenAuthenticated : { model | shared : Shared.Model, url : Url, key : Browser.Navigation.Key } -> (Auth.User -> ( Main.Pages.Model.Model, Cmd Msg )) -> ( Main.Pages.Model.Model, Cmd Msg )
runWhenAuthenticated model toTuple =
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
                , toMainMsg = identity
                }
    in
    case authAction of
        Auth.Action.LoadPageWithUser user ->
            toTuple user

        Auth.Action.ShowLoadingPage loadingView ->
            ( Main.Pages.Model.Loading_ loadingView
            , Cmd.none
            )

        Auth.Action.ReplaceRoute options ->
            ( Main.Pages.Model.Redirecting_
            , toCmd (Effect.replaceRoute options)
            )

        Auth.Action.PushRoute options ->
            ( Main.Pages.Model.Redirecting_
            , toCmd (Effect.pushRoute options)
            )

        Auth.Action.LoadExternalUrl externalUrl ->
            ( Main.Pages.Model.Redirecting_
            , Browser.Navigation.load externalUrl
            )



-- UPDATE


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url
    | PageSent Main.Pages.Msg.Msg
    | LayoutSent Main.Layouts.Msg.Msg
    | SharedSent Shared.Msg


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
            if url.path == model.url.path then
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
                        { page } =
                            initPageAndLayout { key = model.key, shared = sharedModel, url = model.url, layout = model.layout }

                        ( pageModel, pageCmd ) =
                            page
                    in
                    ( { model | shared = sharedModel, page = pageModel }
                    , Cmd.batch
                        [ pageCmd
                        , fromSharedEffect { model | shared = sharedModel } sharedEffect
                        ]
                    )

                False ->
                    ( { model | shared = sharedModel }
                    , fromSharedEffect { model | shared = sharedModel } sharedEffect
                    )


updateFromPage : Main.Pages.Msg.Msg -> Model -> ( Main.Pages.Model.Model, Cmd Msg )
updateFromPage msg model =
    case ( msg, model.page ) of
        ( Main.Pages.Msg.Authors pageMsg, Main.Pages.Model.Authors pageModel ) ->
            Tuple.mapBoth
                Main.Pages.Model.Authors
                (Effect.map Main.Pages.Msg.Authors >> fromPageEffect model)
                (Page.update (Pages.Authors.page model.shared (Route.fromUrl () model.url)) pageMsg pageModel)

        ( Main.Pages.Msg.BlogPosts pageMsg, Main.Pages.Model.BlogPosts pageModel ) ->
            Tuple.mapBoth
                Main.Pages.Model.BlogPosts
                (Effect.map Main.Pages.Msg.BlogPosts >> fromPageEffect model)
                (Page.update (Pages.BlogPosts.page model.shared (Route.fromUrl () model.url)) pageMsg pageModel)

        ( Main.Pages.Msg.Home_ pageMsg, Main.Pages.Model.Home_ pageModel ) ->
            Tuple.mapBoth
                Main.Pages.Model.Home_
                (Effect.map Main.Pages.Msg.Home_ >> fromPageEffect model)
                (Page.update (Pages.Home_.page model.shared (Route.fromUrl () model.url)) pageMsg pageModel)

        ( Main.Pages.Msg.NotFound_, Main.Pages.Model.NotFound_ ) ->
            ( model.page
            , Cmd.none
            )

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
        ( Just (Layouts.Header settings), Just (Main.Layouts.Model.Header layoutModel), Main.Layouts.Msg.Header layoutMsg ) ->
            Tuple.mapBoth
                (\newModel -> Just (Main.Layouts.Model.Header { layoutModel | header = newModel }))
                (Effect.map Main.Layouts.Msg.Header >> fromLayoutEffect model)
                (Layout.update (Layouts.Header.layout settings.header model.shared route) layoutMsg layoutModel.header)

        ( Just (Layouts.Sidebar settings), Just (Main.Layouts.Model.Sidebar layoutModel), Main.Layouts.Msg.Sidebar layoutMsg ) ->
            Tuple.mapBoth
                (\newModel -> Just (Main.Layouts.Model.Sidebar { layoutModel | sidebar = newModel }))
                (Effect.map Main.Layouts.Msg.Sidebar >> fromLayoutEffect model)
                (Layout.update (Layouts.Sidebar.layout settings.sidebar model.shared route) layoutMsg layoutModel.sidebar)

        ( Just (Layouts.Sidebar_Header settings), Just (Main.Layouts.Model.Sidebar_Header layoutModel), Main.Layouts.Msg.Sidebar layoutMsg ) ->
            Tuple.mapBoth
                (\newModel -> Just (Main.Layouts.Model.Sidebar_Header { layoutModel | sidebar = newModel }))
                (Effect.map Main.Layouts.Msg.Sidebar >> fromLayoutEffect model)
                (Layout.update (Layouts.Sidebar.layout settings.sidebar model.shared route) layoutMsg layoutModel.sidebar)

        ( Just (Layouts.Sidebar_Header settings), Just (Main.Layouts.Model.Sidebar_Header layoutModel), Main.Layouts.Msg.Sidebar_Header layoutMsg ) ->
            Tuple.mapBoth
                (\newModel -> Just (Main.Layouts.Model.Sidebar_Header { layoutModel | header = newModel }))
                (Effect.map Main.Layouts.Msg.Sidebar_Header >> fromLayoutEffect model)
                (Layout.update (Layouts.Sidebar.Header.layout settings.header model.shared route) layoutMsg layoutModel.header)

        ( Just (Layouts.Sidebar_Header_Tabs settings), Just (Main.Layouts.Model.Sidebar_Header_Tabs layoutModel), Main.Layouts.Msg.Sidebar layoutMsg ) ->
            Tuple.mapBoth
                (\newModel -> Just (Main.Layouts.Model.Sidebar_Header_Tabs { layoutModel | sidebar = newModel }))
                (Effect.map Main.Layouts.Msg.Sidebar >> fromLayoutEffect model)
                (Layout.update (Layouts.Sidebar.layout settings.sidebar model.shared route) layoutMsg layoutModel.sidebar)

        ( Just (Layouts.Sidebar_Header_Tabs settings), Just (Main.Layouts.Model.Sidebar_Header_Tabs layoutModel), Main.Layouts.Msg.Sidebar_Header layoutMsg ) ->
            Tuple.mapBoth
                (\newModel -> Just (Main.Layouts.Model.Sidebar_Header_Tabs { layoutModel | header = newModel }))
                (Effect.map Main.Layouts.Msg.Sidebar_Header >> fromLayoutEffect model)
                (Layout.update (Layouts.Sidebar.Header.layout settings.header model.shared route) layoutMsg layoutModel.header)

        ( Just (Layouts.Sidebar_Header_Tabs settings), Just (Main.Layouts.Model.Sidebar_Header_Tabs layoutModel), Main.Layouts.Msg.Sidebar_Header_Tabs layoutMsg ) ->
            Tuple.mapBoth
                (\newModel -> Just (Main.Layouts.Model.Sidebar_Header_Tabs { layoutModel | tabs = newModel }))
                (Effect.map Main.Layouts.Msg.Sidebar_Header_Tabs >> fromLayoutEffect model)
                (Layout.update (Layouts.Sidebar.Header.Tabs.layout settings.tabs model.shared route) layoutMsg layoutModel.tabs)

        _ ->
            ( model.layout
            , Cmd.none
            )


toLayoutFromPage : Model -> Maybe Layouts.Layout
toLayoutFromPage model =
    case model.page of
        Main.Pages.Model.Authors pageModel ->
            Route.fromUrl () model.url
                |> Pages.Authors.page model.shared
                |> Page.layout

        Main.Pages.Model.BlogPosts pageModel ->
            Route.fromUrl () model.url
                |> Pages.BlogPosts.page model.shared
                |> Page.layout

        Main.Pages.Model.Home_ pageModel ->
            Route.fromUrl () model.url
                |> Pages.Home_.page model.shared
                |> Page.layout

        Main.Pages.Model.NotFound_ ->
            Nothing

        Main.Pages.Model.Redirecting_ ->
            Nothing

        Main.Pages.Model.Loading_ _ ->
            Nothing


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        subscriptionsFromPage : Sub Msg
        subscriptionsFromPage =
            case model.page of
                Main.Pages.Model.Authors pageModel ->
                    Page.subscriptions (Pages.Authors.page model.shared (Route.fromUrl () model.url)) pageModel
                        |> Sub.map Main.Pages.Msg.Authors
                        |> Sub.map PageSent

                Main.Pages.Model.BlogPosts pageModel ->
                    Page.subscriptions (Pages.BlogPosts.page model.shared (Route.fromUrl () model.url)) pageModel
                        |> Sub.map Main.Pages.Msg.BlogPosts
                        |> Sub.map PageSent

                Main.Pages.Model.Home_ pageModel ->
                    Page.subscriptions (Pages.Home_.page model.shared (Route.fromUrl () model.url)) pageModel
                        |> Sub.map Main.Pages.Msg.Home_
                        |> Sub.map PageSent

                Main.Pages.Model.NotFound_ ->
                    Sub.none

                Main.Pages.Model.Redirecting_ ->
                    Sub.none

                Main.Pages.Model.Loading_ _ ->
                    Sub.none

        maybeLayout : Maybe Layouts.Layout
        maybeLayout =
            toLayoutFromPage model

        route : Route ()
        route =
            Route.fromUrl () model.url

        subscriptionsFromLayout : Sub Msg
        subscriptionsFromLayout =
            case ( maybeLayout, model.layout ) of
                ( Just (Layouts.Header settings), Just (Main.Layouts.Model.Header layoutModel) ) ->
                    Layout.subscriptions (Layouts.Header.layout settings.header model.shared route) layoutModel.header
                        |> Sub.map Main.Layouts.Msg.Header
                        |> Sub.map LayoutSent

                ( Just (Layouts.Sidebar settings), Just (Main.Layouts.Model.Sidebar layoutModel) ) ->
                    Layout.subscriptions (Layouts.Sidebar.layout settings.sidebar model.shared route) layoutModel.sidebar
                        |> Sub.map Main.Layouts.Msg.Sidebar
                        |> Sub.map LayoutSent

                ( Just (Layouts.Sidebar_Header settings), Just (Main.Layouts.Model.Sidebar_Header layoutModel) ) ->
                    Sub.batch
                        [ Layout.subscriptions (Layouts.Sidebar.layout settings.sidebar model.shared route) layoutModel.sidebar
                            |> Sub.map Main.Layouts.Msg.Sidebar
                            |> Sub.map LayoutSent
                        , Layout.subscriptions (Layouts.Sidebar.Header.layout settings.header model.shared route) layoutModel.header
                            |> Sub.map Main.Layouts.Msg.Sidebar_Header
                            |> Sub.map LayoutSent
                        ]

                ( Just (Layouts.Sidebar_Header_Tabs settings), Just (Main.Layouts.Model.Sidebar_Header_Tabs layoutModel) ) ->
                    Sub.batch
                        [ Layout.subscriptions (Layouts.Sidebar.layout settings.sidebar model.shared route) layoutModel.sidebar
                            |> Sub.map Main.Layouts.Msg.Sidebar
                            |> Sub.map LayoutSent
                        , Layout.subscriptions (Layouts.Sidebar.Header.layout settings.header model.shared route) layoutModel.header
                            |> Sub.map Main.Layouts.Msg.Sidebar_Header
                            |> Sub.map LayoutSent
                        , Layout.subscriptions (Layouts.Sidebar.Header.Tabs.layout settings.tabs model.shared route) layoutModel.tabs
                            |> Sub.map Main.Layouts.Msg.Sidebar_Header_Tabs
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


view : Model -> View Msg
view model =
    let
        route : Route ()
        route =
            Route.fromUrl () model.url
    in
    case ( toLayoutFromPage model, model.layout ) of
        ( Just (Layouts.Header settings), Just (Main.Layouts.Model.Header layoutModel) ) ->
            Layout.view
                (Layouts.Header.layout settings.header model.shared route)
                { model = layoutModel.header
                , toMainMsg = Main.Layouts.Msg.Header >> LayoutSent
                , content = viewPage model
                }

        ( Just (Layouts.Sidebar settings), Just (Main.Layouts.Model.Sidebar layoutModel) ) ->
            Layout.view
                (Layouts.Sidebar.layout settings.sidebar model.shared route)
                { model = layoutModel.sidebar
                , toMainMsg = Main.Layouts.Msg.Sidebar >> LayoutSent
                , content = viewPage model
                }

        ( Just (Layouts.Sidebar_Header settings), Just (Main.Layouts.Model.Sidebar_Header layoutModel) ) ->
            Layout.view
                (Layouts.Sidebar.layout settings.sidebar model.shared route)
                { model = layoutModel.sidebar
                , toMainMsg = Main.Layouts.Msg.Sidebar >> LayoutSent
                , content =
                    Layout.view
                        (Layouts.Sidebar.Header.layout settings.header model.shared route)
                        { model = layoutModel.header
                        , toMainMsg = Main.Layouts.Msg.Sidebar_Header >> LayoutSent
                        , content = viewPage model
                        }
                }

        ( Just (Layouts.Sidebar_Header_Tabs settings), Just (Main.Layouts.Model.Sidebar_Header_Tabs layoutModel) ) ->
            Layout.view
                (Layouts.Sidebar.layout settings.sidebar model.shared route)
                { model = layoutModel.sidebar
                , toMainMsg = Main.Layouts.Msg.Sidebar >> LayoutSent
                , content =
                    Layout.view
                        (Layouts.Sidebar.Header.layout settings.header model.shared route)
                        { model = layoutModel.header
                        , toMainMsg = Main.Layouts.Msg.Sidebar_Header >> LayoutSent
                        , content =
                            Layout.view
                                (Layouts.Sidebar.Header.Tabs.layout settings.tabs model.shared route)
                                { model = layoutModel.tabs
                                , toMainMsg = Main.Layouts.Msg.Sidebar_Header_Tabs >> LayoutSent
                                , content = viewPage model
                                }
                        }
                }

        _ ->
            viewPage model


viewPage : Model -> View Msg
viewPage model =
    case model.page of
        Main.Pages.Model.Authors pageModel ->
            Page.view (Pages.Authors.page model.shared (Route.fromUrl () model.url)) pageModel
                |> View.map Main.Pages.Msg.Authors
                |> View.map PageSent

        Main.Pages.Model.BlogPosts pageModel ->
            Page.view (Pages.BlogPosts.page model.shared (Route.fromUrl () model.url)) pageModel
                |> View.map Main.Pages.Msg.BlogPosts
                |> View.map PageSent

        Main.Pages.Model.Home_ pageModel ->
            Page.view (Pages.Home_.page model.shared (Route.fromUrl () model.url)) pageModel
                |> View.map Main.Pages.Msg.Home_
                |> View.map PageSent

        Main.Pages.Model.NotFound_ ->
            Pages.NotFound_.page

        Main.Pages.Model.Redirecting_ ->
            View.none

        Main.Pages.Model.Loading_ loadingView ->
            View.map never loadingView



-- INTERNALS


fromPageEffect : { model | key : Browser.Navigation.Key, url : Url, shared : Shared.Model } -> Effect Main.Pages.Msg.Msg -> Cmd Msg
fromPageEffect model effect =
    Effect.toCmd
        { key = model.key
        , url = model.url
        , shared = model.shared
        , toMainMsg = PageSent
        , fromSharedMsg = SharedSent
        }
        effect


fromLayoutEffect : { model | key : Browser.Navigation.Key, url : Url, shared : Shared.Model } -> Effect Main.Layouts.Msg.Msg -> Cmd Msg
fromLayoutEffect model effect =
    Effect.toCmd
        { key = model.key
        , url = model.url
        , shared = model.shared
        , toMainMsg = LayoutSent
        , fromSharedMsg = SharedSent
        }
        effect


fromSharedEffect : { model | key : Browser.Navigation.Key, url : Url, shared : Shared.Model } -> Effect Shared.Msg -> Cmd Msg
fromSharedEffect model effect =
    Effect.toCmd
        { key = model.key
        , url = model.url
        , shared = model.shared
        , toMainMsg = SharedSent
        , fromSharedMsg = SharedSent
        }
        effect
