// .vitepress/theme/index.js
import DefaultTheme from 'vitepress/theme'
import './custom.css'
import BrowserWindow from './components/BrowserWindow.vue'
import ExampleGallery from './components/ExampleGallery.vue'
import NewsPost from './components/NewsPost.vue'
import Header from './components/Header.vue'

export default {
  ...DefaultTheme,

  enhanceApp({ app }) {
    app.component('BrowserWindow', BrowserWindow)
    app.component('NewsPost', NewsPost)
    app.component('Header', Header)
    app.component('ExampleGallery', ExampleGallery)
  }
}
