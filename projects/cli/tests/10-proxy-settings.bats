load helpers

@test "'21-proxy-settings' example builds successfully" {
  cd ../../examples/21-proxy-settings
  expectElmExampleBuilds
}

@test "'21-proxy-settings' example proxies requests correctly" {
  cd ../../examples/21-proxy-settings

  run elm-land build
  expectToPass

  # Run elm-land server in the background
  elm-land server &
  ELM_LAND_PID=$!

  # Run node ./server.js in the background
  node ./server.js &
  PROXY_PID=$!

  # Wait for server to start
  sleep 3

  run curl -s http://localhost:1234/api/hello-world
  expectOutputEquals "/hello-world"
  
  run curl -s http://localhost:1234/api
  expectOutputEquals "/"

  run curl -s http://localhost:1234/foo
  expectOutputEquals "/foo"

  run curl -s http://localhost:1234/bar
  expectOutputEquals "/bar"

  run curl -s http://localhost:1234/baz
  expectOutputEquals "/baz/quux"

  kill $PROXY_PID
  kill $ELM_LAND_PID

  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}
