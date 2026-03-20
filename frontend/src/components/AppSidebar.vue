<template>
  <v-navigation-drawer
    v-model="drawer"
    permanent
    :width="rail ? 72 : 260"
    style="background: #0D1426; border-right: 1px solid rgba(0,200,150,0.12)"
  >
    <!-- Logo -->
    <div class="sidebar-logo" :class="{ rail }">
      <div class="logo-icon">
        <v-icon color="#00C896" size="22">mdi-hospital-box</v-icon>
      </div>
      <transition name="label-fade">
        <div v-if="!rail" class="logo-text">
          <span class="logo-main">ECO</span><span class="logo-accent">MED</span>
          <div class="logo-sub">Sistema Médico</div>
        </div>
      </transition>
      <v-btn
        :icon="rail ? 'mdi-chevron-right' : 'mdi-chevron-left'"
        variant="text"
        size="small"
        color="rgba(255,255,255,0.3)"
        @click="rail = !rail"
        class="ml-auto"
      />
    </div>

    <div class="sidebar-divider" />

    <!-- Nav items -->
    <div class="nav-section">
      <div v-if="!rail" class="nav-label">NAVEGACIÓN</div>
      <div
        v-for="item in menuItems"
        :key="item.to"
        class="nav-item"
        :class="{ active: isActive(item.to), rail }"
        @click="navigate(item.to)"
      >
        <v-icon :color="isActive(item.to) ? '#00C896' : 'rgba(255,255,255,0.45)'" size="20">
          {{ item.icon }}
        </v-icon>
        <transition name="label-fade">
          <span v-if="!rail" class="nav-label-text">{{ item.title }}</span>
        </transition>
        <div v-if="isActive(item.to)" class="active-indicator" />
      </div>
    </div>

    <!-- Footer -->
    <template #append>
      <div class="sidebar-footer" :class="{ rail }">
        <div class="user-card" :class="{ rail }">
          <v-avatar size="34" color="#00C896" style="flex-shrink:0">
            <span style="font-size:12px;font-weight:700;color:#0A0F1E">{{ initials }}</span>
          </v-avatar>
          <transition name="label-fade">
            <div v-if="!rail" class="user-info">
              <div class="user-name">{{ displayName }}</div>
              <div class="user-role">{{ roleLabel }}</div>
            </div>
          </transition>
        </div>
        <v-btn
          :icon="rail"
          variant="text"
          size="small"
          color="rgba(239,68,68,0.7)"
          @click="logout"
          :class="{ 'mt-2': rail }"
        >
          <v-icon size="18">mdi-logout</v-icon>
          <span v-if="!rail" class="ml-1" style="font-size:12px">Salir</span>
        </v-btn>
      </div>
    </template>
  </v-navigation-drawer>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const route  = useRoute()
const auth   = useAuthStore()
const rail   = ref(false)
const drawer = ref(true)

const displayName = computed(() => auth.user?.nombre || 'Usuario')
const initials    = computed(() => displayName.value.substring(0, 2).toUpperCase())
const roleLabel   = computed(() => (auth.primaryRole || '').replace('ROLE_', ''))

const MENU: Record<string, { to: string; icon: string; title: string }[]> = {
  ROLE_ADMIN: [
    { to: '/dashboard/admin',     icon: 'mdi-view-dashboard',     title: 'Dashboard' },
    { to: '/users',               icon: 'mdi-account-group',      title: 'Usuarios' },
    { to: '/patients',            icon: 'mdi-account-heart',      title: 'Pacientes' },
    { to: '/appointments',        icon: 'mdi-calendar-month',     title: 'Turnos' },
    { to: '/billing/invoices',    icon: 'mdi-file-document',      title: 'Facturación' },
  ],
  ROLE_DOCTOR: [
    { to: '/dashboard/doctor',    icon: 'mdi-view-dashboard',     title: 'Dashboard' },
    { to: '/appointments',        icon: 'mdi-calendar-clock',     title: 'Mis Turnos' },
    { to: '/patients',            icon: 'mdi-account-heart',      title: 'Pacientes' },
  ],
  ROLE_RECEPTION: [
    { to: '/dashboard/reception', icon: 'mdi-view-dashboard',     title: 'Dashboard' },
    { to: '/appointments',        icon: 'mdi-calendar-plus',      title: 'Turnos' },
    { to: '/patients',            icon: 'mdi-account-search',     title: 'Pacientes' },
  ],
  ROLE_BILLING: [
    { to: '/dashboard/billing',   icon: 'mdi-view-dashboard',     title: 'Dashboard' },
    { to: '/billing/insurance',   icon: 'mdi-shield-check',       title: 'Obras Sociales' },
    { to: '/billing/invoices',    icon: 'mdi-receipt',            title: 'Liquidaciones' },
  ],
  ROLE_PATIENT: [
    { to: '/dashboard/patient',   icon: 'mdi-view-dashboard',     title: 'Mi Panel' },
    { to: '/my-appointments',     icon: 'mdi-calendar',           title: 'Mis Turnos' },
  ],
}

const menuItems = computed(() => MENU[auth.primaryRole || ''] || [])
const isActive  = (to: string) => route.path === to

const navigate = (to: string) => router.push(to)
const logout   = () => { auth.logout(); router.push('/login') }
</script>

<style scoped>
.sidebar-logo {
  display: flex; align-items: center; gap: 10px;
  padding: 20px 16px 16px;
  transition: all 0.25s;
}
.sidebar-logo.rail { padding: 20px 16px; justify-content: center; }
.logo-icon {
  width: 36px; height: 36px; border-radius: 10px;
  background: rgba(0,200,150,0.15);
  border: 1px solid rgba(0,200,150,0.3);
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.logo-main { font-family: 'Playfair Display', serif; font-size: 16px; font-weight: 700; color: #E8EDF5; letter-spacing: 2px; }
.logo-accent { font-family: 'Playfair Display', serif; font-size: 16px; font-weight: 700; color: #00C896; letter-spacing: 2px; }
.logo-sub { font-size: 9px; color: rgba(255,255,255,0.35); letter-spacing: 1.5px; text-transform: uppercase; margin-top: 1px; }

.sidebar-divider { height: 1px; background: rgba(255,255,255,0.06); margin: 0 16px 12px; }

.nav-section { padding: 0 10px; }
.nav-label { font-size: 9px; color: rgba(255,255,255,0.25); letter-spacing: 2px; text-transform: uppercase; padding: 4px 8px 8px; }

.nav-item {
  display: flex; align-items: center; gap: 12px;
  padding: 10px 12px; border-radius: 10px; margin-bottom: 3px;
  cursor: pointer; position: relative;
  transition: background 0.18s, color 0.18s;
  color: rgba(255,255,255,0.45);
}
.nav-item:hover { background: rgba(255,255,255,0.05); color: rgba(255,255,255,0.8); }
.nav-item.active { background: rgba(0,200,150,0.1); color: #00C896; }
.nav-item.rail { justify-content: center; padding: 12px; }

.nav-label-text { font-size: 13.5px; font-weight: 500; white-space: nowrap; }
.active-indicator {
  position: absolute; right: 0; top: 50%; transform: translateY(-50%);
  width: 3px; height: 18px; background: #00C896; border-radius: 2px 0 0 2px;
}

.sidebar-footer {
  padding: 12px 10px 16px;
  border-top: 1px solid rgba(255,255,255,0.06);
  display: flex; flex-direction: column; gap: 8px;
}
.sidebar-footer.rail { align-items: center; }

.user-card {
  display: flex; align-items: center; gap: 10px;
  padding: 8px 10px; border-radius: 10px;
  background: rgba(255,255,255,0.04);
}
.user-card.rail { justify-content: center; padding: 8px; }
.user-name { font-size: 12.5px; font-weight: 600; color: #E8EDF5; }
.user-role { font-size: 10px; color: #00C896; text-transform: uppercase; letter-spacing: 1px; margin-top: 1px; }

.label-fade-enter-active, .label-fade-leave-active { transition: opacity 0.15s; }
.label-fade-enter-from, .label-fade-leave-to { opacity: 0; }
</style>
