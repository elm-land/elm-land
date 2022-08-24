# Working with REST APIs

### What we'll learn

- How to __send an HTTP request__
- How to __read data from JSON__ responses
- How to use custom Elm types


<BrowserWindow src="./data-fetching/screenshot.gif" alt="Demo of Pokemon API data" />

## Let's make a Pokemon app

For this project, we'll be using the free, open-source [PokeAPI](https://pokeapi.co/) to show the original 150 Pokémon on the homepage.

Let's create a new project and get started!

```sh
npx elm-land init rest-apis
```

```sh
cd rest-apis
```

```sh
npx elm-land server
```

Running those 3 commands will run our new Elm Land project at `http://localhost:1234`

## Commands and subscriptions

In previous guides, we used the `elm add` command to create new pages. Let's use that command again to replace our initial homepage, but this time with `page:element`. 

This new "element" page will allow us to return HTTP requests from our `init` and `update` functions via `Cmd Msg`.


```sh
npx elm-land add page:element /
```

Here is the new page that gets created from that command. I've highlighted some things that have changed from the `Page.sandbox` we used in [the last guide on "User input"](/user-input):

```elm {13,16,29,32,44,48,55-57}
module Pages.Home_ exposing (Model, Msg, page)

import Html exposing (Html)
import Page exposing (Page)
import View exposing (View)


-- PAGE


page : Page Model Msg
page =
    Page.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}
    , Cmd.none
    )



-- UPDATE


type Msg
    = ExampleMsgReplaceMe


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ExampleMsgReplaceMe ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pages.Home_"
    , body = [ Html.text "/" ]
    }
```

In the last guide, we learned about "the Elm Architecture". That introduced us to `Model`, `init`, `Msg`, and `update`. Those functions gave us the ability to manage the state of our page.

This new "element" page introduces two new concepts, which will let us do more!

### `Cmd msg`

This time around, our `init` and `update` functions are returning `( Model, Cmd Msg )` instead of just `Model`:

```elm {1}
init : ( Model, Cmd Msg )
init =
    ( {}
    , Cmd.none
    )
```

```elm {1}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ExampleMsgReplaceMe ->
            ( model, Cmd.none )
```

What you learned before is still true– `Model` represents the current state of our page. So what is `Cmd Msg` for? In Elm programs, `Cmd` is short for "command". We use commands to return "side-effects"– like making HTTP requests, working with local storage, and more. 

In this guide, we'll just be using it for HTTP requests to the PokeAPI endpoint.

When we don't have any commands we want to run, we use the built-in `Cmd.none` to say "don't do any side-effects".

::: tip "Why are `Model` and `Cmd Msg` wrapped in those parentheses?"

The new parentheses mean that our functions are returning a "tuple" or "pair" of two values– instead of just one `Model` value. 

