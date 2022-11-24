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

@test "'elm-land build' works with the '06-components' example" {
  cd ../../examples/06-components
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

@test "'elm-land build' works with the '08-query-parameters' example" {
  cd ../../examples/08-query-parameters
  run elm-land build
  expectToPass

  expectOutputContains "successfully built"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}

@test "'elm-land build' works with the '09-javascript-interop' example" {
  cd ../../examples/09-javascript-interop
  run elm-land build
  expectToPass

  expectOutputContains "successfully built"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}

@test "'elm-land build' works with the '10-typescript-interop' example" {
  cd ../../examples/10-typescript-interop
  run elm-land build
  expectToPass

  expectOutputContains "successfully built"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}

@test "'elm-land build' works with the '11-error-reporting' example" {
  cd ../../examples/11-error-reporting
  run npm install
  run elm-land build
  expectToPass

  expectOutputContains "successfully built"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}

@test "'elm-land build' works with the '12-elm-ui-and-more' example" {
  cd ../../examples/12-elm-ui-and-more
  run elm-land build
  expectToPass

  expectOutputContains "successfully built"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}

@test "'elm-land build' works with the '13-custom-404-pages' example" {
  cd ../../examples/13-custom-404-pages
  run elm-land build
  expectToPass

  expectOutputContains "successfully built"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}

@test "'elm-land build' works with the '14-assets-and-static-files' example" {
  cd ../../examples/14-assets-and-static-files
  run elm-land build
  expectToPass

  expectOutputContains "successfully built"

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}