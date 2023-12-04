const version = '0.19.4'

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
      { text: 'CLI', link: '/concepts/cli' },
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
          { text: 'GitHub', link: `https://github.com/elm-land/elm-land/releases/tag/v${version}` }
        ]
      }
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/elm-land/elm-land' },
      { icon: 'twitter', link: 'https://twitter.com/elmland_' },
      { icon: 'discord', link: 'https://join.elm.land' },
      // {
      //   icon: {
      //     svg: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="icon"><path d="M12,22.2c-0.3,0-0.5-0.1-0.7-0.3l-8.8-8.8c-2.5-2.5-2.5-6.7,0-9.2c2.5-2.5,6.7-2.5,9.2,0L12,4.3l0.4-0.4c0,0,0,0,0,0C13.6,2.7,15.2,2,16.9,2c0,0,0,0,0,0c1.7,0,3.4,0.7,4.6,1.9l0,0c1.2,1.2,1.9,2.9,1.9,4.6c0,1.7-0.7,3.4-1.9,4.6l-8.8,8.8C12.5,22.1,12.3,22.2,12,22.2zM7,4C5.9,4,4.7,4.4,3.9,5.3c-1.8,1.8-1.8,4.6,0,6.4l8.1,8.1l8.1-8.1c0.9-0.9,1.3-2,1.3-3.2c0-1.2-0.5-2.3-1.3-3.2l0,0C19.3,4.5,18.2,4,17,4c0,0,0,0,0,0c-1.2,0-2.3,0.5-3.2,1.3c0,0,0,0,0,0l-1.1,1.1c-0.4,0.4-1,0.4-1.4,0l-1.1-1.1C9.4,4.4,8.2,4,7,4z"></path></svg>'
      //   },
      //   link: 'https://github.com/sponsors/ryannhg/',
      //   // You can include a custom label for accessibility too (optional but recommended):
      //   ariaLabel: 'Sponsor'
      // }
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
      copyright: 'Copyright © 2022-present, Ryan Haskell-Glatz'
    },
    editLink: {
      pattern: 'https://github.com/elm-land/elm-land/edit/main/docs/:path',
      text: 'Found a typo? Let us know!'
    },
    lastUpdatedText: 'Updated on'
  }
}
