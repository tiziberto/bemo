<script setup lang="ts">
import { useRouter } from "vue-router";
import { useAuthStore } from "@/stores/auth";
import AdminDashboard from "./AdminDashboard.vue";
import PatientDashboard from "./PatientDashboard.vue";
import DoctorDashboard from "./DoctorDashboard.vue";
import AdminStaffDashboard from "./AdminStaffDashboard.vue";
import AccountingDashboard from "./AccountingDashboard.vue";

const auth = useAuthStore();
const router = useRouter();

if (!auth.user) {
  router.replace("/login");
}
</script>

<template>
  <AdminDashboard v-if="auth.user?.role === 'admin'" />
  <PatientDashboard v-else-if="auth.user?.role === 'paciente'" />
  <DoctorDashboard v-else-if="auth.user?.role === 'medico'" />
  <AdminStaffDashboard v-else-if="auth.user?.role === 'administrativo'" />
  <AccountingDashboard v-else-if="auth.user?.role === 'contaduria'" />
</template>
