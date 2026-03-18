<template>
  <v-container fluid class="dashboard-container fill-height align-start pa-6">
    
    <div class="d-flex flex-column flex-md-row justify-space-between align-md-center mb-8 animate__animated animate__fadeIn">
      <div>
        <div class="d-flex align-center">
          <v-icon color="primary" class="mr-3" size="32">mdi-monitor-dashboard</v-icon>
          <h1 class="text-h4 font-weight-black text-white tracking-wide">
            MONITOR DE PLANTA <span class="text-primary">.</span>
          </h1>
        </div>
        <p class="text-grey-darken-1 mt-1 font-weight-medium ls-1">
          SISTEMA DE GESTIÓN DE CARGA Y TELEMETRÍA
        </p>
      </div>
      
      <div class="d-flex align-center mt-4 mt-md-0">
        <v-chip color="success" variant="outlined" class="mr-2 font-weight-bold">
          <v-icon start size="small" class="blink-icon">mdi-circle</v-icon> ONLINE
        </v-chip>
        <span class="text-grey text-caption font-mono">{{ new Date().toLocaleDateString() }}</span>
      </div>
    </div>

    <v-row class="mb-6">
      
      <v-col cols="12" sm="6" md="4">
        <v-card class="industrial-card d-flex align-center pa-4" elevation="0">
          <v-sheet 
            color="rgba(255, 152, 0, 0.1)" 
            class="rounded-lg pa-4 mr-4 d-flex align-center justify-center"
            height="64" width="64"
          >
            <v-icon color="primary" size="32">mdi-tanker-truck</v-icon>
          </v-sheet>
          <div>
            <div class="text-caption font-weight-bold text-grey text-uppercase ls-1">Cargas Activas</div>
            <div class="text-h3 font-weight-black text-white mt-n1">{{ ordenesActivas }}</div>
          </div>
          <v-icon class="bg-icon" icon="mdi-progress-clock"></v-icon>
        </v-card>
      </v-col>

      <v-col cols="12" sm="6" md="4">
        <v-card class="industrial-card d-flex align-center pa-4" elevation="0">
          <v-sheet 
            color="rgba(76, 175, 80, 0.1)" 
            class="rounded-lg pa-4 mr-4 d-flex align-center justify-center"
            height="64" width="64"
          >
            <v-icon color="success" size="32">mdi-flag-checkered</v-icon>
          </v-sheet>
          <div>
            <div class="text-caption font-weight-bold text-grey text-uppercase ls-1">Finalizadas Hoy</div>
            <div class="text-h3 font-weight-black text-white mt-n1">{{ ordenesFinalizadas }}</div>
          </div>
          <v-icon class="bg-icon" icon="mdi-clipboard-check"></v-icon>
        </v-card>
      </v-col>

      <v-col cols="12" sm="6" md="4">
        <v-card 
          class="industrial-card d-flex align-center pa-4" 
          :class="{'alarm-active': alarmasActivas > 0}"
          elevation="0"
        >
          <v-sheet 
            :color="alarmasActivas > 0 ? 'rgba(255, 82, 82, 0.2)' : 'rgba(117, 117, 117, 0.1)'" 
            class="rounded-lg pa-4 mr-4 d-flex align-center justify-center"
            height="64" width="64"
          >
            <v-icon :color="alarmasActivas > 0 ? 'error' : 'grey'" size="32" :class="{'shake-animation': alarmasActivas > 0}">
              mdi-alert-octagram
            </v-icon>
          </v-sheet>
          <div>
            <div class="text-caption font-weight-bold text-grey text-uppercase ls-1">Alertas Críticas</div>
            <div class="text-h3 font-weight-black mt-n1" :class="alarmasActivas > 0 ? 'text-error' : 'text-white'">
              {{ alarmasActivas }}
            </div>
          </div>
        </v-card>
      </v-col>
    </v-row>

    <v-expand-transition>
      <div v-if="alarmasActivas > 0" class="mb-6 w-100">
        <v-alert
          color="#380000"
          theme="dark"
          border="start"
          border-color="error"
          elevation="4"
          class="industrial-alert"
        >
          <template v-slot:prepend>
            <v-icon color="error" size="large" class="mr-4">mdi-fire-alert</v-icon>
          </template>
          <div class="d-flex flex-column flex-sm-row justify-space-between align-center w-100">
            <div>
              <div class="text-h6 font-weight-bold text-red-lighten-1">INCIDENCIA TÉRMICA DETECTADA</div>
              <div class="text-body-2 text-grey-lighten-2">
                Se requiere revisión inmediata en <strong>{{ alarmasActivas }}</strong> orden(es).
              </div>
            </div>
            <v-btn
              color="error"
              variant="flat"
              class="mt-3 mt-sm-0 font-weight-bold"
              prepend-icon="mdi-arrow-right"
              @click="irAOrdenConAlarma"
            >
              GESTIONAR AHORA
            </v-btn>
          </div>
        </v-alert>
      </div>
    </v-expand-transition>

    <v-card class="industrial-card pa-0 flex-grow-1 d-flex flex-column" elevation="0">
      
      <div class="d-flex align-center justify-space-between px-4 py-3 border-b-thin">
        <div class="text-overline font-weight-bold text-white ls-1">
          <v-icon size="small" color="primary" class="mr-2">mdi-table-large</v-icon>
          ÓRDENES RECIENTES
        </div>
        <v-btn 
          icon 
          variant="text" 
          size="small" 
          color="grey" 
          @click="store.fetchOrders(false)"
        >
          <v-icon>mdi-refresh</v-icon>
          <v-tooltip activator="parent" location="top">Actualizar Datos</v-tooltip>
        </v-btn>
      </div>

      <v-data-table
        :headers="headers"
        :items="store.ordenesProcesadas"
        :loading="store.loading && !store.ordenes.length"
        class="industrial-table bg-transparent flex-grow-1"
        hover
        density="comfortable"
      >
        <template v-slot:item.numeroOrden="{ item }">
          <span class="font-mono text-primary font-weight-bold">#{{ item.numeroOrden }}</span>
        </template>

        <template v-slot:item.estado="{ item }">
          <v-chip
            :color="getStatusColor(item._estadoNum)"
            size="x-small"
            variant="flat"
            class="font-weight-bold text-uppercase ls-1"
            label
          >
            {{ getStatusName(item._estadoNum) }}
          </v-chip>
        </template>

        <template v-slot:item.progreso="{ item }">
          <div style="min-width: 160px" class="py-2">
            <div class="d-flex justify-space-between text-caption mb-1">
              <span class="text-white font-weight-bold">{{ Math.round(item._progreso) }}%</span>
              <span class="text-grey-darken-1 font-mono">{{ item.ultimaMasaAcumulada?.toFixed(0) }} kg</span>
            </div>
            <v-progress-linear
              :model-value="item._progreso"
              :color="getProgressColor(item._estadoNum, item._tieneAlarma)"
              height="4"
              rounded
              :stream="item._estadoNum === 2"
            ></v-progress-linear>
          </div>
        </template>

        <template v-slot:item.telemetria="{ item }">
          <div v-if="item._estadoNum >= 2" class="d-flex align-center gap-3">
            <v-chip size="small" :color="item._tieneAlarma ? 'error' : 'surface'" variant="flat" label class="font-mono">
              <v-icon start size="x-small" :color="item._tieneAlarma ? 'white' : 'red'">mdi-thermometer</v-icon>
              {{ item.ultimaTemperatura?.toFixed(1) || '--' }}°C
            </v-chip>
            <span class="text-caption text-grey font-mono">
              DNS: {{ item.ultimaDensidad?.toFixed(3) || '--' }}
            </span>
          </div>
          <span v-else class="text-grey-darken-2 text-caption">--</span>
        </template>

        <template v-slot:item.acciones="{ item }">
          <v-btn
            icon
            variant="tonal"
            size="small"
            color="primary"
            :to="{ name: 'detalle-orden', params: { id: item.numeroOrden } }"
          >
            <v-icon>mdi-chevron-right</v-icon>
          </v-btn>
        </template>
      </v-data-table>
    </v-card>

  </v-container>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import { useOrdersStore } from '../stores/orders';

