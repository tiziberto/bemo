<template>
  <v-app>
    <AppSidebar v-if="!isLoginPage" />
    <v-main>
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </v-main>
  </v-app>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import AppSidebar from './components/AppSidebar.vue'

const route = useRoute()
const isLoginPage = computed(() => route.path === '/login')
</script>

<style>
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
::-webkit-scrollbar { width: 8px; }
::-webkit-scrollbar-track { background: #121212; }
::-webkit-scrollbar-thumb { background: #424242; border-radius: 4px; }
::-webkit-scrollbar-thumb:hover { background: #FF9800; }
</style>