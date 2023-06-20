---
outline: [2,3]
---

# Route

## Overview

As you add files in the `src/Pages` folder, the `Route` and `Route.Path` are regenerated to include all the latest pages throughout your application:

1. `Route` – __Represents the full URL__, including path, query parameters, hash fragments, and other URL stuff
1. `Route.Path` – __Represents the URL path__, which corresponds to a page file.

Each of these functions exposes an API for making navigation across pages easy. They also provide helpful functions like `href` that give you friendly compiler feedback when removing old pages. For that reason, Elm Land recommends using `Route` and `Route.Path` when linking to other pages within your app.

This guide will walk you through the functions you'll have access to in these generated modules!

::: tip "What routes are in my application?"

 If you're ever curious about what routes exist, you can use the built-in `elm-land routes` command to list them! 

:::

## `Route`

This module represents the full URL, and is provided to every page and route. It even includes a field the original `elm/url` value. 


```elm
type alias Route params =
    { path : Route.Path.Path
    , params : params
    , query : Dict String String
    , hash : Maybe String
    , url : Url
    }
```

The generic `params` type variable allows certain routes to store type-safe dynamic parameters, whereas static pages, layouts, and the `Shared` module will use `Route ()`.


### `Route.href`

This function allows you to build a type-safe link to a page like `/people?sort=name`. If you don't need to specify query parameters or hash fragments, see [Route.Path.href](#route-path-href) for a nicer API!

#### Definition

```elm
href :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Html.Attribute msg
```

#### Example usage

```elm
--
-- Renders:
--   <a href="/people?sort=name">People page</a>
--
Html.a 
    [ Route.href
        { path = Route.Path.People
        , query =
            Dict.fromString
                [ ( "sort", "name" )
                ]
        , hash = Nothing
        }
    ]
    [ Html.text "People page" ]
```

### `Route.toString`

This function is similar to `Route.href`, but is helpful when getting absolute URL strings without rendering them with `Html.a` element. 

If you don't need to specify query parameters or hash fragments, see [Route.Path.toString](#route-path-toString) for a nicer API!

#### Definition

```elm
toString :
    { route
        | path : Route.Path.Path
        , query : Dict String String
        , hash : Maybe String
    }
    -> String
```

#### Example usage

```elm
Element.link
    { label = "People page"
    , url = 
        Route.toString
            { path = Route.Path.People
            , query =
                Dict.fromString
                    [ ( "sort", "name" )
                    ]
            , hash = Nothing
            }
    }
```


## `Route.Path`

This module is generated to provide a type-safe way to link to other pages. Unlike `Route`, it doesn't store query parameters, hashes, or any other URL details.

Depending on your folder structure, the value of the `Path` type will be different. Underscores are used to separate folders. Here's an example folder structure and the corresponding generated `Path` custom type:

```txt
src/
└── Pages/
    ├── Home_.elm
    ├── Settings
    │   ├── Account.elm
    │   └── Notifications.elm
    ├── People.elm
    └── People/
        └── Id_.elm
```

```elm
type Path
    = Home_
    | Settings_Account
    | Settings_Notifications
    | People
    | People_Id_ { id : String }
    | NotFound_
```


### `Route.Path.href`

This function allows you to build a type-safe link to a page like `/people`.

#### Type definition

```elm
href : Path -> Html.Attribute msg
```

#### Example usage

```elm
--
-- Renders:
--   <a href="/people">People page</a>
--
Html.a 
    [ Route.Path.href Route.Path.People ]
    [ Html.text "People page" ]
```

### `Route.Path.toString`

This function is similar to `Route.Path.href`, but is helpful when getting absolute URL strings without rendering them with `Html.a` elements:

#### Type definition

```elm
toString : Path -> String
```

#### Example usage

```elm
Element.link
    { label = "People page"
    , url = Route.Path.toString Route.Path.People
    }
```
