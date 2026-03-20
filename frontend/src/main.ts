// src/main.ts
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'

// Vuetify
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import '@mdi/font/css/materialdesignicons.css'

const vuetify = createVuetify({
  components,
  directives,
  theme: {
    defaultTheme: 'industrial',
    themes: {
      industrial: {
        dark: true,
        colors: {
          background: '#121212',
          surface:    '#1E1E1E',
          primary:    '#FF9800',
          secondary:  '#757575',
          success:    '#4CAF50',
          warning:    '#FFC107',
          error:      '#FF5252',
          info:       '#2196F3',
        }
      }
    }
  }
})

const pinia = createPinia()
const app   = createApp(App)

// ORDEN CRÍTICO: pinia → router → vuetify → mount
app.use(pinia)
app.use(router)
app.use(vuetify)
app.mount('#app')