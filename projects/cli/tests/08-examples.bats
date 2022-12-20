load helpers

@test "'01-hello-world' example builds successfully" {
  cd ../../examples/01-hello-world
  expectElmExampleBuilds
}

@test "'02-pages-and-routes' example builds successfully" {
  cd ../../examples/02-pages-and-routes
  expectElmExampleBuilds
}

@test "'03-user-input' example builds successfully" {
  cd ../../examples/03-user-input
  expectElmExampleBuilds
}

@test "'04-rest-apis' example builds successfully" {
  cd ../../examples/04-rest-apis
  expectElmExampleBuilds
}

@test "'05-user-auth' example builds successfully" {
  cd ../../examples/05-user-auth
  expectElmExampleBuilds
}

@test "'06-query-parameters' example builds successfully" {
  cd ../../examples/06-query-parameters
  expectElmExampleBuilds
}

@test "'07-working-with-js' example builds successfully" {
  cd ../../examples/07-working-with-js
  run npm install
  expectElmExampleBuilds
}

# @test "'10-typescript-interop' example builds successfully" {
#   cd ../../examples/10-typescript-interop
#   run elm-land build
#   expectToPass

#   expectOutputContains "successfully built"

#   rm -r .elm-land elm-stuff dist
#   cd ../../projects/cli
# }

# @test "'11-error-reporting' example builds successfully" {
#   cd ../../examples/11-error-reporting
#   run npm install
#   expectElmExampleBuilds
# }

# @test "'12-elm-ui-and-more' example builds successfully" {
#   cd ../../examples/12-elm-ui-and-more
#     expectElmExampleBuilds
# }

# @test "'13-custom-404-pages' example builds successfully" {
#   cd ../../examples/13-custom-404-pages
#   expectElmExampleBuilds
# }

# @test "'14-assets-and-static-files' example builds successfully" {
#   cd ../../examples/14-assets-and-static-files
#   expectElmExampleBuilds
# }