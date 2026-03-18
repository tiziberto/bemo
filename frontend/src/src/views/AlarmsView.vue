<template>
  <v-container fluid class="pa-6 bg-main-dark min-h-screen">
    <div class="mb-6">
      <h1 class="text-h4 font-weight-black text-white">Gestión de Incidentes</h1>
      <p class="text-grey">Monitoreo y resolución de alertas críticas de planta.</p>
    </div>

    <v-card variant="flat" class="bg-card border-thin">
      <v-data-table
        :headers="headers"
        :items="store.alarmasActivas"
        class="bg-transparent text-white"
        no-data-text="No hay incidentes activos en este momento."
      >
        <template v-slot:item.numeroOrden="{ item }">
          <span class="font-weight-bold text-white">#{{ item.numeroOrden }}</span>
        </template>

        <template v-slot:item.ultimaTemperatura="{ item }">
          <v-chip color="red" variant="flat" class="font-weight-bold">
            <v-icon start icon="mdi-thermometer-alert"></v-icon>
            {{ item.ultimaTemperatura }} °C
          </v-chip>
        </template>

        <template v-slot:item.estado="{ item }">
          <span class="text-uppercase text-caption font-weight-bold text-grey">
            {{ item._estadoNombre || 'EN PROCESO' }}
          </span>
        </template>

        <template v-slot:item.actions="{ item }">
          <v-btn
            color="success"
            variant="tonal"
            size="small"
            @click="handleAcknowledge(item.numeroOrden)"
            :loading="loadingId === item.numeroOrden"
          >
            <v-icon start>mdi-check-circle-outline</v-icon>
            RECONOCER Y DESACTIVAR
          </v-btn>
        </template>
      </v-data-table>
    </v-card>
  </v-container>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useOrdersStore } from '../stores/orders';

const store = useOrdersStore();
const loadingId = ref<number | null>(null);

const headers = [
  { title: 'Orden Afectada', key: 'numeroOrden', align: 'start' },
  { title: 'Temperatura Registrada', key: 'ultimaTemperatura', align: 'center' },
  { title: 'Estado del Proceso', key: 'estado', align: 'start' },
  { title: 'Acción Requerida', key: 'actions', align: 'end', sortable: false },
] as const;

// --- Manejador del Click (Sin chequeo de Admin) ---
const handleAcknowledge = async (id: number) => {
  loadingId.value = id; 
  await store.acknowledgeAlarm(id); 
  loadingId.value = null;
};

onMounted(() => {
  store.fetchOrders(); 
});
</script>

<style scoped>
.bg-main-dark { background-color: #0d1117; }
.bg-card { background-color: #161b22; }
.border-thin { border: 1px solid rgba(255, 255, 255, 0.1); }
</style>