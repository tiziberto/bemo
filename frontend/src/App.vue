<template>
  <v-app style="background: #0A0F1E">
    <EcoSidebar v-if="!isLoginPage" />
    <v-main :style="!isLoginPage ? 'margin-left: 0' : ''">
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
import EcoSidebar from './components/AppSidebar.vue'

const route = useRoute()
const isLoginPage = computed(() => route.path === '/login')
</script>

<style>
.fade-enter-active, .fade-leave-active { transition: opacity 0.18s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>