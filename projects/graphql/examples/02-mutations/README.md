# 2️⃣ Mutations

## Introduction

GraphQL provides "[mutations](https://graphql.org/learn/queries/)" that allow users to make changes in their API. [Queries](../01-queries/) are intended for read-only stuff, while mutations are for write operations (creating, updating, deleting, etc).

With `@elm-land/graphql`, you write your mutations in a normal `.graphql` file. From there, the `elm-land graphql build` command will generate Elm code that can be used in your program.

## Example

### 1️⃣ What you write

- [./graphql/Api/Mutations/SignUp.graphql](./graphql/Api/Mutations/SignUp.graphql)

    ```graphql
    mutation SignUp(
      $email: String!
      $password: String!
      $name: String
    ) {
      signUp(email: $email, password: $password, name: $name) {
        id
        email
        avatarUrl
      }
    }
    ```


### 2️⃣ The files Elm Land generates

- [Api.Mutations.SignUp](.elm-land/src/Api/Mutations/SignUp.elm)

    ```elm
    module Api.Mutations.SignUp exposing
        ( Input, Data, new
        , User
        )

    -- ...
    ```

- [Api.Mutations.SignUp.Input](.elm-land/src/Api/Mutations/SignUp/Input.elm)

    ```elm
    module Api.Mutations.SignUp.Input exposing
        ( Input, new
        , email, password, name
        , null
        )

    -- ...
    ```


### 3️⃣ How you use it

```elm
module Main exposing (..)

import GraphQL.Operation exposing (Operation)
import Api.Mutations.SignUp exposing (Data)
import Api.Mutations.SignUp.Input


signUpMutation : Operation Data
signUpMutation =
    let
        input : Api.Mutations.SignUp.Input
        input =
            Api.Mutations.SignUp.Input.new
                |> Api.Mutations.SignUp.Input.email "ryan@elm.land"
                |> Api.Mutations.SignUp.Input.password "supersecret123"
    in
    Api.Mutations.SignUp.new input
```

[View full source](./src/Main.elm)


