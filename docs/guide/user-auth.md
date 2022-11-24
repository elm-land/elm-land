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

## Requesting an API token

In order to see this working with a real HTTP request, we'll need an example backend that accepts requests! For this example, I've created a simple Node.js server so you can follow along on your own machine. The code for it is available on GitHub here:

https://github.com/elm-land/elm-land/tree/main/examples/05-user-auth/api-server

### How our REST API works

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
  "token": "RYANS_SUPER_SECRET_TOKEN"
}
```

Let's make our new form handle these two possible JSON responses from the API, and make sure the correct fields are highlighted!

## Calling the Sign In API

Let's make sure the `elm/http` package is installed on our new Elm Land project:

```sh
elm install elm/http
```

Back in `src/Pages/SignIn.elm`, we'll want to update the `UserSubmittedForm` branch in our `update` function to send out an API request:

```elm {7-14}
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
        
-- ...

```
