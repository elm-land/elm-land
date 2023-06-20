---
outline: [2,3]
---

# "Route.Path" module

The `Route.Path` module is generated based on the names of files in the `src/Pages` folder. Deleting a page file will automatically remove a `Route.Path` value. Unlike [Route](./route.md), it doesn't have information about query parameters or hash fragments.

This value is most commonly accessed from pages, layouts, and shared modules via the `route.path` field. This module comes with functions for working with `<a>` tags in HTML, and has a `toString` function for getting absolute URL paths.

## Route.Path

The actual value of `Path` will vary based on the names of files in the pages folder, but it will always be a custom type. The custom type variants will only have arguments if they are for dynamic routes that need URL parameters:

Here's an example of what this might look like for an application with 4 pages:

```elm
type Path
    = Home_
    | Settings
    | Profile { id : String }
    | SignIn
```


## Route.Path.href

This is a helpful function when rendering HTML `<a>` tags.

Rather than working with `String` URLs in your code, we recommend using either `Route.Path.href` or `Route.href`. When you delete a page, the Elm compiler can walk you through any broken links in your application. Using the standard `Html.Attributes.href` doesn't have that guarantee.

```elm
Route.Path.href : Path -> Html.Attribute msg
```

__Tip:__ If you need to specify `query` or `hash`,  use [Route.href](./route.md) instead!


#### Example usage

```elm
import Html exposing (..)
import Route.Path


viewLinkToDashboard : Html msg
viewLinkToDashboard =
    a [ Route.Path.href Route.Path.Dashboard ]
      [ text "Go to Dashboard"
      ]
```

## Route.Path.toString

In rare cases, like error reporting, you may find a need to convert a `Route` value into a URL path. 


This can also be helpful when working with Elm UI, Elm CSS, or anything that isn't `elm/html` values.

```elm
Route.toString : Path -> String
```

__Note:__ The resulting URL string does __not contain__ query parameters or hash fragments (see [Route.toString](./route.md) if you need those)