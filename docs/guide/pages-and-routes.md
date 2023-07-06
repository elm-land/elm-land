---
outline: [2,3]
---

# Pages and routes

<h3>What you'll learn</h3>

1. How to __[add new pages](#adding-new-pages)__
1. How to __[link from one page to another](#navigating-between-pages)__
1. How to __[style a page with CSS](#adding-in-css)__

<BrowserWindow src="/images/guide/pages-and-routes.gif" alt="Demo of pages and layouts" />

<h3>Creating a new project</h3>

Before we get started, let's create a fresh new project called "pages-and-routes" using the Elm Land CLI:

```sh
elm-land init pages-and-routes
```
```sh
cd pages-and-routes
```
```sh
elm-land server
```

You should see your new Elm Land application is running at `http://localhost:1234`.

## Adding new pages

When you create a new project with `elm-land init`, a homepage is automatically created for you. A homepage is a great start, but most web applications will need multiple pages.

Let's imagine we are building a GitHub clone. Here are six pages it might contain:

- __Home__ - shows a feed with interesting repos to follow
- __Sign in__ - allow users to sign in with email/password
- __Account Settings__ - allows a user to change their email, username, etc
- __User__ - shows the profile for a specific user
- __Repo__ - shows a repo for a specific user
- __File Explorer__ - shows a repo for a specific user

In Elm Land, the __names of files__ in the `src/Pages` folder automatically connect a URL to a specific page. For example, if you navigated to `/banana` in your web browser, Elm Land would look for a file named `src/Pages/Banana.elm`. 

With that in mind, what would the pages in our fake GitHub app look like?

Page | Elm File & Example URLs
:-- | :-- 
__Home__|  __Elm file:__<br/>`src/Pages/Home_.elm`<br/><br/>__URLs:__<br/> `/` 
__Sign in__| __Elm file:__<br/> `src/Pages/SignIn.elm`<br/><br/>__URLs:__<br/> `/sign-in` 
__Account Settings__| __Elm file:__<br/> `src/Pages/Settings/Account.elm`<br/><br/>__URLs:__<br/> `/settings/account` 
__User__|  __Elm file:__<br/>`src/Pages/User_.elm`<br/><br/>__URLs:__<br/> `/elm`<br/>`/elm-land`<br/>`/ryannhg` 
__Repo__|  __Elm file:__<br/>`src/Pages/User_/Repo_.elm`<br/><br/>__URLs:__<br/> `/elm/compiler`<br/>`/elm-land/vscode`<br/>`/ryannhg/elm-spa` 
__Code Explorer__| __Elm file:__<br/> `src/Pages/User_/Repo_/Tree/Branch_/ALL_.elm`<br/><br/>__URLs:__<br/> `/elm-land/elm-land/tree/main/README.md`<br/>`/elm-land/elm-land/tree/main/examples/01-hello-world/elm.json`<br/>`/elm/compiler/tree/master/roadmap.md`

Let's add each of those pages together!


### The "Sign in" page

To get started, let's start with a page that is displayed when a user visits the URL `/sign-in`. 

We can create our sign-in page using the `elm-land add page` command shown below:

```sh
elm-land add page:view /sign-in
```

```txt
🌈  Elm Land added a new page at /sign-in
    ⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺
    You can edit your new page here:
    ./src/Pages/SignIn.elm
```

The `elm-land add page:view` command created a view-only page that allows us to customize two things:
- `title` - the text shown in the browser tab
- `body` - the HTML we want to render on the screen

Here's what that code looks like for our `/sign-in` page

```elm
module Pages.SignIn exposing (page)

import Html exposing (..)
import View exposing (View)


page : View msg
page =
    { title = "Pages.SignIn"
    , body = [ text "/sign-in" ]
    }
```

Anytime you run the `elm-land add page:view` command, a new file will be created in the `src/Pages` folder.

If we visit `http://localhost:1234/sign-in` in the browser, we will see this new page:

![Browser window showing the sign in page](./pages/sign-in.png)

### The "Account Settings" page

Some pages in our app need a URL like `/settings/account` or `/settings/notifications`. In _Elm Land_, we refer to these as "nested routes". 

A __nested route__ is what we call a route with more than one slash in the URL. Let's add a nested route for account settings:

```sh
elm-land add page:view /settings/account
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

import Html exposing (..)
import View exposing (View)


page : View msg
page =
    { title = "Pages.Settings.Account"
    , body = [ text "/settings/account" ]
    }
```



This is what we see when we visit `http://localhost:1234/settings/account`

![Browser window showing the settings page](./pages/settings.png)

::: tip "How deep can I nest routes?"

You can nest routes as much as you like, it doesn't have to be only two-levels deep:

```sh
elm-land add page:view /something/really/nested/like/super/nested
```

That command will create a file in a __bunch__ of nested folders inside your `src/Pages` directory, and be available when visiting the provided URL.

:::

### The "User" page

For things like the "User" page, our app won't know all the usernames up-front. It's common to define a single detail page that will work for _any_ username provided in the URL.

When we need to handle URLs like `/ryan`, `/duncan`, or `/alexa`, we can make a "dynamic route". 

A __dynamic route__ passes in URL parameters (like `username`) to your page as an input, so it can handle the dynamic values.

```sh
elm-land add page:view /:user
```

Unlike our static `/sign-in` and `/settings/account` pages, the dynamic user page has access to a URL parameter input. Let's take a look at the new file together:

```elm
module Pages.User_ exposing (page)

import Html exposing (..)
import View exposing (View)


page : { user : String } -> View msg
page params =
    { title = "Pages.User_"
    , body = [ text ("/" ++ params.user) ]
    }
```

Here, the value of `params.user` depends on the URL in the browser. For example, when a user navigates to `/elm-land`, the value of `params.user` will be `"elm-land"`.

This will be helpful later, when we learn how to work with APIs to fetch different content based on URL parameters.

#### __Naming dynamic parameters__

We learned earlier that page filenames affect which URL renders our page. Did you know they also affect the names of our dynamic URL parameters?

Because our user page was at `User_.elm`, the value for our URL parameter is `params.user`. 

If we renamed this file to `Id_.elm`, it would automatically update the parameter name to `params.id`. The Elm compiler will let us know if any of our code needs to change. This gives you the flexibility to choose the name that makes sense in each specific scenario.

::: tip "What's up with the trailing underscore?"
You may have noticed there is a __trailing underscore__ in the "User_.elm" file. What's up with that? 

Underscores help Elm Land distinguish a __static__ route from a __dynamic__ one:
- `User.elm` is __static__, and only handles `/user`
- `User_.elm` is __dynamic__, and can handle `/ryannhg`, `/elm-land`, and more

:::

### The "Repo" route

For our repo route, we'll want to access two dynamic parameters:
1. The `user` who owns the repo
2. The `repo` name for the project.


Elm Land supports __nested dynamic routes__, which handle _multiple_ dynamic URL parameters:

```sh
elm-land add page:view /:user/:repo
```


```elm
module Pages.User_.Repo_ exposing (page)

import Html exposing (..)
import View exposing (View)


page : { user : String, repo : String } -> View msg
page params =
    { title = "Pages.User_.Repo_"
    , body =
        [ text ("/" ++ params.user ++ "/" ++ params.repo)
        ]
    }
```

### The "Code Explorer" page

Some web applications have pages that need to respond to many different URLs with an unknown number of `/` characters between them. This might not make sense for Twitter, but can be helpful if you are building an app like GitHub.

To help users navigate their projects, GitHub has a [code explorer page](https://github.com/elm-land/elm-land/tree/main/examples/01-hello-world), which needs to handle a pattern like this:

```txt
/:owner/:repo/tree/:branch/*
```

Here are some real URL examples to help you visualize how the depth of this page's URL could be _any_ length:

```txt
/elm/compiler/tree/master/README.md
/elm-land/elm-land/tree/main/docs/README.md
/elm-land/elm-land/tree/main/examples/01-hello-world/elm.json
```

There will always be an `owner`, `repo`, and `branch`, but the number of files in a user's repo could be multiple URL levels deep. It depends on the content of each project's repo.

```sh
elm-land add page:view '/:user/:repo/tree/:branch/*'
```

This will create a file at `src/Pages/User_/Repo_/Tree/Branch_/ALL_.elm`: 

```elm
module Pages.User_.Repo_.Tree.Branch_.ALL_ exposing (page)

import Html exposing (..)
import View exposing (View)


page :
    { user : String
    , repo : String
    , branch : String 
    , all_ : List String 
    }
    -> View msg
page params =
    { title = "Pages.User_.Repo_.Tree.Branch_.ALL_"
    , body = [ text "..." ]
    }

```

The `ALL_.elm` filename is a special filename to handle a "catch-all route". Try opening any of these URLs in your web browser, all of them will match the new page we created!

- `http://localhost:1234/elm/compiler/tree/master/README.md`
- `http://localhost:1234/elm-land/elm-land/tree/main/docs/README.md`
- `http://localhost:1234/elm-land/elm-land/tree/main/examples/01-hello-world/elm.json`

#### The "all_" parameter

When working with catch-all routes, you'll have access to the special `params.all_` parameter. Here's a quick visualization of how the value of `params.all_` will change, based on the URL:

URL | `route.params`
:-- | :--
`/blog/hello` | `{ all_ = [ "hello" ] }`
`/blog/elm/land` | `{ all_ = [ "elm", "land" ] }`
`/blog/elm/land/ui` | `{ all_ = [ "elm", "land", "ui" ] }`


#### The "elm-land routes" command

After adding in all these pages, our project should look something like this:

```txt
pages-and-routes/
├── README.md
├── elm.json
├── elm-land.json
└── src/
    └── Pages/
        ├── Home_.elm
        ├── SignIn.elm
        ├── Settings/
        │   └── Account.elm
        ├── User_.elm
        └── User_/
            ├── Repo_.elm
            └── Repo_/
                └── Tree/
                    └── Branch_/
                        └── ALL_.elm
```

If you are ever curious about the routes in your Elm application, you can use the built-in `elm-land routes` command. Here's what that looks like:

```sh
elm-land routes
```

```txt

  🌈  Elm Land (v0.19.1) found 6 pages in your application
    ⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺
  src/Pages/Home_.elm ........................... /
  src/Pages/SignIn.elm .......................... /sign-in
  src/Pages/Settings/Account.elm ................ /settings/account
  src/Pages/User_.elm ........................... /:user
  src/Pages/User_/Repo_.elm ..................... /:user/:repo
  src/Pages/User_/Repo_/Tree/Branch_/ALL_.elm ... /:user/:repo/tree/:branch/*


```

## Navigating between pages

So far, to navigate from one page to another, we've been manually changing the URL in the browser. In a real app, our users need a way to navigate the app within the UI. 

For that reason, let's make a sidebar component with convenient links to the "Homepage", "Settings", and "User" pages. We'll design our component so it's easy to add it to any page we like.

### The "Sidebar" component

Let's start by creating a new file at `src/Components/Sidebar.elm`, with the following content:

```elm
module Components.Sidebar exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import View exposing (View)


view :
    { title : String
    , body : List (Html msg) 
    }
    -> View msg
view props =
    { title = props.title
    , body =
        [ div [ class "layout" ]
            [ aside [ class "sidebar" ]
                [ a [ href "/" ] [ text "Home" ]
                , a [ href "/elm-land" ] [ text "User" ]
                , a [ href "/elm-land/vscode" ] [ text "Repo" ]
                , a [ href "/settings/account" ] [ text "Settings" ]
                ]
            , div [ class "page" ] props.body
            ]
        ]
    }
```

To make it easy to reuse, we'll accept the entire page as the input to the UI component. Just like we might pass in a `String`, `Int`, or another value, we can pass in `Html msg` to allow our page's content to be nested inside our component.


### Using components on pages

This new sidebar isn't automatically wired up to all our pages. In _Elm Land_, you can easily opt-in to which pages should use the sidebar by importing the module.

For our example, we don't want a sidebar on the "Sign in" page. For that reason, we will only connect it to 
our "Homepage", "Account Settings", and "User" page by adding in these lines of code:

```elm {3,10}
module Pages.Home_ exposing (page)

import Components.Sidebar
import Html exposing (..)
import View exposing (View)


page : View msg
page =
    Components.Sidebar.view
        { title = "Homepage"
        , body = [ text "Hello, world!" ]
        }
```

Here's what we did in the code snippet above:
1. Imported the `Components.Sidebar` module on line 3
2. Passed in the previous `{ title, body }` record as an input to our component

Try following the same steps to get this working for: `Pages.Settings.Account` and `Pages.User_`. I've included the actual code snippets when you're ready to see what's changed:

::: details Adding the sidebar to `Pages.Settings.Account`

```elm {3,10}
module Pages.Settings.Account exposing (page)

import Components.Sidebar
import Html exposing (..)
import View exposing (View)


page : View msg
page =
    Components.Sidebar.view
        { title = "Pages.Settings.Account"
        , body = [ text "/settings/account" ]
        }
```

:::

::: details Adding the sidebar to `Pages.User_`

```elm {3,10}
module Pages.User_ exposing (page)

import Components.Sidebar
import Html exposing (..)
import View exposing (View)


page : { username : String } -> View msg
page params =
    Components.Sidebar.view 
      { title = "Pages.User_"
      , body = [ text ("/" ++ params.user) ]
      }
```

:::

## Adding in CSS

All of our pages and layouts are ready, but there's still one missing piece: the page doesn't look pretty. We can add __CSS__ to our Elm Land projects by modifying the `elm-land.json` file at the root of our project.

Let's add a `<link>` tag to our HTML by updating the `app.html.link` property:

```json {19-21}
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
        { "rel": "stylesheet", "href": "/main.css" }
      ],
      "script": []
    },
    "router": {
      "useHashRouting": false
    }
  }
}
```

### The "static" folder

You can serve static files like images or CSS by adding them in a `static` folder at the project root, alongside the `src` folder and `elm-land.json` file.

Let's start by creating a file at `./static/main.css`:

```txt{8-9}
pages-and-routes/
├── README.md
├── elm.json
├── elm-land.json
├── src/
│   └── Pages/
│       └── ...
└── static/
    └── main.css
```

```css
/* static/main.css */

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

<h3>Nice work!</h3>

You just made a multi-page application in Elm Land! Next up, let's take a look at how we can handle user input by learning "The Elm Architecture".

See you there! :wave:
