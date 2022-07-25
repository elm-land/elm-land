# Shared State

## Each page gets its own Model

When you navigate from one page to another in Elm Land, the `init` function for each page is getting called. This means that if you are on the `Home_` page, and click a link to the `Settings` page, all the data for the homepage will be replaced with the settings page's data.

Here's a high-level look of how Elm Land stores your page data under-the-hood:

```elm
module Main exposing (main)

import Pages.Home_
import Pages.Settings


type alias Model =
    { page : PageModel
    }


type PageModel
    = HomePageModel Pages.Home_.Model
    | SettingsPageModel Pages.Settings.Model
```

Sometimes, you'll want to share data across multiple pages. That's where the __Shared__ module comes in. The Shared module is a way to store things like:

- The currently signed-in user
- The user's time zone
- Global settings like dark mode

By default, an empty `Shared` module is generated for you in the background. When you are ready to share data across pages, you can run this `elm-land` command to "eject" that default file into your `src/` folder. From there, it can be customized however you like:

```sh
elm-land eject shared
```



<code-group>
<code-block title="Terminal output">

```txt
🌈 Shared module is ready to customize at:
     ./src/Shared.elm
```

</code-block>
</code-group>

## Taking a look at Shared.elm

If you open the file at `src/Shared.elm`, here's what you'll see:

```elm
module Shared exposing
    ( Flags, decoder
    , Model, Msg(..)
    , init, update, subscriptions
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions

-}
import ElmLand.Request exposing (Request)
import Json.Decode.Value


-- FLAGS


type alias Flags =
    {}


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.succeed {}



-- INIT


type alias Model =
    {}


init : Result Json.Decode.Error Flags -> Request () -> ( Model, Cmd Msg )
init flagsResult req =
    ( {}
    , Cmd.none
    )



-- UPDATE


type Msg 
    = ExampleMsgReplaceMe


update : Request () -> Msg -> Model -> ( Model, Cmd Msg )
update req msg model =
    case msg of
        ExampleMsgReplaceMe ->
            ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Request () -> Model -> Sub Msg
subscriptions req model =
    Sub.none

```


Let's breakdown the different types and functions exposed by this module, so you can understand how to use them in your own Elm Land application:

- `Flags` - initial data from JavaScript that you want to send to your Elm application
  - `decoder` - how to safely turn the raw JSON sent from JavaScript into the `Flags` type
- `Model` - the data you want to store across pages
  - `init` - how to initialize the `Model`
- `Msg` - the different ways your `Model` can be updated
  - `update` - how to update the shared state when a new `Msg` comes in
  - `subscriptions` - any subscriptions you want to run on every page


Each of the sections below will talk through an example of how you might use these 7 parts of the Shared module.


### Flags

When working with [JS interop](./interop-with-js), you can send in some initial data from JavaScript by defining the `flags` function in your `src/interop.js` file. The `Shared.Flags` type should match what you are expecting to return from that `flags` function.

Here's an example of sending in a "Hello!" from JavaScript when your application starts up:


<code-group>
<code-block title="src/interop.js">

```js
export const flags = ({ env }) => {
  return {
    message: 'Hello from JS!'
  }
}
```

</code-block>
<code-block title="src/Shared.elm">

```elm
module Shared exposing (Flags, decoder, ...)

import Json.Decode


type alias Flags =
    { message : String
    }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map Flags
        (Json.Decode.field "message" Json.Decode.string)

-- ...
```

</code-block>
</code-group>

You'll use the `decoder` to define the JSON you expect from JavaScript. Later on, in the `init` function, you will be able to see if your `decoder` worked:


```elm
module Shared exposing (...)

import ElmLand.Request exposing (Request)
import Json.Decode


-- FLAGS

...

-- INIT

type alias Model =
    { messageFromFlags : Maybe String
    }


init : Result Json.Decode.Error Flags -> Request () -> ( Model, Cmd Msg )
init flagsResult req =
    case flagsResult of
        Ok flags ->
            ( { messageFromFlags = Just flags.message }
            , Cmd.none
            )

        Err flagJsonDecodeError ->
            ( { messageFromFlags = Nothing }
            , Cmd.none
            )

```

::: tip Note
Instead of using `Cmd.none` in the `Err` branch above, you can also send the `flagDecodeError` to your preferred error logging service using the [elm/http](https://package.elm-lang.org/packages/elm/http/latest/Http) package.

```elm{3-7}
        Err flagJsonDecodeError ->
            ( { messageFromFlags = Nothing }
            , Http.post
                { url = "https://..."
                , body = ...
                , expect = ...
                }
            )
```

This way you can be alerted anytime your JS gives you an unexpected value.
:::


### Model & init

As we saw in the `Flags` example above, the `init` function will determine the initial value of your `Model`. When you are working within an Elm Land page, you'll be able to access the latest value of the `Shared.Model`.

If your app has a user sign-in form, it is common to store the signed-in user in your `Shared.Model`. That way, you can easily see who the user is at a page-level:



<code-group>
<code-block title="src/Shared.elm">

```elm
module Shared exposing (..., Model, init, ...)



-- INIT


type alias Model =
    { signInStatus : SignInStatus
    }


type SignInStatus
    = NotSignedIn
    | SignedInAsUser User


type alias User =
    { name : String
    , email : Maybe String
    }


init : Result Json.Decode.Error Flags -> Request () -> ( Model, Cmd Msg )
init flagsResult request =
    ( { signInStatus =
          SignedInAsUser
              { name = "Ryan Haskell-Glatz"
              , email = Nothing
              }
      }
    , Cmd.none
    )

-- ...
```

</code-block>
<code-block title="src/Pages/Dashboard.elm">

```elm{12,28-34}
module Pages.Dashboard exposing (Model, Msg, page)

import Shared
...


page : Shared.Model -> Request () -> Page Model Msg
page shared req =
    ElmLand.Page.new
        { init = init
        , update = update
        , view = view shared
        , subscriptions = subscriptions
        }


...



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    { title = "Dashboard"
    , body =
        [ case shared.user of
            NotSignedIn ->
                Html.text "Hello, stranger!"

            SignedInAsUser user ->
                Html.text ("Oh hi, " ++ user.name ++ "!")
        ]
    }

```

</code-block>
</code-group>