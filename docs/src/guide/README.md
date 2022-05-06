# Getting started

## Introduction

The goal of _Elm Land_ is to solve common problems folks run into when creating web apps. Traditionally, frontend web development comes with an overwhelming amount of decisions to make. Getting set up with the right tooling and project configuration can be intimidating, and the internet has strong opinions about which tool is best for the job. By providing guides and conventions, we can get frontend devs up-and-running with confidence.

In order to create real-world applications, there are a few things that should be easy:

1. __Scaling an application__ - Understanding how to organize files, share data between pages, and reuse your application code.
1. __Talking to servers__ - Communicating with REST APIs, GraphQL endpoints, and how to authenticate HTTP requests for those backend APIs.
1. __Working with UI__ - Building components with a solid foundation, solving common CSS layout problems, and learning how to design your UI modules.


## Your first app

_Elm Land_ comes with a CLI tool that we can get via [NPM](https://npmjs.org/elm-land).

Let's use the `elm-land init` command to create a new `elm-land-twitter` project:

<<< @/snippets/init-input.sh

<code-group>
<code-block title="Terminal output">

<<< @/snippets/init-output.txt

</code-block>
</code-group>


### Adding new pages <Badge type="warning" text="wip" vertical="middle" />

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

