# 21-tailwind-with-ambient-module-declarations

> Built with [Elm Land](https://elm.land) 🌈

This differs from [`19-tailwindcss`](../19-tailwindcss/) by using
ambient module declarations found in `assets.d.ts` to provide the TypeScript
compiler how to import non-script assets such as a CSS file.

```bash
# Requires Node.js v18+ (https://nodejs.org)
npm install
npx elm-land server
```

## Deploying to production

Elm Land projects are most commonly deployed as static websites.

Please visit [the "Deployment" guide](https://elm.land/guide/deploying) to learn
more about deploying your app for free using Netlify or Vercel.
