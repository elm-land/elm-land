module Auth exposing (User, onPageLoad)

import Auth.Action
import Dict
import Domain.SignInStatus
import Domain.User
import Html
import Html.Attributes as Attr
import Route exposing (Route)
import Route.Path
import Shared.Model exposing (Model)
import View exposing (View)


type alias User =
    Domain.User.User


onPageLoad : Shared.Model.Model -> Route () -> Auth.Action.Action User
onPageLoad shared route =
    case shared.signInStatus of
        Domain.SignInStatus.NotSignedIn ->
            Auth.Action.replaceRoute
                { path = Route.Path.SignIn
                , query = Dict.fromList [ ( "from", route.url.path ) ]
                , hash = Nothing
                }

        Domain.SignInStatus.SignedInWithToken token ->
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

        Domain.SignInStatus.SignedInWithUser user ->
            Auth.Action.loadPageWithUser user

        Domain.SignInStatus.FailedToSignIn user ->
            Auth.Action.replaceRoute
                { path = Route.Path.SignIn
                , query = Dict.fromList [ ( "from", route.url.path ) ]
                , hash = Nothing
                }
