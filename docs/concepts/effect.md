---
outline: [2,3]
---

# Effect

## Overview

The `Effect msg` type in Elm Land is an abstraction built on top of Elm's standard `Cmd msg` type. In this guide, we'll learn:
1. How to __use the default__ `Effect` module
1. __How to customize__ the `Effect` module
1. The __benefits of defining custom effects__ for your application

## `Effect`

By default, Elm Land has a few effects defined for you. Here's the module's API, and what each function does:

```elm
module Effect exposing
    ( Effect
    , none, batch
    , sendCmd, sendMsg
    , pushRoute, replaceRoute, loadExternalUrl
    )
```

### `Effect.none`

Similar to [Cmd.none](https://package.elm-lang.org/packages/elm/core/latest/Platform-Cmd#none), this tells Elm Land not to run any side-effects.

#### __Definition__

```elm
Effect.none : Effect msg
```

### `Effect.batch`

Similar to [Cmd.batch](https://package.elm-lang.org/packages/elm/core/latest/Platform-Cmd#batch), this allows you to send many effects at once.

#### __Definition__

```elm
Effect.batch : List (Effect msg) -> Effect msg
```

### `Effect.sendCmd`

Convert a `Cmd` to an `Effect`. 

#### __Definition__

```elm
Effect.sendCmd : Cmd msg -> Effect msg
```

::: tip "Wait... should I be using this?"

The `Effect.sendCmd` is great for first learning the Elm Land framework, or if you're tinkering around. For production applications, we recommend that you prefer [defining custom effects](#custom-effects).

Later in this guide, you'll learn how "custom effects" use `Cmd` behind-the-scenes, to help make your life easier when working in pages or layouts.

:::

### `Effect.sendMsg`

Send a `msg` as an `Effect`. This is perfect for ["stateful components"](./components.md#3-stateful-components) that need to emit events up to their parent.

#### __Definition__

```elm
Effect.sendMsg : msg -> Effect msg
```

### `Effect.pushRoute`

Push a new URL onto the browser history. This is just like [Browser.Navigation.pushUrl](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Navigation#pushUrl), except it doesn't require a `Key` argument.

#### __Definition__

```elm
Effect.pushRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
```

### `Effect.replaceRoute`

Replace the current browser history entry with the new URL. This is just like [Browser.Navigation.replaceUrl](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Navigation#replaceUrl), except it doesn't require a `Key` argument.

#### __Definition__

```elm
Effect.replaceRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
```

### `Effect.loadExternalUrl`

Navigate to an external URL, outside your application. This is just like [Browser.Navigation.load](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Navigation#load), except it returns an `Effect` rather than a `Cmd`.

```elm
Effect.loadExternalUrl : String -> Effect msg
```


## Comparison with `Cmd`

In the official Elm guide, we learned that `Cmd Msg` is the way that Elm applications can send "side-effects". The core packages and Elm package ecosystem use this type to send HTTP requests, generate random numbers, and more.

```elm
--  ┏━ The state of our page
--  ┃                                       
( Model, Cmd Msg )
--        ┃
--        ┗━ Literally everything else
```

In Elm, the `Cmd` type is the lowest level primitive for creating side-effects. In Elm Land, __the `Effect` type is an abstraction on top of `Cmd`__. As we'll learn in the next section, they allow us to create custom tailored commands specific to our application's needs.

```elm
--  ┏━ The state of our page
--  ┃                                       
( Model, Effect Msg )
--         ┃
--         ┗━ Literally everything else
```

### Using commands in practice

Let's imagine we were building a Twitter clone. When our homepage loads, we want to fetch posts for the feed.

If we did this with Elm commands, the API calling code for fetching that feed would look something like this:

```elm{9,20-35}
module Pages.Home_ exposing (Model, Msg, page)

-- ...


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.element
        { init = init shared
        , ...
        }


-- ...


init : Shared.Model -> () -> ( Model, Cmd Msg )
init shared _ =
    ( { model | posts = Loading } 
    , Http.request
        { method = "GET"
        , url = shared.baseApiUrl ++ "/api/feed"
        , headers =
            case shared.user of
                Just user ->
                    [ Http.header "Authorization" ("Bearer " ++ user.token)
                    ]

                Nothing ->
                    []
        , body = Http.emptyBody
        , expect = Http.expectJson GotPostsForFeed decoder
        , timeout = Just 15000
        , tracker = Nothing
        }
    )


decoder : Json.Decode.Decoder (List Post)
decoder =
    ...

-- ...
```

I've highlighted a few things to note from the snippet above:
1. We need to pass in the `shared` value to `init`, so the HTTP request can access certain variables
    - `shared.baseUrl` – It's common to request `http://localhost:3000/api` in development, but `https://api.myapp.com` in production. The `.baseApiUrl` field is based on an environment variable, and ensures we use the right endpoint in dev and production
    - `shared.user` – We also conditionally apply an `Authorization` header if a user is signed in. This makes our API return posts based on a user's followers. For a signed-out user, we just show the popular stuff.
1. Some web applications will want to enforce other things, like a 15 second `timeout` before terminating the request

You can imagine a lot of this code will need to be repeated as we add more features. For example, if we wanted to create a new post with a `POST` request later, we'd need to pass around `shared.user` all over again. 

Functions definitely can help reduce the boilerplate, but those functions would still need access to the `shared` value to work.

### Using effects in practice

Let's do the same request, but with Elm Land's `Effect` abstraction:

```elm{6-10}
-- ...

init : () -> ( Model, Effect Msg )
init _ =
    ( { model | posts = Loading } 
    , Effect.sendApiRequest
        { endpoint = "/api/feed"
        , decoder = decoder
        , onResponse = GotPostsForFeed
        }
    )

-- ...
```

Effects let us talk about our side-effects at a higher level. They allow us to:
1. Prevent needing to pass `shared` to every `init` or `update` functions that sends an API request
1. Prevent bugs and other surprises that come from forgetting to correctly wire up values like `headers` or `timeout`
1. Create end-to-end tests for our application, using [elm-program-test](https://elm-program-test.netlify.app/#guidebooks)


## Custom effects

Using the `elm-land customize` command, we can eject the default `Effect` module into `src/Effect.elm`.

```sh
elm-land customize effect
```

From there, you'll have complete control over the `Effect` module! 

::: tip Define your ports here!

In Elm Land, the convention is to use the `Effect` module for any ports. We recommend defining one incoming and one outgoing port in this module.

From there, expose small functions like `Effect.saveUser` and `Effect.clearUser` to avoid dealing with JSON encoding elsewhere in your application! See the [User Auth](../guide/user-auth.md) guide for a practical example on doing this with local storage.

:::

### Example 1: `Shared.Msg`

If you've customized the [Shared](./shared.md) module, you may also want to send `Shared.Msg` values from a page, like `Shared.Msg.SignOut`. Effects can send commands, but they can also send `Shared.Msg` under the hood.

Here's what you would need to add to support `Effect.signOut` on any page or layout:

```elm{4,9-11}
module Effect exposing
    ( Effect, none, batch
    , ...
    , signOut
    )

-- ...

signOut : Effect msg
signOut =
    SendSharedMsg Shared.Msg.SignOut

-- ...
```

For convenience, the `SendSharedMsg` variant is already defined within the `Effect` module. It's really that easy!

__Note:__ Rather than exposing one `Effect.sendSharedMsg` function, we recommend only exposing the effects you'll need. This will make each `Effect` easier to use, and help you easily see which `Shared.Msg` values are actually called.

Here's a visual of how it will help provide a nicer API in practice:

```elm
-- ❌ DON'T – Expose a generic `sendSharedMsg` 
Effect.sendSharedMsg
    (Shared.Msg.SignIn
        { email = model.email 
        , password = model.password
        }
    )

-- ✅ DO – Expose simple functions as needed
Effect.signIn
    { email = model.email 
    , password = model.password
    }
```


### Example 2: HTTP requests

Earlier in this guide, we showed an example `Effect.sendApiRequest`. Let's walk through a quick visual example of how to implement that function under the hood:

```elm{4,11-15,19-41,50-55,73-101}
module Effect exposing
    ( Effect, none, batch
    , ...
    , sendApiRequest
    )

-- ...

type Effect msg
    = ...
    | SendApiRequest
        { endpoint : String
        , decoder : Json.Decode.Decoder msg
        , onHttpError : Http.Error -> msg
        }

-- ...

sendApiRequest :
    { endpoint : String
    , decoder : Json.Decode.Decoder value
    , onResponse : Result Http.Error value -> msg
    }
    -> Effect msg
sendApiRequest options =
    let
        decoder : Json.Decode.Decoder msg
        decoder =
            options.decoder 
                |> Json.Decode.map Ok
                |> Json.Decode.map options.onResponse

        onHttpError : Http.Error -> msg
        onHttpError httpError =
            options.onResponse (Err httpError)
    in
    SendApiRequest
        { endpoint = options.endpoint
        , decoder = decoder
        , onHttpError = onHttpError
        }

-- ...

map : (msg1 -> msg2) -> Effect msg1 -> Effect msg2
map fn effect =
    case effect of
        ...

        SendApiRequest data ->
            SendApiRequest
                { endpoint = data.endpoint
                , decoder = Json.Decode.map fn data.decoder
                , onHttpError = \err -> Json.Decode.map fn (data.onHttpError err)
                }

-- ...

toCmd :
    { key : Browser.Navigation.Key
    , url : Url
    , shared : Shared.Model.Model
    , fromSharedMsg : Shared.Msg.Msg -> msg
    , batch : List msg -> msg
    , toCmd : msg -> Cmd msg
    }
    -> Effect msg
    -> Cmd msg
toCmd options effect =
    case effect of
        ...

        SendApiRequest data ->
            Http.request
                { method = "GET"
                , url = options.shared.baseApiUrl ++ data.endpoint
                , headers =
                    case options.shared.user of
                        Just user ->
                            [ Http.header
                                "Authorization"
                                ("Bearer " ++ user.token)
                            ]

                        Nothing ->
                            []
                , body = Http.emptyBody
                , expect =
                    Http.expectJson
                        (\httpResult ->
                            case httpResult of
                                Ok msg ->
                                    msg

                                Err httpError ->
                                    data.onHttpError httpError
                        )
                        data.decoder
                , timeout = Just 15000
                , tracker = Nothing
                }
```

We do some fancy `Json.Decode.map` stuff in our function to avoid needing the generic `value` type variable for our `Effect msg` type. 

Although there's quite a bit of logic up front, you'll only define this effect once per application. The time savings come from actually making HTTP requests throughout the application, and not wiring up all this stuff each time.

The benefits become much clearer in [the official "Error Reporting" example](https://github.com/elm-land/elm-land/tree/main/examples/11-error-reporting). There, we add some extra logic to ensure that all JSON decoding errors are __automatically__ logged to Sentry, to help us debug issues that come from unexpected API responses.
