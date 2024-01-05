---
outline: deep
---
# elm-land.json

## Overview

The purpose of the `elm-land.json` file is to provide one place to configure your Elm Land application. Elm Land works out-of-the-box with zero-configuration, but more advanced web applications will customize some of the options described below.


### The complete file

For reference, here is the default `elm-land.json` file that is created with every new Elm Land project created via the CLI:

```json
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
      "title": "Elm Land",
      "meta": [
        { "charset": "UTF-8" },
        { "http-equiv": "X-UA-Compatible", "content": "IE=edge" },
        { "name": "viewport", "content": "width=device-width, initial-scale=1.0" }
      ],
      "link": [],
      "script": []
    },
    "router": {
      "useHashRouting": false
    },
    "proxy": null
  }
}
```

There are no hidden defaults here, everything in this JSON file is explicitly defined to prevent unexpected behavior. When you run `elm-land server` or `elm-land build`, any missing fields in this file show a helpful message. That message will explain which fields are missing, and how you can fix the problem.

The sections below provide more details on the purpose of each individual field.

## app.elm

::: info TYPE
```elm
{ development : { debugger : Bool }
, production :  { debugger : Bool }
}
```
:::

This section specifies options that you would normally send the Elm compiler. For convenience, this is split into the two fields below, so you can control each independently.


### app.elm.development


::: info TYPE
```elm
{ debugger : Bool }
```
:::


This defines the Elm compiler options that will be used during `elm-land server`.

```jsonc {4}
{
  "app": {
    "elm": {
      "development": { "debugger": true },
      // ...
    }
    // ...
  }
}
```

- By specifying `true`, you will enable the Elm debugger in the bottom-right corner of your web browser.
- By specifying `false`, the Elm debugger will be disabled, and the icon will no longer be visible.


### app.elm.production


::: info TYPE
```elm
{ debugger : Bool }
```
:::


This defines the Elm compiler options that will be used during `elm-land build`.

```jsonc {5}
{
  "app": {
    "elm": {
      // ...
      "production": { "debugger": false },
    }
    // ...
  }
}
```

- By specifying `true`, you will enable the Elm debugger in the bottom-right corner of your web browser.
- By specifying `false`, the Elm debugger will be disabled, and the icon will no longer be visible.


## app.env

::: info TYPE
```elm
List String
```
:::


Elm Land allows users to access "environment variables". These variables are commonly used to help determine if an application is running in production or development. 

For security reasons, __all environment variables are hidden__ from your Elm Land application by default. For example, even if you run `NODE_ENV=production elm-land server`, your Elm application still will not have access to the `NODE_ENV` variable.

This is because these values are __fully visible to anyone__ visiting your website. For that reason, you should __never__ expose any private secrets via environment variables. 

When you want to share an environment variable with your app, the `app.env` field is the one spot check:

```jsonc {4}
{
  "app": {
    // ...
    "env": [ "NODE_ENV", "PUBLIC_GITHUB_TOKEN" ],
    // ...
  }
}
```

In the [Working with JavaScript](/guide/working-with-js) guide, you'll learn how to use `src/interop.js` to access the environment variables allowed by this file.


::: tip Auditing made easy!
If you ever need to audit which variables are exposed to your frontend, this one field in your `elm-land.json` file is the only place you need to check.
:::


## app.html


::: info TYPE
```elm
{ attributes : 
    { html : Dict String String 
    , head : Dict String String
    }
, title : String
, meta : List (Dict String String)
, link : List (Dict String String)
, script : List (Dict String String)
}
```
:::



Because Elm Land generates "single-page apps", all requests are directed to a single `index.html` file. This section specifies how that `index.html` file should be generated, and will apply to every page.

Here is the general shape of that HTML template to give you an overview:

```html
<!DOCTYPE html>
<html {{attributes.html}} >
  <head {{attributes.head}} >
    <title>{{title}}</title>
    {{ meta tags }}
    {{ link tags }}
    {{ script tags }}
  </head>
  <body>
    <!-- Elm Land's entrypoint -->
  </body>
</html>
```

