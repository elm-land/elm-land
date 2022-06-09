# Deploying to Production

## Building your app

When you are ready to publish your Elm Land app, you can use the `elm-land build` command. The build command will handle building, optimizing, and minifying your app for production.

```sh
elm-land build
```

<code-group>
<code-block title="Terminal output">

```txt
🌈 Build was successful!
```

</code-block>
</code-group>

If the Elm compiler detects _any_ problems, they will be reported as friendly messages in your terminal.

### Understanding the output

All Elm Land apps are compiled as "single-page applications" in the `dist` folder. This means no matter what page is requested, that request will need to be directed to a single file: `dist/index.html`.

Depending on your hosting provider, you may need to add some configuration to tell it to redirect all URL requests to the `dist/index.html` file.


## Deploying with Netlify

In this guide, we'll show you how to deploy your app for free on [Netlify](https://netlify.app/). Netlify is a popular choice for static website and single-page application hosting for frontend projects.


### Step 1. The configuration file

With Netlify, you can add a configuration file to tell Netlify how to build your application, and where those files will be after the build succeeds.

Add this `netlify.toml`, alongside your `elm-land.json` file, at the root of your project:

<code-group>
<code-block title="netlify.toml">

```toml
# 1️⃣ Tells Netlify how to build your app, and where the files are
[build]
  command = "npx elm-land build"
  publish = "dist"

# 2️⃣ Handles SPA redirects so all your pages work
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

</code-block>
</code-group>

### Step 2. Deploy your site

In your web browser, you can connect a GitHub repo to your Netlify app here:
[https://app.netlify.com/start](https://app.netlify.com/start)

![Netlify's "import an existing project" screen in the browser](./deploying/netlify-step-1.png)

If your Elm Land project is already hosted on [GitHub](https://github.com/), follow the step-by-step process on Netlify to connect that repo to Netlify.

### Continuous deployment

Once GitHub and Netlify are connected, anytime you make a commit to the main branch of your repo your changes will automatically be deployed. If you are making something you are excited about, be sure to share it with us on Twitter at [@ElmLand_](https://twitter.com/elmland_)

We love to see the awesome stuff you build with Elm Land! :heart: