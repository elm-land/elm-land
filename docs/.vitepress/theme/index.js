// .vitepress/theme/index.js
import DefaultTheme from 'vitepress/theme'
import './custom.css'
import BrowserWindow from './components/BrowserWindow.vue'

export default {
  ...DefaultTheme,

  enhanceApp({ app }) {
    app.component('BrowserWindow', BrowserWindow)
  }
}
