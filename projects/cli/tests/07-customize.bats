
load helpers

@test "'elm-land customize' fails without an argument" {

  # Create a sample project
  mkdir -p tests/tmp
  cd tests/tmp
  run elm-land init hello-world
  expectToPass
  cd hello-world

  # Run elm-land customize without an argument
  run elm-land customize
  expectToFail
  expectOutputContains "needs more details"
  expectOutputContains "Here are the commands"

  # Clean up tmp folder
  cd ../..
  rm -r tmp
}

@test "'elm-land customize fart' fails with an invalid argument" {

  # Create a sample project
  mkdir -p tests/tmp
  cd tests/tmp
  run elm-land init hello-world
  expectToPass
  cd hello-world

  # Run elm-land customize without an argument
  run elm-land customize fart
  expectToFail
  expectOutputContains "Here are the commands"

  # Clean up tmp folder
  cd ../..
  rm -r tmp
}

@test "'elm-land customize shared' moves Shared file into src folder" {

  # Create a sample project
  mkdir -p tests/tmp
  cd tests/tmp
  run elm-land init hello-world
  expectToPass
  cd hello-world

  # Run elm-land customize without an argument
  run elm-land customize shared
  expectToPass
  expectOutputContains "3 new files"
  expectOutputContains "./src/Shared.elm"
  expectOutputContains "./src/Shared/Model.elm"
  expectOutputContains "./src/Shared/Msg.elm"

  expectFileExists "src/Shared.elm"
  expectFileExists "src/Shared/Model.elm"
  expectFileExists "src/Shared/Msg.elm"

  # Clean up tmp folder
  cd ../..
  rm -r tmp
}

@test "'elm-land add page' uses 'View.fromString' if the View module is customized" {

  # Create a new project
  mkdir -p tests/tmp
  cd tests/tmp
  run elm-land init hello-world
  expectToPass
  cd hello-world

  # Generating a page before customizing View.elm
  # should use the standard { title = "...", body = [...] }
  run elm-land add page /test
  expectFileExists "src/Pages/Test.elm"
  expectFileContains "src/Pages/Test.elm" "{ title = "

  # Customize the View module
  run elm-land customize view
  expectToPass
  expectFileExists "src/View.elm"

  # Generate a page after customizing View.elm
  # should use the 'View.fromString' function defined by the user
  run elm-land add page /test
  expectFileExists "src/Pages/Test.elm"
  expectFileContains "src/Pages/Test.elm" "View.fromString"

  # Clean up tmp folder
  cd ../..
  rm -r tmp
}

@test "'elm-land customize view' customizes the View module using the default variant" {

  # Create a new project
  mkdir -p tests/tmp
  cd tests/tmp
  run elm-land init hello-world
  expectToPass
  cd hello-world

  run elm-land customize view
  expectFileExists "src/View.elm"
  expectFileContains "src/View.elm" "import Html exposing (Html)"

  # Clean up tmp folder
  cd ../..
  rm -r tmp
}

@test "'elm-land customize view:elm-css' customizes the View module using elm-css variant" {

  # Create a new project
  mkdir -p tests/tmp
  cd tests/tmp
  run elm-land init hello-world
  expectToPass
  cd hello-world

  run elm-land customize view:elm-css
  expectFileExists "src/View.elm"
  expectFileContains "src/View.elm" "import Html.Styled"

  # Clean up tmp folder
  cd ../..
  rm -r tmp
}

@test "'elm-land customize view:elm-ui' customizes the View module using elm-ui variant" {

  # Create a new project
  mkdir -p tests/tmp
  cd tests/tmp
  run elm-land init hello-world
  expectToPass
  cd hello-world

  run elm-land customize view:elm-ui
  expectFileExists "src/View.elm"
  expectFileContains "src/View.elm" "import Element"

  # Clean up tmp folder
  cd ../..
  rm -r tmp
}

@test "default View module is restored after customization and removal of custom View module" {

  # Create a new project
  mkdir -p tests/tmp
  cd tests/tmp
  run elm-land init hello-world
  expectToPass
  cd hello-world

  run elm-land customize view:elm-css
  rm src/View.elm
  run elm-land generate
  expectFileDoesNotExist "src/View.elm"
  expectFileExists ".elm-land/src/View.elm"
  expectFileContains ".elm-land/src/View.elm" "import Html exposing (Html)"

  # Clean up tmp folder
  cd ../..
  rm -r tmp
}

@test "cleanup" {
  cleanupTmpFolder
}
