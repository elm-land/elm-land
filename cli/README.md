# Elm Land
> Reliable web apps for everyone

![](../elm-land-banner.jpg)

### Alpha release

Although this framework is still a work-in-progress, please feel free to tinker around until `v1.0.0` is released!

Feedback is welcome anytime in the [Elm slack](https://elmlang.herokuapp.com/). Drop a comment in the `#elm-spa-users` channel and tag `@ryan` if you like!

## Using the CLI

The `elm-land` CLI tool has everything you need to create your next Elm application:

```
$ npx elm-land

🌈 Welcome to Elm Land! (v0.16.0)

Here are the commands:
✨ elm-land init <folder-name> ...... create a new project
🚀 elm-land server ................ run a local dev server
📦 elm-land build .......... build your app for production
📄 elm-land add page <url> ................ add a new page
📑 elm-land add layout <name> ........... add a new layout
🔧 elm-land customize <name> .. customize a default module
```

## The source code

If you would like to see how it works, all the code is available and [open-source on GitHub](https://github.com/elm-land/elm-land). 

The CLI, docs website, and other related Elm Land projects can all be found in that single repo.

### Running the test suite

The tests in this project are designed to verify that the [official guide](https://elm.land/guide) and [all of the examples](https://github.com/elm-land/elm-land/tree/main/examples) are accurate for users.

For that reason, we are using [bats](https://github.com/bats-core/bats-core) to make sure our CLI behaves as expected!

```bash
# Make sure you are in the `./cli` folder!
npm install
npm link
npm run setup
npm run test
```
