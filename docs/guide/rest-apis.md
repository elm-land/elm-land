# REST APIs

### What we'll learn

- How to __send an HTTP request__
- How to __read data from JSON__ responses
- How to __handle errors__ without crashing


<BrowserWindow src="/images/guide/rest-apis.gif" alt="Demo of Pokemon API data" />

## Let's make a Pokemon app

For this project, we'll be using the free, open-source [PokeAPI](https://pokeapi.co/) to show the original 150 Pokémon on the homepage.

Let's create a new project and get started!

```sh
elm-land init rest-apis
```

```sh
cd rest-apis
```

```sh
elm-land server
```

Running those 3 commands will run our new Elm Land project at `http://localhost:1234`

## Commands and subscriptions

In previous guides, we used the `elm-land add` command to create new pages. Let's use that command again to replace our initial homepage, but this time with `page:element`. 

This new "element" page will allow us to return HTTP requests from our `init` and `update` functions via `Cmd Msg`.


```sh
elm-land add page:element /
```

Here is the new page that gets created from that command. I've highlighted some things that have changed from the `Page.sandbox` we used in [the last guide on "User input"](./user-input):

```elm {13,16,29,32,44,48-50,57-59}
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
            ( model
            , Cmd.none
            )



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
            ( model
            , Cmd.none
            )
```

What you learned before is still true– `Model` represents the current state of our page. So what is `Cmd Msg` for? In Elm programs, `Cmd` is short for "command". We use commands to return "side-effects"– like making HTTP requests, working with local storage, and more. 

In this guide, we'll just be using it for HTTP requests to the PokeAPI endpoint.

When we don't have any commands we want to run, we use the built-in `Cmd.none` to say "don't do any side-effects".

::: tip "Why are `Model` and `Cmd Msg` wrapped in those parentheses?"

The new parentheses mean that our functions are returning a "tuple" or "pair" of two values– instead of just one `Model` value. 

