# 5️⃣ Union Types

## Context

GraphQL allows users to specify [union types](https://graphql.org/learn/schema/#union-types) to handle returning one of multiple possible values

## Example

### Schema

```graphql
type Query {
  currentUser: UserResult!
}

union UserResult
  = User
  | NotSignedIn

type User {
  id: ID!
  name: String!
  email: String!
  avatarUrl: String
}

type NotSignedIn {
  message: String!
}
```

### Input

```graphql
query FetchUser {
  currentUser {
    ...on User {
      id
      name
      avatarUrl
    }
    ...on NotSignedIn {
      message
    }
  }
}
```

### Output

- [src/GraphQL/Queries/FetchUser.elm](src/GraphQL/Queries/FetchUser.elm)
- [src/GraphQL/Queries/FetchUser/UserResult.elm](src/GraphQL/Queries/FetchUser/UserResult.elm)
- [src/GraphQL/Scalar.elm](src/GraphQL/Scalar.elm)
- [src/GraphQL/Scalar/ID.elm](src/GraphQL/Scalar/ID.elm)

### Usage

```elm
module Main exposing (..)

import GraphQL.Http
import GraphQL.Http.Error
import Api.Queries.FetchUser


type Msg
    = ApiResponded (Result GraphQL.Http.Error Api.Queries.FetchUser.Data)


config : GraphQL.Http.Config
config =
    GraphQL.Http.get
        { url = "http://localhost:3000/graphql"
        }


sendMeQuery : Cmd Msg
sendMeQuery =
    GraphQL.Http.run config
        { operation = Api.Queries.FetchUser.new
        , onResponse = ApiResponded
        }

```

```bash
# Run this to see it compile!
elm make src/Main.elm --output=/dev/null
```

## Design notes

If users don't include the `__typename` field, Elm Land GraphQL can't reliably tell the difference between two custom type variants. For this reason, Elm Land GraphQL __automatically injects__ the `__typename` field anytime the `...on` keyword is used.

To help understand this problem, imagine we have this GraphQL schema:

```graphql
union CreateTweetResult
  = Tweet
  | NotSignedInError
  | PermissionDeniedError

type Tweet {
  id: ID!
  body: String!
}

type NotSignedInError {
  message: String!
}

type TweetTooLongError {
  message: String!
}
```

And we use this mutation:

```graphql
mutation CreateTweet($body: String!) {
  createTweet(body: $body) {
    ...on Tweet {
      id
      body
    }
    ...on NotSignedInError {
      message
    }
    ...on TweetTooLongError {
      message
    }
  }
}
```

When the server responds, it will be one of these three results:

### 1. Everything worked

```json
{
  "data": {
    "createTweet": {
      "id": "1",
      "body": "GraphQL is so cool, omg!"
    }
  }
}
```

### 2. Got back a "not signed in" error

```json
{
  "data": {
    "createTweet": {
      "message": "Please sign in to create a tweet."
    }
  }
}
```

### 3. Got back a "tweet too long" error

```json
{
  "data": {
    "createTweet": {
      "message": "Tweets cannot be longer than 280 characters"
    }
  }
}
```

In both of the error cases, the shape of the data is identical, and it's not possible to know where the `{ message : String }` type was from a `NotSignedInError` or a `TweetTooLongError`.

For this reason, we modify the user's query to send the server this instead:

```graphql
mutation CreateTweet($body: String!) {
  createTweet(body: $body) {
    __typename      # Injected by @elm-land/graphql
    ...on Tweet {
      id
      body
    }
    ...on NotSignedInError {
      message
    }
    ...on TweetTooLongError {
      message
    }
  }
}
```

Now the server will respond with JSON that looks like this:


### 1. Everything worked

```json
{
  "data": {
    "createTweet": {
      "__typename": "Tweet",
      "id": "1",
      "body": "GraphQL is so cool, omg!"
    }
  }
}
```

### 2. Got back a "not signed in" error

```json
{
  "data": {
    "createTweet": {
      "__typename": "NotSignedInError",
      "message": "Please sign in to create a tweet."
    }
  }
}
```

### 3. Got back a "tweet too long" error

```json
{
  "data": {
    "createTweet": {
      "__typename": "TweetTooLongError",
      "message": "Tweets cannot be longer than 280 characters"
    }
  }
}
```

Now that the JSON response includes the `__typename`, Elm Land GraphQL can reliably assign the response to the correct `CreateTweetResult` custom type value!
