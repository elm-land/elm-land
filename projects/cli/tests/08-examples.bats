load helpers

@test "'elm-land build' works with the '01-hello-world' example" {
  cd ../../examples/01-hello-world
  run elm-land build
  expectToPass

  expectOutputContains "successfully built"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}

@test "'elm-land build' works with the '02-pages-and-routes' example" {
  cd ../../examples/02-pages-and-routes
  run elm-land build
  expectToPass

  expectOutputContains "successfully built"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}

@test "'elm-land build' works with the '03-user-input' example" {
  cd ../../examples/03-user-input
  run elm-land build
  expectToPass

  expectOutputContains "successfully built"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}

@test "'elm-land build' works with the '04-rest-apis' example" {
  cd ../../examples/04-rest-apis
  run elm-land build
  expectToPass

  expectOutputContains "successfully built"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}

@test "'elm-land build' works with the '05-user-auth' example" {
  cd ../../examples/05-user-auth
  run elm-land build
  expectToPass

  expectOutputContains "successfully built"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}

@test "'elm-land build' works with the '06-query-parameters' example" {
  cd ../../examples/06-query-parameters
  run elm-land build
  expectToPass

  expectOutputContains "successfully built"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}

@test "'elm-land build' works with the '07-layouts' example" {
  cd ../../examples/07-layouts
  run elm-land build
  expectToPass

  expectOutputContains "successfully built"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}

@test "'elm-land build' works with the '08-components' example" {
  cd ../../examples/08-components
  run elm-land build
  expectToPass

  expectOutputContains "successfully built"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}

@test "'elm-land build' works with the '09-error-reporting' example" {
  cd ../../examples/09-error-reporting
  run npm install
  run elm-land build
  expectToPass

  expectOutputContains "successfully built"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}