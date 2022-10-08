# 3️⃣ Input types

## Context

GraphQL provides "[input types](https://graphql.org/learn/schema/#input-types)" that allow users to group input fields together, and give them a name.


## Example

### Schema

```graphql
type Mutation {
  signIn(form: UserSignInForm!): User
}

input UserSignInForm {
  email: String!
  password: String!
}

type User {
  id: ID!
  email: String!
  avatarUrl: String
}
```

### Input

```graphql
mutation SignIn($form: UserSignInForm!) {
  signIn(form: $form) {
    id
    email 
    avatarUrl
  }
}
```

### Output

- [src/GraphQL/Mutations/SignIn.elm](src/GraphQL/Mutations/SignIn.elm)
- [src/GraphQL/Mutations/SignIn/Input.elm](src/GraphQL/Mutations/SignIn/Input.elm)
- [src/GraphQL/Input.elm](src/GraphQL/Input.elm)
- [src/GraphQL/Input/UserSignInForm.elm](src/GraphQL/Input/UserSignInForm.elm)
- [src/GraphQL/Scalar.elm](src/GraphQL/Scalar.elm)
- [src/GraphQL/Scalar/ID.elm](src/GraphQL/Scalar/ID.elm)

### Usage

```elm
module Main exposing (..)

import GraphQL.Http
import GraphQL.Input
import GraphQL.Input.UserSignInForm
import GraphQL.Mutations.SignIn
import GraphQL.Mutations.SignIn.Input


type Msg
    = ApiResponded (Result GraphQL.Http.Error GraphQL.Mutations.SignIn.Data)


config : GraphQL.Http.Config
config =
    GraphQL.Http.get
        { url = "http://localhost:1234/graphql"
        }


sendSignInMutation : Cmd Msg
sendSignInMutation =
    let
        input : GraphQL.Mutations.SignIn.Input
        input =
            GraphQL.Mutations.SignIn.Input.new
                |> GraphQL.Mutations.SignIn.Input.form userSignInForm

        userSignInForm : GraphQL.Input.UserSignInForm
        userSignInForm =
            GraphQL.Input.UserSignInForm.new
                |> GraphQL.Input.UserSignInForm.email "ryan@elm.land"
                |> GraphQL.Input.UserSignInForm.password "supersecret123"
    in
    GraphQL.Http.run config
        { operation = GraphQL.Mutations.SignIn.new input
        , onResponse = ApiResponded
        }
```

```bash
# Run this to see it compile!
elm make src/Main.elm --output=/dev/null
```

## Design notes

Because GraphQL input types can reference one another, the generated Elm code needs to do some weird stuff to prevent circular dependency errors. 

It creates a single `GraphQL.Internals.Input` module that each individual `GraphQL.Input.*` function uses under-the-hood.

This allows them to reference each other without issues!