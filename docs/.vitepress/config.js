const version = '0.19.0'

const sidebar = [
  {
    text: 'Guide',
    items: [
      { text: 'Getting started', link: '/guide/' },
      { text: 'Pages and routes', link: '/guide/pages-and-routes' },
      { text: 'User input', link: '/guide/user-input' },
      { text: 'REST APIs', link: '/guide/rest-apis' },
      { text: 'User authentication', link: '/guide/user-auth' },
      { text: 'Working with JavaScript', link: '/guide/working-with-js' },
      { text: 'Deploying to production', link: '/guide/deploying' },
    ]
  },
  {
    text: 'Concepts',
    items: [
      { text: 'Introduction', link: '/concepts/' },
      { text: 'Pages', link: '/concepts/pages' },
      { text: 'Layouts', link: '/concepts/layouts' },
      { text: 'Components', link: '/concepts/components' },
      { text: 'Shared', link: '/concepts/shared' },
      { text: 'Effect', link: '/concepts/effect' },
      { text: 'View', link: '/concepts/view' },
      { text: 'Auth', link: '/concepts/auth' },
      { text: 'The 404 Page', link: '/concepts/404' },
    ]
  },
  {
    text: "Reference",
    items: [
      { text: 'elm-land.json', link: '/reference/elm-land-json' },
      { text: 'Auth.Action', link: '/reference/auth-action' },
      { text: 'Layout', link: '/reference/layout' },
      { text: 'Layouts', link: '/reference/layouts' },
      { text: 'Page', link: '/reference/page' },
      { text: 'Route', link: '/reference/route' },
      { text: 'Route.Path', link: '/reference/route-path' },
    ]
  },
  {
    text: "More resources",
    items: [
      { text: 'FAQs', link: '/faqs' },
      { text: 'Problems', link: '/problems' }
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
    outline: 'deep',
    search: {
      provider: 'local',
      options: {
        disableDetailedView: true,
        disableQueryPersistence: true
      }
    },
    nav: [
      { text: 'Guide', link: '/guide/' },
      { text: 'Examples', link: '/examples/' },
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
      '/docs': sidebar,
      '/quickstart': sidebar,
      '/guide/': sidebar,
      '/concepts/': sidebar,
      '/reference/': sidebar,
      '/faqs': sidebar,
      '/problems': sidebar
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
