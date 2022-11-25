# User authentication

### What we'll learn

- How to make a sign-in form
- How to store a JWT fetched from a REST API
- How to redirect when a page should only be seen by signed-in users

<BrowserWindow src="/images/guide/user-auth.gif" alt="Demo of sign-in flow" />


Many applications require a signed-in user to render certain pages. For example, your app's `Dashboard` page should only be seen by folks who have already signed in. In contrast, these apps have other pages (like the `SignIn` page) that should be available even if folks are signed out.

This guide will walk you through how to build a complete sign-in process for a REST API that returns JSON web tokens (JWTs). Here are the things we'll make together:

1. Creating a sign-in page and adding a form
1. Handling sign-in form validation errors
1. Redirecting to another page after a successful login
1. Persisting user tokens with `LocalStorage`, so they are still available after refresh
1. Handling redirects from any pages that require signed-in users

To get started, let's create a new Elm Land project using the CLI:

```sh
elm-land init user-auth
```

## Creating a sign-in page

We can use the CLI to create a new page at `/sign-in`:

```sh
elm-land add page /sign-in
```

In the last few guides, we used `page:static`, `page:sandbox`, or `page:element` to create a page. This time, we'll be using the standard `elm add page` command. This will give us a fully featured page that will become useful for sharing our signed-in user across pages. We'll dive into how to do this soon!

Now that we have our new sign-in page, let's run the dev server:

```sh
elm-land server
```

Opening `http://localhost:1234/sign-in` in a web browser should show us a screen that looks like this:

![A screenshot of a webpage reading "/sign-in"](./user-auth/01-sign-in-page.png)

## Adding a form

To make our sign-in form look nice, let's use a CSS framework called [Bulma](https://bulma.io). We can add the Bulma CSS by editing the `elm-land.json` file at the root of the project:


```json{6-8}
{
  "app": {
    "env": [],
    "html": {
      ...
      "link": [
        { "rel": "stylesheet", "href": "https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css" }
      ]
      ...
    }
  }
}
```

Let's update `src/Pages/SignIn.elm` to use the following code in our `view` function instead of the default "/sign-in" message.

This will involve a few small steps:

1. __Updating our imports__
2. __Initializing our form__ (in our `INIT` section)
3. __Handling form updates from the UI__ (in our `UPDATE` section)
4. __Adding in some Bulma HTML__ (in our `VIEW` section) 

###  1. Updating our imports

