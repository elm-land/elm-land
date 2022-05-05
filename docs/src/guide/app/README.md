---
wip: true
---

# Your first app

Everything we saw in the [Introduction](/guide) section was for a standard Elm application, which only rendered content for a single page. When we were using `elm reactor`, our browser needed to be at the URL `/src/Main.elm` to view the page.


To refresh your memory, here was our "Hello, world!" app:

<code-group>
<code-block title="src/Main.elm">
<<< @/examples/01-hello-world/src/Main.elm
</code-block>
</code-group>


If you're building a real web app like _Twitter_, you'll need to show different pages for URLs like `/home`, `/notifications`, or `/settings`. Some pages will handle different values, like showing a profile page for a specific user. These might be something like `/profile/alexa` or `/profile/billy`.

_Elm Land_ makes this possible by allowing us to organize our code like this:

<code-group>
<code-block title="src/Pages/Home.elm">

<<< @/examples/02-elm-land-app/src/Pages/Home.elm

</code-block>
<code-block title="src/Pages/Notifications.elm">

<<< @/examples/02-elm-land-app/src/Pages/Notifications.elm

</code-block>
<code-block title="src/Pages/Settings.elm">

<<< @/examples/02-elm-land-app/src/Pages/Settings.elm

</code-block>
<code-block title="src/Pages/Profile/Id_.elm">

<<< @/examples/02-elm-land-app/src/Pages/Profile/Id_.elm

</code-block>
</code-group>

In the new example, when a user visits `/home` in their web browser, they'll see the message "Home". If they visit `/profile/ryan`, they'll see the message "Profile: ryan". Each URL in the browser will map to a single page in our `src/Pages` folder. 

## Getting started

In the [Introduction](/guide) section, we also saw that Elm came with a single CLI tool for creating a new project. _Elm Land_ also has a CLI tool that we can access via NPM.

Let's use the `elm-land init` command to create a new `elm-land-twitter` project:

```sh
npx elm-land init --name=elm-land-twitter
```

<code-group>
<code-block title="Terminal Output">

```
🌈 New project created in "./elm-land-twitter"
```

</code-block>
</code-group>

### Adding our pages

With the `elm-land page init` command, we can also create our 4 new pages without leaving the terminal. Each command will take the URL path you want as its argument.

```sh
npx elm-land page init /home
```
```sh
npx elm-land page init /notifications
```
```sh
npx elm-land page init /settings
```
```sh
npx elm-land page init /profile/:id
```

For that last page, we use `/profile/:id` rather than `/profile/id` to indicate that profile will take a dynamic `id` URL parameter. This `:` prefix might already be familar to you if you've worked with dynamic routing in libraries like [ExpressJS](https://expressjs.com/en/guide/routing.html), [NextJS](https://nextjs.org/docs/routing/dynamic-routes), [NuxtJS](https://nuxtjs.org/examples/routing/dynamic-pages/), or [Gridsome](https://gridsome.org/docs/dynamic-routing/).

### Running the app

Just like Elm's CLI, Elm Land comes along with it's own dev server. That means we can run our new Elm Land app in the browser with the `server` command:

```sh
npx elm-land server
```

Visiting [http://localhost:1234](http://localhost:1234) in your browser will show you our new web app!

