---
outline: [2,3]
---

# "Layout" module

Every layout file imports a `Layout` module. This module provides the `Layout` type and the `Layout.new`. This section documents all the functions exposed, and what they are used for.

### Layout

This type represents a layout, and contains four parameters. 

```elm
type Layout parentProps model msg contentMsg
```

Here's a breakdown of each parameter:

1. `parentProps` – When working with [Nested layouts](/concepts/layouts#nested-layouts), this parameter is the parent layout's settings. For top-level layouts that aren't nested, this value is always `()`.
2. `model` – Represents the state of the layout
3. `msg` – Represents the messages the layout can send
4. `contentMsg` – Because layouts can embed other HTML, this common variable allows us to combine that HTML together. We describe this in more detail in [the "Understanding layouts" section](/concepts/layouts#understanding-layouts) above!

### Layout.new

Create a new layout, providing functions to describe how to initialize, update, and view your page.

```elm
Layout.new :
    { init : () -> ( Model, Effect Msg )
    , update : Msg -> Model -> ( Model, Effect Msg )
    , view :
        { model : Model
        , toContentMsg : Msg -> contentMsg
        , content : View contentMsg
        }
        -> View contentMsg
    , subscriptions : Model -> Sub Msg
    }
    -> Layout () Model Msg contentMsg
```

### Layout.withParentProps

This is required for [nested layouts](/concepts/layouts#nested-layouts), which are embedded within other parent layouts. Use this function to provide settings that are required by the parent layout.

#### Type definition

```elm
Layout.withParentProps :
    parentProps
    -> Layout () Model Msg contentMsg
    -> Layout parentProps Model Msg contentMsg
```

#### Usage example

```elm{12-14}
module Layouts.Sidebar.Header exposing (..)

-- ...

layout :
    Props
    -> Shared.Model
    -> Route ()
    -> Layout Layouts.Sidebar.Props Model Msg contentMsg
layout props shared route =
    Layout.new { ... }
        |> Layout.withParentProps
            { user = settings.user 
            }
```


### `Layout.withOnUrlChanged`

The `Layout.withOnUrlChanged` function allows a layout to respond to any changes in the URL __that don't involve navigating to another layout__.

For example, let's imagine we have the following 3 pages in our application:

Page | Layout
:-- | :--
`Pages.Dashboard` | `Layouts.Sidebar`
`Pages.Settings` | `Layouts.Sidebar`
`Pages.SignIn` | _None_

If we navigated from `/dashboard` to `/settings`, then our `UrlChanged` message would be sent to our `Layouts.Sidebar` module. 

If we navigated from `/dashboard` to `/dashboard?code=123`, we would also receive a message. However, if we navigated to the `/sign-in` route, we would __not receive__ a message, because the "Sign in" page doesn't use this layout.

Use the `Layout.withOnUrlChanged` whenever you want to know if the current page, query parameters, or hash has changed within a layout.


#### Type definition

```elm
Layout.withOnUrlChanged :
    ({ from : Route (), to : Route () } -> Msg)
    -> Layout () Model Msg
    -> Layout () Model Msg
```

#### Usage example

```elm{15,23,29-30}
module Layouts.Sidebar exposing (Props, Model, Msg, layout)

import Layout exposing (Layout)
-- ...


layout : Props -> Shared.Model -> Route () -> Layout () Model Msg
layout props shared route =
    Layout.new
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
        |> Layout.withOnUrlChanged UrlChanged


-- ...


type Msg
    = ...
    | UrlChanged { from : Route (), to : Route () }


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UrlChanged { from, to } ->
            ( model, Effect.none )

        ...
```

__Note:__ In [the Route section](./route), you'll learn about the `Route` type and how it stores URL information.
