<template>
  <v-app>

    <!-- TOP BAR -->
    <v-app-bar
      elevation="0"
      height="64"
      class="px-6"
      style="background: rgba(15,23,42,0.95); backdrop-filter: blur(8px);"
    >

      <!-- Botón colapsar sidebar -->
      <v-btn
        icon
        variant="text"
        @click="drawer = !drawer"
        class="mr-3"
      >
        <v-icon>mdi-menu</v-icon>
      </v-btn>

      <v-app-bar-title class="font-weight-bold">
        FuelControl
      </v-app-bar-title>

      <v-spacer />

      <!-- Usuario -->
      <v-chip
        class="mr-4"
        variant="tonal"
        color="primary"
      >
        <v-icon start size="18">mdi-account</v-icon>
        {{ username }} ({{ roleLabel }})
      </v-chip>

      <!-- Logout -->
      <v-btn
        variant="tonal"
        color="error"
        @click="logout"
      >
        <v-icon start>mdi-logout</v-icon>
        Salir
      </v-btn>

    </v-app-bar>

    <!-- SIDEBAR -->
    <v-navigation-drawer
      v-model="drawer"
      width="240"
      elevation="0"
      style="background: #0F172A;"
    >
      <v-list nav density="comfortable">

        <v-list-item
          prepend-icon="mdi-view-dashboard"
          title="Dashboard"
          :active="isActive('/dashboard')"
          @click="go('/dashboard')"
        />

        <v-list-item
          prepend-icon="mdi-alert"
          title="Alarmas"
          :active="isActive('/alarms')"
          @click="go('/alarms')"
        />

        <!-- SOLO ADMIN -->
        <v-list-item
          v-if="role === 'ROLE_ADMIN'"
          prepend-icon="mdi-account-group"
          title="Usuarios"
          :active="isActive('/users')"
          @click="go('/users')"
        />

      </v-list>
    </v-navigation-drawer>

    <!-- CONTENIDO -->
    <v-main style="background: #0F172A;">
      <v-container fluid class="pa-6">
        <slot />
      </v-container>
    </v-main>

  </v-app>
</template>

<script setup lang="ts">
import { useRouter, useRoute } from "vue-router"
import { computed, ref } from "vue"

const router = useRouter()
const route = useRoute()

const drawer = ref(true)

const username = localStorage.getItem("username") || "Usuario"
const role = localStorage.getItem("role")

const roleLabel = computed(() => {
  return role === "ROLE_ADMIN" ? "Admin" : "Operador"
})

const logout = () => {
  localStorage.clear()
  router.push("/login")
}

const go = (path: string) => {
  router.push(path)
}

const isActive = (path: string) => {
  return route.path === path
}
</script>

<style scoped>
.v-list-item--active {
  background: rgba(99, 102, 241, 0.15) !important;
  border-radius: 8px;
}
</style>
