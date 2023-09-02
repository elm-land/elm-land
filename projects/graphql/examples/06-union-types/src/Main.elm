module Main exposing (..)

import Api.Queries.FetchUser exposing (Data)
import Api.Queries.FetchUser.UserResult as UserResult
import GraphQL.Operation exposing (Operation)


operation : Operation Data
operation =
    Api.Queries.FetchUser.new


toWelcomeMessage : Data -> String
toWelcomeMessage data =
    case data.currentUser of
        UserResult.On_User user ->
            "Hello, " ++ user.name ++ "!"

        UserResult.On_NotSignedIn { message } ->
            "Please sign in"
