# Shared

## Overview

The `Shared` module is designed to enable us to __share data between pages__. To understand why it exists, it might first be helpful to understand how Elm Land stores information. Under the hood, Elm Land generates a bit of code for making a standard Elm application.

Normally, Elm applications have a single, top-level `Model` that represents the entire state of our application. Elm Land is no different, except it generates that `Model` for us. This allows you to focus on creating smaller models for each page.

Here's a high-level overview of the `Model` that is used internally by Elm Land to store our web application state:

```elm
type alias Model =
    { shared : Shared.Model
    , page : Pages.Model
    }
```

Every Elm Land application has two fields:
- `shared` - stores data that is available to every page
- `page` field - stores data for the current page

### A quick example

For example, if we had an application with a `Dashboard`, `Settings`, and `SignIn` page, this would be the generated `Pages.Model` type:

```elm
module Pages exposing (..)

-- ...

type Model
    = Dashboard Pages.Dashboard.Model
    | Settings Pages.Settings.Model
    | SignIn Pages.SignIn.Model
```

When a user visits a URL like `/dashboard`, Elm Land calls the `Pages.Dashboard.init` function to determine the initial state of `Pages.Dashboard.Model`. Each time the user navigates to a different page, the `model.page` field is cleared out, and replaced with the `Model` for the new page.

```elm
-- 1️⃣ User visits `/dashboard` (`Pages.Dashboard.init` is called)
model.page ==
    { shared = {}
    , page = Dashboard { ... }
    }

-- 2️⃣ User clicks a link to `/settings` (`Pages.Settings.init` is called)
model.page ==
    { shared = {}
    , page = Settings { ... }
    }

-- 3️⃣ User refreshes the page (`Pages.Settings.init` is called again)
model.page ==
    { shared = {}
    , page = Settings { ... }
    }
```

The important thing to understand is that as the user changes the URL, the entire `model.page` field is replaced with a new one. This behavior help makes Elm Land pages easier to understand, but introduces a new challenge: "How do we share information like a signed-in user across pages?"

## Customizing the `Shared` modules

In order to create data that should be available across pages, we'll want to customize our `Shared.Model` so it can store whatever information is important for our specific app.

Elm Land has a `customize` command for allowing you to gradually adopt more features in your Elm application. Let's use this command to get started:

```sh
elm-land customize shared
```

To prevent an issue with a circular import dependency with `Effect`, the `Shared` modules need to be broken into three separate files. Here's what each file is for:

File | Description
:-- | :--
`src/Shared/Model.elm` | Defines the `Shared.Model` we want to share across every page
`src/Shared/Msg.elm` | Defines the ways our `Shared.Model` can be updated
`src/Shared.elm` | Defines the `init`, `update`, and `subscriptions` functions

## `Shared.Model`

The `Model` type in `src/Shared/Model.elm` defines what data is available on every page. 

For example, you might add two fields to track:

```elm{4-15}
module Shared.Model exposing (..)

type alias Model =
    { user : Maybe User
    , window :
        { width : Int
        , height : Int
        }
    }

type alias User =
    { username : String
    , avatarUrl : Maybe String
    }
```

## `Shared.init`

The `init` function in the `src/Shared.elm` file defines the initial state of our `Shared.Model`. This function is called anytime the web application __loads for the first time__ or is __refreshed__.


For example, if you have edited the `Shared.Model`, you'll see a compiler error message saying that this function needs to be updated. 

```elm{7-9}
module Shared exposing (..)

-- ...

init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult route =
    ( { user = Nothing
      , window = { width = 0, height = 0 }
      }
    , Effect.none
    )

-- ...
```

It takes in two arguments as input:
1. `flagsResult` - The result of decoding the [Shared.Flags](#shared-flags) type (covered next)
1. `route` - Information about the current URL, including query parameters, path, etc

And returns the initial value of `Shared.Model` and any effects that need to run. For a real user authentication example, check out the [User Auth](../guide/user-auth.md) guide.

## `Shared.Flags`

```elm{6-8,13-15}
module Shared exposing (..)

-- ...

type alias Flags = 
    { width : Int
    , height : Int
    }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map2 Flags
        (Json.Decode.field "width" Json.Decode.int)
        (Json.Decode.field "height" Json.Decode.int)

-- ...
```

The `Shared.Flags` type represents the initial data (if any) you expect to be passed in from JavaScript on startup. If you add a new `src/interop.js` file, you can define a `flags` function that returns the initial data.

### Defining flags

For example, you might want to pass in the initial `window` dimensions when your application loads. This would involve editing these two files:

__`src/interop.js`__

```js{1-6}
export const flags = ({ env }) => {
  return {
    width: window.innerWidth,
    height: window.innerHeight,
  }
}
```

__`src/Shared.elm`__

### Using flags

After changing these three lines of code, your `init` function will receive the safely decoded JSON data in the first argument, `flagsResult`:

__`src/Shared.elm`__

```elm{7-18,21-23}
module Shared exposing (..)

-- ...

init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult route =
    let
        flags : Flags
        flags =
            case flagsResult of
                Ok value ->
                    value

                Err reason ->
                    { width = 0
                    , height = 0 
                    }
    in
    ( { user = Nothing
      , window =
          { width = flags.width
          , height = flags.height
          }
      }
    , Effect.none
    )

-- ...
```

In our example above, everything would work out great. Later on, if our JavaScript file had a typo or returned other JSON we don't expect, our Elm application would gracefully fallback to the default `{ width = 0, height = 0 }` value from before. This means our Elm application will never crash from unexpected JSON data!

::: tip "What about error handling?"

If you have an error reporting service, we recommend logging the `Json.Decode.Error` value so you know about any issues coming from the JavaScript flags

:::

## `Shared.Msg`

The `Msg` type defined in `Shared.Msg` makes it available for use in the `Shared` module, as well as [the `Effect` module](./effect.md) covered later in the guide.

This type works just like page or layout's `Msg` value: it defines all the possible events that can be handled by the `Shared.update` function.

For example, you might define `Msg` values like these:

```elm{3,6-8}
module Shared.Msg exposing (..)

import Shared.Model exposing (User)

type Msg
    = SignInApiResponded User
    | SignOutClicked
    | WindowResized Int Int
```

In the next section, we'll see how `Shared.update` uses these values to make changes to the `Shared.Model`!

## `Shared.update`

The `update` function handles how our `Shared.Model` should change in response to events across our application. This concept should be familar to you if you have already read the [Pages](./pages.md) or [Layouts](./layouts.md) guides.

Here's a visual example of a `Shared.update` function responding from message you might find in a real world application:

```elm{8-23}
module Shared exposing (..)

-- ...

update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        SignInApiResponded user ->
            ( { model | user = Just user }
            , Effect.none
            )
        
        SignOutClicked ->
            ( { model | user = Nothing }
            , Effect.none
            )

        WindowResized width height ->
            ( { model
                  | window = { width = width, height = height }
              }
            , Effect.none
            )

-- ...
```

## `Shared.subscriptions`

Just like on a page or a layout, the `Shared` module allows you to continually listen for events and fire a `Msg` when they occur.

If your application needs to know the current window size, you might use this function with `Browser.Events.onResize` to keep track of the current size of the window:

```elm
module Shared exposing (..)

-- ..

subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    Browser.Events.onResize WindowResized
```

The subscriptions defined here will be active regardless of the page you are on. This means you can reliably use `shared.window.width` in any of your pages, and won't have to worry about it getting out-of-sync!
