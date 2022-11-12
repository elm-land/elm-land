module Auth exposing (User, onPageLoad)

import Api.User
import Auth.Action
import Dict
import Html
import Html.Attributes as Attr
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


type alias User =
    Api.User.User


onPageLoad : Shared.Model -> Route () -> Auth.Action.Action User
onPageLoad shared route =
    case shared.signInStatus of
        Shared.NotSignedIn ->
            Auth.Action.replaceRoute
                { path = Route.Path.SignIn
                , query = Dict.fromList [ ( "from", route.url.path ) ]
                , hash = Nothing
                }

        Shared.SignedInWithToken token ->
            Auth.Action.showLoadingPage
                { title = "Signing in..."
                , body =
                    [ Html.section [ Attr.class "hero is-medium" ]
                        [ Html.div [ Attr.class "hero-body" ]
                            [ Html.div [ Attr.class "container has-text-centered" ]
                                [ Html.h1 [ Attr.class "subtitle" ] [ Html.text "Signing in..." ]
                                ]
                            ]
                        ]
                    ]
                }

        Shared.SignedInWithUser user ->
            Auth.Action.loadPageWithUser user

        Shared.FailedToSignIn user ->
            Auth.Action.replaceRoute
                { path = Route.Path.SignIn
                , query = Dict.fromList [ ( "from", route.url.path ) ]
                , hash = Nothing
                }
