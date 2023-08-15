---
title: Building a better Elm Land
description: Learn how the project has evolved, and what's new in the big Elm Land v0.18.0 release!

head:
  # OG Tags – https://ogp.me
  - [ meta, { "property": "og:type", "content": "article" } ]
  - [ meta, { "property": "og:title", "content": "Building a better Elm Land" } ]
  - [ meta, { "property": "og:description", "content": "Learn how the project has evolved, and what's new in the big Elm Land v0.18.0 release!" } ]
  - [ meta, { "property": "og:site_name", "content": "Elm Land" }]
  - [ meta, { "property": "og:url", "content": "https://elm.land/news/hello-world" } ]
  - [ meta, { "property": "og:image", "content": "https://elm.land/images/news/sprout.png" } ]
  - [ meta, { "property": "og:image:type", "content": "image/png" } ]
  - [ meta, { "property": "og:image:width", "content": "512" } ]
  - [ meta, { "property": "og:image:height", "content": "512" } ]
  - [ meta, { "property": "og:image:alt", "content": "The Elm Land logo and a sprouting sapling emoji" } ]

  # Twitter Card – https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/summary
  - [ meta, { "name": "twitter:card", "content": "summary" } ]
  - [ meta, { "name": "twitter:site", "content": "@elmland_" } ]
  - [ meta, { "name": "twitter:title", "content": "Building a better Elm Land" } ]
  - [ meta, { "name": "twitter:description", "content": "Learn how the project has evolved, and what's new in the big Elm Land v0.18.0 release!" } ]
  - [ meta, { "name": "twitter:image", "content": "https://elm.land/images/news/sprout.png" } ]
  - [ meta, { "name": "twitter:image:alt", "content": "The Elm Land logo and a sprouting sapling emoji" } ]

---

# 🌱 Building a better Elm Land

Written by _Ryan_ on _December 20th, 2022_


### What's new in Elm Land?

It's been two months, and a lot has happened for Elm Land. Our official Discord server has grown to __just over 100 members__. I want to start 
by highlighting some of the great projects shared in the `#cool-projects` channel by our community:

