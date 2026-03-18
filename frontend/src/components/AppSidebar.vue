<template>
  <v-navigation-drawer
    v-model="drawer"
    permanent
    color="surface"
    class="border-e-thin"
    width="280"
  >
    <div class="pa-6 d-flex flex-column align-center">
      <v-avatar color="primary" size="64" variant="tonal" class="mb-4 elevation-4">
        <v-icon size="32" color="primary">mdi-tanker-truck</v-icon>
      </v-avatar>
      <h3 class="text-h6 font-weight-bold text-white tracking-wide">LOGÍSTICA IW3</h3>
      <span class="text-caption text-grey">Sistema de Planta</span>
    </div>

    <v-divider class="mb-2"></v-divider>

    <v-list nav class="pa-2">
      <v-list-item
        to="/dashboard"
        prepend-icon="mdi-view-dashboard-outline"
        title="Panel de Control"
        active-class="active-item"
        rounded="lg"
        class="mb-1"
      ></v-list-item>

      <v-list-item
        to="/ordenes"
        prepend-icon="mdi-clipboard-list-outline"
        title="Gestión de Órdenes"
        active-class="active-item"
        rounded="lg"
        class="mb-1"
      ></v-list-item>

      <v-list-item
        to="/alarms"
        prepend-icon="mdi-alert-octagram-outline"
        title="Alertas & Incidentes"
        active-class="active-item"
        rounded="lg"
        class="mb-1"
      >
        <template v-slot:append v-if="alarmasActivas > 0">
          <v-badge color="error" :content="alarmasActivas" inline></v-badge>
        </template>
      </v-list-item>

      <v-list-item
        to="/users"
        prepend-icon="mdi-account-group-outline"
        title="Usuarios"
        active-class="active-item"
        rounded="lg"
      ></v-list-item>
    </v-list>

    <template v-slot:append>
      <div class="pa-4">
        <v-card color="background" variant="flat" class="pa-3 rounded-lg mb-3">
          <div class="d-flex align-center">
            <v-avatar size="36" color="grey-darken-3">
              <span class="text-caption font-weight-bold">{{ userInitials }}</span>
            </v-avatar>
            <div class="ml-3 overflow-hidden">
              <div class="text-caption font-weight-bold text-white text-truncate">{{ username }}</div>
              <div class="text-caption text-primary" style="font-size: 0.7rem;">{{ userRole }}</div>
            </div>
          </div>
        </v-card>
        
        <v-btn 
          block 
          color="error" 
          variant="outlined" 
          prepend-icon="mdi-logout" 
          @click="logout"
        >
          Cerrar Sesión
        </v-btn>
      </div>
    </template>
  </v-navigation-drawer>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useOrdersStore } from '../stores/orders';

const router = useRouter();
const store = useOrdersStore();
const drawer = ref(true);

const username = localStorage.getItem('username') || 'Usuario';
const userRole = (localStorage.getItem('role') || 'USER').replace('ROLE_', '');
const userInitials = computed(() => username.substring(0, 2).toUpperCase());

// SOLUCIÓN DEFINITIVA: Una sola declaración y protegida contra undefined
const alarmasActivas = computed(() => (store.alarmasActivas || []).length);

const logout = () => {
  localStorage.clear();
  router.push('/login');
};
</script>