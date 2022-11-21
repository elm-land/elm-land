# Components and UI

### What we'll learn

- How to __create components__ in Elm
- How to __track state__ within a component
- How to __send effects__ back to a parent container

<BrowserWindow src="/images/guide/user-auth.gif" alt="Demo of sign-in flow" />

### Getting started

This section will introduce you to components in four steps:

1. __Creating component files__ - How to define a component in it's own file
1. __Supporting optional input__ - How to make it easy to provide good defaults, and optional input to a component
1. __Tracking internal state__ - How to make a component "stateful", so it can maintain it's own `Model`
1. __Supporting effects__ – How to send HTTP requests or bubble up information to your parent container

To learn how to do this, we're going to design a `Components.Table` module. This component will make it easier to add tables across multiple pages in our app and provide our users with a consistent UI experience.

Let's create a new Elm Land project to get started:

```sh
elm-land init 08-components-and-ui
```


## Stateless components

Whenever you can, you'll want to make your components "stateless". Just like `Html.div` or `Html.h1`, a stateless component doesn't need to track it's own `Model` nor define it's own messages.

These components are really easy to implement, and even easier to use!

### Simple example

```elm
module Components.Footer exposing (view)

view : Html msg
```

```elm
import Components.Footer


view : Model -> Html msg
view model =
    Components.Footer.view
```

### Optional arguments


```elm
module Components.Button exposing
    ( Button
    , newPrimary, newSecondary, newDanger
    , view
    , withOnClick
    , withDisabledIf
    , withIconLeft, withIconRight
    )

type Button msg

newPrimary : { label : String } -> Button msg
newSecondary : { label : String } -> Button msg
newDanger : { label : String } -> Button msg

withOnClick : msg -> Button msg -> Button msg
withDisabledIf : Bool -> Button msg-> Button msg
withIconLeft : Components.Icon.Icon -> Button msg-> Button msg
withIconRight : Components.Icon.Icon -> Button msg-> Button msg

view : Button msg -> Html msg
```

```elm
import Components.Button


view : Model -> Html msg
view model =
    Html.div []
        [ Components.Button.newPrimary
            { label = "Submit form" 
            }
            |> Components.Button.withOnClick UserClickedSubmit
            |> Components.Button.view
        , Components.Button.newSecondary
            { label = "Cancel" 
            }
            |> Components.Button.withOnClick UserClickedCancel
            |> Components.Button.view
        ]
```

## Stateful components


```elm
module Components.Accordion exposing
    ( Model, init
    , Msg, update
    , view
    )


-- INIT

type Model id

init : { open : Set id } -> Model id


-- UPDATE

type Msg id

update : Msg id -> Model id -> Model id


-- VIEW

type alias Accordion id =
    { id : id
    , label : String 
    }

view : 
    { model : Model id
    , toMsg : Msg id -> msg
    , items : List (Accordion id)
    , view : id -> Html msg
    }
    -> Html msg
```

## Components with side-effects