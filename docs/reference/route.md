# "Route" module

The `Route` module allows you to work with URLs in a type-safe way. You can directly access fields like `route.path`, `route.query`, or `route.params` without needing to parse the URL by hand.

It also comes with some helpful functions for working with `<a href></a>` tags in HTML, or converting to a URL for other use cases like error reporting. 

## Route

Here is the complete definition of the `Route` type:

```elm
type alias Route params =
    { path : Route.Path.Path
    , params : params
    , query : Dict String String
    , hash : Maybe String
    , url : Url
    }
```

The `Route` type is a record with fields that are commonly used when building web applications. The following sections break down when you might want to use each field.

### route.path

Each item in the [Route.Path](./route-path.md) module has a one-to-one mapping with a file in the `src/Pages` folder. Comparing two path values is often a good way to know if you are on the same page or not.

For example, if we were on the homepage, then `route.path == Route.Path.Home_`. If our application had a "Settings" page, then this value would be `route.path == Route.Path.Settings`.

Keep in mind that all values in `Route.Path` are generated based on the names of files in the `src/Pages` folder. Deleting a page file will automatically remove a `Route.Path` value.


### route.params

The `Route params` type will have parameters based on what page you are working in. Shared modules, layouts, and static page routes will all have `Route ()` by default. This denotes there are no dynamic variables you can access.

Pages with [Dynamic routes](../concepts/pages.md#dynamic-routes) might have a value like `Route { id : String }`, depending on the name of the dynamic page file.


### route.query

Many applications use a specific format for query parameters that looks somethings like this:

```txt
?sort=name&owner=me&date=upcoming
```

To make it easy to access those key value pairs, Elm Land created the `route.query` type. It uses a `Dict` to make looking up values easier for your application code:

```elm
-- ?sort=name&owner=me&date=upcoming

Dict.get "sort" route.query == Just "name"
Dict.get "owner" route.query == Just "me"
Dict.get "date" route.query == Just "upcoming"
Dict.get "archived" route.query == Nothing
```

### route.hash

It's common to use `#section-name` when making applications that have jump links (like this documentation site). The `route.hash` value will give you back the current value of the hash fragment in the URL (if it exists)


### route.url

If you ever need access to [the standard `elm/url` value](https://package.elm-lang.org/packages/elm/url/latest/Url), it is available in `route.url`. Sometimes this is useful if you need to know the protocol, current port, hostname, or access the raw query parameter strings.

## Route.href

This is a helpful function when rendering HTML `<a>` tags.

Rather than working with `String` URLs in your code, we recommend using either `Route.Path.href` or `Route.href`. When you delete a page, the Elm compiler can walk you through any broken links in your application. Using the standard `Html.Attributes.href` doesn't have that guarantee.

```elm
Route.href : 
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Html.Attribute msg
```

__Tip:__ If you don't care about `query` or `hash`, prefer to use [Route.Path.href](./route-path.md) instead!


## Route.toString

In rare cases, like error reporting, you may find a need to convert a `Route` value into a URL string. That string will include the query parameters, hash fragment, and URL path.

This can also be helpful when working with Elm UI, Elm CSS, or anything that isn't `elm/html` values.

```elm
Route.toString :
    { route
        | path : Route.Path.Path
        , query : Dict String String
        , hash : Maybe String
    }
    -> String
```