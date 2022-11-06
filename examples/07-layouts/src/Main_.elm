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
import Layouts.Sidebar.WithHeader
import Page
import Pages.Authors
import Pages.BlogPosts
import Pages.Home_
import Pages.NotFound_
import Route
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
    , page : PageModel
    , layout : Maybe LayoutModel
    , shared : Shared.Model
    }


type PageModel
    = PageModelAuthors Pages.Authors.Model
    | PageModelBlogPosts Pages.BlogPosts.Model
    | PageModelHome_ Pages.Home_.Model
    | PageModelNotFound_
    | Redirecting
    | Loading (View Never)


type LayoutModel
    = LayoutModelHeader Layouts.Header.Model
    | LayoutModelSidebar__WithHeader
        { sidebar : Layouts.Sidebar.Model
        , withHeader : Layouts.Sidebar.WithHeader.Model
        }
    | LayoutModelSidebar Layouts.Sidebar.Model


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


initLayout : { key : Browser.Navigation.Key, url : Url, shared : Shared.Model, layout : Maybe LayoutModel } -> Layouts.Layout -> ( LayoutModel, Cmd Msg )
initLayout model layout =
    case ( layout, model.layout ) of
        ( Layouts.Header settings, Just (LayoutModelHeader existing) ) ->
            ( LayoutModelHeader existing
            , Cmd.none
            )

        ( Layouts.Header settings, _ ) ->
            let
                ( layoutModel, layoutCmd ) =
                    Layout.init (Layouts.Header.layout settings model.shared (Route.fromUrl () model.url)) ()
            in
            ( LayoutModelHeader layoutModel
            , fromLayoutEffect model (Effect.map Msg_LayoutHeader layoutCmd)
            )

        ( Layouts.Sidebar settings, Just (LayoutModelSidebar existing) ) ->
            ( LayoutModelSidebar existing
            , Cmd.none
            )

        ( Layouts.Sidebar settings, _ ) ->
            let
                ( layoutModel, layoutCmd ) =
                    Layout.init (Layouts.Sidebar.layout settings model.shared (Route.fromUrl () model.url)) ()
            in
            ( LayoutModelSidebar layoutModel
            , fromLayoutEffect model (Effect.map Msg_LayoutSidebar layoutCmd)
            )

        ( Layouts.Sidebar__WithHeader settings, Just (LayoutModelSidebar__WithHeader existing) ) ->
            ( LayoutModelSidebar__WithHeader existing
            , Cmd.none
            )

        ( Layouts.Sidebar__WithHeader settings, Just (LayoutModelSidebar sidebarLayoutModel) ) ->
            let
                ( layoutModel, layoutCmd ) =
                    Layout.init (Layouts.Sidebar.WithHeader.layout settings.withHeader model.shared (Route.fromUrl () model.url)) ()
            in
            ( LayoutModelSidebar__WithHeader { sidebar = sidebarLayoutModel, withHeader = layoutModel }
            , fromLayoutEffect model (Effect.map Msg_LayoutSidebar__WithHeader layoutCmd)
            )

        ( Layouts.Sidebar__WithHeader settings, _ ) ->
            let
                ( sidebarLayoutModel, sidebarLayoutCmd ) =
                    Layout.init (Layouts.Sidebar.layout settings.sidebar model.shared (Route.fromUrl () model.url)) ()

                ( withHeaderLayoutModel, withHeaderLayoutCmd ) =
                    Layout.init (Layouts.Sidebar.WithHeader.layout settings.withHeader model.shared (Route.fromUrl () model.url)) ()
            in
            ( LayoutModelSidebar__WithHeader { sidebar = sidebarLayoutModel, withHeader = withHeaderLayoutModel }
            , Cmd.batch
                [ fromLayoutEffect model (Effect.map Msg_LayoutSidebar sidebarLayoutCmd)
                , fromLayoutEffect model (Effect.map Msg_LayoutSidebar__WithHeader withHeaderLayoutCmd)
                ]
            )


initPageAndLayout : { key : Browser.Navigation.Key, url : Url, shared : Shared.Model, layout : Maybe LayoutModel } -> { page : ( PageModel, Cmd Msg ), layout : Maybe ( LayoutModel, Cmd Msg ) }
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
                    PageModelAuthors
                    (Effect.map Msg_Authors >> fromPageEffect model)
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
                    PageModelBlogPosts
                    (Effect.map Msg_BlogPosts >> fromPageEffect model)
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
                    PageModelHome_
                    (Effect.map Msg_Home_ >> fromPageEffect model)
                    (Page.init page ())
            , layout = Page.layout page |> Maybe.map (initLayout model)
            }

        Route.Path.NotFound_ ->
            { page = ( PageModelNotFound_, Cmd.none )
            , layout = Nothing
            }


