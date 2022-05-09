# Getting started

## Introduction

The goal of _Elm Land_ is to solve common problems folks run into when creating web apps. Traditionally, frontend web development comes with an overwhelming amount of decision making. By providing clear guides and conventions, we can get frontend devs up-and-running in Elm with confidence.

In order to create real-world applications, there are a few things that should be easy:

1. __Scaling an application__ - Understanding how to organize files, share data between pages, and reuse your application code.
1. __Talking to servers__ - Communicating with REST APIs, GraphQL endpoints, and how to authenticate HTTP requests for those backend APIs.
1. __Working with UI__ - Building components with a solid foundation, solving common CSS layout problems, and learning how to design your UI modules.


## Your first app

If you already have [NodeJS](https://nodejs.org) installed, you can get started with _Elm Land_ using the official CLI tool available on [NPM](https://npmjs.org/elm-land).

Let's start by using the `elm-land init` command to create a new `elm-land-twitter` project:

<<< @/snippets/init-input.sh

<code-group>
<code-block title="Terminal output">

<<< @/snippets/init-output.txt

</code-block>
</code-group>


### Adding new pages <Badge type="warning" text="wip" vertical="middle" />

Now that our project is created in the `elm-land-twitter` folder, we can begin to add pages.

With the `elm-land page` command, we can also create our 4 new pages without leaving the terminal. Each command will take the URL path you want as its argument.

```sh
npx elm-land page /home
```
```sh
npx elm-land page /notifications
```
```sh
npx elm-land page /settings
```
```sh
npx elm-land page /profile/:id
```

For that last page, we use `/profile/:id` rather than `/profile/id` to indicate that profile will take a dynamic `id` URL parameter. This `:` prefix might already be familar to you if you've worked with dynamic routing in libraries like [ExpressJS](https://expressjs.com/en/guide/routing.html), [NextJS](https://nextjs.org/docs/routing/dynamic-routes), [NuxtJS](https://nuxtjs.org/examples/routing/dynamic-pages/), or [Gridsome](https://gridsome.org/docs/dynamic-routing/).

### Running the app <Badge type="warning" text="wip" vertical="middle" />


Just like Elm's CLI, Elm Land comes along with it's own dev server. That means we can run our new Elm Land app in the browser with the `server` command:

```sh
npx elm-land server
```

Visiting [http://localhost:1234](http://localhost:1234) in your browser will show you our new web app!

