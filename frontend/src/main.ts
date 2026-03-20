import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import '@mdi/font/css/materialdesignicons.css'

const vuetify = createVuetify({
  components,
  directives,
  theme: {
    defaultTheme: 'ecomed',
    themes: {
      ecomed: {
        dark: true,
        colors: {
          background: '#0A0F1E',
          surface:    '#111827',
          primary:    '#00C896',
          secondary:  '#3B82F6',
          error:      '#EF4444',
          warning:    '#F59E0B',
          success:    '#10B981',
          info:       '#6366F1',
        }
      }
    }
  }
})

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.use(vuetify)
app.mount('#app')