import { join } from 'path'
import { Files } from './files.js'

let generateElmLandFiles = async ({ pages, layouts, router }) => {
  let { Elm } = (await import('../dist/codegen-worker.cjs')).default

  let newFiles = await new Promise((resolve, reject) => {
    // Insert not found page if it hasn't been customized yet
    if (isMissingNotFoundPage(pages)) {
      pages = pages.concat([hardcodedNotFoundPage])
    }

    let app = Elm.Worker.init({
      flags: {
        tag: 'generate',
        data: { pages, layouts, router }
      }
    })
    app.ports.onComplete.subscribe(resolve)
  })

  return newFiles
}

let addNewPage = async ({ kind, url, filepath }) => {
  let { Elm } = (await import('../dist/codegen-worker.cjs')).default

  let hasViewBeenCustomized = await Files.exists(join(process.cwd(), 'src', 'View.elm'))

  let newFiles = await new Promise((resolve, reject) => {
    let app = Elm.Worker.init({
      flags: {
        tag: 'add-page',
        data: {
          hasViewBeenCustomized,
          kind,
          page: { filepath, contents: '' },
          url
        }
      }
    })
    app.ports.onComplete.subscribe(resolve)
  })

  return newFiles
}

let addNewLayout = async ({ moduleSegments }) => {
  let { Elm } = (await import('../dist/codegen-worker.cjs')).default

  let newFiles = await new Promise((resolve, reject) => {
    let app = Elm.Worker.init({
      flags: {
        tag: 'add-layout',
        data: { moduleSegments }
      }
    })
    app.ports.onComplete.subscribe(resolve)
  })

  return newFiles
}

export const Codegen = {
  generateElmLandFiles,
  addNewPage,
  addNewLayout
}

// Not found page

const isMissingNotFoundPage = (pages = []) => {
  let hasNotFoundPage = pages.some(page => page.filepath && page.filepath.length === 1 && page.filepath[0] === 'NotFound_')
  return !hasNotFoundPage
}


const hardcodedNotFoundPage = {
  filepath: ['NotFound_'],
  contents: `module Pages.NotFound_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html exposing (..)
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init () =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "404"
    , body = [ text "Not found" ]
    }
`
}