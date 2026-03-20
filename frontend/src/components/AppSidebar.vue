<template>
  <v-navigation-drawer
    v-model="drawer"
    permanent
    color="surface"
    class="border-e-thin"
    width="280"
  >
    <!-- Logo / Header -->
    <div class="pa-6 d-flex flex-column align-center">
      <v-avatar color="primary" size="64" variant="tonal" class="mb-4 elevation-4">
        <v-icon size="32" color="primary">mdi-hospital-building</v-icon>
      </v-avatar>
      <h3 class="text-h6 font-weight-bold text-white">ECOMED</h3>
      <span class="text-caption text-grey">Sistema Médico Integral</span>
    </div>

    <v-divider class="mb-2"></v-divider>

    <!-- Menú dinámico según rol -->
    <v-list nav class="pa-2">
      <v-list-item
        v-for="item in menuItems"
        :key="item.to"
        :to="item.to"
        :prepend-icon="item.icon"
        :title="item.title"
        active-class="active-item"
        rounded="lg"
        class="mb-1"
      ></v-list-item>
    </v-list>

    <!-- Footer con usuario -->
    <template v-slot:append>
      <div class="pa-4">
        <v-card color="background" variant="flat" class="pa-3 rounded-lg mb-3">
          <div class="d-flex align-center">
            <v-avatar size="36" color="grey-darken-3">
              <span class="text-caption font-weight-bold">{{ userInitials }}</span>
            </v-avatar>
            <div class="ml-3 overflow-hidden">
              <div class="text-caption font-weight-bold text-white text-truncate">{{ username }}</div>
              <div class="text-caption text-primary" style="font-size: 0.7rem;">{{ rolLabel }}</div>
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
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router  = useRouter()
const auth    = useAuthStore()
const drawer  = ref(true)

// ── Datos del usuario (leídos desde el JWT via Pinia) ──────────
const username     = computed(() => auth.username || 'Usuario')
const rolLabel     = computed(() => {
  const labels: Record<string, string> = {
    ROLE_ADMIN:       'Administrador',
    ROLE_DOCTOR:      'Médico',
    ROLE_RECEPCION:   'Recepción',
    ROLE_FACTURACION: 'Facturación',
    ROLE_PACIENTE:    'Paciente',
  }
  return labels[auth.primaryRole ?? ''] ?? auth.primaryRole ?? ''
})
const userInitials = computed(() => username.value.substring(0, 2).toUpperCase())

// ── Menú por rol (roles exactos del backend) ───────────────────
const MENU: Record<string, { to: string; icon: string; title: string }[]> = {
  ROLE_ADMIN: [
    { to: '/dashboard/admin',     icon: 'mdi-shield-crown',        title: 'Panel Admin' },
    { to: '/dashboard/doctor',    icon: 'mdi-doctor',              title: 'Vista Médico' },
    { to: '/dashboard/reception', icon: 'mdi-desk',                title: 'Vista Recepción' },
    { to: '/dashboard/billing',   icon: 'mdi-cash-register',       title: 'Vista Facturación' },
    { to: '/dashboard/patient',   icon: 'mdi-account-heart',       title: 'Vista Paciente' },
  ],
  ROLE_DOCTOR: [
    { to: '/dashboard/doctor',    icon: 'mdi-view-dashboard',      title: 'Mi Panel' },
    { to: '/appointments',        icon: 'mdi-calendar-clock',      title: 'Mis Turnos' },
    { to: '/patients',            icon: 'mdi-account-heart',       title: 'Pacientes' },
  ],
  ROLE_RECEPCION: [
    { to: '/dashboard/reception', icon: 'mdi-view-dashboard',      title: 'Mi Panel' },
    { to: '/appointments',        icon: 'mdi-calendar-plus',       title: 'Gestión de Turnos' },
    { to: '/patients',            icon: 'mdi-account-search',      title: 'Pacientes' },
  ],
  ROLE_FACTURACION: [
    { to: '/dashboard/billing',   icon: 'mdi-view-dashboard',      title: 'Mi Panel' },
    { to: '/billing/insurance',   icon: 'mdi-shield-check',        title: 'Obras Sociales' },
    { to: '/billing/invoices',    icon: 'mdi-file-document',       title: 'Liquidaciones' },
  ],
  ROLE_PACIENTE: [
    { to: '/dashboard/patient',   icon: 'mdi-view-dashboard',      title: 'Mi Panel' },
    { to: '/my-appointments',     icon: 'mdi-calendar',            title: 'Mis Turnos' },
  ],
}

const menuItems = computed(() => MENU[auth.primaryRole || ''] || [])

// ── Logout ─────────────────────────────────────────────────
const logout = () => {
  auth.logout()
  router.push('/login')
}
</script>

<style scoped>
.active-item {
  background-color: rgba(255, 152, 0, 0.15) !important;
  color: #FF9800 !important;
}
</style>