::: tip
Elm Land is designed for web applications, usually behind a sign-in screen. For that reason, only a single HTML page is currently supported.

If you'd like to use Elm, but for a website that needs HTML tags to be specified on a per-page basis, other projects like [Elm Pages](https://elm-pages.com) are better suited for your use-case.
:::


### app.html.attributes


::: info TYPE
```elm
{ html : Dict String String 
, head : Dict String String
}
```
:::

This section allows users to specify HTML attributes on the generated `<html>` and `<head>` tags. Each set of attributes can be represented with a JSON object, where the object's key is the HTML attribute's name, and the `value` is the attribute's value. 


#### app.html.attributes.html

::: info TYPE
```elm
Dict String String
```
:::

Specifies which HTML attributes should render on the `<html>` tag. If the object is empty, no attributes will be added.

::: tip EXAMPLE

__Input__: `elm-land.json`

```jsonc {6}
{
  "app": {
    // ...
    "html": {
      "attributes": {
        "html": { "lang": "en", "elm": "very-cool" },
        // ...
      },
      // ...
    }
  }
}
```

__Output__: `dist/index.html`

```html {2}
<!DOCTYPE>
<html lang="en" elm="very-cool">
  <!-- ... -->
</html>
```
:::


#### app.html.attributes.head


::: info TYPE
```elm
Dict String String
```
:::

Specifies which HTML attributes should render on the `<head>` tag. If the object is empty, no attributes will be added.

::: tip EXAMPLE

__Input__: `elm-land.json`

```jsonc {7}
{
  "app": {
    // ...
    "html": {
      "attributes": {
        // ...
        "head": { "color": "red", "fruit": "apple" },
        // ...
      },
      // ...
    }
  }
}
```

__Output__: `dist/index.html`

```html {3}
<!DOCTYPE>
<html lang="en">
  <head color="red" fruit="apple">
    <!-- ... -->
  </head>
  <!-- ... -->
</html>
```
:::


### app.html.title

::: info TYPE
```elm
String
```
:::

Before your Elm application loads, the HTML file will have a default title. This title will appear in the top tab of the web browser, but only when JavaScript is disabled or if the Elm Land application hasn't run yet.

Once the app is ready, Elm Land will use the tab title defined by the page you are currently on, which can be modified by that page's layout. Check out [Pages and routes](../guide/pages-and-routes.md) to better understand the `title` property.

::: tip EXAMPLE

__Input__: `elm-land.json`

```jsonc {6}
{
  "app": {
    // ...
    "html": {
      // ...
      "title": "My Cool App!",
      // ...
    }
  }
}
```

__Output__: `dist/index.html`

```html {4}
<!DOCTYPE>
<html lang="en">
  <body>
    <title>My Cool App!</title>
    <!-- ... -->
  </body>
    <!-- ... -->
</html>
```
:::

### app.html.meta

::: info TYPE
```elm
List (Dict String String)
```
:::

For each item in the list, a `<meta>` tag will be rendered within the `<head>` tag. Each item in the list represents the attributes that should be rendered with the new HTML element.

::: tip EXAMPLE

__Input__: `elm-land.json`

```jsonc {7-8}
{
  "app": {
    // ...
    "html": {
      // ...
      "meta": [
        { "charset": "UTF-8" },
        { "name": "description", "content": "This app is 2 cool 4 me." },
      ],
      // ...
    }
  }
}
```

__Output__: `dist/index.html`

```html {5-6}
<!DOCTYPE html>
<html>
  <head>
    <!-- ... -->
    <meta charset="UTF-8">
    <meta name="description" content="This app is 2 cool 4 me.">
    <!-- ... -->
  </head>
  <!-- ... -->
</html>
```

:::

### app.html.link

::: info TYPE
```elm
List (Dict String String)
```
:::

