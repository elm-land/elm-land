# 1️⃣ Queries

## Context

GraphQL provides "[queries](https://graphql.org/learn/queries/)" that allow users to fetch data from their API.


## Example

### Schema

```graphql
type Query {
  me: User 
} 

type User {
  id: ID!
  email: String!
  avatarUrl: String
}
```

### Input

```graphql
query Me {
  me {
    id 
    email 
    avatarUrl 
  }
}
```

### Output

- [src/GraphQL/Queries/Me.elm](src/GraphQL/Queries/Me.elm)
- [src/GraphQL/Scalar.elm](src/GraphQL/Scalar.elm)
- [src/GraphQL/Scalar/ID.elm](src/GraphQL/Scalar/ID.elm)

### Usage

```elm
module Main exposing (..)

import GraphQL.Http
import GraphQL.Http.Error
import GraphQL.Queries.FetchCurrentUser


type Msg
    = ApiResponded (Result GraphQL.Http.Error GraphQL.Queries.FetchCurrentUser.Data)


config : GraphQL.Http.Config
config =
    GraphQL.Http.get
        { url = "http://localhost:3000/graphql"
        }


sendCurrentUserQuery : Cmd Msg
sendCurrentUserQuery =
    GraphQL.Http.run config
        { operation = GraphQL.Queries.FetchCurrentUser.new
        , onResponse = ApiResponded
        }

```

```bash
# Run this to see it compile!
elm make src/Main.elm --output=/dev/null
```