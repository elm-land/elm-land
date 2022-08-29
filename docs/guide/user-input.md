# User input

### What we'll learn

- The three pieces of __the Elm architecture__
- How to update UI when a __user clicks a button__
- How to __add more features__ to an existing app

<BrowserWindow src="./state-management/screenshot.gif" alt="Demo of the counter app example" />

## Making HTML interactive

All the pages we saw in the guide so far were rendering HTML. Every time you loaded a page, it showed the same HTML. For more interesting applications, you'll need to update HTML as a user interacts with your app.

Let's start with a brand new project: __Making a counter app!__


```sh
npx elm-land init user-input
```
```sh
cd user-input
```
```sh
npx elm-land server
```

We can create a new page that keeps track of our UI's state using the `elm-land add page:sandbox` command. This time around, we'll use `page:sandbox` instead of the `page:static` from previous guides:

```sh
npx elm-land add page:sandbox /counter
```

```elm
module Pages.Counter exposing (Model, Msg, page)

import Html exposing (Html)
import Page exposing (Page)
import View exposing (View)



-- PAGE


page : Page Model Msg
page =
    Page.sandbox
        { init = init
        , update = update
        , view = view
        }



-- INIT


type alias Model =
    {}


init : Model
init =
    {}



-- UPDATE


type Msg
    = ExampleMsgReplaceMe


update : Msg -> Model -> Model
update msg model =
    case msg of
        ExampleMsgReplaceMe ->
            model



-- VIEW


view : Model -> View Msg
view model =
    { title = "Counter"
    , body = [ Html.text "/counter" ]
    }
```

The page file generated for us doesn't do anything cool yet. It just shows "/counter" (which is pretty boring).

## Learning the Elm architecture

All Elm Land projects use [the Elm Architecture](https://guide.elm-lang.org/architecture/), which is an easy way to track the state of our web application.

Let's walk through updating each piece of our new page step-by-step. By the end, we'll have a fully working "Counter" app!

### __`Model`__

The `Model` describes the shape of the state of our application. We'll add a `counter` field to track an `Int` value. In Elm, "Int" is short for "integer" which is nerd-speak for "whole number":

```elm
type alias Model =
    { counter : Int
    }
```

### __`init`__ 

The `init` function defines the __initial value__ of your `Model` when the page loads. The `Model` we defined above only describes the __shape__ of our model, but not it's current value.

In our app, we'll want the counter to start at `0` when the page loads. We'll define that initial value in our `init` function:

```elm
init : Model
init =
    { counter = 0
    }
```

### __`Msg`__ 

The `Msg` type is a __custom type__ that defines how a user can change our page's `Model`. Elm lets us use "custom types" to define all the possible ways our UI can change our code. 

Looking at the `Msg` type is an easy way to learn all the ways a page's state can change. Here are the two "variants" we'll need for this page's `Msg` type:

```elm
type Msg
    = UserClickedIncrement
    | UserClickedDecrement
```

### __`update`__ 

The `update` function returns a new, updated `Model` based on which `Msg` was sent from our `view` function. It also has access to the current state of our `Model`, so it can do any calculations it needs.

Here we'll use Elm's "record update syntax" to change the `counter` field of our `model` based on which `Msg` we get:

```elm
update : Msg -> Model -> Model
update msg model =
    case msg of
        UserClickedIncrement ->
            { model | counter = model.counter + 1 }

        UserClickedDecrement ->
            { model | counter = model.counter - 1 }
```

::: tip "Where does update get called?"

Elm automatically calls `update` for us whenever the `view` function sends a `Msg`. Unlike in a JS framework, we don't call the `update` function manually ourselves.

:::

### __`view`__ 

The `view` function renders the current version of our `Model` into HTML our users can see.

For our example, our `view` function will need two `<button>` HTML elements that send `Msg` values. Between each button, we'll render a `<div>` that shows the current value of our counter:

```elm
import Html.Events

-- ( imports always go at the top, under the "module" declaration )


view : Model -> View Msg
view model =
    { title = "Counter" 
    , body =
        [ Html.button 
            [ Html.Events.onClick UserClickedIncrement ]
            [ Html.text "+" ]
        , Html.div [] 
            [ Html.text (String.fromInt model.counter) ]
        , Html.button 
            [ Html.Events.onClick UserClickedDecrement ]
            [ Html.text "-" ]
        ]
    }
```

## Putting it all together

If we add each of these snippets to our `src/Pages/Counter.elm` file, we'll have a working counter app that can increment and decrement a number!

::: details Our updated `src/Pages/Counter.elm`

```elm{4,26-28,31-34,42-43,49-50,52-53,60-73}
module Pages.Counter exposing (Model, Msg, page)

import Html exposing (Html)
import Html.Events
import Page exposing (Page)
import View exposing (View)



-- PAGE


page : Page Model Msg
page =
    Page.sandbox
        { init = init
        , update = update
        , view = view
        }



-- INIT


type alias Model =
    { counter : Int 
    }


init : Model
init =
    { counter = 0
    }



-- UPDATE


type Msg
    = UserClickedIncrement
    | UserClickedDecrement


update : Msg -> Model -> Model
update msg model =
    case msg of
        UserClickedIncrement ->
            { model | counter = model.counter + 1 }

        UserClickedDecrement ->
            { model | counter = model.counter - 1 }



-- VIEW


view : Model -> View Msg
view model =
    { title = "Counter" 
    , body =
        [ Html.button 
            [ Html.Events.onClick UserClickedIncrement ]
            [ Html.text "+" ]
        , Html.div [] 
            [ Html.text (String.fromInt model.counter) ]
        , Html.button 
            [ Html.Events.onClick UserClickedDecrement ]
            [ Html.text "-" ]
        ]
    }
```


:::

When we open our web browser at `http://localhost:1234/counter`, we'll see an interactive counter application that looks like this:

<BrowserWindow src="./state-management/screenshot.gif" alt="Demo of the counter app example" url="http://localhost:1234/counter" />

See the full example in the [examples/03-user-input](https://github.com/elm-land/elm-land/tree/main/examples/03-user-input) folder on GitHub.

### Oops, you're an Elm developer! :tada:

Now that you've seen the official counter example, you're officially an Elm developer. We're so glad to have you join the party!

You can use the `elm-land add page:sandbox` command __anytime__ you want your page to track local UI state.

For things like talking to a REST API, you'll want to use something a bit more advanced. Let's cover that in the next section!