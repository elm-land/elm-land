---
outline: [2,3]
---
# Pages

## Overview

Pages are the basic building blocks of your Elm Land application. When a user visits a URL, Elm Land will use the names of the files in your `src/Pages` folder to decide which page to render.

Later on in this section, you'll learn different kinds of routes and priority. 

::: tip Already familiar with Elm?

In a standard Elm project, all URL requests go to one `Main.elm` file. In Elm Land, you can think of each `page` as
its own `main` function.

The big difference is that all pages are connected to each other, can share data with via `Shared.Model`, and access type-safe URL information using the `Route` type. 

No need to write your URL parsers by hand!

:::

## Adding pages

When you run the `elm-land add page` command, a new page is created. Each new page will look something like this:

```sh
elm-land add page /settings
```

__That command generates `src/Pages/Settings.elm`:__

```elm
module Pages.Settings exposing (Model, Msg, page)

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
```

::: tip "What about view, sandbox, and element?"

Earlier in the guide, you may have seen commands like `add page:view`, `add page:sandbox`, or `add page:element`.

Those three commands are designed to help you learn the basics "The Elm Architecture". 

Once you are comfortable with `Model`, `Msg`, `Effect`, and `Sub`, we recommend only using `Page.new` in your app.

:::


### Understanding pages

The `Page.new` function takes in four smaller functions. Together, they tell Elm Land how your page should look and behave. Here's an overview of each function:

#### `init`

This function is called anytime your page loads.
```elm
init : () -> ( Model, Effect Msg )
init _ =
    ...
```

#### `update`

This function is called whenever a user or the browser sends a message.

```elm
update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    ...
```

#### `view`

This function converts the current model to the HTML you want to show the user.

```elm
view : Model -> View Msg
view model =
    ...
```

#### `subscriptions`
This function listens for ongoing events like "window resized" or "javascript sent a message" and forwards that as a `Msg` for the `update` function to handle.

```elm
subscriptions : Model -> Sub Msg
subscriptions model =
    ...
```

### Working with "shared" or "route"

You may have noticed that every `page` is a function that receive two arguments, `shared` and `route`:

```elm{2}
page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
```

But what are these arguments for?

- `shared` – Stores any data you want to share across all your pages. 

  - In [the Shared section](./shared), you'll learn how to customize what data should be available.

- `route` – Stores URL information, including things like `route.params` or `route.query`. 

  - In [the Route section](./route), you'll learn more about the other values on the `route` field.


Both of these values are available to any function within `page`. That means `init`, `update`, `view` and `subscriptions` all can get access to `shared` and `route`.

In the code example below, note how we pass the `shared` value as the first argument of the `view` function:

```elm{12}
module Pages.Settings exposing (Model, Msg, page)

import Page exposing (Page)
-- ...


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , view = view shared
        , subscriptions = subscriptions
        }
```

After we pass in the `shared` argument on line 12, we can update our `view` function to get access to `shared` in our view code:

```elm{6-7}
-- BEFORE
view : Model -> View Msg
view model = ...

-- AFTER
view : Shared.Model -> Model -> View Msg
view shared model = ...
```

The same concept applies to `init`, `update`, and `subscriptions`. 

For example, you might want your `init` function to use a URL parameter to decide what API endpoint to call. In this case, we can pass `route` into our `init` function using the same process as before:

```elm{10}
module Pages.Settings exposing (Model, Msg, page)

import Page exposing (Page)
-- ...


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init route
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
```

After we pass in the `route` argument on line 10, we can update our `init` function to get access to `route` in our view code:

```elm{6-7}
-- BEFORE
init : () -> ( Model, Effect Msg )
init _ = ...

-- AFTER 
init : Route () -> () -> ( Model, Effect Msg )
init route _ = ...
```


## Removing pages

Elm Land uses the `elm-land add page` command to create pages, so a few users have expected a similar `elm-land remove page` command. There is no special command for removing a page file, instead you can delete the file in your file explorer, or run this command:

```sh
rm src/Pages/Settings.elm
```

Elm Land will automatically delete the generated code associated with the old page. The Elm compiler will let you know if any other parts of your app depended directly on that page. 

