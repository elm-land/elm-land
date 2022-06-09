
load helpers

@test "'elm-land build' works with hello world example" {
  cd ../examples/01-hello-world
  run elm-land build
  expectToPass

  expectOutputContains "🌈 Build was successful!"

  cd ../../cli
}

@test "cleanup" {
  cleanupTmpFolder
}