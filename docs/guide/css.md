# Adding in CSS

## Modifying elm-land.json

We left off with a sidebar layout that didn't look quite right. Fortunately, Elm Land allows us to easily drop in a CSS stylesheet to use in our web app.

First, let's open up the `elm-land.json` file that was automatically created for us when we ran the `elm-land init` command:

<code-group>
<code-block title="elm-land.json">

```json
{
  "app": {
    "env": [],
    "html": {
      "attributes": {
        "html": { "lang": "en" },
        "head": {},
        "body": {}
      },
      "title": "My Elm Land App",
      "meta": [
        { "charset": "UTF-8" },
        { "http-equiv": "X-UA-Compatible", "content": "IE=edge" },
        { "name": "viewport", "content": "width=device-width, initial-scale=1.0" }
      ],
      "link": []
    }
  }
}
```

</code-block>
</code-group>

Each time we modify something in `elm-land.json`, the HTML entrypoint of our app is automatically generated. Here's what that looks like for an initial Elm Land project:

<code-group>
<code-block title="Generated HTML">

```html
<!DOCTYPE html>
  <html lang="en">
  <head>
    <title>My Elm Land App</title>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="./main.js"></script>
  </body>
</html>
```

</code-block>
</code-group>

If we want to add a new CSS stylesheet, we'll need to update the `app.html.link` property, like we would in HTML.

As soon as we do that, you'll see a new `<link>` tag in the generated HTML file rendered at [http://localhost:1234](http://localhost:1234)

<code-group>
<code-block title="elm-land.json">

```json{16-18}
{
  "app": {
    "env": [],
    "html": {
      "attributes": {
        "html": { "lang": "en" },
        "head": {},
        "body": {}
      },
      "title": "My Elm Land App",
      "meta": [
        { "charset": "UTF-8" },
        { "http-equiv": "X-UA-Compatible", "content": "IE=edge" },
        { "name": "viewport", "content": "width=device-width, initial-scale=1.0" }
      ],
      "link": [
        { "rel": "stylesheet", "href": "/styles.css" }
      ]
    }
  }
}
```

</code-block>
</code-group>

<code-group>
<code-block title="Generated HTML">

```html{8}
<!DOCTYPE html>
  <html lang="en">
  <head>
    <title>My Elm Land App</title>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="/styles.css">
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="./main.js"></script>
  </body>
</html>
```

</code-block>
</code-group>


## Adding static files

Now that our HTML is pointing to a CSS stylesheet at `/styles.css`, we'll need to create a CSS file for it to load.

With Elm Land, we can do this by creating a file in the "static" folder, alongside our "src" directory. Let's create a new CSS file:

<code-group>
<code-block title="./static/styles.css">

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

</code-block>
</code-group>


Here's how our website looks now that we've added that new CSS file:

![Sidebar is actually on the side of the page content](./css/layout-after-css.jpg)

## Using a CSS framework

Our example above modified the `elm-land.json` to use a local CSS file, but if you want to work with [Bootstrap](https://getbootstrap.com/), [Bulma](https://bulma.io/), [Tailwind CSS](https://tailwindcss.com/), or any other CSS framework- you can use the `elm-land.json` file for that too!


<code-group>
<code-block title="Bootstrap">

```json{6-8}
{
  "app": {
    "env": [],
    "html": {
      ...
      "link": [
        { "rel": "stylesheet", "href": "https://cdn.jsdelivr.net/npm/bootstrap@5.2.0-beta1/dist/css/bootstrap.min.css" }
      ]
    }
  }
}
```

</code-block>
<code-block title="Bulma">

```json{6-8}
{
  "app": {
    "env": [],
    "html": {
      ...
      "link": [
        { "rel": "stylesheet", "href": "https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css" }
      ]
    }
  }
}
```

</code-block>
<code-block title="Tailwind CSS">

```json{6-8}
{
  "app": {
    "env": [],
    "html": {
      ...
      "link": [
        { "rel": "stylesheet", "href": "https://unpkg.com/tailwindcss@^2/dist/tailwind.min.css" }
      ]
    }
  }
}
```

</code-block>
</code-group>