Here we need to import a few modules from the [elm/html](https://package.elm-lang.org/packages/elm/html/latest). As we saw in previous guides, these modules will allow us to handle user interaction and set HTML attributes where we need them.

Here are the modules we'll need to add to `src/Pages/SignIn.elm`:

```elm
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
```

### 2. Initializing our form

Our sign-in form will involve two fields, "Email address" and "Password". We need a way to track the current value in the `<input>` element. We use two `String` fields in our sign-in page's `Model`. Additionally, we'll want to disable the "Sign in" button when the user clicks it. This will let them know that a sign-in request is in progress and their form submission was successful.

Here's the `Model`, describing the shape of the data we want to keep track of, and the `init` function that defines the __initial state__ of our `Model`.

```elm
-- INIT


type alias Model =
    { email : String
    , password : String
    , isSubmittingForm : Bool
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { email = ""
      , password = ""
      , isSubmittingForm = False
      }
    , Effect.none
    )
```

__"Wait, what's an `Effect Msg`?"__

In the last guide, we saw how the `Cmd Msg` message type allowed our pages to send side-effects like HTTP requests. To allow us to define custom side-effects specific to our application, _Elm Land_ introduces a new `Effect Msg` type. We'll see how this is useful very soon when it's time to save the signed-in user's token!


### 3. Handling updates from the UI

Next, we'll need to define all the ways a user could interact with our Sign In page. Let's add a `UserUpdatedInput` message for handling when our `<input>` fields receive new values. Additionally, we'll want a message for `UserSubmittedForm` so we can set the form to loading.
 

```elm
-- UPDATE


type Msg
    = UserUpdatedInput Field String
    | UserSubmittedForm


type Field
    = Email
    | Password


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserUpdatedInput Email value ->
            ( { model | email = value }
            , Effect.none
            )

        UserUpdatedInput Password value ->
            ( { model | password = value }
            , Effect.none
            )

        UserSubmittedForm ->
            ( { model | isSubmittingForm = True }
            , Effect.none
            )
```

In the code snippet above, we defined a `Msg` with two arguments: `UserUpdatedInput Field String`. It would also be totally reasonable to define a `UserUpdatedEmail String` and `UserUpdatedPassword String` field instead.

The single `UserUpdatedInput` variant will be helpful in the next section, when we make the `viewFormInput` function

### 4. Rendering the form as HTML

```elm
-- VIEW


view : Model -> View Msg
view model =
    { title = "Sign in"
    , body =
        [ viewPage model
        ]
    }


viewPage : Model -> Html Msg
viewPage model =
    Html.div [ Attr.class "columns is-mobile is-centered" ]
        [ Html.div [ Attr.class "column is-narrow" ]
            [ Html.div [ Attr.class "section" ]
                [ Html.h1 [ Attr.class "title" ] [ Html.text "Sign in" ]
                , viewForm model
                ]
            ]
        ]


viewForm : Model -> Html Msg
viewForm model =
    Html.form [ Attr.class "box", Html.Events.onSubmit UserSubmittedForm ]
        [ viewFormInput
            { field = Email
            , value = model.email
            }
        , viewFormInput
            { field = Password
            , value = model.password
            }
        , viewFormControls model.isSubmittingForm
        ]


viewFormInput :
    { field : Field
    , value : String
    }
    -> Html Msg
viewFormInput options =
    Html.div [ Attr.class "field" ]
        [ Html.label [ Attr.class "label" ] [ Html.text (fromFieldToLabel options.field) ]
        , Html.div [ Attr.class "control" ]
            [ Html.input
                [ Attr.class "input"
                , Attr.type_ (fromFieldToInputType options.field)
                , Attr.value options.value
                , Html.Events.onInput (UserUpdatedInput options.field)
                ]
                []
            ]
        ]


fromFieldToLabel : Field -> String
fromFieldToLabel field =
    case field of
        Email ->
            "Email address"

        Password ->
            "Password"


fromFieldToInputType : Field -> String
fromFieldToInputType field =
    case field of
        Email ->
            "email"

        Password ->
            "password"


viewFormControls : Bool -> Html Msg
viewFormControls isSubmitting =
    Html.div [ Attr.class "field is-grouped is-grouped-right" ]
        [ Html.div
            [ Attr.class "control" ]
            [ Html.button
                [ Attr.class "button is-link"
                , Attr.disabled isSubmitting
                , Attr.classList [ ( "is-loading", isSubmitting ) ]
                ]
                [ Html.text "Sign in" ]
            ]
        ]
```

Once you have copied those snippets into your `SignIn.elm` page, here's what you should see in the web browser:

![A sign-in form with an email and password, which shows a loading spinner when submitted](./user-auth/02-form.gif)

The form looks nice, but clicking "Sign in" doesn't actually send an HTTP request to a backend API. As we saw earlier in the `update` function, in the `UserSubmittedForm` branch, we're just setting `isSubmitting` to `True`.

The next step will involve talking to an actual REST API to get a user token.

## Running the backend API

In order to see this form work with a real HTTP request, we'll need a real backend API! For this sign-in example, we've created a simple Node.js API server. This means you can follow along on your own machine. Run these commands to get the server running at `http://localhost:5000`:

```
git clone https://github.com/elm-land/elm-land
cd elm-land/examples/05-user-auth/api-server
npm install
node index.js
```

### POST /api/sign-in

This tiny web server accepts POST requests at `/api/sign-in` and sends an example JSON web token when __any__ email/password combo is provided.

If we forget to provide an email/password, our API server will return errors like this:

```json
POST "http://localhost:5000/api/sign-in"
```

```json
Status code: 400

{
  "errors": [
    {
      "field": "email",
      "message": "Email is required."
    },
    {
      "field": "password",
      "message": "Password is required."
    }
  ]
}
```

The errors always include a `field` value, so our Elm frontend will be able to highlight the specific input field that is causing the issue.

On the other hand, if we provide an email and password, the `/api/sign-in` endpoint will return a sample token for use for other API requests:

```json
POST "http://localhost:5000/api/sign-in"

{
  "email": "ryan@elm.land",
  "password": "password1234"
}
```

```json
Status code: 200

{
  "token": "ryans-secret-token"
}
```

Let's make our new form handle these two possible JSON responses from the API, and make sure the correct fields are highlighted!

## Calling the Sign In API

Let's make sure the `elm/http` package is installed on our new Elm Land project:

```sh
elm install elm/http
```

### Defining a `Api.SignIn` module

Whenever you're working with a REST API endpoint, we recommend creating a module that takes care of the details. 

Let's create a new file at `src/Api/SignIn.elm` that will expose a `post` function that sends a `POST` request to the `/api/sign-in` function described above:

```elm
module Api.SignIn exposing (Data, post)

import Effect exposing (Effect)
import Http
import Json.Decode
import Json.Encode


{-|
The data we expect if the sign in attempt was successful.
-}
type alias Data =
    { token : String
    }


{-| 
Sends a POST request to our `/api/sign-in` endpoint, which
returns our JWT token if a user was found with that email 
and password.
-}
post :
    { onResponse : Result Http.Error Data -> msg
    , email : String
    , password : String
    }
    -> Effect msg
post options =
    let
        body : Json.Encode.Value
        body =
            Json.Encode.object
                [ ( "email", Json.Encode.string options.email )
                , ( "password", Json.Encode.string options.password )
                ]

        decoder : Json.Decode.Decoder Data
        decoder =
            Json.Decode.map Data
                (Json.Decode.field "token" Json.Decode.string)

        cmd : Cmd msg
        cmd =
            Http.post
                { url = "http://localhost:5000/api/sign-in"
                , body = Http.jsonBody body
                , expect = Http.expectJson options.onResponse decoder
                }
    in
    Effect.sendCmd cmd
```

Let's break down the important parts of this module, that might be new to you even after reading the [REST APIs](./rest-apis) guide that introduces sending HTTP requests with JSON responses:

#### 1. We pass in our form body as a JSON object

```elm {3-9}
-- ...
    let
        body : Json.Encode.Value
        body =
            Json.Encode.object
                [ ( "email", Json.Encode.string options.email )
                , ( "password", Json.Encode.string options.password )
                ]

        -- ...
    in
-- ...
```

The `Json.Encode` module is part of [the elm/json package](https://package.elm-lang.org/packages/elm/json/latest/), and it allows us to serialize Elm values as JSON so they can be sent as strings in our HTML requests. For example, if the user enters the email `"ryan@elm.land"` and the password `"secret123"`, this would be the resulting JSON body encoded by the lines highlighted above:

```json
{ "email": "ryan@elm.land", "password": "secret123" }
```

#### 2. We define a JSON decoder that describes the response we expect

```elm {5-8}
-- ...
    let
        -- ...

        decoder : Json.Decode.Decoder Data
        decoder =
            Json.Decode.map Data
                (Json.Decode.field "token" Json.Decode.string)

        -- ...
    in
-- ...
```

For `/api/sign-in`, we're expecting a JSON response like `{ "token": "???" }`. This JSON decoder describes the names of fields we expect, and what kinds of data are in those fields.

On line 8 of the code snippet above, we're saying _"look for a field named 'token' and expect to find a `String` value there."_

#### 3. We create a HTTP request using `Http.post`

```elm {5-11}
-- ...
    let
        -- ...

        cmd : Cmd msg
        cmd =
            Http.post
                { url = "http://localhost:5000/api/sign-in"
                , body = Http.jsonBody body
                , expect = Http.expectJson options.onResponse decoder
                }
    in
-- ...
```

The `Http.post` function puts our API URL, JSON body, JSON decoder, and the `onResponse` callback function together in one place. This creates a `Cmd msg`, which is Elm's standard way of sending side-effects from a web app. We'll need one final function to convert this `Cmd msg` into the final `Effect msg` the sign-in page is expecting!

#### 4. We convert the `Cmd msg` into an `Effect msg`

```elm {5}
-- ...
    let
        -- ...
    in
    Effect.sendCmd cmd

```

After importing Elm Land's `Effect` module, we can have access to the `Effect.sendCmd` function. This function will convert any `Cmd msg` into an `Effect msg`. 

::: tip "Why not just return a `Cmd msg`?" 

Later in the guide, we'll learn that `Effect msg` is a useful type because it can do _more_ that just send commands. For that reason, Elm Land applications use it by default, rather than the standard `Cmd msg` you'll see in other Elm applications.

:::

### Using our new `Api.SignIn.post` function


Back in `src/Pages/SignIn.elm`, we'll want to update the `UserSubmittedForm` branch in our `update` function to send out an API request:

```elm {3-4,10,21-25,28-36}
module Pages.SignIn exposing (Model, Msg, page)

import Api.SignIn
import Http

-- ...

type Msg
    = ...
    | SignInApiResponded (Result Http.Error Api.SignIn.Data)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        
        -- ...

        UserSubmittedForm ->
            ( { model | isSubmittingForm = True }
            , Api.SignIn.post
                { onResponse = SignInApiResponded
                , email = model.email
                , password = model.password
                }
            )

        SignInApiResponded (Ok { token }) ->
            ( { model | isSubmittingForm = False }
            , Effect.none
            )

        SignInApiResponded (Err httpError) ->
            ( { model | isSubmittingForm = False }
            , Effect.none
            )

-- ...
```

If you try using the sign-in form again in your browser, you'll be able to fill in the fields and submit the form. This time, an HTTP request will be sent to the API running at `http://localhost:5000`, and you will see the button is no longer in the "loading" state.

The only thing left to do is handle the response in both cases: when the sign-in works and when it fails!

## Storing the JSON web token

After we successfully log in, the API gives us a JSON web token (or "JWT") that we can use for future API requests. It's our job to make sure that this token is available on other pages. For that reason, we're going to store the user token in the `Shared.Model`. The `Shared.Model` is available to every page in our application, and the data we store there will be available even when we navigate to other pages in our application.

To get started, we'll need to customize the default `Shared` modules so we can add a field for storing our user token. Elm Land allows us to customize default modules using the `elm-land customize` command. Let's try it out:

```sh
elm-land customize shared
```

Running that command will move 3 new files into your `src` folder:

1. `src/Shared.elm` – Defines the functions to manage the `Shared.Model`
1. `src/Shared/Model.elm` – Defines the data that should be available on every page
1. `src/Shared/Msg.elm` – Defines how the `Shared.Model` can be updated

Let's edit `src/Shared/Model.elm` to conditionally store a user token:

```elm {5-6}
module Shared.Model exposing (Model)


type alias Model =
    { token : Maybe String
    }
```

Because we don't always have a user token, we'll use a `Maybe String` to represent the possibility of the missing value. When we save this file, we should see some errors coming from `src/Shared.elm`. These are letting us know that we need to edit the `init` function to correctly initialize the `Shared.Model`. Let's fix those next:

```elm {7}
module Shared exposing (..)

-- ...

init : Result Json.Decode.Error Flags -> ( Model, Effect Msg )
init flagsResult =
    ( { token = Nothing } 
    , Effect.none
    )

-- ...
```

### Updating the value of `shared.token`

When `Pages.SignIn` gets the API response, it needs to tell the `Shared.Model` that the user token is now available. To make this happen, we're going to define our first custom `Effect msg` that is able to update the value of `shared.token`.

This custom sign-in effect isn't built-in to Elm Land's default `Effect` module, because it's specific to our application. Let's use the `elm-land customize` command again, but this time to customize the `Effect` module:

```
elm-land customize effect
```

Just like before, this will move a new file into your `src` folder. This time around, that new file will be `src/Effect.elm`:

```elm
module Effect exposing
    ( Effect
    , none, batch
    , sendCmd, sendMsg
    , pushRoute, replaceRoute, loadExternalUrl
    , map, toCmd
    )

-- ...
```

This is a high-level view of the existing Effect module, but we'll want to add two new custom effects of our own:

1. `Effect.signIn` – Signs in the current user
1. `Effect.signOut` – Signs out the current user

Let's add them in by defining two new functions in `src/Effect.elm`:

```elm {6,16-18,21-23}
module Effect exposing
    ( Effect
    , none, batch
    , sendCmd, sendMsg
    , pushRoute, replaceRoute, loadExternalUrl
    , signIn, signOut
    , map, toCmd
    )

-- ...


-- SHARED


signIn : { token : String } -> Effect msg
signIn options =
    SendSharedMsg (Shared.Msg.SignIn options)


signIn : Effect msg
signIn =
    SendSharedMsg Shared.Msg.SignOut

-- ...
```

Using the existing `SendSharedMsg` effect, internally available in `src/Effect.elm` we can send any message we like to our `Shared.update` function. This code won't work until we add the new `SignIn` and `SignOut` variants.

Let's edit `src/Shared/Msg.elm` to include these two variants:

```elm {4-6}
module Shared.Msg exposing (Msg(..))


type Msg
    = SignIn { token : String }
    | SignOut
```

And update `src/Shared.elm` to handle the logic for each message:

```elm {3-4,10-22}
module Shared exposing (..)

import Dict
import Route.Path
-- ...

update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        Shared.Msg.SignIn { token } ->
            ( { model | token = Just token }
            , Effect.pushRoute
                { path = Route.Path.Home_
                , query = Dict.empty
                , hash = Nothing
                }
            )

        Shared.Msg.SignOut ->
            ( { model | token = Nothing }
            , Effect.none
            )
```

As an added bonus, the `Shared` module will even redirect users to the `Home_` page after a successful sign-in.

### Sending `Effect.signIn`

Now that our new custom effect is defined, and the logic is handled in our `Shared` modules, let's use it on our sign-in page:

```elm {13}
module Pages.SignIn exposing (Model, Msg, page)

-- ...

update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        
        -- ...

        SignInApiResponded (Ok { token }) ->
            ( { model | isSubmittingForm = False }
            , Effect.signIn { token = token }
            )

        SignInApiResponded (Err httpError) ->
            ( { model | isSubmittingForm = False }
            , Effect.none
            )

-- ...
```

Let's try it out in the web browser. Fill out the form with a valid email address and any password you like, and you should see our application redirect you to the homepage. That's great!

But what happens when a user makes a mistake filling out the form? What about when the API is unavailable or sends an unexpected response? Right now, our Elm application is ignoring both of those important scenarios. Let's handle those sign in errors the right way, so our app is more delightful for our users (and for ourselves later when debugging issues)!

## Extending `Http.Error`

Luckily for us, the `elm/http` package already enumerates all the things that can go wrong with an HTTP request. We don't need to remember all the edge cases, that's what the [`Http.Error` type](https://package.elm-lang.org/packages/elm/http/latest/Http#Error) does for us:

```elm
-- Taken from the official elm/http docs

{-| A request can fail in a couple ways:

- `BadUrl` means you did not provide a valid URL.
- `Timeout` means it took too long to get a response.
- `NetworkError` means the user turned off their wifi, went in a cave, etc.
- `BadStatus` means you got a response back, but the status code indicates failure.
- `BadBody` means you got a response back with a nice status code, but the body of the response was something unexpected. The String in this case is a debugging message that explains what went wrong with your JSON decoder or whatever.

-}
type Error
    = BadUrl String
    | Timeout
    | NetworkError
    | BadStatus Int
    | BadBody String
```