- `@thecallea` shared the __[the first Elm Land site in production](https://twitter.com/thecallea/status/1578736234528387072)__

- `@mattcheely` posted __[the first Elm Land job](https://www.elmweekly.nl/i/83942580/jobs)__

- `@voxal` shared __[the first Elm Land game](https://github.com/voxxal/cryptopuz)__

- `@pravin-raha` started building __[the first Elm Land RealWorld app](https://github.com/pravin-raha/elmland-realworld)__

Seeing folks post screenshots and links to GitHub repos has been so exciting to see. 

If you are using Elm Land for making games, apps, or even using it at work– be sure to share your experience with us in the [Community Discord](https://join.elm.land). I'd love to feature your project in the next release!

After seeing all the cool things being made Elm Land– it's time for me to share my own `#cool-project` ...


### Elm Land v0.18.0 :package:

Over the past few months, I've been working to tackle some of the key developer experience challenges I experienced when designing _elm-spa_, the predecessor to Elm Land. 

Here are the three areas where Elm Land v0.18.0 has improved:

1. __Missing__ framework features
2. Better __examples, guides, and docs__
3. __Community-driven__ features

Let's dive into each of these three areas together!


## Stateful layouts

The biggest pain point I wanted to address with the new release is making it easy to reuse navbars, sidebars, or other UI layout onto an existing page. In the previous version of Elm Land, this was easy for simple layouts. The real challenge was wiring up layouts that track state between each of these pages.

With the new Layouts API, folks can create __interactive, stateful__ layouts and share them across their application. We can see how this works with the new "User auth" example:

![A demo of a reusable sidebar layout](../guide/user-auth/05-sidebar-links.gif)

In Elm Land v0.18.0, not only is the view code for that layout controlled in a single file, but the update logic for the "Sign out" button is also handled in one place:

```elm {8-11}
module Layouts.Sidebar exposing (..)

-- ..

update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserClickedSignOut ->
            ( model
            , Effect.signOut
            )

-- ...
```

Any page that wants to use this sidebar layout can opt-in via the `Page.withLayout` function:

```elm {13}
module Pages.Home_ exposing (..)

-- ...

page : Auth.User -> Shared.Model -> Route () -> Page Model Msg
page user shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
        |> Page.withLayout (layout user)


layout : Auth.User -> Model -> Layouts.Layout
layout user model =
    Layouts.Sidebar
        { sidebar =
            { title = "Dashboard"
            , user = user
            }
        }
```

For more detail on how to build your application with the new layout system, be sure to check out [the official User Authentication example](../guide/user-auth). 

It will walk you through building a hands-on example __from scratch__. This includes things like local storage, talking to a backend API, and creating the layout we highlighted above!

## Catch-all routes

In the "Hello, world!" announcement back in October, I shared that Elm Land will earn the 1.0 release when it can build GitHub from scratch. With the addition of __catch-all routes__, we're getting one step closer to that goal!

On advanced apps like GitHub, sometimes user-defined content determines the length of the URL path. Here's a screenshot of the "code explorer" page, where the URL reflects your current position in the filesystem:

![GitHub's code explorer page, showing a folder in the Elm Land repo](/images/news/building-better-apps/github-catch-all.png)

Elm Land v0.18.0 comes with a new enhancement to the file-based routing system to make pages like this possible.

This isn't a new idea by any means, Elm Land drew it's inspiration from popular JavaScript frameworks that solve the problem really well. 

After exploring how this was done in [Next.js](https://nextjs.org/docs/routing/dynamic-routes#catch-all-routes), [Nuxt.js](https://nuxtjs.org/docs/features/file-system-routing#unknown-dynamic-nested-routes), [SvelteKit](https://kit.svelte.dev/docs/advanced-routing#rest-parameters), and [elm-pages](https://elm-pages.com/docs/file-based-routing#splat-routes), Elm Land was ready to tackle this problem, too!

Here's how you can create a page like the one we see GitHub use above, using the official Elm Land CLI:

![The output of the "elm-land add page" command, creating a new file](/images/news/building-better-apps/elm-land-add-page.png)


This new routing update also comes along with a great feature recommended by [@duncanmalashock](https://twitter.com/duncanmalashock): The `elm-land routes` command! 

They had a positive experience with [Ruby on Rail's "bin/rails routes" command](https://guides.rubyonrails.org/routing.html#listing-existing-routes), which helps folks see all the routes for an application at a glance. For that reason, Elm v0.18.0 ships with its own `routes` command:

![The "elm-land routes" command, listing 5 routes in an example application in the terminal](/images/news/building-better-apps/elm-land-routes.png)

## TypeScript support

The last big feature I want to share is the __zero-configuration__ TypeScript support. Adding first-class TypeScript support means you can get a higher level of confidence when working with NPM, environment variables, or other existing JS codebases. Using JavaScript is still 100% supported– but upgrading to TypeScript is as easy as renaming `src/interop.js` to `src/interop.ts`.

If you'd like to add custom TypeScript configuration to your Elm Land project, you can add the standard `tsconfig.json` right alongside your `elm.json` file. 

Elm Land's built-in development server will automatically emit any TypeScript compiler errors to your browser as you code. If you are building for production, we'll also compile your TypeScript project and report any errors as a part of the standard `elm-land build` command. 

( No need to roll your own TypeScript build setup– we've got you covered! )

The latest release also took a closer look at how to provide Elm-quality error messages when you encounter build errors with JavaScript, TypeScript or NPM. Here's a quick visual of an error message you might encounter in practice:

![The "elm-land build" command, showing a helpful error reminding users to run npm install](/images/news/building-better-apps/npm-install-error.png)


## New guides and examples

Elm Land has a big focus on making things approachable and easy to understand for newcomers to the Elm language. When I was first learning, having concrete examples and guides for how to build real projects were super helpful to me. 

With the latest release, we also shipped an [in-depth "User Authentication" guide](../guide/user-auth)!

This guide offers solutions to some common problems you might encounter when building your next web application:

  1. __Local storage__ – Working with JavaScript to store a user token
  1. __User auth__ - Using the `Auth.elm` module to only render pages when a user is signed-in
  1. __Using layouts__ - How to use the new layouts system 

In addition to the in-depth guide, this release comes with a handful of example for folks who are trying to customize or enhance their application.

1. [Using Elm UI](https://github.com/elm-land/elm-land/tree/main/examples/12-elm-ui)
1. [Using Elm CSS](https://github.com/elm-land/elm-land/tree/main/examples/13-elm-css)
1. [Using a CSS preprocessor, like SCSS](https://github.com/elm-land/elm-land/tree/main/examples/14-scss-and-assets)
1. [Reporting production errors to Sentry](https://github.com/elm-land/elm-land/tree/main/examples/11-error-reporting)
1. [Customize the not found page](https://github.com/elm-land/elm-land/tree/main/examples/15-custom-404-pages)

__Those are just a few!__ Check out the [examples](https://github.com/elm-land/elm-land/tree/main/examples) folder on our GitHub repo for the full list. 

Ultimately, I'd love to see each of these examples as their own in-depth guide– but I want to get the latest release out for the Elm Land community. 

It's important to me that I can release this version and get meaningful feedback as I go! I'm looking forward to seeing more examples of how folks are using Elm Land in their own applications.

## Community-driven features

This release also comes with a handful of features that came from the Elm Land community! If you ever want to contribute, our Discord comes with channels like `#suggest-a-feature` and `#report-a-bug`.

Those two channels played a huge role in adding of the following highlighted features:

### Hash-based routing

Some web hosting environments have constraints that make hosting apps with multiple pages difficult. `@mattcheely` tackled this problem head-on by adding hash-routing support to the project. Now any Elm Land user can easily opt-in to having their single-page apps use URLs like `/#/blog/123` in case `/blog/123` doesn't work with their workplace's hosting setup.

### Support for &lt;script&gt; tags

Community member `@thomasin` opened [their first Elm Land PR](https://github.com/elm-land/elm-land/pull/55) which made it possible to easily drop in `<script>` tags to the `elm-land.json` file. This allows folks to add CDN links to JavaScript just as easily as we can add CSS tags.

This was another great example of a conversation that started in Discord and became a real feature in the framework!

### A new Elm NPM package

Simon Lydell (`@lydell`) is exploring a new way to distribute the official Elm binaries via NPM. His latest NPM package is internally used by Elm Land to fix issues for folks using M1 or M2 MacBook Pros. Huge shoutout to Simon and Mario Rogic for their work on this package– it's solving real issues for real users!

### CLI improvements

Folks in the `#report-a-bug` channel reported issues when running `--help`, so we've added detailed help commands for each CLI command. Here's an example of running it for the `elm-land init` command:


![The "elm-land init --help" command, showing more detailed instructions](/images/news/building-better-apps/elm-land-help.png)

Be sure to try out this `--help` flag on any Elm Land command if you ever get stuck!

## What's next?

Elm Land is just getting started. To see what's next on the project, here are some public resources for you:

1. Check out [the official roadmap](https://github.com/elm-land/elm-land/wiki/Roadmap) on GitHub
2. Follow [the Elm Land project on Twitter](https://twitter.com/elmland_)
3. Come join the [Discord community](https://join.elm.land) and share your ideas!

For the next release, I'm hoping to refine the error messages and get a start on the plugin ecosystem. I hope everyone has a wonderful December and a Happy New Year!

__Let's be mainstream!__ :rainbow:
