# @elm-land/graphql

[![Discord](https://badgen.net/badge/icon/discord?icon=discord&label&color=7289da)](https://join.elm.land) [![Twitter](https://badgen.net/badge/icon/twitter?icon=twitter&label&color=00acee)](https://twitter.com/elmland_) [![GitHub](https://badgen.net/badge/icon/github?icon=github&label&color=4078c0)](https://www.github.com/elm-land/elm-land) 

[![Elm Land: Reliable web apps for everyone](https://github.com/elm-land/elm-land/raw/main/elm-land-banner.jpg)](https://elm.land)

### Alpha release 🌱

Although Elm Land is still a work-in-progress, please feel free to tinker around until the big `v1.0.0` release!

If you're excited to try things out– come join the [Elm Land Discord](https://join.elm.land) to get help or share your experience! 

## Installation

If you have [Node.js v16+](https://nodejs.org) installed, you can install the `elm-land` CLI via NPM.

Running the `elm-land graphql` command will automatically download this separate package, which includes dependencies on `graphql`

```
npm install -g elm-land@latest
```

```txt
$ elm-land graphql

🌈 Elm Land (v0.19.5) wants to add a plugin!
   ⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺
   To use the `@elm-land/graphql` plugin, I'll need
   to install the NPM package and add a bit of JSON
   to your "elm-land.json" file.

   May I perform those two steps? [y/N] _
```

```txt
$ elm-land graphql build

🌈  Elm Land (v0.19.5) successfully generated Elm files
    ⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺
```

```txt
$ elm-land graphql watch

🌈  Elm Land (v0.19.5) is watching "./graphql/*" for changes...
    ⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺
```

## Providing a schema

If you try to run the `elm-land graphql` command you’ll see that all Elm Land needs is a way to access your GraphQL schema, which contains information about the kind of data your GraphQL server will return.

Here’s what running the CLI looks like when there’s no schema provided:

```
$ elm-land graphql build

🌈 Elm Land (v0.19.5) needs a GraphQL schema
   ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
   You can provide one by customizing the "elm-land.json"
   file to include a "graphql.schema" field.

   Here's an example with a **local file**:

   {
     ...,
     "graphql": {
       "schema": "../backend/schema.graphql"
     }
   }

   And here's another example with a **URL**:

   {
     ...,
     "graphql": {
       "schema": {
         "method": "POST",
         "url": "https://api.github.com/graphql",
         "headers": {
           "User-Agent": "$GITHUB_USERNAME",
           "Authorization": "Bearer $GITHUB_API_TOKEN"
         }
       }
     }
   }
```

Once you’ve updated your `elm-land.json` to point to your GraphQL schema, Elm Land will be able to automatically generate the API code for you ( including all the JSON decoding! )


## The source code

If you would like to see how this package works, all the code is available and [open-source on GitHub](https://github.com/elm-land/elm-land). 

The CLI, docs website, and all other Elm Land projects can all be found in that single repo.


