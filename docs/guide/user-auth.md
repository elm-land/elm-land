# User authentication

### What we'll learn

- How to make a sign-in form
- How to store a JWT fetched from a REST API
- How to redirect when a page should only be seen by signed-in users

<BrowserWindow src="/images/guide/user-auth.gif" alt="Demo of sign-in flow" />


Some applications require a signed-in user to render certain pages. For example, your app's `Dashboard` page should only be seen by folks who have signed in. In contrast, there are pages like the `SignIn` page that should be available even for signed-out users.

This guide will walk you through how to build a complete sign-in process for a REST API that returns JSON web tokens (JWTs). Here are the things we'll make together:

1. Creating a sign-in page and adding a form
1. Handling sign-in error messages
1. Redirecting to the Dashboard page after a successful login
1. Persisting user tokens with LocalStorage, so they are available after refresh
1. Handling redirects from pages that require signed-in users

To get started, let's create a new Elm Land project using the CLI:

```sh
npx elm-land init user-auth
```

## Creating a sign-in page

We can use the CLI to create a new page at `/sign-in`:

```sh
npx elm-land add page /sign-in
```

Now that we have a sign-in page, let's run the dev server:

```sh
npx elm-land server
```

Opening `http://localhost:1234/sign-in` in a web browser should show us a screen that looks like this:

![A screenshot of a webpage reading "/sign-in"](./user-auth/01-sign-in-page.png)

## Adding a form

To make our sign-in form look nice, let's use a CSS framework called [Bulma](https://bulma.io).

We can add the Bulma CSS by editing the `./elm-land.json` file at the root of the project:


```json{6-8}
{
  "app": {
    "env": [],
    "html": {
      ...
      "link": [
        { "rel": "stylesheet", "href": "https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css" }
      ]
    }
  }
}
```

Let's update `src/Pages/SignIn.elm` to use the following code in our `view` function instead of the default "/sign-in" message.

This will involve a few steps:

1. __Updating our imports__
2. __Initializing our form__ (in our `INIT` section)
3. __Handling form updates from the UI__ (in our `UPDATE` section)
4. __Adding in some Bulma HTML__ (in our `VIEW` section) 

###  1. Updating our imports

```elm
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
```

### 2. Initializing our form

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


### 3. Handling updates from the UI

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

### 4. Adding in some Bulma HTML

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

Once you have copied those snippets into your `SignIn.elm` page, here's what you should see in the browser:

![A sign-in form with an email and password, which shows a loading spinner when submitted](./user-auth/02-form.gif)

The form looks great, but submitting it doesn't actually send an API request to a server. As we saw earlier in the `update` function, when a user submits the form it just sets `isSubmitting` to `True`.

The next step will involve talking to an actual REST API to get a user token.

## Requesting a user token on form submit

In order to request a user token, we'll need an example backend API to make HTTP requests to. I've created a simple Node.js server if you are following along on your own machine.

The code for it is available here:
