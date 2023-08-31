# 3️⃣ Fragments

## Context

Elm Land GraphQL uses a simple formula when naming type aliases in your generated code:

1. Attempt to use the exact name from the GraphQL Schema (Example: "User")
2. If that name is already in use, attempt to prefix it with the field that's using it (Example: "Followers_User")
3. If that name is already in use, keep incrementing numbers until it works ("User_1", "User_2", etc)

This strategy prevents conflicts, but can generate less-readable names like `Followers_User` when the same GraphQL type is used twice in one query.

Elm Land GraphQL allows you to use __GraphQL fragments__ to solve this problem, and provide more readable names in your code. If you move an entire selection into a named fragment, Elm will generate type aliases with the name you want to use in your Elm code.


## Example

### Backend Schema

```graphql
type Query {
  user: User!
}

type User {
  id: ID!
  username: String!
  avatarUrl: String
  followers: [User!]!
}
```

### Frontend Query

```graphql
query FetchUser {
  user {
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
}
```

### Usage

```elm
import Api.Queries.FetchUser
-- ...


fetchUser : Operation Api.Queries.FetchUser.Data
fetchUser =
    Api.Queries.FetchUser.new
```

```elm
-- BEFORE
followers : List Followers_User
followers =
    data.user.followers

-- AFTER
followers : List Follower
followers =
    data.user.followers
```

### Generated code

- [Api.Queries.FetchUser](.elm-land/src/Api/Queries/FetchUser.elm)


