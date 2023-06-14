
load helpers

@test "'elm-land build' works with hello world example" {
  cd ../../examples/01-hello-world
  run elm-land build
  expectToPass

  expectOutputContains "success"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}

@test "'elm-land build' still works after customizing a file" {
  cd ../../examples/01-hello-world

  run elm-land customize effect
  expectToPass

  run elm-land build
  expectToPass

  expectOutputContains "success"

  rm -r .elm-land elm-stuff dist src/Effect.elm
  cd ../../projects/cli
}

@test "'elm-land build' still works after creating a top-level catch-all page" {
  cd ../../examples/01-hello-world

  run elm-land add page "/*"
  expectToPass

  run elm-land build
  expectToPass

  expectOutputContains "success"

  rm -r .elm-land elm-stuff dist src/Pages/ALL_.elm
  cd ../../projects/cli
}

@test "cleanup" {
  cleanupTmpFolder
}