
load helpers


@test "'elm-land server' fails when not run in an Elm Land project folder" {
  run elm-land server
  expectToFail

  expectOutputContains "🌈 Elm Land couldn't find a \"elm-land.json\""
  expectOutputContains "elm-land init my-project"
}

@test "'elm-land server' generates files when run" {
  mkdir -p tests/tmp/hello-world
  cd tests/tmp
  
  run elm-land init hello-world
  cd hello-world

  # If server runs for 3 seconds, we're probably fine
  elm-land server &
  PID=$!

  sleep 3
  kill $PID

  expectFileExists ".elm-land/src/Main.elm"
  expectFileExists ".elm-land/src/Route.elm"
  expectFileExists ".elm-land/src/Pages/NotFound_.elm"

  
  # expectToPass
  # expectOutputContains "http://localhost:1234"

  cd ../..
  rm -r tmp
}


@test "cleanup" {
  cleanupTmpFolder
}