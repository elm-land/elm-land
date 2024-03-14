# Elm Land

 [![@elm-land/cli](https://github.com/elm-land/elm-land/actions/workflows/cli.js.yml/badge.svg?)](https://github.com/elm-land/elm-land/actions/workflows/cli.js.yml) [![@elm-land/graphql](https://github.com/elm-land/elm-land/actions/workflows/graphql.js.yml/badge.svg?)](https://github.com/elm-land/elm-land/actions/workflows/graphql.js.yml)

[![Elm Land: Reliable web apps for everyone](https://github.com/elm-land/elm-land/raw/main/elm-land-banner.jpg)](https://elm.land)

[![Latest NPM version](https://badgen.net/npm/v/elm-land)](https://npmjs.com/package/elm-land) [![BSD-3 Clause](https://img.shields.io/github/license/elm-land/elm-land?color=333)](https://github.com/elm-land/elm-land/blob/main/LICENSE)

[![Discord](https://badgen.net/discord/members/vnmYFfySbH?icon=discord&label)](https://join.elm.land) [![Twitter](https://badgen.net/badge/icon/twitter?icon=twitter&label&color=00acee)](https://twitter.com/elmland_) [![GitHub](https://badgen.net/badge/icon/github?icon=github&label&color=4078c0)](https://www.github.com/elm-land/elm-land) 

## Introduction

Welcome to [Elm Land](https://elm.land), an application framework that helps you build reliable web applications using the [Elm](https://elm-lang.org) programming language. 

Inspired by projects like [Nuxt](https://nuxt.com), [Next.js](https://nextjs.org), and [Ruby on Rails](https://rubyonrails.org/), Elm Land's goal is make you feel productive fast– especially if you're completely new to Elm.

We take care of the developer tooling, conventions, and learning resources so you can focus on building your next web app with confidence.

__Ready to get started?__ Your adventure begins at https://elm.land/guide

---

## Exploring this codebase

Elm Land is open source and free to use. The code for this GitHub project is broken down into smaller projects within one "monorepo".

### __[@elm-land/cli](./projects/cli/)__

The CLI tool, available at [npmjs.org/elm-land](https://npmjs.org/elm-land). This includes `elm-land build`, `elm-land server`, and other commands run from the terminal.

### __[@elm-land/www](./docs/)__

The official website, including guides and examples, available at [elm.land](https://elm.land).

### __[@elm-land/graphql](./projects/graphql/)__ 

Write GraphQL code and we'll generate the Elm code for you! (Available via [npm](https://npmjs.org/@elm-land/graphql))

### __[@elm-land/codegen](./projects/tooling/codegen/)__ 

A tiny codegen library used internally by Elm Land to generate Elm code!
