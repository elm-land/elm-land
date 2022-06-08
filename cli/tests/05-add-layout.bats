load helpers


@test "'elm-land add layout' fails without a name" {
  run elm-land add layout
  expectToFail

  expectOutputContains "missing a name"
  expectOutputContains "elm-land add layout Sidebar"
}

@test "'elm-land add layout Sidebar' creates a Sidebar layout" {
  mkdir -p tests/tmp
  cd tests/tmp
  
  run elm-land init hello-world
  cd hello-world

  run elm-land add layout Sidebar
  expectToPass

  expectOutputContains "New layout added"
  expectOutputContains "Sidebar.elm"

  expectFileExists "src/Layouts/Sidebar.elm"
  expectFileContains "src/Layouts/Sidebar.elm" "module Layouts.Sidebar exposing (layout)"
  expectFileContains "src/Layouts/Sidebar.elm" "layout : { page : View msg } -> View msg"

  cd ../..
  rm -r tmp
}

@test "cleanup" {
  cleanupTmpFolder
}