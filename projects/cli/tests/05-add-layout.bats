load helpers


@test "'elm-land add layout' fails without a name" {
  run elm-land add layout
  expectToFail

  expectOutputContains "<module-name>"
  expectOutputContains "Here are some examples:"
  expectOutputContains "elm-land add layout"
}

@test "'elm-land add layout 1234' fails with a bad name" {
  mkdir -p tests/tmp
  cd tests/tmp
  
  run elm-land init hello-world
  cd hello-world

  run elm-land add layout 1234
  expectToFail

  expectOutputContains "Layout names need to start with"
  expectOutputContains "Here are some examples:"
  expectOutputContains "elm-land add layout"

  cd ../..
  rm -r tmp
}

@test "'elm-land add layout Sidebar' creates a Sidebar layout" {
  mkdir -p tests/tmp
  cd tests/tmp
  
  run elm-land init hello-world
  cd hello-world

  run elm-land add layout Sidebar
  expectToPass

  expectOutputContains "added a new layout"
  expectOutputContains "./src/Layouts/Sidebar.elm"

  expectFileExists "src/Layouts/Sidebar.elm"
  expectFileContains "src/Layouts/Sidebar.elm" "module Layouts.Sidebar exposing (Model, Msg, Props, layout)"
  expectFileContains "src/Layouts/Sidebar.elm" "layout :"

  cd ../..
  rm -r tmp
}

@test "'elm-land add layout Sidebar.WithTabs' creates a nested layout" {
  mkdir -p tests/tmp
  cd tests/tmp
  
  run elm-land init hello-world
  cd hello-world

  run elm-land add layout Sidebar.WithTabs
  expectToPass

  expectOutputContains "added a new layout"
  expectOutputContains "./src/Layouts/Sidebar/WithTabs.elm"

  expectFileExists "src/Layouts/Sidebar/WithTabs.elm"
  expectFileContains "src/Layouts/Sidebar/WithTabs.elm" "module Layouts.Sidebar.WithTabs exposing (Model, Msg, Props, layout)"
  expectFileContains "src/Layouts/Sidebar/WithTabs.elm" "layout :"

  cd ../..
  rm -r tmp
}

@test "lowercase layout names are automatically capitalized" {
  mkdir -p tests/tmp
  cd tests/tmp
  
  run elm-land init hello-world
  cd hello-world

  run elm-land add layout lowercase
  expectToPass

  expectOutputContains "added a new layout"
  expectOutputContains "./src/Layouts/Lowercase.elm"

  expectFileExists "src/Layouts/Lowercase.elm"

  cd ../..
  rm -r tmp
}

@test "cleanup" {
  cleanupTmpFolder
}