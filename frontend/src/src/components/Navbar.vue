<template>
  <nav class="nav">
    <router-link to="/dashboard">Dashboard</router-link>
    <router-link to="/alarms">Alarmas</router-link>
    <router-link to="/reconciliation">Conciliaciones</router-link>
    <button @click="logout">Logout</button>
  </nav>
</template>

<script setup>
import { useAuthStore } from "../stores/auth";
const auth = useAuthStore();

const logout = () => {
  auth.logout();
  window.location.href = "/login";
};
</script>

<style>
.nav {
  background: #222;
  padding: 15px;
  color: white;
  display: flex;
  gap: 20px;
}
</style>
