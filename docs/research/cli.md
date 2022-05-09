# Research

Instead of rolling-my-own experience, I looked at popular JS frameworks to learn from how they handle common CLI commands.

Here's what I learned:

## the `init` command

### Nuxt.js (v2)

https://nuxtjs.org/docs/get-started/installation

```
npx create-nuxt-app [folder-name]
```

- If folder name is missing, create in current directory
    - If current directory is NOT empty, then show the user an error and exit
- If folder name is present
    1. Provides prompts
        - Ask "Project name"
        - Ask "Language" (JS/TS)
        - Ask "Package manager" (yarn/npm)
        - Ask "UI Framework"
        - Ask "Nuxt.js modules" (axios/pwa stuff/cms)
        - Ask "Linter"
        - Ask "Testing" (jest/nightwatch)
        - Ask "Rendering mode" (static site / spa)
        - Ask "Hosting" (running node.js/static like netlify)
        - Ask "Development tools" (jsconfig/semantic prs/ dependabot)
        - Asks for "GitHub username"
        - Asks for "VCS" (git/none)
    1. Then they automatically run `npm install`
    1. Clear the terminal, then they print
        - The name of the project
        - The next commands to run for dev
            - `cd my-nuxt-app`
            - `npm run dev`
        - The commands to run for prod
    

### Next.js

```
npx create-next-app@latest
```

- Asks for your project name
- Creates folder for your project
- Automatically knows you are using `npm`
- Says what dependencies it is installing
- Says what dev dependencies it is installing
- Runs `npm install` for you
- Here's the folder we created
- Here are the commands you can run
    - `npm run dev`
    - `npm run build`
    - `npm start`
- Suggests the user run:
  ```
  cd my-react-project
  npm run dev
  ```

### Nuxt.js 3 (Nuxi)

```
npx nuxi init [folder-name]
```

- If folder name is missing, create in current directory
    - If current directory is NOT empty, then show the user an error and exit
- If folder name is present, create a new folder for the project
  - Provides full folder path
  - Says "New project is created!"
  - Says `cd my-project-name`
  - Says run `npm install`
  - Says run `npm run dev`


### Notes
- It's nice to allow users to create new projects in their current folder
    - Elm users are to going to __expect__ this if they're already familiar with `elm init`.
    - (Imagine creating a new folder, running git init, making a README etc)
    - Warning the user if you're going to overwrite a file:
        - "I need to create an elm.json file, but I see there's already one in this folder. May I overwrite it? [y/N]"
- Tell the user the next commands to run:
  - `cd new-folder-name`
  - `npx elm-spa server`