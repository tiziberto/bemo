<template>
  <div class="login-container d-flex align-center justify-center">
    <div class="bg-gradient"></div>

    <v-card class="login-card elevation-12 rounded-lg" width="400">
      <v-card-title class="text-center pt-6 pb-2">
        <v-avatar color="primary" size="60" class="mb-3 shadow-glow">
          <v-icon icon="mdi-gas-station" size="32" color="white"></v-icon>
        </v-avatar>
<v-icon icon="mdi-hospital-building" size="32" color="white"></v-icon>
<h2 class="text-h5 font-weight-bold text-white">Ecomed</h2>
      </v-card-title>

      <v-card-text class="pa-6">
        <v-form @submit.prevent="handleLogin">
          <v-text-field
            v-model="username"
            label="Usuario"
            prepend-inner-icon="mdi-account"
            variant="outlined"
            density="comfortable"
            color="primary"
            class="mb-2"
            bg-color="rgba(255,255,255,0.05)"
          ></v-text-field>

          <v-text-field
            v-model="password"
            label="Contraseña"
            prepend-inner-icon="mdi-lock"
            type="password"
            variant="outlined"
            density="comfortable"
            color="primary"
            class="mb-4"
            bg-color="rgba(255,255,255,0.05)"
          ></v-text-field>

          <v-alert
            v-if="errorMessage"
            type="error"
            variant="tonal"
            density="compact"
            class="mb-4"
            closable
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
            INGRESAR
          </v-btn>
        </v-form>
      </v-card-text>
      
      <v-card-actions class="justify-center pb-4">
        <span class="text-caption text-grey">v1.0.0 - Sistema IW3</span>
      </v-card-actions>
    </v-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import api from '../api/api'; // Importamos nuestro objeto de servicios

const router = useRouter();
const username = ref('');
const password = ref('');
const loading = ref(false);
const errorMessage = ref('');

const handleLogin = async () => {
  loading.value = true;
  errorMessage.value = '';

  try {
    // CORRECCIÓN: Usamos api.login() en lugar de api.post()
    const response = await api.login({
      username: username.value,
      password: password.value
    });

    // El backend devuelve { "token": "..." }
    const { token } = response.data;

    if (token) {
      localStorage.setItem('token', token);
      
      // Decodificar rol del token (JWT) de forma simple para guardar en localstorage
      // El payload es la segunda parte del token (separado por puntos)
      try {
        const payload = JSON.parse(atob(token.split('.')[1]));
        const roles = payload.roles || [];
        // Guardamos el rol principal o USER por defecto
        localStorage.setItem('role', roles[0] || 'ROLE_USER');
        localStorage.setItem('username', payload.sub || username.value);
      } catch (e) {
        console.error("Error decodificando token", e);
        localStorage.setItem('role', 'ROLE_USER'); // Fallback
      }

      router.push('/dashboard');
    } else {
      errorMessage.value = 'Respuesta inválida del servidor.';
    }
  } catch (error: any) {
    console.error(error);
    if (error.response && error.response.status === 401) {
      errorMessage.value = 'Usuario o contraseña incorrectos.';
    } else {
      errorMessage.value = 'Servidor no disponible o error de red.';
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
  background-color: #0f172a; /* Fondo oscuro base */
}

/* Fondo degradado animado */
.bg-gradient {
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(circle, rgba(29, 78, 216, 0.15) 0%, rgba(15, 23, 42, 0) 50%);
  animation: pulse 10s infinite;
  z-index: 0;
}

@keyframes pulse {
  0% { transform: scale(1); opacity: 0.5; }
  50% { transform: scale(1.2); opacity: 0.8; }
  100% { transform: scale(1); opacity: 0.5; }
}

.login-card {
  z-index: 1;
  background: rgba(30, 41, 59, 0.7) !important;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.shadow-glow {
  box-shadow: 0 0 20px rgba(59, 130, 246, 0.5);
}

.shadow-btn {
  box-shadow: 0 4px 15px rgba(59, 130, 246, 0.4);
  transition: transform 0.2s, box-shadow 0.2s;
}

.shadow-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(59, 130, 246, 0.6);
}
</style>