runWhenAuthenticated : { model | shared : Shared.Model, url : Url, key : Browser.Navigation.Key } -> (Auth.User -> ( PageModel, Cmd Msg )) -> ( PageModel, Cmd Msg )
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
            ( Loading loadingView
            , Cmd.none
            )

        Auth.Action.ReplaceRoute options ->
            ( Redirecting
            , toCmd (Effect.replaceRoute options)
            )

        Auth.Action.PushRoute options ->
            ( Redirecting
            , toCmd (Effect.pushRoute options)
            )

        Auth.Action.LoadExternalUrl externalUrl ->
            ( Redirecting
            , Browser.Navigation.load externalUrl
            )



-- UPDATE


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url
    | PageSent PageMsg
    | LayoutSent LayoutMsg
    | SharedSent Shared.Msg


type PageMsg
    = Msg_Authors Pages.Authors.Msg
    | Msg_BlogPosts Pages.BlogPosts.Msg
    | Msg_Home_ Pages.Home_.Msg
    | Msg_NotFound_


type LayoutMsg
    = Msg_LayoutHeader Layouts.Header.Msg
    | Msg_LayoutSidebar__WithHeader Layouts.Sidebar.WithHeader.Msg
    | Msg_LayoutSidebar Layouts.Sidebar.Msg


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


updateFromPage : PageMsg -> Model -> ( PageModel, Cmd Msg )
updateFromPage msg model =
    case ( msg, model.page ) of
        ( Msg_Authors pageMsg, PageModelAuthors pageModel ) ->
            Tuple.mapBoth
                PageModelAuthors
                (Effect.map Msg_Authors >> fromPageEffect model)
                (Page.update (Pages.Authors.page model.shared (Route.fromUrl () model.url)) pageMsg pageModel)

        ( Msg_BlogPosts pageMsg, PageModelBlogPosts pageModel ) ->
            Tuple.mapBoth
                PageModelBlogPosts
                (Effect.map Msg_BlogPosts >> fromPageEffect model)
                (Page.update (Pages.BlogPosts.page model.shared (Route.fromUrl () model.url)) pageMsg pageModel)

        ( Msg_Home_ pageMsg, PageModelHome_ pageModel ) ->
            Tuple.mapBoth
                PageModelHome_
                (Effect.map Msg_Home_ >> fromPageEffect model)
                (Page.update (Pages.Home_.page model.shared (Route.fromUrl () model.url)) pageMsg pageModel)

        ( Msg_NotFound_, PageModelNotFound_ ) ->
            ( model.page
            , Cmd.none
            )

        _ ->
            ( model.page
            , Cmd.none
            )


updateFromLayout : LayoutMsg -> Model -> ( Maybe LayoutModel, Cmd Msg )
updateFromLayout msg model =
    let
        maybeLayout : Maybe Layouts.Layout
        maybeLayout =
            toLayoutFromPage model
    in
    case ( maybeLayout, msg, model.layout ) of
        ( Just (Layouts.Header settings), Msg_LayoutHeader layoutMsg, Just (LayoutModelHeader layoutModel) ) ->
            Tuple.mapBoth
                (\newModel -> Just (LayoutModelHeader newModel))
                (Effect.map Msg_LayoutHeader >> fromLayoutEffect model)
                (Layout.update (Layouts.Header.layout settings model.shared (Route.fromUrl () model.url)) layoutMsg layoutModel)

        ( Just (Layouts.Sidebar__WithHeader settings), Msg_LayoutSidebar layoutMsg, Just (LayoutModelSidebar__WithHeader layoutModels) ) ->
            Tuple.mapBoth
                (\withSidebarLayoutModel -> Just (LayoutModelSidebar__WithHeader { layoutModels | sidebar = withSidebarLayoutModel }))
                (Effect.map Msg_LayoutSidebar >> fromLayoutEffect model)
                (Layout.update (Layouts.Sidebar.layout settings.withHeader model.shared (Route.fromUrl () model.url)) layoutMsg layoutModels.sidebar)

        ( Just (Layouts.Sidebar__WithHeader settings), Msg_LayoutSidebar__WithHeader layoutMsg, Just (LayoutModelSidebar__WithHeader layoutModels) ) ->
            Tuple.mapBoth
                (\withHeaderLayoutModel -> Just (LayoutModelSidebar__WithHeader { layoutModels | withHeader = withHeaderLayoutModel }))
                (Effect.map Msg_LayoutSidebar__WithHeader >> fromLayoutEffect model)
                (Layout.update (Layouts.Sidebar.WithHeader.layout settings.withHeader model.shared (Route.fromUrl () model.url)) layoutMsg layoutModels.withHeader)

        ( Just (Layouts.Sidebar settings), Msg_LayoutSidebar layoutMsg, Just (LayoutModelSidebar layoutModel) ) ->
            Tuple.mapBoth
                (\newModel -> Just (LayoutModelSidebar layoutModel))
                (Effect.map Msg_LayoutSidebar >> fromLayoutEffect model)
                (Layout.update (Layouts.Sidebar.layout settings model.shared (Route.fromUrl () model.url)) layoutMsg layoutModel)

        _ ->
            ( model.layout
            , Cmd.none
            )


