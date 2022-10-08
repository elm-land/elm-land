# 1️⃣ Queries

## Context

Elm Land GraphQL does its best to generate Elm types based on your schema, but to prevent conflicts, it can sometimes can generate less-readable names like `User` and `Followers_User` if the same GraphQL type is used twice in one query.

Here is the auto-naming strategy it uses:
- Create a type exactly matching what's in the GraphQL schema
- If that type is already used, prefix it with the field name where it was used

By using GraphQL fragments, you can let `elm-land/graphql` know what you'd like it to call your type aliases!


## Example

### Schema

```graphql
type Query {
  users: [User!]!
}

type User {
  id: ID!
  username: String!
  avatarUrl: String
  followers: [User!]!
}
```

### Input

```graphql
query FetchUsers {
  users {
    id
    username
    avatarUrl
    followers {
      ...Follower
    }
  }
}

fragment Follower on User {
  id
  username
  avatarUrl
}
```

### Output

- [src/GraphQL/Queries/FetchUsers.elm](src/GraphQL/Queries/FetchUsers.elm)
- [src/GraphQL/Scalar.elm](src/GraphQL/Scalar.elm)
- [src/GraphQL/Scalar/ID.elm](src/GraphQL/Scalar/ID.elm)

### Usage

```elm
module Main exposing (..)

import GraphQL.Http
import GraphQL.Http.Error
import GraphQL.Queries.FetchUsers


type Msg
    = ApiResponded (Result GraphQL.Http.Error GraphQL.Queries.FetchUsers.Data)


config : GraphQL.Http.Config
config =
    GraphQL.Http.get
        { url = "http://localhost:3000/graphql"
        }


sendMeQuery : Cmd Msg
sendMeQuery =
    GraphQL.Http.run config
        { operation = GraphQL.Queries.FetchUsers.new
        , onResponse = ApiResponded
        }

```

```bash
# Run this to see it compile!
elm make src/Main.elm --output=/dev/null
```