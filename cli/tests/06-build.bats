
load helpers

@test "'elm-land build' works with hello world example" {
  cd ../examples/01-hello-world
  run elm-land build
  expectToPass

  expectOutputContains "🌈 Build was successful!"

  rm -r .elm-land elm-stuff dist
  cd ../../cli
}

@test "'elm-land build' still works after customizing a file" {
  cd ../examples/01-hello-world

  run elm-land customize effect
  expectToPass

  run elm-land build
  expectToPass

  expectOutputContains "🌈 Build was successful!"

  rm -r .elm-land elm-stuff dist src/Effect.elm
  cd ../../cli
}

@test "cleanup" {
  cleanupTmpFolder
}