const store = useOrdersStore();
const router = useRouter();

const headers: any = [
  { title: 'ID', key: 'numeroOrden', align: 'start', width: '80px' },
  { title: 'ESTADO', key: 'estado', width: '120px' },
  { title: 'PATENTE', key: 'camion.patente' },
  { title: 'PROGRESO', key: 'progreso', width: '220px' },
  { title: 'TELEMETRÍA', key: 'telemetria' },
  { title: 'ETA', key: '_eta', align: 'center' },
  { title: '', key: 'acciones', sortable: false, align: 'end' },
];

const ordenesActivas = computed(() => store.ordenesProcesadas.filter(o => o._estadoNum === 2).length);
const ordenesFinalizadas = computed(() => store.ordenesProcesadas.filter(o => o._estadoNum === 4).length);
// @ts-ignore
const alarmasActivas = computed(() => store.alarmasActivas.length);

// Helpers
const getStatusColor = (n: number) => {
  const map = {1: 'warning', 2: 'info', 3: 'secondary', 4: 'success'};
  // @ts-ignore
  return map[n] || 'grey';
};
const getStatusName = (n: number) => {
  const map = {1: 'ESPERA', 2: 'CARGANDO', 3: 'CERRADA', 4: 'FINALIZADA'};
  // @ts-ignore
  return map[n] || 'UNK';
};
const getProgressColor = (estado: number, alarma: boolean) => {
  if (alarma) return 'error';
  return estado === 4 ? 'success' : 'primary';
};

