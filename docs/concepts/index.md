# Concepts


## Introduction

Hello there, and welcome to Elm Land: a framework to help you build reliable web apps.

Elm Land's goal is to provide easy-to-learn conventions, great developer tooling, hands-on guides, and resources for building real world applications. This guide assumes a bit of experience with HTML, CSS, and JavaScript, but __if you're new to Elm, that's _perfect!___

These guides will introduce you to each new concept one step at a time. By the end, we hope you will have learned everything you need to know to build frontend apps with confidence.

If you're learning Elm Land for the first time, we encourage you to join the official [Elm Land Discord](https://join.elm.land) to get help, share your cool projects, and make friends!

## What is Elm Land?

In the JavaScript ecosystem, the idea of an "application framework" is pretty common. In the React community, one popular framework is called __Next.js__. In the Vue.js community, you'll find a similar framework called __Nuxt__.

These frameworks help take care of the common questions you might encounter when getting started with a new project. They also include helpful guides and learning resources throughout your personal journey.

Elm Land is no different! But instead of building apps in React or Vue.js, you'll be using something different: __Elm__!

![A visual showing: "Nuxt" maps to "Vue.js", "Next.js" to "React", "Svelte" to "SvelteKit", and "Elm Land" to "Elm"](./images/frameworks-to-frameworks.jpg)

### Wait, what is "Elm"?

Elm is a __language__ designed for building reliable web applications. Like TypeScript, it can help you catch problems during development before they have an impact on your users.

You can also think of Elm as a __UI framework__, like React or Vue.js. Every Elm application follows the same pattern, known as "The Elm Architecture". Because of this design, the things you learn in Elm Land will translate to _any_ Elm project you work on down the road.

Many folks have success diving right into the ["Getting started"](/guide/) guide, but you might prefer checking out [the official guide](https://guide.elm-lang.org). It's a _wonderful_ resource for learning the fundamental concepts of the Elm language.



## The CLI

The [__Elm Land CLI tool__ is available on NPM](https://www.npmjs.com/package/elm-land), and allows you to create new projects, add pages or layouts, run a development server, and more.

```sh
npm install -g elm-land
```

Having a single CLI command allows you to get up and running fast from your terminal, and easily perform production builds via GitHub Actions or another CI build system.


In [the CLI section](./cli), you'll learn more about how each of the `elm-land` commands work.

## Project structure

Every Elm Land application has a folder structure that looks something like this:

```txt
your-project/
├── elm.json
├── elm-land.json
├── src/
│   └── Pages/
│   └── Layouts/
│   └── Components/
└── static/
    └── main.css
```

Here's a breakdown of what those files and folders are:

1. `elm.json` – Keeps track of your Elm package dependencies.
1. `elm-land.json` - Settings for the Elm Land framework.
1. `src/Pages` – The home for your __page__ files, which correspond to URLs in your app.
1. `src/Layouts` – __Layouts__ allow you to nest pages within common UI.
1. `src/Components` – The place to define buttons, dropdowns, or other __reusable UI__.
1. `static` – A folder for serving "static" assets, like CSS or images, so they are directly available via URL.

In the [Guides](/guide/), you'll see more practical examples of how to use these folders. Let's continue with a simple overview of each of those concepts.

## Pages

Pages are the basic building blocks of your app. In a typical Elm application, you just have one file: `Main.elm`. That file is served on every page request. It's up to the developer to define "URL parsers" to help different URLs match up with the correct files inside the project.

Elm Land has a __file-based routing convention__ that automatically generates that code for you. So if you want a new page at `/hello`, you can create a new file at `src/Pages/Hello.elm`. Elm Land handles the rest!

As you add more features to your app, you pages folder will grow to match all the URLs you care about. After a while, it might look something like this:

```txt
src/
└── Pages/
    ├── Home_.elm
    ├── Settings
    │   ├── Account.elm
    │   └── Notifications.elm
    ├── People.elm
    └── People/
        └── Id_.elm
```

In the [Pages](./pages) section, you'll learn more about the naming conventions for files. (Including why some of those page files have a weird trailing `_` character)!

## Layouts

In the last section, we learned each file in the `src/Pages` folder maps to certain URLs. Most web applications you'll need to build have "layouts" that you want to reuse across pages. 

Elm Land provides the `src/Layouts` folder to allow you to define reusable layouts like "Sidebar" to be used on any page that you want to have a sidebar layout:

![A visual showing the sidebar layout being reused on three pages: Dashboard, Settings, and Person Detail. The layout is not included for the "Sign in" page, suggesting that a layout isn't mandatory for every page](./images/layout-visual.jpg)

By design, every page explicitly opts in to its layout. This means you can easily glance at any page's source code to see which layout, if any, is being used.

In the [Layouts](./layouts) section, you'll learn more about how these files will save you time when building common features for your app.

## Components

By convention, all UI components you make in Elm Land will live in the "Components" folder. A component can be something as simple as a button or as complex as a dropdown that handles keyboard navigation and HTTP requests to an API.

Just like in a JavaScript framework like React or Vue.js, each component you build will have its own file. Here's an example of what your project's component folder might look like:

```txt
src/
└── Components/
    ├── Accordion.elm
    ├── Button.elm
    ├── Dropdown
    │   ├── Autocomplete.elm
    │   └── Multiselect.elm
    └── Modal.elm
```

In the [Components](./components) section, we'll cover the "123s" of making components in Elm. Even if you're an experienced Elm engineer already, definitely check out that section!

## Customizable files

Throughout the documentation, you'll find files that you can customize. Under the hood, Elm Land generates code in the `.elm-land/src` folder. Some of that generated code is useful to change as you continue to build more nuanced features. 

Here are the five customizable files in Elm Land:

1. `Pages.NotFound_` – This __"Not found" page__ is shown when visiting any URL that doesn't map to a page.
1. `Shared` – Allows you to __share data across pages__, like a signed-in user or the current window size.
1. `Effect` – This module allows you to __define custom "side-effects"__ that are specific to your application.
1. `View` – Allows you to __customize the UI library__ used across pages and layouts (Elm UI, Elm CSS, and more!)
1. `Auth` – Defines behavior for pages that should only be visible __when a user is logged in__.

In [the CLI section](./cli), you'll learn how to run `elm-land customize` to work with these pages. Additionally, each of those five customizable files are covered in more detail in this guide!


---

#### __That's it for now!__

You made it through the overview– nice work! If you're ready to learn more Elm Land concepts, the next section will walk through the official Elm Land CLI tool. 

See you there! :wave:

