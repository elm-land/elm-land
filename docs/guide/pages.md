# Pages and routes

### What we'll learn

- How to add __pages__ to our app
- How to __to navigate__ from one page to another
- How to style a page with __CSS__

<BrowserWindow src="/images/guide/pages-and-routes.gif" alt="Demo of pages and layouts" />

## How routing works

When we create a new project with `elm-land init`, a homepage is automatically created for us. A homepage is a great start, but most web applications have multiple pages!

For example, we might want these four pages in our app:

- __Homepage__ - shows a feed of the latest posts
- __Sign in__ - allow users to sign in with email/password
- __Settings__ - allows a user to change their account settings
- __Profile__ - View the profile of a specific user



Page | URLs | Elm file
:-- | :-- | :--
Homepage | `/` | `src/Pages/Home_.elm`
Sign in | `/sign-in` | `src/Pages/SignIn.elm`
Settings | `/settings/account` | `src/Pages/Settings/Account.elm`
Profile | `/profile/ryan`<br/>`/profile/duncan`<br/>`/profile/alexa` | `src/Pages/Profile/Username_.elm`

In _Elm Land_, the names of files in our `src/Pages` automatically connect a URL to a specific page. For example, if we navigated to `/messages` in a web browser, _Elm Land_ would look for a file at `src/Pages/Messages.elm`

In this guide, we'll learn how to use the Elm Land CLI to add new pages by specifying the URL we want to visit in the browser.

### Creating a fresh project

Let's create a new project with the CLI, then run a local development server:

```sh
elm-land init pages-and-routes
```
```sh
cd pages-and-routes
```
```sh
elm-land server
```

Now that we have a new Elm Land project, and a server running at `http://localhost:1234` we can use the CLI to add a new page.

## Static routes

To get started, let's start with a page that is displayed when a user visits the URL `/sign-in`. 

We can create our sign-in page using the `elm-land add page` command shown below:

```sh
elm-land add page:static /sign-in
```

```txt
🌈  Elm Land added a new page at /sign-in
    ⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺
    You can edit your new page here:
    ./src/Pages/SignIn.elm
```

The `elm-land add page:static` command created a view-only page that allows us to customize two things:
- `title` - the text shown in the browser tab
- `body` - the HTML we want to render on the screen

Here's what that code looks like for our `/sign-in` page

```elm
module Pages.SignIn exposing (page)

import Html
import View exposing (View)


page : View msg
page =
    { title = "Pages.SignIn"
    , body = [ Html.text "/sign-in" ]
    }
```

Anytime you run the `elm-land add page` command, a new file will be created in the `src/Pages` folder.

If we visit `http://localhost:1234/sign-in` in the browser, we will see this new page:

![Browser window showing the sign in page](./pages/sign-in.png)

## Nested routes

Some pages in our app need a URL like `/settings/account` or `/settings/notifications`. In _Elm Land_, we refer to these as "nested routes". 

A __nested route__ is what we call a route with more than one slash in the URL. Let's add a nested route for account settings:

```sh
elm-land add page:static /settings/account
```

```txt
🌈  Elm Land added a new page at /settings/account
    ⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺
    You can edit your new page here:
    ./src/Pages/Settings/Account.elm
```

Here is the code generated at `./src/Pages/Settings/Account.elm`:

```elm
module Pages.Settings.Account exposing (page)

import Html
import View exposing (View)


page : View msg
page =
    { title = "Pages.Settings.Account"
    , body = [ Html.text "/settings/account" ]
    }
```



This is what we see when we visit `http://localhost:1234/settings/account`

![Browser window showing the settings page](./pages/settings.png)

::: tip "How deep can I nest routes?"

You can nest routes as much as you like, it doesn't have to be only two-levels deep:

```sh
elm-land add page:static /something/really/nested/like/super/nested
```

That command will create a file in a __bunch__ of nested folders inside your `src/Pages` directory, and be available when visiting the provided URL.

:::

## Dynamic routes

For things like our "Profile" page, we won't know all the usernames up-front. It's common to define a single detail page that will work for _any_ username provided in the URL.

When we need a page to handle URLs like `/profile/ryan`, `/profile/duncan`, or `/profile/alexa`, we can make a "dynamic route". 

A __dynamic route__ passes in URL parameters (like `username`) to your page as an input, so it can handle the dynamic values.

```sh
elm-land add page:static /profile/:username
```

![Browser window showing the profile page](./pages/profile-ryan.png)


Unlike our static `/sign-in` and `/settings/account` pages, the dynamic profile page has access to a URL parameter input. Let's take a look at the new file together:

```elm
module Pages.Profile.Username_ exposing (page)

import Html
import View exposing (View)


page : { username : String } ->  View msg
page params =
    { title = "Pages.Profile.Username_"
    , body = [ Html.text ("/profile/" ++ params.username) ]
    }
```

Here, the value of `params.username` depends on the URL in the browser. For example, when a user navigates to `/profile/ryan`, the value of `params.username` will be `"ryan"`.

This will be helpful later, when we learn how to work with APIs to fetch different content based on URL parameters.

### Names for dynamic parameters

We learned that names of page files affect which URL renders our page, but they also can affect the names of our URL parameters.

Because our profile page was at `Profile/Username_.elm`, the value for our URL parameter is `params.username`. 

If we renamed this file to `Profile/Id_.elm`, it would automatically update the parameter name to `params.id`. The Elm compiler will let us know if any of our code needs to change, so this isn't a scary thing!

This allows us the flexibility to choose the name that makes sense in each specific scenario.

::: tip "What about numeric IDs?"

Many apps have URLs like `/posts/123`, which use `Int` IDs to work with backend APIs. _Elm Land_ supports these URLs too!

If we made a page at `src/Pages/Posts/Id_.elm`, and visited `/posts/123`, this would be the value of our URL parameters:

```elm
params.id == "123"
```

Notice how `"123"` is a `String`, not an `Int`?

_Elm Land_ treats all URL parameters as `String` values. In practice, whether we get a URL like `/posts/99999` or `/posts/banana`, we'll still show the same "post not found" view in our app. 

