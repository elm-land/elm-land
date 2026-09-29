load helpers

setup_file() {
  npm install --global elm
  npm link
}

teardown_file() {
  npm uninstall --global elm-land
  npm uninstall --global elm
}

@test "can run 'elm-land'" {
  run elm-land
  expectOutputContains "Welcome to Elm Land!"
}

@test "'elm-land banana' warns user of unknown command" {
  run elm-land banana
  expectToFail
  expectOutputContains "couldn't find"
  expectOutputContains "Commonly used commands"
}