toLayoutFromPage : Model -> Maybe Layouts.Layout
toLayoutFromPage model =
    case model.page of
        PageModelAuthors pageModel ->
            let
                page =
                    Pages.Authors.page model.shared (Route.fromUrl () model.url)
            in
            Page.layout page

        PageModelBlogPosts pageModel ->
            let
                page =
                    Pages.BlogPosts.page model.shared (Route.fromUrl () model.url)
            in
            Page.layout page

        PageModelHome_ pageModel ->
            let
                page =
                    Pages.Home_.page model.shared (Route.fromUrl () model.url)
            in
            Page.layout page

        PageModelNotFound_ ->
            Nothing

        Redirecting ->
            Nothing

        Loading _ ->
            Nothing


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        fromPage : { subscriptions : Sub Msg, maybeLayout : Maybe Layouts.Layout }
        fromPage =
            case model.page of
                PageModelAuthors pageModel ->
                    let
                        page =
                            Pages.Authors.page model.shared (Route.fromUrl () model.url)
                    in
                    { subscriptions =
                        Page.subscriptions page pageModel
                            |> Sub.map Msg_Authors
                            |> Sub.map PageSent
                    , maybeLayout = Page.layout page
                    }

                PageModelBlogPosts pageModel ->
                    let
                        page =
                            Pages.BlogPosts.page model.shared (Route.fromUrl () model.url)
                    in
                    { subscriptions =
                        Page.subscriptions page pageModel
                            |> Sub.map Msg_BlogPosts
                            |> Sub.map PageSent
                    , maybeLayout = Page.layout page
                    }

                PageModelHome_ pageModel ->
                    let
                        page =
                            Pages.Home_.page model.shared (Route.fromUrl () model.url)
                    in
                    { subscriptions =
                        Page.subscriptions page pageModel
                            |> Sub.map Msg_Home_
                            |> Sub.map PageSent
                    , maybeLayout = Page.layout page
                    }

                PageModelNotFound_ ->
                    { subscriptions = Sub.none, maybeLayout = Nothing }

                Redirecting ->
                    { subscriptions = Sub.none, maybeLayout = Nothing }

                Loading _ ->
                    { subscriptions = Sub.none, maybeLayout = Nothing }

        maybeLayout : Maybe Layouts.Layout
        maybeLayout =
            Nothing

        -- TODO
        subscriptionsFromLayout : Sub Msg
        subscriptionsFromLayout =
            case ( maybeLayout, model.layout ) of
                ( Just (Layouts.Header settings), Just (LayoutModelHeader layoutModel) ) ->
                    Layout.subscriptions (Layouts.Header.layout settings model.shared (Route.fromUrl () model.url)) layoutModel
                        |> Sub.map Msg_LayoutHeader
                        |> Sub.map LayoutSent

                ( Just (Layouts.Sidebar__WithHeader settings), Just (LayoutModelSidebar__WithHeader layoutModels) ) ->
                    Sub.batch
                        [ Layout.subscriptions (Layouts.Sidebar.WithHeader.layout settings.withHeader model.shared (Route.fromUrl () model.url)) layoutModels.withHeader
                            |> Sub.map Msg_LayoutSidebar__WithHeader
                            |> Sub.map LayoutSent
                        , Layout.subscriptions (Layouts.Sidebar.layout settings.sidebar model.shared (Route.fromUrl () model.url)) layoutModels.sidebar
                            |> Sub.map Msg_LayoutSidebar
                            |> Sub.map LayoutSent
                        ]

                ( Just (Layouts.Sidebar settings), Just (LayoutModelSidebar layoutModel) ) ->
                    Layout.subscriptions (Layouts.Sidebar.layout settings model.shared (Route.fromUrl () model.url)) layoutModel
                        |> Sub.map Msg_LayoutSidebar
                        |> Sub.map LayoutSent

                _ ->
                    Sub.none
    in
    Sub.batch
        [ Shared.subscriptions (Route.fromUrl () model.url) model.shared
            |> Sub.map SharedSent
        , fromPage.subscriptions
        , subscriptionsFromLayout
        ]



