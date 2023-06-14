# "Page" module

When you see `import Page` at the top of your file, this refers to the generated Elm Land `Page` module.

That module is centered around the `Page Model Msg` type, which every page creates with `Page.new`. This module also contains useful "modifier" functions that allow you to add optional features to your pages. 

Let's take a look at each function, and why you might use them in your own pages.

### `Page.withLayout`

The `Page.withLayout` function allows your page to opt-in to a layout file. In [the Layouts section](./layouts), you'll learn how layouts allow you to reuse stateful UI across pages, like sidebars, navbars, etc.

#### Type definition

```elm
Page.withLayout :
    (Model -> Layouts.Layout Msg)
    -> Page Model Msg
    -> Page Model Msg
```

#### Usage example

```elm{4,16,19-26}
module Pages.People exposing (Model, Msg, page)

import Page exposing (Page)
import Layouts
-- ...


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
        |> Page.withLayout toLayout


{-| Use the sidebar layout on this page -}
toLayout : Model -> Layouts.Layout
toLayout model =
    Layouts.Sidebar
        { title = "Settings"
        }
```


### `Page.withOnUrlChanged`

The `Page.withOnUrlChanged` function allows a page to respond to any changes in the URL __that don't involve navigating to another page__.

For example, going from `/dashboard` to `/settings` moves you from `Pages.Dashboard` to `Pages.Settings`. In that case, `Page.withOnUrlChanged` won't be called. 

Instead, the `Page.Settings.init` function will run to initialize the new page.

Use the `Page.withOnUrlChanged` whenever you want to know if any "query parameters" or "hash" values have changed within a page. 

::: tip But wait, there's more!

Be sure to check out [Page.withOnQueryParameterChanged](#page-withonqueryparameterchanged) and [Page.withOnHashChanged](#page-withonhashchanged) below, for nicer, less general APIs for common URL changes.

:::

#### Type definition

```elm
Page.withOnUrlChanged :
    ({ from : Route (), to : Route () } -> Msg)
    -> Page Model Msg
    -> Page Model Msg
```

#### Usage example

```elm{15,23,29-30}
module Pages.People exposing (Model, Msg, page)

import Page exposing (Page)
-- ...


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
        |> Page.withOnUrlChanged UrlChanged


-- ...


type Msg
    = ...
    | UrlChanged { from : Route (), to : Route () }


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        OnUrlChanged { from, to } ->
            ( model, Effect.none )

        ...
```

__Note:__ In [the Route section](./route), you'll learn about the `Route` type and how it stores URL information.

### `Page.withOnQueryParameterChanged`

The `Page.withOnQueryParameterChanged` function allows your page to respond to changes for a certain URL query parameter. 

This is a more specific version of `Page.onUrlChanged`, often used with filters like `?sort=name`.

#### Type definition

```elm
Page.withOnQueryParameterChanged :
    { name : String
    , onChange : { from : Maybe String, to : Maybe String } -> Msg
    }
    -> Page Model Msg
    -> Page Model Msg
```

#### Usage example

```elm{15-18,26-29,35-36}
module Pages.People exposing (Model, Msg, page)

import Page exposing (Page)
-- ...


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
        |> Page.withOnQueryParameterChanged
            { name = "sort" 
            , onChange = SortParameterChanged
            }


-- ...


type Msg
    = ...
    | SortParameterChanged
        { from : Maybe String
        , to : Maybe String
        }


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SortParameterChanged { from, to } ->
            ( model, Effect.none )

        ...
```

#### Example messages

These examples are here to help you visualize what values will be passed
to your `update` function as query parameters change:

```elm
-- When "/people" becomes "/people?sort=name"
SortParameterChanged
    { from = Nothing
    , to = Just "name"
    }

-- When "/people?sort=name" becomes "/people?sort=jobTitle"
SortParameterChanged
    { from = Just "name"
    , to = Just "jobTitle"
    }

-- When "/people?sort=jobTitle" becomes "/people"
SortParameterChanged
    { from = Just "jobTitle"
    , to = Nothing
    }
```


### `Page.withOnHashChanged`

The `Page.withOnHashChanged` function allows your page to respond to changes in the hash or URL fragment. 

This is a more specific version of `Page.onUrlChanged`, often used when jumping to certain sections on a page like `#about-us`.

#### Type definition

```elm
Page.withOnHashChanged :
    ({ from : Maybe String, to : Maybe String } -> Msg)
    -> Page Model Msg
    -> Page Model Msg
```

#### Usage example

```elm{15,23,29-30}
module Pages.People exposing (Model, Msg, page)

import Page exposing (Page)
-- ...


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
        |> Page.withOnHashChanged UrlHashChanged


-- ...


type Msg
    = ...
    | UrlHashChanged { from : Maybe String, to : Maybe String }


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UrlHashChanged { from, to } ->
            ( model, Effect.none )

        ...
```

#### Example messages

These examples are here to help you visualize what values will be passed
to your `update` function as query parameters change:

```elm
-- When "/people" becomes "/people#about-us"
UrlHashChanged
    { from = Nothing
    , to = Just "about-us"
    }

-- When "/people#about-us" becomes "/people#our-mission"
UrlHashChanged
    { from = Just "about-us"
    , to = Just "our-mission"
    }
```
