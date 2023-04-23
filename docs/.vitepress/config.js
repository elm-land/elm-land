const version = '0.18.2'

const sidebar = [
  {
    text: 'Guides',
    items: [
      { text: 'Getting started', link: '/guide/' },
      { text: 'Pages and routes', link: '/guide/pages-and-routes' },
      { text: 'User input', link: '/guide/user-input' },
      { text: 'REST APIs', link: '/guide/rest-apis' },
      { text: 'User authentication', link: '/guide/user-auth' },
      // { text: 'Components', link: '/guide/components' },
      // { text: 'Layouts', link: '/guide/layouts' },
      // { text: 'Query parameters', link: '/guide/query-parameters' },
      { text: 'Working with JavaScript', link: '/guide/working-with-js' },
      // { text: 'TypeScript', link: '/guide/typescript' },
      // { text: 'CSS, assets, and static files', link: '/guide/assets-and-static-files' },
      // { text: 'Elm UI and Elm CSS', link: '/guide/elm-ui-and-views' },
      // { text: 'Custom 404 pages', link: '/guide/custom-404-pages' },
      // { text: 'Error reporting', link: '/guide/error-reporting' },
      { text: 'Deploying to production', link: '/guide/deploying' },
    ]
  },
  {
    text: 'Concepts',
    items: [
      { text: 'Overview', link: '/concepts/' },
      { text: 'The CLI', link: '/concepts/cli' },
      { text: 'elm-land.json', link: '/concepts/elm-land-json' },
      { text: 'Pages', link: '/concepts/pages' },
      { text: 'Layouts', link: '/concepts/layouts' },
      { text: 'Components', link: '/concepts/components' },
      { text: 'Shared', link: '/concepts/shared' },
      { text: 'Effects', link: '/concepts/effects' },
      { text: 'View', link: '/concepts/view' },
      { text: 'Auth', link: '/concepts/auth' },
      { text: 'Custom 404 pages', link: '/concepts/404' },
      { text: 'Routes', link: '/concepts/routes' },
    ]
  },
  {
    text: "Other resources"
    , items: [
      { text: 'FAQs', link: '/faqs' }
    ]
  }
]

export default {
  title: 'Elm Land',
  description: 'Reliable web apps for everyone. A production-ready framework for building Elm applications. Build your next app with confidence, step by step.',
  head: [
    ['link', { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Fira+Code:wght@500&family=Lora:wght@600&family=Nunito+Sans:ital,wght@0,400;0,700;1,400;1,700&display=swap' }],
    ['link', { rel: 'icon', href: '/images/logo-256.png' }],
  ],

  markdown: {
    lineNumbers: true,
    theme: 'one-dark-pro'
  },

  themeConfig: {
    logo: '/images/logo-256.png',
    nav: [
      { text: 'Guide', link: '/guide/' },
      { text: 'Concepts', link: '/concepts/' },
      { text: 'News', link: '/news/' },
      {
        text: `v${version}`,
        items: [
          { text: 'NPM', link: `https://www.npmjs.com/package/elm-land/v/${version}` },
          { text: 'GitHub', link: `https://github.com/elm-land/elm-land/releases/tag/v${version}` },
          // { text: `About this release`, link: `/blog/releases/${version}` }
        ]
      }
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/elm-land/elm-land' },
      { icon: 'twitter', link: 'https://twitter.com/elmland_' },
      { icon: 'discord', link: 'https://join.elm.land' }
    ],
    sidebar: {
      '/guide/': sidebar,
      '/concepts/': sidebar,
      '/faqs': sidebar
    },
    footer: {
      message: 'Made for you with ❤️',
      copyright: 'Copyright © 2022-present Ryan Haskell-Glatz'
    },
    editLink: {
      pattern: 'https://github.com/elm-land/elm-land/edit/main/docs/:path',
      text: 'Found a typo? Let us know!'
    },
    lastUpdatedText: 'Updated on'
  }
}
