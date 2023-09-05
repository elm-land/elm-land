module Main exposing (..)

import Api.Queries.Characters exposing (Data)
import Api.Queries.Characters.Character as Character exposing (Character)
import GraphQL.Operation exposing (Operation)


operation : Operation Data
operation =
    Api.Queries.Characters.new


toGreetings : Data -> List String
toGreetings data =
    data.characters
        |> List.map toGreeting


toGreeting : Character -> String
toGreeting character =
    case character of
        Character.On_Human human ->
            toGreetingForHuman human

        Character.On_Droid droid ->
            toGreetingForDroid droid


toGreetingForHuman : Character.Human -> String
toGreetingForHuman { name, hasHair } =
    if hasHair then
        "My name is " ++ name ++ "and I'm bald."

    else
        "My name is " ++ name ++ "and I have hair."


toGreetingForDroid : Character.Droid -> String
toGreetingForDroid { name, primaryFunction } =
    "My name is "
        ++ name
        ++ (case primaryFunction of
                Just function ->
                    ", and my primary function is " ++ function ++ "."

                Nothing ->
                    "."
           )
