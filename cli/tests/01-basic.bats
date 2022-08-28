load helpers

@test "can run 'elm-land'" {
  run elm-land
  expectOutputContains "Welcome to Elm Land!"
}

@test "'elm-land banana' warns user of unknown command" {
  run elm-land banana
  expectToFail
  expectOutputContains "couldn't find"
  expectOutputContains "Here are the available commands"
}