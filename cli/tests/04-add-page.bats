load helpers


@test "'elm-land add' fails without 'page' subcommand" {
  run elm-land add
  expectToFail

  expectOutputContains "elm-land add page"
}

@test "'elm-land add page' fails without a URL" {
  run elm-land add page
  expectToFail

  expectOutputContains "command is missing a URL"
  expectOutputContains "elm-land add page /sign-in"
}

@test "'elm-land add page /sign-in' fails when not run in an Elm Land project folder" {
  run elm-land add page /sign-in
  expectToFail

  expectOutputContains "🌈 Elm Land couldn't find a \"elm-land.json\""
  expectOutputContains "elm-land init my-project"
}

@test "'elm-land add page /sign-in' creates a SignIn page" {
  mkdir -p tests/tmp
  cd tests/tmp
  
  run elm-land init hello-world
  cd hello-world

  run elm-land add page /sign-in
  expectToPass

  expectOutputContains "New page added"
  expectOutputContains "SignIn.elm"

  expectFileExists "src/Pages/SignIn.elm"
  expectFileContains "src/Pages/SignIn.elm" "module Pages.SignIn exposing (page)"
  expectFileContains "src/Pages/SignIn.elm" "page : Html.Html msg"

  cd ../..
  rm -r tmp
}


@test "'elm-land add page /profile/:username' creates a Profile/Username_ page" {
  mkdir -p tests/tmp
  cd tests/tmp
  
  run elm-land init hello-world
  cd hello-world

  run elm-land add page /profile/:username
  expectToPass

  expectOutputContains "New page added"
  expectOutputContains "Profile/Username_.elm"

  expectFileExists "src/Pages/Profile/Username_.elm"
  expectFileContains "src/Pages/Profile/Username_.elm" "module Pages.Profile.Username_ exposing (page)"
  expectFileContains "src/Pages/Profile/Username_.elm" "page : { username : String } -> Html.Html msg"

  cd ../..
  rm -r tmp
}


@test "cleanup" {
  cleanupTmpFolder
}