-- VIEW


view : Model -> View Msg
view model =
    let
        route : Route.Route ()
        route =
            Route.fromUrl () model.url

        page : { view : View Msg, maybeLayout : Maybe Layouts.Layout }
        page =
            viewPage model
    in
    case ( page.maybeLayout, model.layout ) of
        ( Just (Layouts.Header settings), Just (LayoutModelHeader layoutModel) ) ->
            Layout.view
                (Layouts.Header.layout settings model.shared route)
                { model = layoutModel
                , toMainMsg = Msg_LayoutHeader >> LayoutSent
                , content = page.view
                }

        ( Just (Layouts.Sidebar__WithHeader settings), Just (LayoutModelSidebar__WithHeader layoutModels) ) ->
            Layout.view
                (Layouts.Sidebar.layout settings.sidebar model.shared route)
                { model = layoutModels.sidebar
                , toMainMsg = Msg_LayoutSidebar >> LayoutSent
                , content =
                    Layout.view
                        (Layouts.Sidebar.WithHeader.layout settings.withHeader model.shared route)
                        { model = layoutModels.withHeader
                        , toMainMsg = Msg_LayoutSidebar__WithHeader >> LayoutSent
                        , content = page.view
                        }
                }

        ( Just (Layouts.Sidebar settings), Just (LayoutModelSidebar layoutModel) ) ->
            Layout.view
                (Layouts.Sidebar.layout settings model.shared route)
                { model = layoutModel
                , toMainMsg = Msg_LayoutSidebar >> LayoutSent
                , content = page.view
                }

        _ ->
            page.view


viewPage : Model -> { view : View Msg, maybeLayout : Maybe Layouts.Layout }
viewPage model =
    case model.page of
        PageModelAuthors pageModel ->
            let
                page =
                    Pages.Authors.page model.shared (Route.fromUrl () model.url)
            in
            { view =
                Page.view page pageModel
                    |> View.map Msg_Authors
                    |> View.map PageSent
            , maybeLayout = Page.layout page
            }

        PageModelBlogPosts pageModel ->
            let
                page =
                    Pages.BlogPosts.page model.shared (Route.fromUrl () model.url)
            in
            { view =
                Page.view page pageModel
                    |> View.map Msg_BlogPosts
                    |> View.map PageSent
            , maybeLayout = Page.layout page
            }

        PageModelHome_ pageModel ->
            let
                page =
                    Pages.Home_.page model.shared (Route.fromUrl () model.url)
            in
            { view =
                Page.view page pageModel
                    |> View.map Msg_Home_
                    |> View.map PageSent
            , maybeLayout = Page.layout page
            }

        PageModelNotFound_ ->
            { view = Pages.NotFound_.page, maybeLayout = Nothing }

        Redirecting ->
            { view = View.none, maybeLayout = Nothing }

        Loading loadingView ->
            { view = View.map never loadingView, maybeLayout = Nothing }



-- INTERNALS


fromPageEffect : { model | key : Browser.Navigation.Key, url : Url, shared : Shared.Model } -> Effect PageMsg -> Cmd Msg
fromPageEffect model effect =
    Effect.toCmd
        { key = model.key
        , url = model.url
        , shared = model.shared
        , toMainMsg = PageSent
        , fromSharedMsg = SharedSent
        }
        effect


fromLayoutEffect : { model | key : Browser.Navigation.Key, url : Url, shared : Shared.Model } -> Effect LayoutMsg -> Cmd Msg
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
