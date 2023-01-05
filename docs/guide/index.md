# Getting started

### What we'll learn

- How to __install__ Elm Land
- How to __create our first project__
- How to __run the project__ in our browser

<BrowserWindow src="/images/guide/hello-world.jpg" alt="Homepage" url="http://localhost:1234" />



### Prerequisites

1. An installation of [Node.js](https://nodejs.org) (v16 or higher)
1. A text editor, we recommend [Visual Studio Code](https://code.visualstudio.com/)


## Installation

To get started, we'll need to install the latest version of _Elm Land_ from NPM. At the time of writing, the latest version of Elm Land is `v0.18.1`. Here's the NPM command that will install `elm-land` on your computer:

```sh
npm install -g elm-land@latest
```

When the install command has finished, you'll be able to run `elm-land` in your terminal. Try it out, to see if it worked:

```txt
$ elm-land

🌈  Welcome to Elm Land! (v0.18.1)
    ⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺
    Here are the available commands:

    ✨ elm-land init <folder-name> ...... create a new project
    🚀 elm-land server ................ run a local dev server
    📦 elm-land build .......... build your app for production
    📄 elm-land add page <url> ................ add a new page
    🍱 elm-land add layout <name> ........... add a new layout
    🔧 elm-land customize <name> .. customize a default module

    Want to learn more? Visit https://elm.land/guide
```

::: warning Getting errors from NPM?

Sometimes, folks have issues with the `-g` flag. If you see an `EACCES` error, check out [this NPM guide](https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally) on how to fix the problem. 

If you get stuck, swing by the [Elm Land Discord](https://join.elm.land), and we'll figure it out together!

:::

## Create your first project

Now that you've installed _Elm Land_, you'll have access to a few new commands from your terminal. Let's start by using the `elm-land init` command to create our first project:

```sh
elm-land init hello-world
```

```txt
🌈  Elm Land created a new project in ./hello-world
    ⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺
    Here are some next steps:

    📂 cd hello-world
    🚀 elm-land server
```


## Run the development server

_Elm Land_ comes with a built-in dev server, which lets us see our project in a web browser. To run a new server, we'll use the `elm-land server` command:

```sh
elm-land server
```

```txt
🌈  Elm Land is ready at http://localhost:1234
```

When you visit `http://localhost:1234` in your browser, here's what you will see:

<BrowserWindow src="/images/guide/hello-world.jpg" alt="Homepage" url="http://localhost:1234" />

### You did it! :tada:

Congratulations! Now that you know how to create an Elm Land application, let's add some more pages. In the next section, we'll learn how to creates new pages and style them with CSS. 

See you there!