Having the "type safety" of `Int` doesn't buy us much in this scenario. This design choice is also consistent with other popular JS frameworks like [Vue's Nuxt.js](https://v3.nuxtjs.org/guide/directory-structure/pages#dynamic-routes) and [React's Next.js](https://nextjs.org/docs/routing/dynamic-routes).

:::

::: tip "What's up with the trailing underscores?"
You may have noticed there is a __trailing underscore__ in some of our filenames. What's up with that? 

Here are some reasons you will see an underscore in page filenames:
1. To distinguish `/` (`Home_.elm`) from `/home` (`Home.elm`)
2. To distinguish a __static__ page from a __dynamic__ one:
     - `Profile/Username.elm` only handles `/profile/username`
     - `Profile/Username_.elm` handles `/profile/ryan`, `profile/duncan`, and more!

:::

## Catch-all routes

Some web applications have pages that need to respond to many different URLs with an unknown number of `/` characters between them.

A popular example of this is [GitHub's code explorer page](https://github.com/elm-land/elm-land/tree/main/examples/01-hello-world), which needs to handle a pattern like this:

```txt
/:owner/:repo/tree/:branchName/*
```

There will always be an `owner`, `repo`, and `branch` name– but the number of files in a repo could mean any length of URL. It depends on the content of the project's repo.

Here are some real URL examples to help you visualize how the depth of this page's URL could be _any_ length:

```txt
/elm/compiler/tree/master/README.md
/elm-land/elm-land/tree/main/docs/README.md
/elm-land/elm-land/tree/main/examples/01-hello-world/elm.json
/elm-land/elm-land/tree/main/examples/02-pages-and-routes
```

### Adding a catch-all route

Luckily, Elm Land supports creating pages like this! Let's use the `elm-land add page` CLI command to create a __"catch-all route"__ that matches deeply nested URL patterns.

For simplicity, let's do one that matches `/blog/*`:

```sh
elm-land add page:static '/blog/*'
```


This will create a brand new file at `src/Pages/Blog/ALL_.elm`: 

```elm
module Pages.Blog.ALL_ exposing (page)

import Html exposing (Html)
import View exposing (View)


page : { first_ : String, rest_ : List String } -> View msg
page params =
    { title = "Pages.Blog.ALL_"
    , body =
        [ Html.text
            ("/blog/" ++
                String.join "/" (params.first_ :: params.rest_)
            )
        ]
    }

```
Just like we saw before with [dynamic routes](#dynamic-routes), the trailing `_` in this filename means this page does something special. In our case, the `ALL_.elm` filename is a reserved keyword for a "catch-all route".

Try opening any of these URLs in our browser:

- `http://localhost:1234/blog/hello`
- `http://localhost:1234/blog/elm/land`
- `http://localhost:1234/blog/elm/land/ui`

All of those URLs will match our single page file.

### Understanding catch-all parameters

When working with catch-all routes, you'll have access to two special URL parameters in `route.params`:

- `first_ : String` – The first URL parameter in the catch-all route
- `rest_ : List String` – The remaining URL parameters

Here's a visual of the URL parameters you'll get for the URLs we listed above:

URL | `route.params`
:-- | :--
`/blog/hello` | `{ first_ = "hello", rest_ = [] }`
`/blog/elm/land` | `{ first_ = "elm", rest_ = [ "land" ] }`
`/blog/elm/land/ui` | `{ first_ = "elm", rest_ = [ "land", "ui" ] }`

::: tip "Why not just one `List String`?"

Elm Land provides the URL parameters in two separate variables so you
don't need to worry about handling the case where your list
is empty.

This is another way to represent a "non-empty list", which is a popular
data structure for guaranteeing that you don't have to handle an edge case
for an impossible URL!

:::

### Our project so far

After adding in all these pages, our project should look something like this:

```txt
elm.json
elm-land.json
src/
|- Pages/
    |- Home_.elm
    |- SignIn.elm
    |- Blog/
        |- ALL_.elm
    |- Settings/
        |- Account.elm
    |- Profile/
        |- Username_.elm
```

If you are ever curious about the routes in your Elm application, you can use the built-in `elm-land routes` command. Here's what that looks like:

```sh
elm-land routes
```

```txt

  🌈  Elm Land (v0.18.2) found 5 pages in your application
  ⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺
  src/Pages/Home_.elm ............... http://localhost:1234/
  src/Pages/SignIn.elm .............. http://localhost:1234/sign-in
  src/Pages/Blog/ALL_.elm ........... http://localhost:1234/blog/*
  src/Pages/Settings/Account.elm .... http://localhost:1234/settings/account
  src/Pages/Profile/Username_.elm ... http://localhost:1234/profile/:username

```

## Adding a sidebar

So far, to navigate from one page to another, we've been manually changing the URL in the browser. In a real app, our users need a way to navigate the app within the UI. 

For that reason, let's make a sidebar component with convenient links to the "Homepage", "Account Settings", and "Profile" pages. We'll design our component so it's
easy to add it to any page we like!

Let's create a new file at `src/Components/Sidebar.elm`:

```elm
module Components.Sidebar exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import View exposing (View)


view : { page : View msg } -> View msg
view { page } =
    { title = page.title
    , body = 
        [ Html.div [ Attr.class "page" ] page.body
        ]
    }
```

To make it easier to use, we'll accept the entire page as the input to this UI component. If you're familiar with Vue.js, this ideas is similar to their notion of "slots".
Just like we might pass in a `String`, `Int`, or another value, we can pass in an entire `View msg` to allow page's to be nested within a component. 

In the default example, we are wrapping the page's content in a `div` with the class `"page"`

### Adding some more HTML

The default layout doesn't have a sidebar, but we can make one with some HTML. Add the highlighted lines below to your new `src/Components/Sidebar.elm` file

```elm {12-16,20-26}
module Components.Sidebar exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import View exposing (View)


view : { page : View msg } -> View msg
view { page } =
    { title = page.title
    , body =
        [ Html.div [ Attr.class "layout" ]
            [ viewSidebar
            , Html.div [ Attr.class "page" ] page.body
            ]
        ]
    }


viewSidebar : Html msg
viewSidebar =
    Html.aside [ Attr.class "sidebar" ]
        [ Html.a [ Attr.href "/" ] [ Html.text "Home" ]
        , Html.a [ Attr.href "/profile/me" ] [ Html.text "Profile" ]
        , Html.a [ Attr.href "/settings/account" ] [ Html.text "Settings" ]
        ]
```

Next, we'll actually use this new sidebar component in our pages.

## Adding a component to a page

This new sidebar isn't automatically wired up to all our pages. In _Elm Land_, you can easily opt-in to which pages should use the sidebar by importing the module.

For our example, we don't want a sidebar on the "Sign in" page. For that reason, we will only connect it to 
our "Homepage", "Account Settings", and "Profile" page by adding in these lines of code:

```elm {3,10-11,15}
module Pages.Home_ exposing (page)

import Components.Sidebar
import Html
import View exposing (View)


page : View msg
page =
    Components.Sidebar.view
        { page =
            { title = "Homepage"
            , body = [ Html.text "Hello, world!" ]
            }
        }
```

Here's what we did in the code snippet above:
1. Imported the `Components.Sidebar` module on line 3
2. Passed in the previous `{ title, body }` record as an input to our component

Try following the same steps to get this working for: `Pages.Settings.Account` and `Pages.Profile.Username_`. I've included the actual code snippets when you're ready to see what's changed:

::: details Adding the sidebar to `Pages.Settings.Account`

```elm {3,10-11,15}
module Pages.Settings.Account exposing (page)

import Components.Sidebar
import Html
import View exposing (View)


page : View msg
page =
    Components.Sidebar.view
        { page =
            { title = "Pages.Settings.Account"
            , body = [ Html.text "/settings/account" ]
            }
        }
```

:::

::: details Adding the sidebar to `Pages.Profile.Username_`

```elm {3,10-11,15}
module Pages.Profile.Username_ exposing (page)

import Components.Sidebar
import Html
import View exposing (View)


page : { username : String } -> View msg
page params =
    Components.Sidebar.view
        { page =
            { title = "Pages.Profile.Username_"
            , body = [ Html.text ("/profile/" ++ params.username) ]
            }
        }
```

:::

## Styling things with CSS

All of our pages and layouts are ready, but there's still one missing piece: the page doesn't look pretty. We can add __CSS__ to our Elm Land projects by modifying the `elm-land.json` file at the root of our project.

Let's add a `<link>` tag to our HTML by updating the `app.html.link` property:

```json {20-22}
{
  "app": {
    "elm": {
      "development": { "debugger": true },
      "production": { "debugger": false }
    },
    "env": [],
    "html": {
      "attributes": {
        "html": { "lang": "en" },
        "head": {}
      },
      "title": "My Elm Land App",
      "meta": [
        { "charset": "UTF-8" },
        { "http-equiv": "X-UA-Compatible", "content": "IE=edge" },
        { "name": "viewport", "content": "width=device-width, initial-scale=1.0" }
      ],
      "link": [
        { "rel": "stylesheet", "href": "/styles.css" }
      ],
      "script": []
    },
    "router": {
      "useHashRouting": false
    }
  }
}
```

You can serve static files like images or CSS by adding them in a `static` folder at the project root, alongside the `src` folder and `elm-land.json` file.

For this example, let's create a new CSS file at `./static/styles.css`, with the following CSS:

```css
body {
  padding: 32px;
}

.layout {
  display: flex;
  gap: 16px;
}

.sidebar {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
```

Now that we've added in some CSS, we should see our full example working. We can use our sidebar to navigate from one page to another.

<BrowserWindow src="/images/guide/pages-and-routes.gif" alt="Demo of pages and layouts" />

See the full example in the [examples/02-pages-and-routes](https://github.com/elm-land/elm-land/tree/main/examples/02-pages-and-routes) folder on GitHub.

### Congratulations! :tada:

You just made a multi-page application in Elm Land! 

Next up, let's take a look at how we can handle user input using The Elm Architecture!

<!-- Next up, we'll use a real REST API to fetch JSON and learn how to handle HTTP requests and responses! -->
