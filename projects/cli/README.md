# Elm Land

[![Discord](https://badgen.net/badge/icon/discord?icon=discord&label&color=7289da)](https://join.elm.land) [![Twitter](https://badgen.net/badge/icon/twitter?icon=twitter&label&color=00acee)](https://twitter.com/elmland_) [![GitHub](https://badgen.net/badge/icon/github?icon=github&label&color=4078c0)](https://www.github.com/elm-land/elm-land) 

[![Elm Land: Reliable web apps for everyone](https://github.com/elm-land/elm-land/raw/main/elm-land-banner.jpg)](https://elm.land)

### Alpha release 🌱

Although Elm Land is still a work-in-progress, please feel free to tinker around until the big `v1.0.0` release!

If you're excited to try things out– come join the [Elm Land Discord](https://join.elm.land) to get help or share your experience! 

## Using the CLI

The `elm-land` CLI comes with everything you need to create your next web application:

```
$ elm-land

🌈  Welcome to Elm Land! (v0.20.0)
    ⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺
    Commonly used commands:

     elm-land init <folder-name> ...... create a new project
     elm-land server ................ run a local dev server
     elm-land build .......... build your app for production

    Other helpful commands:

     elm-land generate ............. generate Elm Land files
     elm-land add page <url> ................ add a new page
     elm-land add layout <name> ........... add a new layout
     elm-land customize <name> .. customize a default module
     elm-land routes ........... list all routes in your app

    Want to learn more? Visit https://elm.land/guide

```

## The source code

If you would like to see how it works, all the code is available and [open-source on GitHub](https://github.com/elm-land/elm-land). 

The CLI, docs website, and all the other Elm Land projects can all be found in that single GitHub repo.

### Running the tests

The tests in this project are designed to verify that the [official guide](https://elm.land/guide) and [all of the examples](https://github.com/elm-land/elm-land/tree/main/examples) are accurate for users.

For that reason, we are using [bats](https://github.com/bats-core/bats-core) to make sure our CLI behaves as expected!

```bash
# Make sure you are in the `./cli` folder!
npm install
npm link
npm run setup
npm run test
```
