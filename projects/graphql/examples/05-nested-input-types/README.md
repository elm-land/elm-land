# 4️⃣ Input types

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

### Usage

```elm
signInMutation : Operation Data
signInMutation =
    let
        input : Api.Mutations.SignIn.Input
        input =
            Api.Mutations.SignIn.Input.new
                |> Api.Mutations.SignIn.Input.form userSignInForm

        userSignInForm : Api.Input.UserSignInForm
        userSignInForm =
            Api.Input.UserSignInForm.new
                |> Api.Input.UserSignInForm.email "ryan@elm.land"
                |> Api.Input.UserSignInForm.password "supersecret123"
    in
    Api.Mutations.SignIn.new input
```

### Generated modules

- [Api.Mutations.SignIn](.elm-land/src/Api/Mutations/SignIn.elm)
- [Api.Mutations.SignIn.Input](.elm-land/src/Api/Mutations/SignIn/Input.elm)
- [Api.Input](.elm-land/src/Api/Input.elm)
- [Api.Input.UserSignInForm](.elm-land/src/Api/Input/UserSignInForm.elm)


## Design notes

Because GraphQL input types can reference one another, the generated Elm code needs to do some weird stuff to prevent circular dependency errors. 

It creates a single `GraphQL.Internals.Input` module that each individual `Api.Input.*` function uses under-the-hood.

This allows them to reference each other without issues!