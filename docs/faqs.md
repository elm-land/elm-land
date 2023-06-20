---
outline: deep
---

# FAQs

These are a few questions that have come up in the [Elm Land Community Discord](https://join.elm.land). 

If you have a question that isn't answered here, be sure to let us know in the `#beginners` or `#general` channel. We'd be happy to provide help there, or make the answer easier to discover from this website.

## "What's next for Elm Land?"

We have [a public roadmap on GitHub](https://github.com/elm-land/elm-land/wiki/Roadmap) that gets updated after each release. If you're using Elm Land, and have an idea for how to improve the framework, please let us know! You can post your suggestion in the `#suggest-a-feature` channel of the [official Elm Land Discord](https://join.elm.land).

Many of the more recent features have come from users reporting on their experiences using Elm Land in practice.

## "Does Elm Land support server-side rendering?"

Elm Land focuses on creating and deploying __single-page applications__. This helps keep hosting costs low or, in most cases, completely free!

It also eliminates complexity during development. Understanding why some parts of your app render on the server, and others in the browser, isn't always easy.

Because we only support client-side rendering, Elm Land is a great choice for "web applications". For example, if your app is behind a sign-in page, SEO doesn't matter as much. 

If you are creating "websites", like this one, we recommend using a tool that better fits the problem at hand.

## "How does Elm Land compare to elm-pages?"

Elm Land is also a framework like [elm-pages](https://elm-pages.com). When you use Elm Land, you're writing standard Elm code that runs client-side in your web browser. Unlike elm-pages, Elm Land doesn't extend the Elm platform, have build time data fetching, or any features for rendering meta tags or handling SEO. For that reason, Elm Land is not a good fit for making a blog or personal website.

Elm Land is designed for applications that don't have per-page SEO needs. If you are building a web app that is behind a sign-in screen, then Elm Land is focused on that use case! The latest version of elm-pages is more flexible, and can build everything from static websites to SSR web applications that run without JavaScript enabled.

If you're unsure which to use, I recommend trying both out and seeing which framework matches your needs!

## "How does Elm Land compare to elm-spa?"

Elm Land is the successor of [elm-spa](https://elm-spa.dev), and was written by [the same person](https://github.com/ryannhg). Although many of the values are the same, Elm Land was redesigned to be more than scaffolding a new project and handling URL routing. Elm Land cares about the full experience of building a web application.

For that reason, Elm Land has a more powerful dev server, more guides and conventions around building apps, and even it's own VS code plugin to ensure a nice editor experience. In the future, Elm Land will also have plugins that are designed to work well together. 

The goal is to provide web developers with one simple way to build Elm apps that works well!

