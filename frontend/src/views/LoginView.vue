<template>
  <div class="login-container d-flex align-center justify-center">
    <div class="bg-gradient"></div>

    <v-card class="login-card elevation-12 rounded-xl" width="420">

      <!-- Header -->
      <v-card-title class="d-flex flex-column align-center pt-8 pb-2">
        <v-avatar color="primary" size="64" class="mb-3 shadow-glow">
          <v-icon icon="mdi-hospital-building" size="34" color="white"></v-icon>
        </v-avatar>
        <h2 class="text-h5 font-weight-bold text-white">ECOMED</h2>
        <span class="text-caption text-grey">Sistema Médico Integral</span>
      </v-card-title>

      <v-card-text class="pa-6 pt-4">
        <v-form @submit.prevent="handleLogin">

          <v-text-field
            v-model="username"
            label="Usuario"
            prepend-inner-icon="mdi-account"
            variant="outlined"
            density="comfortable"
            color="primary"
            class="mb-3"
            bg-color="rgba(255,255,255,0.05)"
            :disabled="loading"
          />

          <v-text-field
            v-model="password"
            label="Contraseña"
            prepend-inner-icon="mdi-lock"
            :type="showPass ? 'text' : 'password'"
            :append-inner-icon="showPass ? 'mdi-eye-off' : 'mdi-eye'"
            @click:append-inner="showPass = !showPass"
            variant="outlined"
            density="comfortable"
            color="primary"
            class="mb-4"
            bg-color="rgba(255,255,255,0.05)"
            :disabled="loading"
          />

          <v-alert
            v-if="errorMessage"
            type="error"
            variant="tonal"
            density="compact"
            class="mb-4"
            closable
            @click:close="errorMessage = ''"
          >
            {{ errorMessage }}
          </v-alert>

          <v-btn
            type="submit"
            color="primary"
            block
            size="large"
            :loading="loading"
            class="font-weight-bold shadow-btn"
          >
            <v-icon start>mdi-login</v-icon>
            INGRESAR
          </v-btn>

        </v-form>
      </v-card-text>

      <v-card-actions class="justify-center pb-5">
        <span class="text-caption text-grey">v1.0.0 · ECOMED &copy; 2026</span>
      </v-card-actions>
    </v-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router  = useRouter()
const auth    = useAuthStore()

const username     = ref('')
const password     = ref('')
const showPass     = ref(false)
const loading      = ref(false)
const errorMessage = ref('')

// Mapa rol → ruta (debe coincidir con el router)
const ROLE_REDIRECT: Record<string, string> = {
  ROLE_ADMIN:       '/dashboard/admin',
  ROLE_DOCTOR:      '/dashboard/doctor',
  ROLE_RECEPCION:   '/dashboard/reception',
  ROLE_FACTURACION: '/dashboard/billing',
  ROLE_PACIENTE:    '/dashboard/patient',
}

const handleLogin = async () => {
  if (!username.value || !password.value) {
    errorMessage.value = 'Completá usuario y contraseña.'
    return
  }

  loading.value      = true
  errorMessage.value = ''

  try {
    await auth.login(username.value.trim(), password.value)

    const dest = ROLE_REDIRECT[auth.primaryRole ?? ''] ?? '/unauthorized'
    router.push(dest)

  } catch (error: any) {
    if (error.response?.status === 401) {
      errorMessage.value = 'Usuario o contraseña incorrectos.'
    } else {
      errorMessage.value = 'Servidor no disponible. Intentá más tarde.'
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-container {
  height: 100vh;
  width: 100vw;
  position: relative;
  overflow: hidden;
  background-color: #0a1628;
}

.bg-gradient {
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(circle at 30% 40%, rgba(29, 78, 216, 0.18) 0%, transparent 55%),
              radial-gradient(circle at 70% 70%, rgba(255, 152, 0, 0.08) 0%, transparent 45%);
  animation: pulse 12s infinite ease-in-out;
  z-index: 0;
}

@keyframes pulse {
  0%, 100% { transform: scale(1);   opacity: 0.6; }
  50%       { transform: scale(1.1); opacity: 1;   }
}

.login-card {
  z-index: 1;
  background: rgba(20, 30, 50, 0.85) !important;
  backdrop-filter: blur(14px);
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.shadow-glow {
  box-shadow: 0 0 24px rgba(255, 152, 0, 0.45);
}

.shadow-btn {
  box-shadow: 0 4px 18px rgba(255, 152, 0, 0.35);
  transition: transform 0.2s, box-shadow 0.2s;
}
.shadow-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 22px rgba(255, 152, 0, 0.55);
}
</style>
