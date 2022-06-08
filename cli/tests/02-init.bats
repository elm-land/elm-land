load helpers


# ELM-LAND INIT

@test "'elm-land init' fails without folder name" {
  run elm-land init
  expectToFail
  expectOutputContains "Please provide a folder name for your new project"
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
  expectFileExists "hello-world/.elm-land/src/ElmLand/Page.elm"

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
  expectOutputContains "please run this command when that folder is empty"

  cd ..
  rm -r tmp
}


@test "cleanup" {
  cleanupTmpFolder
}