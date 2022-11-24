load helpers


# ELM-LAND INIT

@test "'elm-land init' fails without folder name" {
  run elm-land init
  expectToFail
  expectOutputContains "init my-cool-app"
}

@test "'elm-land init' hello-world creates a new hello-world project" {

  mkdir -p tests/tmp
  cd tests/tmp

  run elm-land init hello-world
  expectToPass

  expectOutputContains "cd hello-world"
  expectOutputContains "elm-land server"

  expectFileExists "hello-world/elm.json"
  expectFileExists "hello-world/elm-land.json"
  expectFileExists "hello-world/.gitignore"
  expectFileExists "hello-world/src/Pages/Home_.elm"
  expectFileExists "hello-world/.elm-land/src/Main.elm"
  expectFileExists "hello-world/.elm-land/src/View.elm"
  expectFileExists "hello-world/.elm-land/src/Effect.elm"
  expectFileExists "hello-world/.elm-land/src/Shared.elm"
  expectFileExists "hello-world/.elm-land/src/Page.elm"

  cd ..
  rm -r tmp
}

@test "'elm-land init' fails when run on a non-empty directory" {
  mkdir -p tests/tmp/hello-world
  cd tests/tmp

  echo "{}" > hello-world/elm.json
  
  run elm-land init hello-world
  expectToFail
  expectOutputContains "non-empty folder"
  expectOutputContains "no changes have been made"

  cd ..
  rm -r tmp
}


@test "cleanup" {
  cleanupTmpFolder
}