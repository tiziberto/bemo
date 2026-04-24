<script setup lang="ts">
import { ref, onMounted } from "vue";
import axios from "axios";
import { useAuthStore } from "@/stores/auth";
import { RefreshCw, ChevronLeft, ChevronRight, Users } from "lucide-vue-next";
import Card from "@/components/ui/Card.vue";
import CardContent from "@/components/ui/CardContent.vue";
import CardHeader from "@/components/ui/CardHeader.vue";
import CardTitle from "@/components/ui/CardTitle.vue";

const API_DERIVADOS = "http://localhost:8080/api/turnos/derivados";

const auth    = useAuthStore();
const headers = () => ({ Authorization: `Bearer ${auth.token}` });

interface TurnoDerivado {
  id: number;
  pacienteNombre: string;
  profesionalNombre: string;
  estudioNombre: string | null;
  obraSocialNombre: string | null;
  fechaHora: string;
  estado: string;
  observaciones: string | null;
}

const turnos      = ref<TurnoDerivado[]>([]);
const loading     = ref(false);
const error       = ref("");
const totalPages  = ref(0);
const totalItems  = ref(0);
const currentPage = ref(0);

const filterDesde = ref("");
const filterHasta = ref("");

async function loadDerivados(page = 0) {
  loading.value = true;
  error.value   = "";
  try {
    const params: Record<string, string | number> = { page, size: 20 };
    if (filterDesde.value) params.desde = filterDesde.value;
    if (filterHasta.value) params.hasta = filterHasta.value;
    const res = await axios.get(API_DERIVADOS, { headers: headers(), params });
    turnos.value      = res.data.content;
    totalPages.value  = res.data.totalPages;
    totalItems.value  = res.data.totalElements;
    currentPage.value = res.data.page;
  } catch (e: any) {
    const d = e?.response?.data;
    error.value = d?.error ?? d?.message ?? "Error al cargar los pacientes derivados.";
  } finally {
    loading.value = false;
  }
}

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString("es-AR");
}
function formatTime(iso: string): string {
  return new Date(iso).toLocaleTimeString("es-AR", { hour: "2-digit", minute: "2-digit" });
}

const estadoClass: Record<string, string> = {
  PENDIENTE:  "bg-yellow-100 text-yellow-800 border-yellow-200",
  CONFIRMADO: "bg-blue-100 text-blue-800 border-blue-200",
  ATENDIDO:   "bg-green-100 text-green-800 border-green-200",
  CANCELADO:  "bg-red-100 text-red-800 border-red-200",
  AUSENTE:    "bg-gray-100 text-gray-600 border-gray-200",
};

onMounted(() => loadDerivados());
</script>

<template>
  <div class="space-y-4">
    <!-- Header -->
    <div>
      <h1 class="text-2xl font-bold flex items-center gap-2">
        <Users class="h-6 w-6 text-primary" />
        Mis Pacientes Derivados
      </h1>
      <p class="text-muted-foreground text-sm mt-1">
        Turnos que usted solicitó — cuando el estado es ATENDIDO puede consultar el informe
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
          <button @click="loadDerivados(0)" :disabled="loading"
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

    <template v-else>
      <div class="flex items-center justify-between text-sm text-muted-foreground">
        <span>{{ totalItems }} derivación{{ totalItems !== 1 ? 'es' : '' }}</span>
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
                  <th class="px-4 py-3 text-left font-medium text-muted-foreground">Estudio</th>
                  <th class="px-4 py-3 text-left font-medium text-muted-foreground">Obra Social</th>
                  <th class="px-4 py-3 text-left font-medium text-muted-foreground">Estado</th>
                  <th class="px-4 py-3 text-left font-medium text-muted-foreground">Informe</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="t in turnos" :key="t.id" class="border-b hover:bg-muted/30 transition-colors">
                  <td class="px-4 py-2 font-medium">{{ formatDate(t.fechaHora) }}</td>
                  <td class="px-4 py-2 font-mono text-xs">{{ formatTime(t.fechaHora) }}</td>
                  <td class="px-4 py-2">{{ t.pacienteNombre }}</td>
                  <td class="px-4 py-2 text-muted-foreground">{{ t.estudioNombre ?? "—" }}</td>
                  <td class="px-4 py-2 text-muted-foreground">{{ t.obraSocialNombre ?? "—" }}</td>
                  <td class="px-4 py-2">
                    <span :class="['inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium border',
                      estadoClass[t.estado] ?? 'bg-gray-100 text-gray-700 border-gray-200']">
                      {{ t.estado.charAt(0) + t.estado.slice(1).toLowerCase() }}
                    </span>
                  </td>
                  <td class="px-4 py-2">
                    <span v-if="t.estado === 'ATENDIDO'"
                      class="inline-flex items-center text-xs text-primary font-medium underline cursor-pointer hover:text-primary/80">
                      Ver informe
                    </span>
                    <span v-else class="text-xs text-muted-foreground">—</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>

      <!-- Empty state -->
      <div v-else class="flex flex-col items-center justify-center py-16 text-muted-foreground">
        <Users class="h-10 w-10 mb-3 opacity-30" />
        <p class="text-sm">No se encontraron derivaciones</p>
      </div>

      <!-- Pagination -->
      <div v-if="totalPages > 1" class="flex items-center justify-center gap-2">
        <button @click="loadDerivados(currentPage - 1)" :disabled="currentPage === 0"
          class="p-1.5 rounded border hover:bg-muted transition-colors disabled:opacity-40">
          <ChevronLeft class="h-4 w-4" />
        </button>
        <span class="text-sm">{{ currentPage + 1 }} / {{ totalPages }}</span>
        <button @click="loadDerivados(currentPage + 1)" :disabled="currentPage >= totalPages - 1"
          class="p-1.5 rounded border hover:bg-muted transition-colors disabled:opacity-40">
          <ChevronRight class="h-4 w-4" />
        </button>
      </div>
    </template>
  </div>
</template>
