load helpers


@test "'elm-land add layout:static' fails without a name" {
  run elm-land add layout:static
  expectToFail

  expectOutputContains "<module-name>"
  expectOutputContains "Here are some examples:"
  expectOutputContains "elm-land add layout:static"
}

@test "'elm-land add layout:static Sidebar' creates a Sidebar layout" {
  mkdir -p tests/tmp
  cd tests/tmp
  
  run elm-land init hello-world
  cd hello-world

  run elm-land add layout:static Sidebar
  expectToPass

  expectOutputContains "added a new layout"
  expectOutputContains "./src/Layouts/Sidebar.elm"

  expectFileExists "src/Layouts/Sidebar.elm"
  expectFileContains "src/Layouts/Sidebar.elm" "module Layouts.Sidebar exposing (layout)"
  expectFileContains "src/Layouts/Sidebar.elm" "layout : { page : View msg } -> View msg"

  cd ../..
  rm -r tmp
}

@test "cleanup" {
  cleanupTmpFolder
}