You can learn more about tuples in [the "Core Language" section of the official Elm guide here](https://guide.elm-lang.org/core_language.html).

:::

### `Sub msg`

Some applications need to keep track the size of the browser window, listen for keyboard events, or stay up-to-date with the mouse cursors position.

All of these are possible within Elm's `subscriptions` function. In Elm, we can "subscribe" to events that send us `Msg` values whenever these things change. Those external events can then be handled in `update`, just like `Msg` values that our `view` function sends when a user clicks a button.

In this guide, we won't add any subscriptions– so this will remain as `Sub.none`.

## Installing Elm packages

Just like NPM, Elm has a package ecosystem available at [https://package.elm-lang.org/](https://package.elm-lang.org/). Unlike NPM, the package site has __docs for every package__, which makes it a helpful reference when you need to look up an example on how to use something. 

We'll be using the Elm command line tool to install two of those packages:

- `elm/http` - for sending HTTP requests
- `elm/json` - for handling the JSON data that comes back

Here's how to use the `elm install` command to add these to our project:

```sh
npx elm install elm/http
```

```sh
npx elm install elm/json
```

Once those two packages are installed, you'll see they are included in the `elm.json` file. This means we will be able to import the `Http` and `Json.Decode` modules in our project!

Let's start making some API requests!

## Setting up the API

Although you can call the PokeAPI directly at URLs like [https://pokeapi.co/api/v2/pokemon](https://pokeapi.co/api/v2/pokemon), the __fair use policy__ asks us to cache resources whenever possible.

> PokéAPI is free and open to use. It is also very popular. Because of this, we ask every developer to abide by our fair use policy. People not complying with the [fair use policy](https://pokeapi.co/docs/v2) will have their IP address permanently banned.

To make it easy to follow the rules, we'll use [this tiny Node.js app](https://github.com/ryannhg/pokeapi-cache-server) that caches our API requests for us!

In a separate terminal from your running `elm-land server`, run the following commands

```sh
git clone git@github.com:ryannhg/pokeapi-cache-server
```

```sh
cd pokeapi-cache-server
```

```sh
DELAY=1000 npm start
```

Now the PokeAPI will be available at `http://localhost:5000/api`. In this guide, we'll be making requests to that URL (instead of `https://pokeapi.co/api`), so we don't get in any trouble!

We are also setting an intentional `DELAY` of 1000ms on each request, to make it easier to see our "Loading..." states later.

## Making API requests

Now we are ready to make some API requests from our Elm application! The goal for our homepage is to list the names of the first 150 pokemon using this API endpoint:

```txt
GET http://localhost:5000/api/v2/pokemon?limit=150
```

Rather than using `Http.get` function directly, we'll be making our own `Api.elm` module to keep track of the three states that our data might be in:

- __Loading__ - The page is making a request to the PokeAPI server
- __Success__ - We got the data back, and we are ready to show it on the page
- __Failure__ - Something went wrong with the request, and we should tell the user

To do that, we're going to create a new file at `src/Api.elm` and make our own "custom type":

```elm
module Api exposing (Data(..))

import Http

type Data value
    = Loading
    | Success value
    | Failure Http.Error
```

Our new `Data` custom type uses a "type variable" called `value`. This means we can store any kind of API value in our `Success` case.

Back in our homepage at `src/Pages/Home_.elm`, we can import the `Api` module to keep track of the current state of our API request in the `Model`.

```elm {3,7-9,12-14,19}
module Pages.Home_ exposing (Model, Msg, page)

import Api

-- ...

type alias Model =
    { pokemonData : Api.Data (List Pokemon)
    }


type alias Pokemon =
    { name : String
    }


init : ( Model, Cmd Msg )
init =
    ( { pokemonData = Api.Loading }
    , Cmd.none
    )

-- ...

```

For this example, `value` is `List Pokemon`, because we expect our API endpoint to return a list of pokemon when it comes back.

When the page loads, the `init` function initializes our `pokemonData` to `Api.Loading`. This makes it possible to show a "Loading..." message in our `view` function below:

```elm {11-13,15-22,24-26}
module Pages.Home_ exposing (Model, Msg, page)

-- ...


view : Model -> View Msg
view model =
    { title = "Pokemon"
    , body =
        case model.pokemonData of
            Api.Loading ->
                [ Html.text "Loading..."
                ]

            Api.Success listOfPokemon ->
                let
                    count : Int
                    count =
                        List.length listOfPokemon
                in
                [ Html.text ("Fetched " ++ count ++ " pokemon!")
                ]

            Api.Failure httpError ->
                [ Html.text "Something went wrong..."
                ]
    }
```

When we go to `http://localhost:1234`, our web browser should show the message "Loading..."

To see the actual data, we'll need to make an HTTP request and handle the JSON response.

### Working with JSON

Here's an example of what data comes back when we make a request to the `/api/v2/pokemon?limit=150` REST API endpoint:

```jsonc
{
    "count": 1154,
    "next": "http://localhost:5000/api/v2/pokemon?offset=150&limit=150",
    "previous": null,
    "results": [
        {
            "name": "bulbasaur",
            "url": "http://localhost:5000/api/v2/pokemon/1/"
        },
        {
            "name": "ivysaur",
            "url": "http://localhost:5000/api/v2/pokemon/2/"
        },
        // ( ... 148 more items )
    ]
}
```

Our goal is to make a `GET` request to that API endpoint, and end up with this in our `Model`:

```elm
model ==
    { pokemonData =
        Api.Success
            [ { name = "bulbasaur" }
            , { name = "ivysaur" }
            -- 148 more items
            ]
    }
```

A great way to add a feature in Elm is to pretend you have the function you need, and then let the compiler walk you through the process of making it work.

Let's update our `init` function and pretend we have a function called `Api.PokemonList.fetchFirst150`:

```elm {4,11-14,22-24,30-33,35-38}
module Pages.Home_ exposing (Model, Msg, page)

import Api
import Api.PokemonList

-- ...

init : ( Model, Cmd Msg )
init =
    ( { pokemonData = Api.Loading }
    , Api.PokemonList.fetchFirst150
        { onSuccess = PokeApiReturnedSuccess
        , onFailure = PokeApiReturnedFailure
        }
    )



-- UPDATE


type Msg
    = PokeApiReturnedSuccess (List Pokemon)
    | PokeApiReturnedFailure Http.Error


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PokeApiReturnedSuccess listOfPokemon ->
            ( { model | pokemonData = Api.Success listOfPokemon }
            , Cmd.none
            )

        PokeApiReturnedFailure httpError ->
            ( { model | pokemonData = Api.Failure httpError }
            , Cmd.none
            )

-- ...
```

Now when we visit our browser, we can see a helpful Elm compiler message, reminding us that `Api.PokemonList` isn't available yet.

Let's add 