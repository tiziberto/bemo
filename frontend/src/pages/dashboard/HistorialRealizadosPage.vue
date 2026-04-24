<script setup lang="ts">
import { ref, onMounted, computed } from "vue";
import axios from "axios";
import { useAuthStore } from "@/stores/auth";
import { RefreshCw, ChevronLeft, ChevronRight, Activity } from "lucide-vue-next";
import Card from "@/components/ui/Card.vue";
import CardContent from "@/components/ui/CardContent.vue";
import CardHeader from "@/components/ui/CardHeader.vue";
import CardTitle from "@/components/ui/CardTitle.vue";

const API_HISTORIAL = "http://localhost:8080/api/turnos/historial";
const API_PROF      = "http://localhost:8080/api/profesionales";

const auth    = useAuthStore();
const headers = () => ({ Authorization: `Bearer ${auth.token}` });

const isDoctor    = computed(() => auth.hasAnyRole(["ROLE_DOCTOR"]));
const isAdmin     = computed(() => auth.hasAnyRole(["ROLE_ADMIN"]));
const isRecepcion = computed(() => auth.hasAnyRole(["ROLE_RECEPCION"]));
const canFilter   = computed(() => isAdmin.value || isRecepcion.value);

interface TurnoHistorial {
  id: number;
  pacienteNombre: string;
  profesionalNombre: string;
  estudioNombre: string | null;
  obraSocialNombre: string | null;
  fechaHora: string;
  estado: string;
}

const turnos       = ref<TurnoHistorial[]>([]);
const loading      = ref(false);
const error        = ref("");
const totalPages   = ref(0);
const totalItems   = ref(0);
const currentPage  = ref(0);
const pageSize     = ref(20);

const filterDesde = ref("");
const filterHasta = ref("");

interface ProfDto { id: number; nombre: string; }
const profesionales  = ref<ProfDto[]>([]);
const filterProfId   = ref<number | "">("");

async function loadProfesionales() {
  if (!canFilter.value) return;
  try {
    const res = await axios.get(API_PROF, { headers: headers(), params: { size: 500 } });
    profesionales.value = res.data.content ?? res.data;
  } catch { /* silent */ }
}

async function loadHistorial(page = 0) {
  loading.value = true;
  error.value   = "";
  try {
    const params: Record<string, string | number> = { page, size: pageSize.value };
    if (filterDesde.value) params.desde = filterDesde.value;
    if (filterHasta.value) params.hasta = filterHasta.value;
    if (canFilter.value && filterProfId.value) params.profesionalId = filterProfId.value;
    const res = await axios.get(API_HISTORIAL, { headers: headers(), params });
    turnos.value      = res.data.content;
    totalPages.value  = res.data.totalPages;
    totalItems.value  = res.data.totalElements;
    currentPage.value = res.data.page;
  } catch (e: any) {
    error.value = e?.response?.data?.error ?? "Error al cargar el historial.";
  } finally {
    loading.value = false;
  }
}

function search() {
  loadHistorial(0);
}

function formatDate(iso: string): string {
  const d = new Date(iso);
  return d.toLocaleDateString("es-AR");
}
function formatTime(iso: string): string {
  return new Date(iso).toLocaleTimeString("es-AR", { hour: "2-digit", minute: "2-digit" });
}

const estadoClass: Record<string, string> = {
  ATENDIDO: "bg-green-100 text-green-800 border-green-200",
  CERRADO:  "bg-gray-100 text-gray-700 border-gray-200",
};

onMounted(async () => {
  await loadProfesionales();
  await loadHistorial();
});
</script>

