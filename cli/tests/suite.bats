
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
  echo $output >&3
}



# TEST SUITE


@test "can run 'elm-land'" {
  run elm-land
  expectOutputContains "🌈 Welcome to Elm Land!"
}


@test "'elm-land banana' warns user of unknown command" {
  run elm-land banana
  expectToFail
  expectOutputContains "❗️ We didn't recognize the \"banana\" command"
}



# ELM-LAND INIT


@test "'elm-land init' fails without folder name" {
  run elm-land init
  expectToFail
  expectOutputContains "Please provide a folder name for your new project"
}

@test "'elm-land init' hello-world creates a new hello-world project" {

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



# ELM-LAND SERVER


@test "'elm-land server' fails when not run in an Elm Land project folder" {
  run elm-land server
  expectToFail

  expectOutputContains "🌈 Elm Land couldn't find a \"elm-land.json\""
  expectOutputContains "elm-land init my-project"
}

@test "'elm-land server' doesn't crash on a new project" {
  mkdir -p tests/tmp/hello-world
  cd tests/tmp
  
  run elm-land init hello-world
  cd hello-world

  # If server runs for 3 seconds, we're probably fine
  elm-land server &
  PID=$!

  sleep 3
  kill $PID
  
  # expectToPass
  # expectOutputContains "http://localhost:1234"

  cd ../..
  rm -r tmp
}



# ELM-LAND ADD PAGE


@test "'elm-land add' fails without 'page' subcommand" {

  run elm-land add
  expectToFail

  expectOutputContains "elm-land add page"
}

@test "'elm-land add page' fails without a URL" {

  run elm-land add page
  expectToFail

  expectOutputContains "command is missing a URL"
  expectOutputContains "elm-land add page /sign-in"
}

@test "'elm-land add page /sign-in' fails when not run in an Elm Land project folder" {

  run elm-land add page /sign-in
  expectToFail

  expectOutputContains "🌈 Elm Land couldn't find a \"elm-land.json\""
  expectOutputContains "elm-land init my-project"
}

@test "'elm-land add page /sign-in' creates a SignIn page" {
  mkdir -p tests/tmp
  cd tests/tmp
  
  run elm-land init hello-world
  cd hello-world

  run elm-land add page /sign-in
  expectToPass

  expectOutputContains "New page added"
  expectOutputContains "SignIn.elm"

  expectFileExists "src/Pages/SignIn.elm"

  cd ../..
  rm -r tmp
}

@test "'elm-land add page /people/:username' creates a People/Username_ page" {
  mkdir -p tests/tmp
  cd tests/tmp
  
  run elm-land init hello-world
  cd hello-world

  run elm-land add page /people/:username
  expectToPass

  expectOutputContains "New page added"
  expectOutputContains "People/Username_.elm"

  expectFileExists "src/Pages/People/Username_.elm"

  cd ../..
  rm -r tmp
}
