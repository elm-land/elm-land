---
outline: [2,3]
---

# Auth

## Overview

Elm Land aims to be a great fit for web applications with pages that are only available behind a "sign-in" screen. To make it easy to build apps with user authentication, Elm Land provides an `Auth` module to make it easy to work with signed-in and signed-out users.

If you want a page to be "auth-protected", all you need to do is add `Auth.User` to the page's type annotation:

```elm{7-8}
-- BEFORE
page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    ...

-- AFTER
page : Auth.User -> Shared.Model -> Route () -> Page Model Msg
page user shared route =
    ...
```

By adding that argument, Elm Land will know that this page should only be visible when a user is signed-in. It will look to the `Auth` module to determine how it should respond when a user visits a page they shouldn't have access to.


## Customizing `Auth`

You can customize the `Auth` module with the `elm-land customize` command:

```sh
elm-land customize auth
```

By default, all auth-only pages redirect users to the `NotFound_` page when the application starts up. Let's edit our new `src/Auth.elm` file so it automatically passes the user to any pages that need it, but redirects to `/sign-in` if there's no user logged in.

```elm{7-8,14-28}
module Auth exposing (User, onPageLoad)

-- ...


type alias User =
    { token : String
    }


{-| Called before an auth-only page is loaded. -}
onPageLoad : Shared.Model -> Route () -> Auth.Action.Action User
onPageLoad shared route =
    case shared.token of
        Just token ->
            Auth.Action.loadPageWithUser
                { token = token
                }

        Nothing ->
            Auth.Action.pushRoute
                { path = Route.Path.SignIn
                , query =
                    Dict.fromList
                        [ ( "from", route.url.path )
                        ]
                , hash = Nothing
                }
```

In the case that a user isn't signed in, we can even add a query parameter to let us know which page they were on when the sign-in redirect took place.

This means that if the user was signed out and loaded the /settings page, their new URL would be /sign-in?from=/settings.

We can use this query parameter later to make sure we redirect them to the right page after sign-in, rather than always redirecting to the homepage.

::: tip Understanding the big picture

There's a dedicated [User Auth](../guide/user-auth.md) guide that covers working with the `Auth` module, setting up a sign-in form, and working with tokens and local storage. 

Check that out if you'd like to see a real example of how this API can work for your web application!

:::

## `Auth.Action`

Although this module isn't customizable, it has an API intended for use within your customized `Auth` module. For that reason, it can be helpful to understand the available functions, and what they do!

### `Auth.Action.loadPageWithUser`

Continue to load the page, and provide it with the current `Auth.User` value.

#### Type Definition

```elm
loadPageWithUser : Auth.User -> Action
```

### `Auth.Action.showLoadingPage`

Show a temporary loading page, without redirecting. This is useful if validating a local JSON web token and waiting for the API to respond.

#### Type Definition

```elm
showLoadingPage : View Never -> Action
```

### `Auth.Action.replaceRoute`

Redirect to another existing page, like `/sign-in` or `/access-denied`. Using `replaceRoute` means the back button __will not navigate__ to the previous page.

#### Type Definition

```elm
replaceRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Action
```

### `Auth.Action.pushRoute`

Redirect to another existing page, like `/sign-in` or `/access-denied`. Using `pushRoute` means the back button __will navigate__ to the previous page.

#### Type Definition

```elm
pushRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Action
```

### `Auth.Action.pushRoute`

Redirect to a URL outside of the application, like an OAuth sign in screen.

#### Type Definition

```elm
loadExternalUrl : String -> Action
```