You can learn more about tuples in [the "Core Language" section of the official Elm guide here](https://guide.elm-lang.org/core_language.html).

:::

### `Sub msg`

Some applications need to keep track the size of the browser window, listen for keyboard events, or stay up-to-date with the mouse cursor's position.

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

### Running our PokeAPI server

Although you can call the PokeAPI directly at URLs like [https://pokeapi.co/api/v2/pokemon](https://pokeapi.co/api/v2/pokemon), the __fair use policy__ asks us to cache resources whenever possible.

> PokéAPI is free and open to use. It is also very popular. Because of this, we ask every developer to abide by our fair use policy. People not complying with the [fair use policy](https://pokeapi.co/docs/v2) will have their IP address permanently banned.

To make it easy to follow the rules, we'll use [this tiny Node.js app](https://github.com/ryannhg/pokeapi-cache-server) that caches our API requests for us!

In a separate terminal from the one running `elm-land server`, run the following commands:

```sh
git clone git@github.com:ryannhg/pokeapi-cache-server
```

```sh
cd pokeapi-cache-server
```

```sh
DELAY=1000 npm start
```

Now the PokeAPI will be available at `http://localhost:5000/api/v2`. In this guide, we'll be making requests to that URL (instead of `https://pokeapi.co/api/v2`), so we don't get in any trouble!

We are also setting an intentional `DELAY` of 1000ms on each request, to make it easier to see our "Loading..." states later.

## Storing API data

Now we are ready to make some API requests from our Elm application! The goal for our homepage is to show a grid with the first 150 pokemon using this API endpoint:

```txt
GET http://localhost:5000/api/v2/pokemon?limit=150
```

We'll be making our own `Api.elm` module to keep track of the three states that our data might be in:

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

When the page loads, the `init` function initializes our `pokemonData` to `Api.Loading`. This makes it possible to show a "Loading..." message in our `view` function below:

```elm {8-27}
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
                [ Html.text ("Fetched " ++ String.fromInt count ++ " pokemon!")
                ]

            Api.Failure httpError ->
                [ Html.text "Something went wrong..."
                ]
    }
```

When we go to `http://localhost:1234`, our web browser should show the message "Loading..."

![A webpage showing the message "Loading..."](./rest-apis/loading.png)

To see the actual data, we'll need to make an HTTP request and handle the JSON response.



## Working with JSON

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

Let's update our `init` function and pretend we have a function called `Api.PokemonList.getFirst150`:

```elm {4-5,12-14,23,29-32,34-37}
module Pages.Home_ exposing (Model, Msg, page)

import Api
import Api.PokemonList
import Http

-- ...

init : ( Model, Cmd Msg )
init =
    ( { pokemonData = Api.Loading }
    , Api.PokemonList.getFirst150
        { onResponse = PokeApiResponded
        }
    )



-- UPDATE


type Msg
    = PokeApiResponded (Result Http.Error (List Pokemon))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PokeApiResponded (Ok listOfPokemon) ->
            ( { model | pokemonData = Api.Success listOfPokemon }
            , Cmd.none
            )

        PokeApiResponded (Err httpError) ->
            ( { model | pokemonData = Api.Failure httpError }
            , Cmd.none
            )

-- ...
```

Now when we visit our browser, we can see a helpful Elm compiler message, reminding us that `Api.PokemonList` isn't available yet. Let's create a new file at `./src/Api/PokemonList.elm` that will know how to send our API request.

```elm
module Api.PokemonList exposing (getFirst150)

import Http


getFirst150 :
    { onResponse : Result Http.Error (List Pokemon) -> msg
    }
    -> Cmd msg
getFirst150 options =
    Http.get
        { url = "http://localhost:5000/api/v2/pokemon?limit=150"
        , expect = Http.expectJson options.onResponse decoder
        }
```

Here we're using the `Http.get` function from [the `elm/http` package](https://package.elm-lang.org/packages/elm/http/latest/Http) we installed earlier.

The function requires a record with two fields, before it can return a `Cmd msg`:

- `url` - The full API endpoint URL we want to send our GET request to
- `expect` - A description of what kind of response we are expecting from the API

In this case, we expect the PokeAPI to send us back the JSON snippet shown above. When that data comes back, we'll call the `onResponse` function so our homepage gets the result of that HTTP request.

### What about "decoder"?

There's just one more missing piece– the "decoder" value. Let's walk through creating our first JSON decoder together!

::: warning Warning: JSON decoders are tricky!

If you are new to Elm, JSON decoders can be a really tricky new concept. If this next part of the guide is hard for you to understand, you are not alone!

The [official Elm guide](https://guide.elm-lang.org/effects/json.html) does a great job at slowly building up to this, but we're diving in head-first, because we have Pokemon to catch!

:::

Our end goal is to turn the raw JSON from the API response into a `List Pokemon` for the app to render.

We know that our API response has a list of JSON objects at the "results" field, so that's where our JSON decoder should start!


```jsonc {5}
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

Rather than writing the entire JSON decoder in one function, let's break it down into smaller pieces. Here's the first piece:

```elm
import Json.Decode

decoder : Json.Decode.Decoder (List Pokemon)
decoder =
    Json.Decode.field "results" (Json.Decode.list pokemonDecoder)
```

This decoder is saying "look for a field called `"results"` that has a list of pokemon in it." We'll need to define what `pokemonDecoder` is next, so we can tell Elm how to create each individual `Pokemon` value in the list.

The `pokemonDecoder` will need to describe how to access the data within each object in the `"results"` list:

```jsonc {6-9}
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

For our application, all we need is the `"name"` property. We can use the `type alias` from before and the `Json.Decode.map` function to create a record from the JSON object:

```elm
type alias Pokemon =
    { name : String
    }


pokemonDecoder : Json.Decode.Decoder Pokemon
pokemonDecoder =
    Json.Decode.map Pokemon
        (Json.Decode.field "name" Json.Decode.string)
```

This code looks for a `"name"` field in our JSON object, and expects to find a `String` value. Once it finds that `String` value, it provides it to the `Pokemon` constructor that is included in the `type alias` definition.

We use `Json.Decode.map` for this example, because our record only has one field: `name`. Later we'll use `Json.Decode.map4` for the "Pokemon Detail" page, because that will grab 4 fields from the API response.

### Putting it all together

If we put all those snippets in our `src/Api/PokemonList.elm` file, here's what all the code looks like with the JSON decoding:

```elm {4,18-20,23-25,28-31}
module Api.PokemonList exposing (Pokemon, getFirst150)

import Http
import Json.Decode


getFirst150 :
    { onResponse : Result Http.Error (List Pokemon) -> msg
    }
    -> Cmd msg
getFirst150 options =
    Http.get
        { url = "http://localhost:5000/api/v2/pokemon?limit=150"
        , expect = Http.expectJson options.onResponse decoder
        }


decoder : Json.Decode.Decoder (List Pokemon)
decoder =
    Json.Decode.field "results" (Json.Decode.list pokemonDecoder)


type alias Pokemon =
    { name : String
    }


pokemonDecoder : Json.Decode.Decoder Pokemon
pokemonDecoder =
    Json.Decode.map Pokemon
        (Json.Decode.field "name" Json.Decode.string)

```

When you visit `http://localhost:1234` in your browser, you should see "Loading...", followed by a "Fetched 150 pokemon!" message:

![A webpage showing the message "Fetched 150 pokemon!"](./rest-apis/fetched-150-pokemon.png)

## Making it pretty with CSS

Now that we have all 150 Pokemon, we can render them in a grid layout. Let's use [Bulma.css](https://bulma.io) to style our Elm application. We can add CSS to an Elm Land project by adding our `link` tag to the `elm-land.json` file at the root of our project:

```json { 10-12 }
{
  "app": {
    "elm": {
      "development": { "debugger": true },
      "production": { "debugger": false }
    },
    "env": [],
    "html": {
      // ...
      "link": [
        { "rel": "stylesheet", "href": "https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css" }
      ],
      // ...
    }
  }
}
```

After Bulma has been added to our project, the font for "Fetched 150 pokemon!" should look different if you check your browser. Let's update our `view` code to render a red hero with a title/subtitle, as well as a grid to show our Pokemon!

```elm{3,7-27,30-35,38-67}
module Page.Home_ exposing (Model, Msg, page)

import Html.Attributes exposing (alt, class, src)

-- ...

view : Model -> View Msg
view model =
    { title = "Pokemon"
    , body =
        [ Html.div [ class "hero is-danger py-6 has-text-centered" ]
            [ Html.h1 [ class "title is-1" ] [ Html.text "Pokemon" ]
            , Html.h2 [ class "subtitle is-4" ] [ Html.text "Gotta fetch em all!" ]
            ]
        , case model.pokemonData of
            Api.Loading ->
                Html.div [ class "has-text-centered p-6" ] 
                    [ Html.text "Loading..." ]

            Api.Success pokemon ->
                viewPokemonList pokemon

            Api.Failure httpError ->
                Html.div [ class "has-text-centered p-6" ] 
                    [ Html.text "Something went wrong..." ]
        ]
    }


viewPokemonList : List Pokemon -> Html Msg
viewPokemonList listOfPokemon =
    Html.div [ class "container py-6 p-5" ]
        [ Html.div [ class "columns is-multiline" ]
            (List.indexedMap viewPokemon listOfPokemon)
        ]


viewPokemon : Int -> Pokemon -> Html Msg
viewPokemon index pokemon =
    let
        pokedexNumber : Int
        pokedexNumber =
            index + 1

        pokemonImageUrl : String
        pokemonImageUrl =
            "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/"
                ++ String.fromInt pokedexNumber
                ++ ".png"
    in
    Html.div [ class "column is-4-desktop is-6-tablet" ]
        [ Html.div [ class "card" ]
            [ Html.div [ class "card-content" ]
                [ Html.div [ class "media" ]
                    [ Html.div [ class "media-left" ]
                        [ Html.figure [ class "image is-64x64" ]
                            [ Html.img [ src pokemonImageUrl, alt pokemon.name ] []
                            ]
                        ]
                    , Html.div [ class "media-content" ]
                        [ Html.p [ class "title is-4" ] [ Html.text pokemon.name ]
                        , Html.p [ class "subtitle is-6" ] [ Html.text ("No. " ++ String.fromInt pokedexNumber) ]
                        ]
                    ]
                ]
            ]
        ]
```

After you add all that code, you should see something beautiful waiting for you at `http://localhost:1234`:

![The homepage, showing a grid of all 150 Pokemon](./rest-apis/homepage.png)

## Handling HTTP errors

Elm is popular for having [no runtime exceptions](https://elm-lang.org/) on the client side, but whenever we work with APIs via HTTP requests, there are a handful of things that can go wrong!

Let's take a closer look at how we handled that `Api.Failure` branch from our view code above:

```elm {19-21}
module Pages.Home_ exposing (Model, Msg, page)

-- ...


view : Model -> View Msg
view model =
    { title = "Pokemon"
    , body =
        [ -- ...
        , case model.pokemonData of
            Api.Loading ->
                Html.div [ class "has-text-centered p-6" ] 
                    [ Html.text "Loading..." ]

            Api.Success pokemon ->
                viewPokemonList pokemon

            Api.Failure httpError ->
                Html.div [ class "has-text-centered p-6" ] 
                    [ Html.text "Something went wrong..." ]
        ]
    }
```

Right now, the message "Something went wrong..." doesn't give a user very much information about what led to our Pokemon not showing on the page. 

Let's add a new function to our `Api` module called `toUserFriendlyMessage` that uses the `httpError` value to give our users meaningful information about what caused the problem:

```elm {3,6,11-36}
module Api exposing
    ( Data(..)
    , toUserFriendlyMessage
    )

import Http

-- ...


toUserFriendlyMessage : Http.Error -> String
toUserFriendlyMessage httpError =
    case httpError of
        Http.BadUrl _ ->
            -- The URL is malformed, probably caused by a typo
            "This page requested a bad URL"

        Http.Timeout ->
            -- Happens after
            "Request took too long to respond"

        Http.NetworkError ->
            -- Happens if the user is offline or the API isn't online
            "Could not connect to the API"

        Http.BadStatus code ->
            -- Connected to the API, but something went wrong
            if code == 404 then
                "Item not found"

            else
                "API returned an error code"

        Http.BadBody _ ->
            -- Our JSON decoder didn't match what the API sent
            "Unexpected response from API"

```

In `./src/Pages/Home_.elm`, we can use our new function in the `Api.Failure` branch to replace the old "Something went wrong..." placeholder message.

```elm {7}
module Pages.Home_ exposing (Model, Msg, page)

-- ...

Api.Failure httpError ->
    Html.div [ class "has-text-centered p-6" ] 
        [ Html.text (Api.toUserFriendlyMessage httpError) ]

-- ...
```


### Testing the error messages

Here are a few ways you can test it out by intentionally breaking the API request and seeing Elm show our user the error message.

__1. Close the PokeAPI backend server running at `http://localhost:5000`__

When you refresh your browser, you will see the "Could not connect to the API" message.

__2. Change the URL in `Api.PokemonList`__

This will render the "This page requested a bad URL" message.

```elm {11}
module Api.PokemonList exposing (getFirst150)

-- ...

getFirst150 :
    { onResponse : Result Http.Error (List Pokemon) -> msg
    }
    -> Cmd msg
getFirst150 options =
    Http.get
        { url = "http://#banana"
        , expect = Http.expectJson options.onResponse decoder
        }

```

__3. Edit our decoder in `Api.PokemonList` to look for "nam" instead of "name"__

This change will show the "Unexpected response from API" message when the page loads.

```elm {8}
module Api.PokemonList exposing (getFirst150)

-- ...

pokemonDecoder : Json.Decode.Decoder Pokemon
pokemonDecoder =
    Json.Decode.map Pokemon
        (Json.Decode.field "nam" Json.Decode.string)

```

__4. Timeout & bad status__

The other two possible errors, `Timeout` and `BadStatus` will involve changing the backend servers implementation, so we'll skip those for now.

::: tip "How will I know about these HTTP errors in production?"

Elm includes helpful information about each error case in the `Http.Error` value, so we can send that information to an error logging service like [Rollbar](https://rollbar.com/) or [Sentry](https://sentry.io).

( Stay tuned for another guide on how to wire up error logging to your Elm Land application! )

:::

## Adding a detail page

Our new homepage works great– but what if users want to see more detailed information about a Pokemon on a separate page?

Let's make each of our Pokemon tiles clickable, so they take us to a "Pokemon Detail" page like `/pokemon/bulbasaur` or `/pokemon/pikachu`. We can create a new page with the Elm Land CLI:

```sh
elm-land add page:element /pokemon/:name
```

By using the dynamic `:name` parameter, we'll get a new file at `./src/Pokemon/Name_.elm` that handles requests to any pokemon name we send in.

::: details `./src/Pokemon/Name_.elm`

```elm
module Pages.Pokemon.Name_ exposing (Model, Msg, page)

import Html exposing (Html)
import Page exposing (Page)
import View exposing (View)


page : { name : String } -> Page Model Msg
page params =
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
            ( model
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pages.Pokemon.Name_"
    , body = [ Html.text "/pokemon/:name" ]
    }
```

:::

We can make each Pokemon card on the homepage link to our new page using the `Route.href` function! Let's edit `./src/Pages/Home_.elm` to link to our new page:

```elm {3,19-23,26,43}
module Pages.Home_ exposing (Model, Msg, page)

import Route.Path
-- ...

viewPokemon : Int -> Pokemon -> Html Msg
viewPokemon index pokemon =
    let
        pokedexNumber : Int
        pokedexNumber =
            index + 1

        pokemonImageUrl : String
        pokemonImageUrl =
            "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/"
                ++ String.fromInt pokedexNumber
                ++ ".png"

        pokemonDetailRoute : Route.Path.Path
        pokemonDetailRoute =
            Route.Path.Pokemon_Name_
                { name = pokemon.name
                }
    in
    Html.div [ class "column is-4-desktop is-6-tablet" ]
        [ Html.a [ Route.Path.href pokemonDetailRoute ]
            [ Html.div [ class "card" ]
                [ Html.div [ class "card-content" ]
                    [ Html.div [ class "media" ]
                        [ Html.div [ class "media-left" ]
                            [ Html.figure [ class "image is-64x64" ]
                                [ Html.img [ src pokemonImageUrl, alt pokemon.name ] []
                                ]
                            ]
                        , Html.div [ class "media-content" ]
                            [ Html.p [ class "title is-4" ] [ Html.text pokemon.name ]
                            , Html.p [ class "subtitle is-6" ] [ Html.text ("No. " ++ String.fromInt pokedexNumber) ]
                            ]
                        ]
                    ]
                ]
            ]
        ]

```

Before we try it out, let's update our `view` function in `./src/Pages/Pokemon/Name_.elm` to show the same red hero component with our Pokemon's name.

To do that, we'll need to pass the `params` value through from our `page` function to our `view`:

```elm {3-4,14,19-31}
module Pages.Pokemon.Name_ exposing (Model, Msg, page)

import Html.Attributes exposing (class)
import Route.Path
-- ...


page : { name : String } -> Page Model Msg
page params =
    Page.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view params
        }

-- ...

view : { name : String } -> Model -> View Msg
view params model =
    { title = params.name ++ " | Pokemon"
    , body =
        [ Html.div [ class "hero is-danger py-6 has-text-centered" ]
            [ Html.h1 [ class "title is-1" ] [ Html.text params.name ]
            , Html.h2 [ class "subtitle is-6 is-underlined" ]
                [ Html.a [ Route.Path.href Route.Path.Home_ ]
                    [ Html.text "Back to Pokemon" ]
                ]
            ]
        ]
    }

```

When we go back to our browser, here's what we should see:

<BrowserWindow src="/images/guide/rest-apis/pokemon-detail.gif" alt="Demo of Pokemon tiles linking to detail pages" />

## Fetching a Pokemon's details

The PokeAPI has URLs for all our Pokemon, including things like their "Pokedex ID", "Name", "Types", and more. If we want to get more details on `bulbasaur`, here's the URL we would make a request to:

```txt
GET http://localhost:5000/api/v2/pokemon/bulbasaur
```

That endpoint will have a _huge_ JSON response, but I've highlighted the four fields we will be using in our detail page:

```jsonc {3-4,12,20,27}
{
    // ...
    "name": "bulbasaur",
    "id": 1,
    // ...
    "sprites": {
        // ...
        "other": {
            // ...
            "official-artwork": {
                // ...
                "front_default": ".../bulbasaur.png"
            }
        }
    },
    "types": [
        {
            "slot": 1,
            "type": {
                "name": "grass",
                "url": "http://localhost:5000/api/v2/type/12/"
            }
        },
        {
            "slot": 1,
            "type": {
                "name": "poison",
                "url": "http://localhost:5000/api/v2/type/4/"
            }
        }
    ]
}
```

### Decoding the JSON

For this detail page, we're asking for four fields for each Pokemon. We define a `type alias` to keep track of the order of those fields and what values we expect for each one:

```elm
type alias Pokemon =
    { name : String
    , pokedexId : Int
    , spriteUrl : String
    , types : List String
    }
```

To follow the JSON structure shown above, this is the `decoder` function we'll write:

```elm
decoder : Json.Decode.Decoder Pokemon
decoder =
    Json.Decode.map4 Pokemon
        nameFieldDecoder
        pokedexIdFieldDecoder
        spriteUrlFieldDecoder
        typesFieldDecoder
```

Because our new `Pokemon` record has four fields, our decoder will use `Json.Decode.map4`. The `map4` function needs to be provided four decoders of it's own, one for each field. Once we write a decoder for each field, we can pass them along to the `Pokemon` constructor.


### Decoding the `name` field

```elm
nameFieldDecoder : Json.Decode.Decoder String
nameFieldDecoder =
    Json.Decode.field "name" Json.Decode.string
```

Just like with our `PokemonList` decoder, we'll start with by getting our Pokemon's `name` field. This decoder looks for an object field at `"name"` and is expecting a `String` value there.

### Decoding the `pokedexId` field

```elm
pokedexIdFieldDecoder : Json.Decode.Decoder Int
pokedexIdFieldDecoder =
    Json.Decode.field "id" Json.Decode.int
```

Just like our "name" decoder, the "pokedexId" decoder will use `Json.Decode.field` to look for an object field by its name. This time, we'll look for a field named `"id"` and expect an `Int` value there.

### Decoding the `spriteUrl` field

```elm
spriteUrlFieldDecoder : Json.Decode.Decoder String
spriteUrlFieldDecoder =
    Json.Decode.at
        [ "sprites", "other", "official-artwork", "front_default" ]
        Json.Decode.string
```

Getting our `spriteUrl` introduces a new challenge: Accessing nested JSON fields! Instead of nesting four `Json.Decode.field` calls like this:

```elm
-- The hard way!
(Json.Decode.field "sprites"
    (Json.Decode.field "other"
        (Json.Decode.field "official-artwork"
            (Json.Decode.field "front_default" Json.Decode.string)
        )
    )
)
```

We can use the built-in [`Json.Decode.at`](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#at) function which does this with a `List String` instead. Our decoder will drill down deep into the JSON value, and look for a `String` there.

### Decoding the `types` field

```elm
typesFieldDecoder : Json.Decode.Decoder (List String)
typesFieldDecoder =
    Json.Decode.field "types" (Json.Decode.list pokemonTypeDecoder)
```

To get a `List` of values instead of just a single `String` or `Int` value– we'll need to use [`Json.Decode.list`](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#list).

The `Json.Decode.list` function takes _another_ decoder as it's input. That inner decoder will describe how to get JSON for each element in the list.

Because the `types` field is a `List String`, we'll need to make a `String` decoder for each element that looks something like this:

```elm
pokemonTypeDecoder : Json.Decode.Decoder String
pokemonTypeDecoder =
    Json.Decode.at [ "type", "name" ] Json.Decode.string
```

### Putting it all together

Now that we took care of the hard part (decoding the JSON), we can create a new `./src/Api/PokemonDetail.elm` file, so our detail page can use it!


```elm
module Api.PokemonDetail exposing (Pokemon, get)

import Http
import Json.Decode


type alias Pokemon =
    { name : String
    , pokedexId : Int
    , spriteUrl : String
    , types : List String
    }


get :
    { name : String
    , onResponse : Result Http.Error Pokemon -> msg 
    }
    -> Cmd msg
get options =
    Http.get
        { url = "http://localhost:5000/api/v2/pokemon/" ++ options.name
        , expect = Http.expectJson options.onResponse decoder
        }



-- JSON DECODERS


decoder : Json.Decode.Decoder Pokemon
decoder =
    Json.Decode.map4 Pokemon
        nameFieldDecoder
        pokedexIdFieldDecoder
        spriteUrlFieldDecoder
        typesFieldDecoder


nameFieldDecoder : Json.Decode.Decoder String
nameFieldDecoder =
    Json.Decode.field "name" Json.Decode.string


pokedexIdFieldDecoder : Json.Decode.Decoder Int
pokedexIdFieldDecoder =
    Json.Decode.field "id" Json.Decode.int


spriteUrlFieldDecoder : Json.Decode.Decoder String
spriteUrlFieldDecoder =
    Json.Decode.at
        [ "sprites", "other", "official-artwork", "front_default" ]
        Json.Decode.string


typesFieldDecoder : Json.Decode.Decoder (List String)
typesFieldDecoder =
    Json.Decode.field "types" (Json.Decode.list pokemonTypeDecoder)


pokemonTypeDecoder : Json.Decode.Decoder String
pokemonTypeDecoder =
    Json.Decode.at [ "type", "name" ] Json.Decode.string
```

## Seeing the final detail page

Let's update a few lines in `./src/Pokemon/Name_.elm` and fetch detailed data for each Pokemon:

```elm {3-4,6-7,16,27-29,32-39,47,52-61,88-98,103-131}
module Pages.Pokemon.Name_ exposing (Model, Msg, page)

import Api
import Api.PokemonDetail exposing (Pokemon)
import Html exposing (Html)
import Html.Attributes exposing (alt, class, src, style)
import Http
import Page exposing (Page)
import Route.Path
import View exposing (View)


page : { name : String } -> Page Model Msg
page params =
    Page.element
        { init = init params
        , update = update
        , subscriptions = subscriptions
        , view = view params
        }



-- INIT


type alias Model =
    { pokemonData : Api.Data Pokemon
    }


init : { name : String } -> ( Model, Cmd Msg )
init params =
    ( { pokemonData = Api.Loading }
    , Api.PokemonDetail.get
        { name = params.name
        , onResponse = PokeApiResponded
        }
    )



-- UPDATE


type Msg
    = PokeApiResponded (Result Http.Error Pokemon)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PokeApiResponded (Ok pokemon) ->
            ( { model | pokemonData = Api.Success pokemon }
            , Cmd.none
            )

        PokeApiResponded (Err httpError) ->
            ( { model | pokemonData = Api.Failure httpError }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : { name : String } -> Model -> View Msg
view params model =
    { title = params.name ++ " | Pokemon"
    , body =
        [ Html.div [ class "hero is-danger py-6 has-text-centered" ]
            [ Html.h1 [ class "title is-1" ] [ Html.text params.name ]
            , Html.h2 [ class "subtitle is-6 is-underlined" ]
                [ Html.a [ Route.Path.href Route.Path.Home_ ]
                    [ Html.text "Back to pokemon" ]
                ]
            ]
        , case model.pokemonData of
            Api.Loading ->
                Html.div [ class "has-text-centered p-6" ]
                    [ Html.text "Loading..." ]

            Api.Success pokemon ->
                viewPokemon pokemon

            Api.Failure httpError ->
                Html.div [ class "has-text-centered p-6" ]
                    [ Html.text (Api.toUserFriendlyMessage httpError) ]
        ]
    }


viewPokemon : Pokemon -> Html msg
viewPokemon pokemon =
    Html.div [ class "container p-6 has-text-centered" ]
        [ viewPokemonImage pokemon
        , Html.p [] [ Html.text ("Pokedex No. " ++ String.fromInt pokemon.pokedexId) ]
        , viewPokemonTypes pokemon.types
        ]


viewPokemonImage : Pokemon -> Html msg
viewPokemonImage pokemon =
    Html.figure
        [ class "image my-5 mx-auto"
        , style "width" "256px"
        , style "height" "256px"
        ]
        [ Html.img [ src pokemon.spriteUrl, alt pokemon.name ] []
        ]


viewPokemonTypes : List String -> Html msg
viewPokemonTypes pokemonTypes =
    Html.div [ class "tags is-centered py-4" ]
        (List.map viewPokemonType pokemonTypes)


viewPokemonType : String -> Html msg
viewPokemonType pokemonType =
    Html.span [ class "tag" ] [ Html.text pokemonType ]
```

That was the last step, if we check our web browser, here's what we'll see:

<BrowserWindow src="/images/guide/rest-apis.gif" alt="Demo of Pokemon API data" />

### You did it! :tada:

You are now both a Pokemon _and_ JSON decoding master! Getting comfortable with JSON decoding takes time, but now you're ready for the next exciting guide!

See you there!
