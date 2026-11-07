
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


@test "'elm-land generate' works with hello world example" {
  cd ../../examples/01-hello-world
  run elm-land generate
  expectToPass

  expectOutputContains "success"

  rm -r .elm-land
  cd ../../projects/cli
}

@test "'elm-land build' explains how to upgrade a project made for an older Elm" {
  mkdir -p tests/tmp
  cd tests/tmp
  run elm-land init old-elm-version
  cd old-elm-version
  sed -i.bak 's/"elm-version": "0.19.3"/"elm-version": "0.19.1"/' elm.json

  run elm-land build
  expectToFail

  expectOutputContains "Elm version"
  expectOutputContains '"elm-version": "0.19.3"'

  cd ../../..
}

@test "cleanup" {
  cleanupTmpFolder
}