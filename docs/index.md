---
layout: home
titleTemplate: Reliable web apps for everyone
hero:
  image: 
    src: /images/logo-480.png
    alt: Elm Land logo
  name: "Reliable web apps"
  text: "for everyone."
  tagline: A production-ready framework for building Elm applications. Build your next app with confidence, step by step.
  actions: 
    - text: Get started
      link: /guide/
    - text: Follow for updates
      link: https://twitter.com/elmland_
      theme: alt
features:
- icon: 🌱
  title: Beginners welcome
  details: New to Elm? That's perfect! Elm Land was designed with you in mind. Our guides are here to make you productive, fast!
- icon: 🔋
  title: Batteries included
  details: Comes with a built-in dev server and build tool. Access environment variables, easily work with NPM, TypeScript, add CSS files, and more!
- icon: 📚
  title: Guides & conventions
  details: Elm Land provides clear, consistent guides to help you answer common questions folks have when scaling their apps. You'll be able to leverage years of Elm best practices.
- icon: 🎨
  title: Learn with examples
  details: Are you a visual learner? Check out the "Examples" page, which shows official Elm Land examples alongside real world apps.
- icon: 🪄
  title: File-based routing
  details: Elm Land improves consistency and saves you time. We automatically connect your pages to URLs, using a simple file-naming convention.
- icon: 📦
  title: Easy deployments
  details: Elm Land is designed to be hosted for free on the web as a single-page application. Visit our guides on how to deploy your app with Netlify or Vercel.
footer: Made for you with ❤️
---

<script setup>
import { VPTeamMembers } from 'vitepress/theme'

const foundingSponsors = [
  {
    logo: 'https://lamdera.com/images/lamdera-logo-black.png',
    name: 'Lamdera',
    width: 878,
    height: 141,
    url: 'https://lamdera.com/'
  },
  {
    logo: 'https://blog.cachix.org/img/logo.png',
    name: 'Cachix',
    width: 788,
    height: 261,
    url: 'https://www.cachix.org/'
  }
]

const sponsors = [
  {
    avatar: 'https://www.github.com/pete-murphy.png',
    name: 'Pete Murphy',
    title: '@pete-murphy',
    links: [
      { icon: 'github', link: 'https://github.com/pete-murphy' }
    ]
  },
  {
    avatar: 'https://www.github.com/dbj.png',
    name: 'Dirk Johnson',
    title: '@dbj',
    links: [
      { icon: 'github', link: 'https://github.com/dbj' }
    ]
  },
  {
    avatar: 'https://www.github.com/ianmackenzie.png',
    name: 'Ian Mackenzie',
    title: '@ianmackenzie',
    links: [
      { icon: 'github', link: 'https://github.com/ianmackenzie' }
    ]
  },
  {
    avatar: 'https://www.github.com/alpakaxaxa.png',
    name: '@alpakaxaxa',
    links: [
      { icon: 'github', link: 'https://github.com/alpakaxaxa' }
    ]
  },
  {
    avatar: 'https://www.github.com/dennistruemper.png',
    name: 'Dennis Roch',
    title: '@dennistruemper',
    links: [
      { icon: 'github', link: 'https://github.com/dennistruemper' }
    ]
  },
  {
    avatar: 'https://www.github.com/nathanbraun.png',
    name: 'Nathan Braun',
    title: '@nathanbraun',
    links: [
      { icon: 'github', link: 'https://github.com/nathanbraun' }
    ]
  },
  {
    avatar: 'https://www.github.com/shahnhogan.png',
    name: 'Shahn Hogan',
    title: '@shahnhogan',
    links: [
      { icon: 'github', link: 'https://github.com/shahnhogan' }
    ]
  },
]
</script>

<style>
  :root {
    --vp-home-hero-name-color: mediumseagreen;
  }
  .VPFeatures + div {
    padding: 0 64px;
    margin: 0 auto;
    max-width: 48em;
  }

  .VPFeatures + div h3 {
    font-size: 2rem;
    line-height: 1.2;
    margin-top: 4rem;
    margin-bottom: 1rem;
    font-family: var(--vp-font-family-header);
  }
  .VPTeamMembers {
    margin-top: 2rem;
  }
  .sponsor {
    border-radius: 2rem;
    border: solid 1px;
    padding: 0.5em 1em;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 0.5em;
    transition: border-color 100ms ease-in-out;
  }
  .flex {
    margin: 2rem auto;
    display: flex;
    justify-content: center;
  }

  .flex .icon {
    fill: currentColor;
    height: 20px;
    transition: fill 100ms ease-in-out;
  }

  .sponsor:hover {
    border-color: #cd2e90;
  }
  .sponsor:hover .icon {
    fill: #cd2e90;
  }

  h6 { letter-spacing: 0.05em; text-transform: uppercase; margin-top: 2rem; opacity: 0.75; }
</style>


### 💖 Sponsors

Here are some of the successful companies and wonderful people that make Elm Land possible by supporting the project each month.


<h6>Companies</h6>
<FoundingSponsors :sponsors="foundingSponsors" />

<h6>Individuals</h6>
<VPTeamMembers size="small" :members="sponsors" />



<h3>Want to support Elm Land?</h3>
<br/>

If you'd like to contribute to the health and continuous improvement of the framework, ensure a strong foundation for your business, or be featured on this page– you can support Elm Land via GitHub Sponsors:

<div class="flex">
  <a class="sponsor" href="https://github.com/sponsors/ryannhg/">
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="icon"><path d="M12,22.2c-0.3,0-0.5-0.1-0.7-0.3l-8.8-8.8c-2.5-2.5-2.5-6.7,0-9.2c2.5-2.5,6.7-2.5,9.2,0L12,4.3l0.4-0.4c0,0,0,0,0,0C13.6,2.7,15.2,2,16.9,2c0,0,0,0,0,0c1.7,0,3.4,0.7,4.6,1.9l0,0c1.2,1.2,1.9,2.9,1.9,4.6c0,1.7-0.7,3.4-1.9,4.6l-8.8,8.8C12.5,22.1,12.3,22.2,12,22.2zM7,4C5.9,4,4.7,4.4,3.9,5.3c-1.8,1.8-1.8,4.6,0,6.4l8.1,8.1l8.1-8.1c0.9-0.9,1.3-2,1.3-3.2c0-1.2-0.5-2.3-1.3-3.2l0,0C19.3,4.5,18.2,4,17,4c0,0,0,0,0,0c-1.2,0-2.3,0.5-3.2,1.3c0,0,0,0,0,0l-1.1,1.1c-0.4,0.4-1,0.4-1.4,0l-1.1-1.1C9.4,4.4,8.2,4,7,4z"></path></svg>
    <span>Support Elm Land</span>
  </a>
</div>
