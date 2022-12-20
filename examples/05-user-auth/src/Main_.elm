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
import Layouts.Sidebar
import Main.Layouts.Model
import Main.Layouts.Msg
import Main.Pages.Model
import Main.Pages.Msg
import Page
import Pages.Home_
import Pages.NotFound_
import Pages.Profile.Me
import Pages.Settings
import Pages.SignIn
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


initLayout : { key : Browser.Navigation.Key, url : Url, shared : Shared.Model, layout : Maybe Main.Layouts.Model.Model } -> Layouts.Layout -> ( Main.Layouts.Model.Model, Cmd Msg )
initLayout model layout =
    case ( layout, model.layout ) of
        ( Layouts.Sidebar settings, Just (Main.Layouts.Model.Sidebar existing) ) ->
            ( Main.Layouts.Model.Sidebar existing
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


initPageAndLayout : { key : Browser.Navigation.Key, url : Url, shared : Shared.Model, layout : Maybe Main.Layouts.Model.Model } -> { page : ( Main.Pages.Model.Model, Cmd Msg ), layout : Maybe ( Main.Layouts.Model.Model, Cmd Msg ) }
initPageAndLayout model =
    case Route.Path.fromUrl model.url of
        Route.Path.Home_ ->
            runWhenAuthenticatedWithLayout
                model
                (\user ->
                    let
                        page : Page.Page Pages.Home_.Model Pages.Home_.Msg
                        page =
                            Pages.Home_.page user model.shared (Route.fromUrl () model.url)

                        ( pageModel, pageEffect ) =
                            Page.init page ()
                    in
                    { page =
                        Tuple.mapBoth
                            Main.Pages.Model.Home_
                            (Effect.map Main.Pages.Msg.Home_ >> fromPageEffect model)
                            ( pageModel, pageEffect )
                    , layout = Page.layout pageModel page |> Maybe.map (initLayout model)
                    }
                )

        Route.Path.Profile_Me ->
            runWhenAuthenticatedWithLayout
                model
                (\user ->
                    let
                        page : Page.Page Pages.Profile.Me.Model Pages.Profile.Me.Msg
                        page =
                            Pages.Profile.Me.page user model.shared (Route.fromUrl () model.url)

                        ( pageModel, pageEffect ) =
                            Page.init page ()
                    in
                    { page =
                        Tuple.mapBoth
                            Main.Pages.Model.Profile_Me
                            (Effect.map Main.Pages.Msg.Profile_Me >> fromPageEffect model)
                            ( pageModel, pageEffect )
                    , layout = Page.layout pageModel page |> Maybe.map (initLayout model)
                    }
                )

        Route.Path.Settings ->
            runWhenAuthenticatedWithLayout
                model
                (\user ->
                    let
                        page : Page.Page Pages.Settings.Model Pages.Settings.Msg
                        page =
                            Pages.Settings.page user model.shared (Route.fromUrl () model.url)

                        ( pageModel, pageEffect ) =
                            Page.init page ()
                    in
                    { page =
                        Tuple.mapBoth
                            Main.Pages.Model.Settings
                            (Effect.map Main.Pages.Msg.Settings >> fromPageEffect model)
                            ( pageModel, pageEffect )
                    , layout = Page.layout pageModel page |> Maybe.map (initLayout model)
                    }
                )

        Route.Path.SignIn ->
            let
                page : Page.Page Pages.SignIn.Model Pages.SignIn.Msg
                page =
                    Pages.SignIn.page model.shared (Route.fromUrl () model.url)

                ( pageModel, pageEffect ) =
                    Page.init page ()
            in
            { page =
                Tuple.mapBoth
                    Main.Pages.Model.SignIn
                    (Effect.map Main.Pages.Msg.SignIn >> fromPageEffect model)
                    ( pageModel, pageEffect )
            , layout = Page.layout pageModel page |> Maybe.map (initLayout model)
            }

        Route.Path.NotFound_ ->
            { page = ( Main.Pages.Model.NotFound_, Cmd.none )
            , layout = Nothing
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
                , fromCmd = EffectSentCmd
                , toCmd = Task.succeed >> Task.perform identity
                }
    in
    case authAction of
        Auth.Action.LoadPageWithUser user ->
            toRecord user

        Auth.Action.ShowLoadingPage loadingView ->
            { page =
                ( Main.Pages.Model.Loading_ loadingView
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
    | EffectSentCmd (Cmd Msg)


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

        EffectSentCmd cmd ->
            ( model
            , cmd
            )


updateFromPage : Main.Pages.Msg.Msg -> Model -> ( Main.Pages.Model.Model, Cmd Msg )
updateFromPage msg model =
    case ( msg, model.page ) of
        ( Main.Pages.Msg.Home_ pageMsg, Main.Pages.Model.Home_ pageModel ) ->
            runWhenAuthenticated
                model
                (\user ->
                    Tuple.mapBoth
                        Main.Pages.Model.Home_
                        (Effect.map Main.Pages.Msg.Home_ >> fromPageEffect model)
                        (Page.update (Pages.Home_.page user model.shared (Route.fromUrl () model.url)) pageMsg pageModel)
                )

        ( Main.Pages.Msg.Profile_Me pageMsg, Main.Pages.Model.Profile_Me pageModel ) ->
            runWhenAuthenticated
                model
                (\user ->
                    Tuple.mapBoth
                        Main.Pages.Model.Profile_Me
                        (Effect.map Main.Pages.Msg.Profile_Me >> fromPageEffect model)
                        (Page.update (Pages.Profile.Me.page user model.shared (Route.fromUrl () model.url)) pageMsg pageModel)
                )

        ( Main.Pages.Msg.Settings pageMsg, Main.Pages.Model.Settings pageModel ) ->
            runWhenAuthenticated
                model
                (\user ->
                    Tuple.mapBoth
                        Main.Pages.Model.Settings
                        (Effect.map Main.Pages.Msg.Settings >> fromPageEffect model)
                        (Page.update (Pages.Settings.page user model.shared (Route.fromUrl () model.url)) pageMsg pageModel)
                )

        ( Main.Pages.Msg.SignIn pageMsg, Main.Pages.Model.SignIn pageModel ) ->
            Tuple.mapBoth
                Main.Pages.Model.SignIn
                (Effect.map Main.Pages.Msg.SignIn >> fromPageEffect model)
                (Page.update (Pages.SignIn.page model.shared (Route.fromUrl () model.url)) pageMsg pageModel)

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
        ( Just (Layouts.Sidebar settings), Just (Main.Layouts.Model.Sidebar layoutModel), Main.Layouts.Msg.Sidebar layoutMsg ) ->
            Tuple.mapBoth
                (\newModel -> Just (Main.Layouts.Model.Sidebar { layoutModel | sidebar = newModel }))
                (Effect.map Main.Layouts.Msg.Sidebar >> fromLayoutEffect model)
                (Layout.update (Layouts.Sidebar.layout settings.sidebar model.shared route) layoutMsg layoutModel.sidebar)

        _ ->
            ( model.layout
            , Cmd.none
            )


toLayoutFromPage : Model -> Maybe Layouts.Layout
toLayoutFromPage model =
    case model.page of
        Main.Pages.Model.Home_ pageModel ->
            Route.fromUrl () model.url
                |> toAuthProtectedPage model Pages.Home_.page
                |> Maybe.andThen (Page.layout pageModel)

        Main.Pages.Model.Profile_Me pageModel ->
            Route.fromUrl () model.url
                |> toAuthProtectedPage model Pages.Profile.Me.page
                |> Maybe.andThen (Page.layout pageModel)

        Main.Pages.Model.Settings pageModel ->
            Route.fromUrl () model.url
                |> toAuthProtectedPage model Pages.Settings.page
                |> Maybe.andThen (Page.layout pageModel)

        Main.Pages.Model.SignIn pageModel ->
            Route.fromUrl () model.url
                |> Pages.SignIn.page model.shared
                |> Page.layout pageModel

        Main.Pages.Model.NotFound_ ->
            Nothing

        Main.Pages.Model.Redirecting_ ->
            Nothing

        Main.Pages.Model.Loading_ _ ->
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
                    Auth.Action.subscriptions
                        (\user ->
                            Page.subscriptions (Pages.Home_.page user model.shared (Route.fromUrl () model.url)) pageModel
                                |> Sub.map Main.Pages.Msg.Home_
                                |> Sub.map PageSent
                        )
                        (Auth.onPageLoad model.shared (Route.fromUrl () model.url))

                Main.Pages.Model.Profile_Me pageModel ->
                    Auth.Action.subscriptions
                        (\user ->
                            Page.subscriptions (Pages.Profile.Me.page user model.shared (Route.fromUrl () model.url)) pageModel
                                |> Sub.map Main.Pages.Msg.Profile_Me
                                |> Sub.map PageSent
                        )
                        (Auth.onPageLoad model.shared (Route.fromUrl () model.url))

                Main.Pages.Model.Settings pageModel ->
                    Auth.Action.subscriptions
                        (\user ->
                            Page.subscriptions (Pages.Settings.page user model.shared (Route.fromUrl () model.url)) pageModel
                                |> Sub.map Main.Pages.Msg.Settings
                                |> Sub.map PageSent
                        )
                        (Auth.onPageLoad model.shared (Route.fromUrl () model.url))

                Main.Pages.Model.SignIn pageModel ->
                    Page.subscriptions (Pages.SignIn.page model.shared (Route.fromUrl () model.url)) pageModel
                        |> Sub.map Main.Pages.Msg.SignIn
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
                ( Just (Layouts.Sidebar settings), Just (Main.Layouts.Model.Sidebar layoutModel) ) ->
                    Layout.subscriptions (Layouts.Sidebar.layout settings.sidebar model.shared route) layoutModel.sidebar
                        |> Sub.map Main.Layouts.Msg.Sidebar
                        |> Sub.map LayoutSent

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
                (Layouts.Sidebar.layout settings.sidebar model.shared route)
                { model = layoutModel.sidebar
                , fromMsg = Main.Layouts.Msg.Sidebar >> LayoutSent
                , content = viewPage model
                }

        _ ->
            viewPage model


viewPage : Model -> View Msg
viewPage model =
    case model.page of
        Main.Pages.Model.Home_ pageModel ->
            Auth.Action.view
                (\user ->
                    Page.view (Pages.Home_.page user model.shared (Route.fromUrl () model.url)) pageModel
                        |> View.map Main.Pages.Msg.Home_
                        |> View.map PageSent
                )
                (Auth.onPageLoad model.shared (Route.fromUrl () model.url))

        Main.Pages.Model.Profile_Me pageModel ->
            Auth.Action.view
                (\user ->
                    Page.view (Pages.Profile.Me.page user model.shared (Route.fromUrl () model.url)) pageModel
                        |> View.map Main.Pages.Msg.Profile_Me
                        |> View.map PageSent
                )
                (Auth.onPageLoad model.shared (Route.fromUrl () model.url))

        Main.Pages.Model.Settings pageModel ->
            Auth.Action.view
                (\user ->
                    Page.view (Pages.Settings.page user model.shared (Route.fromUrl () model.url)) pageModel
                        |> View.map Main.Pages.Msg.Settings
                        |> View.map PageSent
                )
                (Auth.onPageLoad model.shared (Route.fromUrl () model.url))

        Main.Pages.Model.SignIn pageModel ->
            Page.view (Pages.SignIn.page model.shared (Route.fromUrl () model.url)) pageModel
                |> View.map Main.Pages.Msg.SignIn
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
        , fromSharedMsg = SharedSent
        , fromCmd = EffectSentCmd
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
        , fromCmd = EffectSentCmd
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
        , fromCmd = EffectSentCmd
        , toCmd = Task.succeed >> Task.perform identity
        }
        (Effect.map SharedSent effect)
