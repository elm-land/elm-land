---
outline: [2,3]
---

# View

## Overview

The `View` module is returned by pages and layouts to tell Elm what to render on the screen. By default, the value of `View msg` matches Elm's [Browser.Document](https://package.elm-lang.org/packages/elm/browser/latest/Browser#Document) type. This allows us to specify what to render in the tab title, and within the page:


```elm
type alias View msg =
    { title : String
    , body : List (Html msg)
    }
```

For many applications, this type is all you need. But you can also change this type to use different Elm UI packages!

## Custom views

If you'd like to customize the `View` module, you can do this with the `elm-land customize` command:

```sh
elm-land customize view
```

Some folks in the Elm community prefer to build their UI in things other than the core [elm/html](https://package.elm-lang.org/packages/elm/html/latest/) package. Here are some popular alternatives:

Package | Description
:-- | :--
[mdgriffith/elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/) | "Layout and style that's easy to refactor, all without thinking about CSS."
[rtfeldman/elm-css](https://package.elm-lang.org/packages/rtfeldman/elm-css/latest/) | "Typed CSS in Elm."
[matheus23/elm-default-tailwind-modules](https://package.elm-lang.org/packages/matheus23/elm-default-tailwind-modules/latest/) | "The default tailwind classes as elm-css, generated using elm-tailwind-modules."

Each of these packages don't use the `Html` type. By customizing Elm Land's `View` type, we make it easier to work with them across pages and layouts.

::: tip Looking for examples?

As a starting point, we have some official examples of working with [Elm UI](https://github.com/elm-land/elm-land/tree/main/examples/12-elm-ui) and [Elm CSS](https://github.com/elm-land/elm-land/tree/main/examples/13-elm-css) in the official repo's `examples/` folder.

Be sure to check those out if you're planning to use either UI package with Elm Land!

:::

### `View.toBrowserDocument`

Used internally by Elm Land to create your application so it works with Elm's expected `Browser.Document msg` type.

#### Example (for Elm UI)

```elm
toBrowserDocument :
    { shared : Shared.Model.Model
    , route : Route ()
    , view : View msg
    }
    -> Browser.Document msg
toBrowserDocument { view } =
    { title = view.title
    , body = [ Element.layout view.attributes view.element ]
    }
```

### `View.map`

Used internally by Elm Land to connect your pages together.

#### Example (for Elm UI)

```elm
map : (msg1 -> msg2) -> View msg1 -> View msg2
map fn view =
    { title = view.title
    , attributes = List.map (Element.mapAttribute fn) view.attributes
    , element = Element.map fn view.element
    }
```

### `View.none`

Used internally by Elm Land whenever transitioning between authenticated pages.

#### Example (for Elm UI)

```elm
none : View msg
none =
    { title = ""
    , attributes = []
    , element = Element.none
    }
```

### `View.fromString`

If you customize the `View` module, anytime you run `elm-land add page`,
the generated page will use this when adding your `view` function.

That way your app will compile after adding new pages, and you can see
the new page working in the web browser!

#### Example (for Elm UI)

```elm
fromString : String -> View msg
fromString moduleName =
    { title = moduleName
    , attributes = []
    , element = Element.text moduleName
    }
```