load helpers

@test "'elm-land build' works with the '01-hello-world' example" {
  cd ../examples/01-hello-world
  run elm-land build
  expectToPass

  expectOutputContains "🌈 Build was successful!"

  rm -r .elm-land elm-stuff dist
  cd ../../cli
}

@test "'elm-land build' works with the '02-pages-and-layouts' example" {
  cd ../examples/02-pages-and-layouts
  run elm-land build
  expectToPass

  expectOutputContains "🌈 Build was successful!"

  rm -r .elm-land elm-stuff dist
  cd ../../cli
}

@test "'elm-land build' works with the '03-user-input' example" {
  cd ../examples/03-user-input
  run elm-land build
  expectToPass

  expectOutputContains "🌈 Build was successful!"

  rm -r .elm-land elm-stuff dist
  cd ../../cli
}

@test "'elm-land build' works with the '04-rest-apis' example" {
  cd ../examples/04-rest-apis
  run elm-land build
  expectToPass

  expectOutputContains "🌈 Build was successful!"

  rm -r .elm-land elm-stuff dist
  cd ../../cli
}

@test "'elm-land build' works with the '05-user-auth' example" {
  cd ../examples/05-user-auth
  run elm-land build
  expectToPass

  expectOutputContains "🌈 Build was successful!"

  rm -r .elm-land elm-stuff dist
  cd ../../cli
}