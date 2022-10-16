module Main exposing (main)

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
    = LayoutModelSidebar { settings : Layouts.Sidebar.Settings, model : Layouts.Sidebar.Model }


init : Json.Decode.Value -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init json url key =
    let
        flagsResult : Result Json.Decode.Error Shared.Flags
        flagsResult =
            Json.Decode.decodeValue Shared.decoder json

        ( sharedModel, sharedEffect ) =
            Shared.init flagsResult (Route.fromUrl () url)

        { page, layout } =
            initPage { key = key, url = url, shared = sharedModel }
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


initLayout : { key : Browser.Navigation.Key, url : Url, shared : Shared.Model } -> Layouts.Layout -> ( LayoutModel, Cmd Msg )
initLayout model layout =
    case layout of
        Layouts.Sidebar settings ->
            let
                ( layoutModel, layoutCmd ) =
                    Layout.init (Layouts.Sidebar.layout settings model.shared (Route.fromUrl () model.url)) ()
            in
            ( LayoutModelSidebar { settings = settings, model = layoutModel }
            , fromLayoutEffect model (Effect.map Msg_LayoutSidebar layoutCmd)
            )


initPage : { key : Browser.Navigation.Key, url : Url, shared : Shared.Model } -> { page : ( PageModel, Cmd Msg ), layout : Maybe ( LayoutModel, Cmd Msg ) }
initPage model =
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
            { page =
                ( PageModelNotFound_
                , Cmd.none
                )
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
    = Msg_LayoutSidebar Layouts.Sidebar.Msg


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
                        initPage { key = model.key, shared = model.shared, url = url }
                in
                ( { model
                    | url = url
                    , page = Tuple.first page
                    , layout = layout |> Maybe.map Tuple.first
                  }
                , Cmd.batch
                    [ Tuple.second page
                    , layout |> Maybe.map Tuple.second |> Maybe.withDefault Cmd.none
                    ]
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
                        { page, layout } =
                            initPage { key = model.key, shared = sharedModel, url = model.url }
                    in
                    ( { model | shared = sharedModel, page = Tuple.first page }
                    , Cmd.batch
                        [ Tuple.second page
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
    case ( msg, model.layout ) of
        ( Msg_LayoutSidebar layoutMsg, Just (LayoutModelSidebar layout) ) ->
            Tuple.mapBoth
                (\newModel -> Just (LayoutModelSidebar { layout | model = newModel }))
                (Effect.map Msg_LayoutSidebar >> fromLayoutEffect model)
                (Layout.update (Layouts.Sidebar.layout layout.settings model.shared (Route.fromUrl () model.url)) layoutMsg layout.model)

        _ ->
            ( model.layout
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        subscriptionsFromPage : Sub Msg
        subscriptionsFromPage =
            case model.page of
                PageModelAuthors pageModel ->
                    Page.subscriptions (Pages.Authors.page model.shared (Route.fromUrl () model.url)) pageModel
                        |> Sub.map Msg_Authors
                        |> Sub.map PageSent

                PageModelBlogPosts pageModel ->
                    Page.subscriptions (Pages.BlogPosts.page model.shared (Route.fromUrl () model.url)) pageModel
                        |> Sub.map Msg_BlogPosts
                        |> Sub.map PageSent

                PageModelHome_ pageModel ->
                    Page.subscriptions (Pages.Home_.page model.shared (Route.fromUrl () model.url)) pageModel
                        |> Sub.map Msg_Home_
                        |> Sub.map PageSent

                PageModelNotFound_ ->
                    Sub.none

                Redirecting ->
                    Sub.none

                Loading _ ->
                    Sub.none

        subscriptionsFromLayout : Sub Msg
        subscriptionsFromLayout =
            case model.layout of
                Just (LayoutModelSidebar layout) ->
                    Layout.subscriptions (Layouts.Sidebar.layout layout.settings model.shared (Route.fromUrl () model.url)) layout.model
                        |> Sub.map Msg_LayoutSidebar
                        |> Sub.map LayoutSent

                Nothing ->
                    Sub.none
    in
    Sub.batch
        [ Shared.subscriptions (Route.fromUrl () model.url) model.shared
            |> Sub.map SharedSent
        , subscriptionsFromPage
        , subscriptionsFromLayout
        ]



-- VIEW


view : Model -> View Msg
view model =
    case model.layout of
        Just (LayoutModelSidebar layout) ->
            Layout.view (Layouts.Sidebar.layout layout.settings model.shared (Route.fromUrl () model.url))
                { model = layout.model
                , toMainMsg = Msg_LayoutSidebar >> LayoutSent
                , content = viewPage model
                }

        Nothing ->
            viewPage model


viewPage : Model -> View Msg
viewPage model =
    case model.page of
        PageModelAuthors pageModel ->
            Page.view (Pages.Authors.page model.shared (Route.fromUrl () model.url)) pageModel
                |> View.map Msg_Authors
                |> View.map PageSent

        PageModelBlogPosts pageModel ->
            Page.view (Pages.BlogPosts.page model.shared (Route.fromUrl () model.url)) pageModel
                |> View.map Msg_BlogPosts
                |> View.map PageSent

        PageModelHome_ pageModel ->
            Page.view (Pages.Home_.page model.shared (Route.fromUrl () model.url)) pageModel
                |> View.map Msg_Home_
                |> View.map PageSent

        PageModelNotFound_ ->
            Pages.NotFound_.page

        Redirecting ->
            View.none

        Loading loadingView ->
            View.map never loadingView



-- INTERNALS


fromPageEffect :
    { model | key : Browser.Navigation.Key, url : Url, shared : Shared.Model }
    -> Effect PageMsg
    -> Cmd Msg
fromPageEffect model effect =
    Effect.toCmd
        { key = model.key
        , url = model.url
        , shared = model.shared
        , toMainMsg = PageSent
        , fromSharedMsg = SharedSent
        }
        effect


fromLayoutEffect :
    { model | key : Browser.Navigation.Key, url : Url, shared : Shared.Model }
    -> Effect LayoutMsg
    -> Cmd Msg
fromLayoutEffect model effect =
    Effect.toCmd
        { key = model.key
        , url = model.url
        , shared = model.shared
        , toMainMsg = LayoutSent
        , fromSharedMsg = SharedSent
        }
        effect


fromSharedEffect :
    { model | key : Browser.Navigation.Key, url : Url, shared : Shared.Model }
    -> Effect Shared.Msg
    -> Cmd Msg
fromSharedEffect model effect =
    Effect.toCmd
        { key = model.key
        , url = model.url
        , shared = model.shared
        , toMainMsg = SharedSent
        , fromSharedMsg = SharedSent
        }
        effect
