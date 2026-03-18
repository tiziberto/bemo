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
          background: '#121212', // Gris casi negro (Material Dark)
          surface: '#1E1E1E',    // Gris un poco más claro para tarjetas
          primary: '#FF9800',    // Naranja Ámbar (Color de seguridad/industrial)
          secondary: '#757575',  // Gris neutro
          success: '#4CAF50',    // Verde estándar
          warning: '#FFC107',
          error: '#FF5252',
          info: '#2196F3',
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