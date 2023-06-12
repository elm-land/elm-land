---
outline: deep
---

# Getting started

Welcome to Elm Land, a framework designed for building reliable web applications with [Elm](https://elm-lang.org). This guide will show you how to get started, so you can start making your next frontend web application.

::: tip :seedling: "What if I'm new to Elm?"

That's _perfect_! These guides are designed specifically for you. If you are familiar with any other JS framework (like React, Vue.js or Svelte) these guides should fill in the gaps. 

Keep an eye out for ":seedling:" callouts like this one, they'll provide additional context for folks who are learning Elm for the first time.

:::

## Installation

Elm Land is a CLI tool available on NPM. If you have the latest verson of [Node.js](https://nodejs.org) installed, you can install Elm Land with this command:

```sh
npm install -g elm-land@latest
```


::: details Getting unexpected errors from NPM?

Sometimes, folks encounter issues with the `-g` flag. If you see an `EACCES` error, check out [this NPM guide](https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally) on how to fix the problem. 

If you are still stuck, stop by the [Elm Land Discord](https://join.elm.land) and we'll figure it out together!

:::

## Creating a new project

You can use the `elm-land` CLI tool to create new projects. Let's make a new `quickstart` project together:

```sh
elm-land init quickstart
```

Every new Elm Land project is created with these three files:

```bash
quickstart/
  |- elm.json           # 🌐 Elm's `package.json` file
  |- elm-land.json      # 🌈 Elm Land configuration
  |- src/
     |- Pages/
        |- Home_.elm    # 🏡 The homepage for our app
```

## Running the dev server

The Elm Land CLI comes with a built in development server. Here's how you can run your new project in the browser:

```sh
elm-land server
```


## Editor setup

Although Elm has [editor support for IntelliK, Vim, Sublime Text, and more](https://github.com/elm/editor-plugins), we recommend using VS Code with [the official Elm Land plugin](https://marketplace.visualstudio.com/items?itemName=elm-land.elm-land) for the best experience.

1. Install [VS Code](https://code.visualstudio.com/)
1. Install the [Elm Land extension](https://marketplace.visualstudio.com/items?itemName=elm-land.elm-land)

![A screenshot of the Elm Land VS Code extension](./images/vscode-plugin.png)

__Note:__ The editor plugin will let you know if you need to install `elm` or `elm-format` and take care of that for you.


<NextSteps />

🌱 __New to Elm?__ We recommend diving right into [the "Tutorial" section](/tutorial/). These are fun mini-projects that gradually introduce you to everything you need to be productive with Elm Land.

🧑‍🎓 __Already familiar with Elm?__ Check out [the "Concepts" section](/concepts/) to learn the core concepts of Elm Land. If you prefer to see examples of real apps, checkout the "Examples" section above.

---

Either way, be sure to join the [Elm Land Discord](https://join.elm.land) to get help if you're stuck or to make new friends. We hope you have an _awesome_ experience with Elm Land, and can't wait to see what you build!

