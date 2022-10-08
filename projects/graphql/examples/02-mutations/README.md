# 2️⃣ Mutations

## Context

GraphQL provides "[mutations](https://graphql.org/learn/queries/)" that allow users to make changes in their API. Unlike [queries](../01-queries/), which are designed for read-only stuff, mutations are for creating, updating, or deleting things.


## Example

### Schema

```graphql
type Mutation {
  signUp(email: String!, password: String!, avatarUrl: String): User
}

type User {
  id: ID!
  email: String!
  avatarUrl: String
}
```

### Input

```graphql
mutation SignUp($email: String!, $password: String!, $name: String) {
  signUp(email: $email, password: $password, name: $name) {
    id
    email
    avatarUrl
  }
}
```

### Output

- [src/GraphQL/Mutations/SignUp.elm](src/GraphQL/Mutations/SignUp.elm)
- [src/GraphQL/Mutations/SignUp/Input.elm](src/GraphQL/Mutations/SignUp/Input.elm)
- [src/GraphQL/Scalar.elm](src/GraphQL/Scalar.elm)
- [src/GraphQL/Scalar/ID.elm](src/GraphQL/Scalar/ID.elm)

### Usage

```elm
module Main exposing (..)

import GraphQL.Http
import GraphQL.Mutations.SignUp
import GraphQL.Mutations.SignUp.Input


type Msg
    = ApiResponded (Result GraphQL.Http.Error GraphQL.Mutations.SignUp.Data)


config : GraphQL.Http.Config
config =
    GraphQL.Http.get
        { url = "http://localhost:1234/graphql"
        }


sendSignUpMutation : Cmd Msg
sendSignUpMutation =
    let
        input : GraphQL.Mutations.SignUp.Input
        input =
            GraphQL.Mutations.SignUp.Input.new
                |> GraphQL.Mutations.SignUp.Input.email "ryan@elm.land"
                |> GraphQL.Mutations.SignUp.Input.password "supersecret123"
    in
    GraphQL.Http.run config
        { operation = GraphQL.Mutations.SignUp.new input
        , onResponse = ApiResponded
        }
```

```bash
# Run this to see it compile!
elm make src/Main.elm --output=/dev/null
```