<template>
  <div class="space-y-4">
    <!-- Header -->
    <div>
      <h1 class="text-2xl font-bold flex items-center gap-2">
        <Activity class="h-6 w-6 text-primary" />
        {{ isDoctor ? "Mi Historial de Turnos" : "Historial de Turnos Atendidos" }}
      </h1>
      <p class="text-muted-foreground text-sm mt-1">
        Turnos finalizados ordenados por fecha descendente
      </p>
    </div>

    <!-- Filters -->
    <Card>
      <CardContent class="pt-4">
        <div class="flex flex-wrap gap-3 items-end">
          <div class="space-y-1">
            <label class="text-xs font-medium text-muted-foreground">Desde</label>
            <input v-model="filterDesde" type="date"
              class="text-sm border rounded-md px-3 py-1.5 bg-background focus:outline-none focus:ring-2 focus:ring-ring" />
          </div>
          <div class="space-y-1">
            <label class="text-xs font-medium text-muted-foreground">Hasta</label>
            <input v-model="filterHasta" type="date"
              class="text-sm border rounded-md px-3 py-1.5 bg-background focus:outline-none focus:ring-2 focus:ring-ring" />
          </div>
          <div v-if="canFilter" class="space-y-1">
            <label class="text-xs font-medium text-muted-foreground">Profesional</label>
            <select v-model="filterProfId"
              class="text-sm border rounded-md px-3 py-1.5 bg-background focus:outline-none focus:ring-2 focus:ring-ring">
              <option value="">Todos</option>
              <option v-for="p in profesionales" :key="p.id" :value="p.id">{{ p.nombre }}</option>
            </select>
          </div>
          <button @click="search" :disabled="loading"
            class="inline-flex items-center gap-2 px-4 py-1.5 rounded-md bg-primary text-primary-foreground text-sm font-medium hover:bg-primary/90 transition-colors disabled:opacity-50">
            <RefreshCw :class="['h-4 w-4', loading && 'animate-spin']" />
            Buscar
          </button>
        </div>
      </CardContent>
    </Card>

    <!-- Error -->
    <div v-if="error" class="rounded-md bg-destructive/10 border border-destructive/30 px-4 py-3 text-sm text-destructive">
      {{ error }}
    </div>

    <!-- Loading -->
    <div v-if="loading" class="flex justify-center py-12">
      <div class="w-6 h-6 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
    </div>

    <!-- Results -->
    <template v-else>
      <!-- Summary -->
      <div class="flex items-center justify-between text-sm text-muted-foreground">
        <span>{{ totalItems }} turno{{ totalItems !== 1 ? 's' : '' }} encontrado{{ totalItems !== 1 ? 's' : '' }}</span>
        <span v-if="totalPages > 1">Página {{ currentPage + 1 }} de {{ totalPages }}</span>
      </div>

      <!-- Table -->
      <Card v-if="turnos.length > 0">
        <CardContent class="p-0">
          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="border-b bg-muted/50">
                <tr>
                  <th class="px-4 py-3 text-left font-medium text-muted-foreground">Fecha</th>
                  <th class="px-4 py-3 text-left font-medium text-muted-foreground">Hora</th>
                  <th class="px-4 py-3 text-left font-medium text-muted-foreground">Paciente</th>
                  <th v-if="!isDoctor" class="px-4 py-3 text-left font-medium text-muted-foreground">Profesional</th>
                  <th class="px-4 py-3 text-left font-medium text-muted-foreground">Estudio</th>
                  <th class="px-4 py-3 text-left font-medium text-muted-foreground">Obra Social</th>
                  <th class="px-4 py-3 text-left font-medium text-muted-foreground">Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="t in turnos" :key="t.id"
                  class="border-b hover:bg-muted/30 transition-colors">
                  <td class="px-4 py-2 font-medium">{{ formatDate(t.fechaHora) }}</td>
                  <td class="px-4 py-2 font-mono text-xs">{{ formatTime(t.fechaHora) }}</td>
                  <td class="px-4 py-2">{{ t.pacienteNombre }}</td>
                  <td v-if="!isDoctor" class="px-4 py-2 text-muted-foreground">{{ t.profesionalNombre }}</td>
                  <td class="px-4 py-2 text-muted-foreground">{{ t.estudioNombre ?? "—" }}</td>
                  <td class="px-4 py-2 text-muted-foreground">{{ t.obraSocialNombre ?? "—" }}</td>
                  <td class="px-4 py-2">
                    <span :class="['inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium border',
                      estadoClass[t.estado] ?? 'bg-gray-100 text-gray-700 border-gray-200']">
                      {{ t.estado.charAt(0) + t.estado.slice(1).toLowerCase() }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>

      <!-- Empty state -->
      <div v-else class="flex flex-col items-center justify-center py-16 text-muted-foreground">
        <Activity class="h-10 w-10 mb-3 opacity-30" />
        <p class="text-sm">No se encontraron turnos atendidos</p>
      </div>

      <!-- Pagination -->
      <div v-if="totalPages > 1" class="flex items-center justify-center gap-2">
        <button @click="loadHistorial(currentPage - 1)" :disabled="currentPage === 0"
          class="p-1.5 rounded border hover:bg-muted transition-colors disabled:opacity-40">
          <ChevronLeft class="h-4 w-4" />
        </button>
        <span class="text-sm">{{ currentPage + 1 }} / {{ totalPages }}</span>
        <button @click="loadHistorial(currentPage + 1)" :disabled="currentPage >= totalPages - 1"
          class="p-1.5 rounded border hover:bg-muted transition-colors disabled:opacity-40">
          <ChevronRight class="h-4 w-4" />
        </button>
      </div>
    </template>
  </div>
</template>