const irAOrdenConAlarma = () => {
  // @ts-ignore
  const orden = store.alarmasActivas[0];
  if (orden) router.push({ name: 'detalle-orden', params: { id: orden.numeroOrden } });
};

onMounted(() => store.startPolling());
onUnmounted(() => store.stopPolling());
</script>

<style scoped>
/* --- ESTILO INDUSTRIAL GLOBAL --- */
.dashboard-container {
  background: #121212 !important; /* Fondo Negro Mate */
  font-family: 'Roboto', sans-serif;
}

.tracking-wide { letter-spacing: 2px; }
.ls-1 { letter-spacing: 1px; }
.font-mono { font-family: 'Roboto Mono', monospace; }

/* --- TARJETAS INDUSTRIALES --- */
.industrial-card {
  background: #1E1E1E !important; /* Gris Oscuro Sólido */
  border: 1px solid #333;
  border-radius: 4px !important; /* Bordes menos redondeados (Industrial) */
  position: relative;
  overflow: hidden;
}

/* Icono de fondo decorativo */
.bg-icon {
  position: absolute;
  right: -10px;
  bottom: -10px;
  font-size: 80px;
  opacity: 0.05;
  color: white;
  transform: rotate(-15deg);
}

/* --- EFECTO DE ALARMA --- */
.alarm-active {
  border: 1px solid #ff5252 !important;
  box-shadow: 0 0 15px rgba(255, 82, 82, 0.15);
  animation: border-pulse 2s infinite;
}

@keyframes border-pulse {
  0% { border-color: #ff5252; }
  50% { border-color: #5c0000; }
  100% { border-color: #ff5252; }
}

.shake-animation {
  animation: shake 0.5s cubic-bezier(.36,.07,.19,.97) infinite both;
}

@keyframes shake {
  10%, 90% { transform: translate3d(-1px, 0, 0); }
  20%, 80% { transform: translate3d(2px, 0, 0); }
  30%, 50%, 70% { transform: translate3d(-4px, 0, 0); }
  40%, 60% { transform: translate3d(4px, 0, 0); }
}

/* --- TABLA INDUSTRIAL --- */
.border-b-thin { border-bottom: 1px solid #333; }

:deep(.industrial-table) {
  color: #E0E0E0 !important;
}
:deep(.industrial-table th) {
  color: #757575 !important;
  font-weight: 700 !important;
  font-size: 0.75rem !important;
  letter-spacing: 1px;
}
:deep(.industrial-table tbody tr:hover) {
  background-color: #2C2C2C !important;
}

/* Luz parpadeante para "Online" */
.blink-icon {
  animation: blink 2s infinite;
  color: #4CAF50;
}
@keyframes blink {
  0% { opacity: 1; }
  50% { opacity: 0.3; }
  100% { opacity: 1; }
}
</style>