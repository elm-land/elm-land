# 1️⃣ Queries

## Introduction

GraphQL provides "[queries](https://graphql.org/learn/queries/)" that allow users to fetch data from their API.

With `@elm-land/graphql`, you write those queries in a standard `.graphql` file. From there, you can run `elm-land graphql build` to generate Elm code that can be used in your program.

## Example

### 1️⃣ What you write

- [./graphql/Api/Queries/FetchUser.graphql](./graphql/Api/Queries/FetchUser.graphql)

    ```graphql
    query FetchUser {
      me {
        id 
        email 
        avatarUrl 
      }
    }
    ```


### 2️⃣ The files Elm Land generates

- [Api.Queries.FetchUser](.elm-land/src/Api/Queries/FetchUser.elm)

    ```elm
    module Api.Queries.FetchUser exposing
        ( Data, new
        , User
        )

    -- ...
    ```


### 3️⃣ How you use it


```elm
module Main exposing (..)

import GraphQL.Operation exposing (Operation)
import Api.Queries.FetchUser exposing (Data)


fetchUser : Operation Data
fetchUser =
    Api.Queries.FetchUser.new
```

[View full source](./src/Main.elm)