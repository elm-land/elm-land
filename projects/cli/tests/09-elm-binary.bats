bats_require_minimum_version 1.5.0

load helpers

@test "'elm-land build' should fail if elm-land is not globally installed" {
  npm rm -g elm-land

  cd ../../examples/01-hello-world
  run -127 elm-land build
  expectToFail
}

@test "'elm-land build' should pass if elm-land is globally installed with npm" {
  npm link

  cd ../../examples/01-hello-world
  run elm-land build
  expectToPass

  # Cleanup
  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}

@test "'elm-land build' should pass even if elm is globally installed with npm" {
  npm link
  npm install -g elm --force

  cd ../../examples/01-hello-world
  run elm-land build
  expectToPass

  # Cleanup
  rm -r .elm-land elm-stuff dist
  cd ../../projects/cli
}

@test "'elm-land build' should pass if elm-land is locally installed with npm" {
  npm rm -g elm-land
  npm pack

  cp -r ../../examples/01-hello-world ../../examples/01-local-hello
  cd ../../examples/01-local-hello
  echo '{ "dependencies": { "elm-land": "file:../../projects/cli/elm-land-0.19.4.tgz" } }' > package.json
  npm install

  run npx elm-land build
  expectToPass

  # Cleanup
  cd ..
  rm -r 01-local-hello
  cd ../projects/cli
}

@test "'elm-land build' should pass if elm-land is locally installed with yarn" {
  npm rm -g elm-land
  npm pack

  cp -r ../../examples/01-hello-world ../../examples/01-local-hello
  cd ../../examples/01-local-hello
  echo '{ "dependencies": { "elm-land": "file:../../projects/cli/elm-land-0.19.4.tgz" } }' > package.json
  npm install -g yarn
  yarn

  run yarn elm-land build
  expectToPass

  # Cleanup
  cd ..
  rm -r 01-local-hello
  cd ../projects/cli
}

@test "'elm-land build' should pass if elm-land is locally installed with pnpm" {
  npm rm -g elm-land
  npm pack

  cp -r ../../examples/01-hello-world ../../examples/01-local-hello
  cd ../../examples/01-local-hello
  echo '{ "dependencies": { "elm-land": "file:../../projects/cli/elm-land-0.19.4.tgz" } }' > package.json
  npm install -g pnpm
  pnpm install

  run npx elm-land build
  expectToPass

  # Cleanup
  cd ..
  rm -r 01-local-hello
  cd ../projects/cli
}

@test "reinstall elm-land" {
  npm link
}