For each item in the list, a `<link>` tag will be rendered within the `<head>` tag. Each item in the list represents the attributes that should be rendered with the new HTML element.

Feel free to visit the example on [Assets and static files](https://github.com/elm-land/elm-land/tree/main/examples/14-scss-and-assets) to understand how to reference local icons, images, and CSS from the `./static` folder.

::: tip EXAMPLE

__Input__: `elm-land.json`

```jsonc {7-8}
{
  "app": {
    // ...
    "html": {
      // ...
      "link": [
        { "rel": "icon", "type": "image/png", "href": "/favicon.png" },
        { "rel": "stylesheet", "href": "/main.css" }
      ],
      // ...
    }
  }
}
```

__Output__: `dist/index.html`

```html {5-6}
<!DOCTYPE html>
<html>
  <head>
    <!-- ... -->
    <link rel="icon" type="image/png" href="/favicon.png">
    <link rel="stylesheet" href="/main.css">
    <!-- ... -->
  </head>
  <!-- ... -->
</html>
```
:::



### app.html.script

::: info TYPE
```elm
List (Dict String String)
```
:::

For each item in the list, a `<script>` tag will be rendered within the `<head>` tag. Each item in the list represents the attributes that should be rendered with the new HTML element.

::: tip EXAMPLE

__Input__: `elm-land.json`

```jsonc {7}
{
  "app": {
    // ...
    "html": {
      // ...
      "script": [
        { "src": "https://code.jquery.com/jquery-3.6.1.min.js" }
      ]
    }
  }
}
```

__Output__: `dist/index.html`

```html {5}
<!DOCTYPE html>
<html>
  <head>
    <!-- ... -->
    <script src="https://code.jquery.com/jquery-3.6.1.min.js"></script>
  </head>
  <!-- ... -->
</html>
```

:::

## app.router

::: info TYPE
```elm
{ useHashRouting : Bool }
```
:::

These are settings specific to how Elm Land deals with URLs and routes. For now, that's just enabling support for Hash-based URLs for folks with hosting constraints.

### app.router.useHashRouting

::: info TYPE
```elm
Bool
```
:::

Some hosting environments don't easily support standard URL path routing. For that reason, we've 
added an option for users to have their URLs with `/#/` prefix.

Hash-based routing still supports query parameters, fragments, and everything else the standard Elm Land
routing uses. Using `Route.Path.toString` will automatically render the correct URL, depending on the value of `useHashRouting`.

__When `useHashRouting` is `false`__

Standard web application behavior:

```txt
Route.Path.Home_ ....................... /
Route.Path.SignIn ...................... /sign-in
Route.Path.Users ....................... /users
Route.Path.Users_Id_ { id = "123" } .... /users/123
```

__When `useHashRouting` is `true`__

Legacy hash-based URL prefixes will be applied.

```txt
Route.Path.Home_ ....................... /#/
Route.Path.SignIn ...................... /#/sign-in
Route.Path.Users ....................... /#/users
Route.Path.Users_Id_ { id = "123" } .... /#/users/123
```

## app.proxy


::: info TYPE
```elm
Dict String String
```
:::

Configure custom proxy rules for the dev server. These options are
forwarded directly to the internal Vite dev server configuration. If
you don't have any proxy needs, you can leave this as `null`.

::: tip EXAMPLE

```jsonc {5}
{
  "app": {
    // ...
    "proxy": {
      "/api": "http://localhost:5000"
    }
  }
}
```

:::

The example above allows requests to `http://localhost:1234/api/xyz` to be redirected to `http://localhost:5000/api/xyz`.

__Note:__ Because the `elm-land.json` file does not support JS functions, you won't be able to
specify the `rewrite` or `configure` functions mentioned in [Vite's proxy options](https://vitejs.dev/config/server-options.html#server-proxy).

::: warning

Just like with Vite, this `proxy` setting only applies to the __development__ server. You'll need
to do something similar to get `/api` forwarding to your production API server another way.

:::