---
outline: [2,3]
---

# "Auth.Action" module

The `Auth.Action` module is only used within [your customized `Auth` file](/concepts/auth). This section outlines what types and values are available to use.



### `Auth.Action.loadPageWithUser`

When definining the behavior of `Auth.onPageLoad`, this value tells Elm Land to provide the authenticated user value to the page. That page will load as expected now that it has access to the user.

#### Type definition

```elm
Auth.Action.loadPageWithUser : Auth.User -> Auth.Action.Action
```


### `Auth.Action.replaceRoute`

If you want to redirect the user to the "/sign-in" or "/access-denied" page, this function will help you do that. It also supports query parameters, so you can track things like `?from=/settings` to know where to redirect users after a successful login.

Behaves like [Browser.Navigation.replaceUrl](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Navigation#replaceUrl), except it doesn't require a `Key` argument.

#### Type definition

```elm
Auth.Action.replaceRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Auth.Action.Action
```


### `Auth.Action.pushRoute`

This is the same as the `Auth.Action.replaceRoute` function, except it adds to the URL history. Pressing the back button will return users to the current page.

Behaves like [Browser.Navigation.pushUrl](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Navigation#pushUrl), except it doesn't require a `Key` argument.

#### Type definition

```elm
Auth.Action.pushRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Auth.Action.Action
```

### `Auth.Action.loadExternalUrl`

Use this to send users to another web application when they aren't signed in. Behaves like [Browser.Navigation.load](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Navigation#load).

#### Type definition

```elm
Auth.Action.loadExternalUrl : String -> Auth.Action.Action
```


### `Auth.Action.showLoadingPage`

Sometimes it is helpful to wait on the current page while validating if a JWT token is expired. The `showLoadingPage` function will display a static view to the user while they wait.

#### Type definition

```elm
Auth.Action.showLoadingPage : View Never -> Auth.Action.Action
```