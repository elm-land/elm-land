# Getting started

## Introduction

The goal of _Elm Land_ is to solve common problems folks run into when creating web apps. In order to create real-world applications, there are a few things that should be easy:

1. __Scaling an application__ - Understanding how to organize files, share data between pages, and reuse your application code.
1. __Talking to servers__ - Communicating with REST APIs, GraphQL endpoints, and how to authenticate HTTP requests for those backend APIs.
1. __Working with UI__ - Building components with a solid foundation, solving common CSS layout problems, and learning how to design your UI modules.


## Your first app

If you already have [NodeJS](https://nodejs.org) installed, you can get started with _Elm Land_ using the official CLI tool available on [NPM](https://npmjs.org/elm-land).

Let's start by using the `elm-land init` command to create a new `hello-world` project:

<<< @/snippets/guide/init-input.sh

<code-group>
<code-block title="Terminal output">

<<< @/snippets/guide/init-output.txt

</code-block>
</code-group>



### Running the app <Badge type="warning" text="wip" vertical="middle" />

The _Elm Land_ CLI tool comes with a dev server built-in, so you can run your new project using this command:

<<< @/snippets/guide/server-input.sh

Visiting [http://localhost:1234](http://localhost:1234) in your browser will show you your new web app!
