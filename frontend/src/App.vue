<template>
  <v-app class="app-root">
    <AppSidebar v-if="!isLoginPage" />

    <v-main class="main-content">
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </v-main>
  </v-app>
</template>

<style>
html, body { overflow-y: auto; background-color: #121212; }
.app-root { background-color: #121212 !important; }
.main-content { min-height: 100vh; background-color: #121212; }
</style>
<script setup lang="ts">
import { computed } from 'vue';
import { useRoute } from 'vue-router';
import AppSidebar from './components/AppSidebar.vue';

const route = useRoute();

// CORRECCIÓN: Verificamos el 'path' en lugar del 'name' para mayor seguridad
const isLoginPage = computed(() => {
  return route.path === '/login' || route.name === 'login';
});
</script>

<style>
/* Estilos Globales Industriales */
.app-background {
  background-color: #121212 !important; /* Fondo base negro/gris */
  color: #E0E0E0;
}

/* Transición suave entre páginas */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* Scrollbars oscuras */
::-webkit-scrollbar { width: 8px; }
::-webkit-scrollbar-track { background: #121212; }
::-webkit-scrollbar-thumb { background: #424242; border-radius: 4px; }
::-webkit-scrollbar-thumb:hover { background: #FF9800; }
</style>