We recommend using `Route.href` rather than `Html.Attributes.href` when linking to other pages with `<a>` tags. This allows Elm Land to detect broken links and tell you about them.

## Route naming convention 

When working with pages, it's important to understand how Elm Land determines which page files to load. If you have worked with a JavaScript application framework before, these rules should look familiar.

Here are the categories of routes you'll find in every Elm Land project, ordered from most to least specific:

Route | URL example | Description
:-- | :-- | :--
__Homepage__ | `/` | Handles requests to the top-level URL (`/`).
__Static routes__ | `/people` | Directly maps __one URL__ to a page.
__Dynamic routes__ | `/people/:id` | Maps __many URLs__ with a similar structure to a page.
__Catch-all routes__ | `/people/*` | Like dynamic routes, but can support __any depth__.
__Not found page__ | `/*` | Handles any URL that can't find a matching page.

### Homepage

This file is created automatically for you with the `elm-land init` command. It uses a special trailing underscore to 
help distinguish itself from the [static routes](#static-routes) documented below.

Here's a visual to help understand the subtle difference:

Page filename | URL
:-- | :--
`src/Pages/Home_.elm` | `/`
`src/Pages/Home.elm` | `/home`

__Note:__ In other projects, you might see this file called "index" or "root" or "top-level".


### Static routes

Let's start by talking about "static routes". These routes directly map one URL to a page file.

You can use capitalization in your filename to add a dash (`-`) between words.

Page filename | URL
:-- | :--
`src/Pages/Hello.elm` | `/hello`
`src/Pages/AboutUs.elm` | `/about-us`
`src/Pages/Settings/Account.elm` | `/settings/account`
`src/Pages/Settings/General.elm` | `/settings/general`
`src/Pages/Something/Really/Nested.elm` | `/something/really/nested`

### Dynamic routes

Some page filenames have a trailing underscore, (like `Id_.elm` or `User_.elm`). These are called "dynamic pages", because this page can handle multiple URLs matching the same pattern. Here are some examples:

Page filename | URL | Example URLs
:-- | :-- | :--
`src/Pages/Blog/Id_.elm` | `/blog/:id` | `/blog/1`, `/blog/2`, `/blog/xyz`, ...
`src/Pages/Users/Username_.elm` | `/users/:username` | `/users/ryan`, `/users/2`, `/users/bob`, ...
`src/Pages/Settings/Tab_.elm` | `/settings/:tab` | `/settings/account`, `/settings/general`, `/settings/api`, ...

The name of the file (`Id_`, `User_` or `Tab_`) will determine the names of the parameters available on the `route.params` value passed into your `page` function:

```
-- /blog/123
route.params.id == "123"

-- /users/ryan
route.params.user == "ryan"

-- /settings/account
route.params.tab == "account"
```

For example, if we renamed `Settings/Tab_.elm` to `Settings/Foo_.elm`, we'd access the dynamic route parameter with `route.params.foo` instead!

::: tip "Wait, I've seen these before!"

If this concept is already familiar to you, great! "Dynamic routes" aren't an Elm Land idea, they come
from popular frameworks like Next.js and Nuxt.js:

- Next.js uses the naming convention: `blog/[id].js`
- Nuxt.js uses the naming convention: `blog/_id.vue`

Because Elm files can't start with special characters, Elm Land uses a trailing `_` to denote the difference between `Blog/Id.elm` and `Blog/Id_.elm`:

- `Blog/Id.elm` is a __static page__ that _only_ handles `/blog/id`
- `Blog/Id_.elm` is a __dynamic page__ that can handle `/blog/id`, `/blog/xyz`, `/blog/3000`, etc

:::

### Catch-all routes

Sometimes you'll need to define a page that handles an unknown depth. Using the special reserved keyword `ALL_.elm`, you can define a "catch-all" route that does just that.

Here are a few examples to help you visualize how it works:

Page filename | URL
:-- | :--
`src/Pages/ALL_.elm` | `/*`
`src/Pages/Blog/ALL_.elm` | `/blog/*`
`src/Pages/Settings/Tab_/ALL_.elm` | `/settings/:tab/*`
`src/Pages/:User/:Repo/Tree/ALL_.elm` | `/:user/:repo/tree/*`

#### The `all_` parameter

For dynamic parameters, we need access to a single variable, like `params.id` or `params.username`. Because catch-all routes are nested, you'll want a `List String` back when dealing with them.

Every catch-all route has access to the `params.all_` variable:

```elm
-- Filename: src/Pages/ALL_.elm
-- URL: /each/part/of/the/path
route.params ==
    { all_ = [ "each", "part", "of", "the", "path" ]
    }
```

__Note:__ To avoid confusion with a dynamic route `All_.elm`, Elm Land adds a trailing underscore after `all_` on the params.

#### Simple catch-all example

If you're making a blog, you might want a page that handles all requests within the `/blog/*` URL. Here are some examples to help you visualize the value of `route.params` for different URLs: 


Page filename | URL
:-- | :--
`src/Pages/Blog/ALL_.elm` | `/blog/*`


```elm
-- /blog/hello-world
route.params ==
    { all_ = [ "hello-world" ]
    }

-- /blog/elm/part-1
route.params ==
    { all_ = [ "elm", "part-1" ]
    }

-- /blog/elm/part-2
route.params ==
    { all_ = [ "elm", "part-2" ]
    }
```

#### Advanced catch-all example

A practical example of this is [GitHub's file explorer page](https://github.com/elm-land/elm-land/tree/main/examples/01-hello-world). These URLs have different depth, depending on the content of a user's repo. 

With Elm Land, you can mix and match dynamic parameters with your catch-all files to get the exact URL route parameters you need. Here's another visual example:

Page filename | URL
:-- | :--
`src/Pages/:User/:Repo/Blob/:Branch/Tree/ALL_.elm`  | `/:user/:repo/tree/:branch/*`


```elm
-- /elm-land/elm-land/tree/main/README.md
route.params ==
    { repo = "elm-land"
    , user = "elm-land"
    , branch = "main"
    , all_ = [ "README.md" ]
    }

-- /ryannhg/elm-spa/tree/master/README.md
route.params ==
    { repo = "ryannhg"
    , user = "elm-spa"
    , branch = "master"
    , all_ = [ "README.md" ]
    }

-- /elm-land/elm-land/tree/main/projects/cli/package.json
route.params ==
    { repo = "elm-land"
    , user = "elm-land"
    , branch = "main"
    , all_ = [ "projects", "cli", "package.json" ]
    }
```

### Not found page

By default, a 404 page is generated by Elm Land. This will automatically handle any URL request that doesn't map to one of your page files. 

Imagine these are the pages in your project:

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

If these were the pages in your app, here's how each URL would map to a page file:

URL | Elm Land Page
:-- | :--
`/` | `src/Pages/Home_.elm`
`/settings` | ( Page not found! )
`/settings/account` | `src/Pages/Settings/Account.elm`
`/settings/notifications` | `src/Pages/Settings/Notifications.elm`
`/people` | `src/Pages/People.elm`
`/people/ryan` | `src/Pages/People/Ryan.elm`
`/people/duncan` | `src/Pages/People/Duncan.elm`
`/people/something/nested` | ( Page not found! )
`/banana` | ( Page not found! )

In [the Custom 404 Pages section](./404), you'll learn how to customize your 404 page. When you do that, a new file called `NotFound_.elm` will appear in your `src/Pages` folder. 

Just like we saw with the [homepage](#homepage) file, the trailing underscore helps prevent confusion with any projects containing a static route at `/not-found`:

Page filename | URL
:-- | :--
`src/Pages/NotFound.elm` | `/not-found`
`src/Pages/NotFound_.elm` | `/*`


## Auth-protected pages

Because Elm Land is designed for building web applications, it also comes with a built-in way to mark a page as "auth-protected". An "auth-protected" page is one that shouldn't be rendered for users that aren't signed in.

You can easily upgrade any page to become "auth-protected", by adding the `Auth.User` as the first argument:

```elm{4}
-- BEFORE
page : Shared.Model -> Route () -> Page Model Msg

-- AFTER
page : Auth.User -> Shared.Model -> Route () -> Page Model Msg
```

By adding `Auth.User` as the first argument of your `page` function, you're letting Elm Land know that this page should only show when a user is signed in.

In [the `Auth` section](./auth.md), we'll learn more about the `User` type, how to define redirect rules, and more.
