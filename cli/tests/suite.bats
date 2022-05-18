# setup_suite () {
  # npm run setup
  # npm link
  # mkdir -p tests/tmp
  # cd tests/tmp
  # >&3
# }

# HELPERS

function expectToPass {
  [ "$status" -eq 0 ]
}

function expectToFail {
  [ "$status" -eq 1 ]
}

function expectFileExists {
  test -f $1
  expectToPass
}

function expectOutputContains {
  [[ ${output} == *$1* ]]
}

function printLastOutput {
  ${output} >&3
}


# TEST SUITE

@test "can run elm-land" {
  run elm-land
  expectOutputContains "🌈 Welcome to Elm Land!"
}


@test "elm-land banana warns user of unknown command" {
  run elm-land banana
  expectToFail
  expectOutputContains "❗️ We didn't recognize the \"banana\" command"
}


@test "elm-land init fails without folder name" {
  run elm-land init
  expectToFail
  expectOutputContains "Please provide a folder name for your new project"
}

@test "elm-land init hello-world creates a new hello-world project" {

  # TODO: Move this into setupSuite
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

  # TODO: Move this into teardownSuite
  cd ..
  rm -r tmp
}

@test "elm-land init fails when run on a non-empty directory" {
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