<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import axios from "axios";
import { useAuthStore } from "@/stores/auth";
import {
  RefreshCw, Printer, ChevronLeft, ChevronRight,
  DollarSign, RotateCcw, Lock, Unlock
} from "lucide-vue-next";
import Card from "@/components/ui/Card.vue";
import CardContent from "@/components/ui/CardContent.vue";
import CardHeader from "@/components/ui/CardHeader.vue";
import CardTitle from "@/components/ui/CardTitle.vue";

const API = "http://localhost:8080/api";
const auth = useAuthStore();
const headers = () => ({ Authorization: `Bearer ${auth.token}` });

interface CajaItem {
  turnoId: number;
  hora: string;
  pacienteNombre: string;
  obraSocialNombre: string;
  estudioNombre: string;
  efectivo: number;
  electronico: number;
  coseguro: number;
  esDeposito: boolean;
  recuperoDeposito: boolean;
  valorDeposito: number | null;
  metodoPago1: string | null;
  metodoPago2: string | null;
  pagoId: number | null;
  esParticular: boolean;
}

interface CajaResumen {
  cajaDiariaId: number | null;
  estado: string;
  fecha: string;
  profesionalId: number;
  profesionalNombre: string;
  firmaTexto: string | null;
  observaciones: string | null;
  items: CajaItem[];
  totalEfectivo: number;
  totalElectronico: number;
  totalCoseguro: number;
  totalDepositos: number;
  totalRecuperos: number;
  totalGeneral: number;
}

const loading = ref(false);
const error = ref("");
const resumen = ref<CajaResumen | null>(null);
const saving = ref(false);

// Filters
const selectedDate = ref(new Date().toISOString().split("T")[0]);
const profesionales = ref<{ id: number; nombre: string }[]>([]);
const selectedProfId = ref("");

// Cerrar caja
const showCerrarModal = ref(false);
const firmaTexto = ref("");
const observaciones = ref("");

async function loadProfesionales() {
  try {
    const res = await axios.get(`${API}/profesionales`, { headers: headers() });
    const data = res.data;
    profesionales.value = Array.isArray(data) ? data : (data.content ?? []);
  } catch {}
}

async function loadResumen() {
  if (!selectedProfId.value) return;
  loading.value = true;
  error.value = "";
  try {
    const res = await axios.get(`${API}/caja/resumen`, {
      headers: headers(),
      params: { profesionalId: selectedProfId.value, fecha: selectedDate.value },
    });
    resumen.value = res.data;
    firmaTexto.value = res.data.firmaTexto ?? "";
    observaciones.value = res.data.observaciones ?? "";
  } catch (e: any) {
    error.value = e?.response?.data?.error ?? "Error al cargar la caja.";
  } finally {
    loading.value = false;
  }
}

async function convertirARecupero(pagoId: number) {
  try {
    await axios.put(`${API}/pagos/${pagoId}/recupero`, {}, { headers: headers() });
    await loadResumen();
  } catch (e: any) {
    error.value = e?.response?.data?.error ?? "Error al convertir a recupero.";
  }
}

async function cerrarCaja() {
  if (!resumen.value?.cajaDiariaId) {
    // Si no hay caja abierta, abrir primero
    try {
      await axios.post(`${API}/caja/abrir`, {
        profesionalId: Number(selectedProfId.value),
        fecha: selectedDate.value,
      }, { headers: headers() });
      await loadResumen();
    } catch (e: any) {
      error.value = e?.response?.data?.error ?? "Error al abrir caja.";
      return;
    }
  }
  saving.value = true;
  try {
    await axios.post(`${API}/caja/${resumen.value!.cajaDiariaId}/cerrar`, {
      firmaTexto: firmaTexto.value || null,
      observaciones: observaciones.value || null,
    }, { headers: headers() });
    showCerrarModal.value = false;
    await loadResumen();
  } catch (e: any) {
    error.value = e?.response?.data?.error ?? "Error al cerrar caja.";
  } finally {
    saving.value = false;
  }
}

// Navegación por fecha
function prevDate() {
  const d = new Date(selectedDate.value);
  d.setDate(d.getDate() - 1);
  selectedDate.value = d.toISOString().split("T")[0];
  loadResumen();
}
function nextDate() {
  const d = new Date(selectedDate.value);
  d.setDate(d.getDate() + 1);
  selectedDate.value = d.toISOString().split("T")[0];
  loadResumen();
}

function formatDate(s: string) {
  return new Date(s + "T00:00:00").toLocaleDateString("es-AR", {
    weekday: "long", day: "2-digit", month: "long", year: "numeric",
  });
}

function fmt(n: number | null | undefined) {
  if (n == null) return "—";
  return "$" + Number(n).toLocaleString("es-AR", { minimumFractionDigits: 2 });
}

// Items normales (no depósitos pendientes)
const itemsNormales = computed(() =>
  resumen.value?.items.filter(i => !i.esDeposito || i.recuperoDeposito) ?? []
);
// Depósitos pendientes (esperando recupero de la OS)
const itemsDepositos = computed(() =>
  resumen.value?.items.filter(i => i.esDeposito && !i.recuperoDeposito) ?? []
);

function printPage() {
  window.print();
}

onMounted(async () => {
  await loadProfesionales();
});
</script>

<template>
  <div class="space-y-4">
    <!-- Header -->
    <div class="flex items-center justify-between flex-wrap gap-3">
      <div>
        <h1 class="text-2xl font-bold flex items-center gap-2">
          <DollarSign class="h-6 w-6 text-primary" />
          Caja Diaria
        </h1>
        <p class="text-muted-foreground text-sm mt-0.5">Resumen de cobros del día por profesional</p>
      </div>
      <div class="flex gap-2 print:hidden">
        <button @click="printPage"
          class="inline-flex items-center gap-2 px-3 py-1.5 text-sm border rounded-md hover:bg-muted transition-colors">
          <Printer class="h-4 w-4" />
          Imprimir
        </button>
        <button v-if="resumen && resumen.estado === 'ABIERTA'"
          @click="showCerrarModal = true"
          class="inline-flex items-center gap-2 px-3 py-1.5 text-sm rounded-md bg-primary text-primary-foreground hover:bg-primary/90 transition-colors">
          <Lock class="h-4 w-4" />
          Cerrar Caja
        </button>
        <span v-else-if="resumen?.estado === 'CERRADA'"
          class="inline-flex items-center gap-1.5 px-3 py-1.5 text-sm rounded-md bg-green-100 text-green-800 font-medium">
          <Lock class="h-4 w-4" />
          Cerrada
        </span>
      </div>
    </div>

    <!-- Filters -->
    <Card class="print:hidden">
      <CardContent class="pt-4">
        <div class="flex flex-wrap gap-3 items-end">
          <!-- Profesional -->
          <div class="space-y-1">
            <label class="text-xs font-medium text-muted-foreground">Profesional</label>
            <select v-model="selectedProfId"
              class="text-sm border rounded-md px-3 py-1.5 bg-background focus:outline-none focus:ring-2 focus:ring-ring">
              <option value="">Seleccione...</option>
              <option v-for="p in profesionales" :key="p.id" :value="String(p.id)">{{ p.nombre }}</option>
            </select>
          </div>

          <!-- Fecha con nav -->
          <div class="space-y-1">
            <label class="text-xs font-medium text-muted-foreground">Fecha</label>
            <div class="flex items-center gap-1">
              <button @click="prevDate" class="p-1.5 border rounded hover:bg-muted transition-colors">
                <ChevronLeft class="h-4 w-4" />
              </button>
              <input v-model="selectedDate" type="date"
                class="text-sm border rounded-md px-3 py-1.5 bg-background focus:outline-none focus:ring-2 focus:ring-ring" />
              <button @click="nextDate" class="p-1.5 border rounded hover:bg-muted transition-colors">
                <ChevronRight class="h-4 w-4" />
              </button>
            </div>
          </div>

          <button @click="loadResumen" :disabled="!selectedProfId || loading"
            class="inline-flex items-center gap-2 px-4 py-1.5 rounded-md bg-primary text-primary-foreground text-sm font-medium hover:bg-primary/90 disabled:opacity-50 transition-colors">
            <RefreshCw :class="['h-4 w-4', loading && 'animate-spin']" />
            Ver caja
          </button>
        </div>
      </CardContent>
    </Card>

    <div v-if="error" class="rounded-md bg-destructive/10 border border-destructive/30 px-4 py-3 text-sm text-destructive print:hidden">
      {{ error }}
    </div>

    <div v-if="loading" class="flex justify-center py-16">
      <div class="w-6 h-6 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
    </div>

    <template v-else-if="resumen">
      <!-- Print header (only visible when printing) -->
      <div class="hidden print:block mb-4">
        <h2 class="text-xl font-bold">Caja Diaria — {{ resumen.profesionalNombre }}</h2>
        <p class="text-sm text-gray-600">{{ formatDate(resumen.fecha) }}</p>
      </div>

      <!-- Summary cards -->
      <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <Card>
          <CardContent class="p-4">
            <p class="text-xs text-muted-foreground">Efectivo</p>
            <p class="text-xl font-bold text-green-700">{{ fmt(resumen.totalEfectivo) }}</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent class="p-4">
            <p class="text-xs text-muted-foreground">Electrónico</p>
            <p class="text-xl font-bold text-blue-700">{{ fmt(resumen.totalElectronico) }}</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent class="p-4">
            <p class="text-xs text-muted-foreground">Coseguro</p>
            <p class="text-xl font-bold text-purple-700">{{ fmt(resumen.totalCoseguro) }}</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent class="p-4">
            <p class="text-xs text-muted-foreground font-semibold">Total General</p>
            <p class="text-xl font-bold">{{ fmt(resumen.totalGeneral) }}</p>
          </CardContent>
        </Card>
      </div>

      <!-- Main table -->
      <Card>
        <CardHeader>
          <CardTitle class="text-base flex items-center justify-between">
            <span>Turnos cobrados</span>
            <span class="text-xs font-normal text-muted-foreground">{{ itemsNormales.length }} registro{{ itemsNormales.length !== 1 ? 's' : '' }}</span>
          </CardTitle>
        </CardHeader>
        <CardContent class="p-0">
          <div v-if="itemsNormales.length === 0" class="py-12 text-center text-muted-foreground text-sm">
            Sin cobros registrados para esta fecha
          </div>
          <div v-else class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="border-b bg-muted/50">
                <tr>
                  <th class="px-4 py-3 text-left font-medium text-muted-foreground">Hora</th>
                  <th class="px-4 py-3 text-left font-medium text-muted-foreground">Paciente</th>
                  <th class="px-4 py-3 text-left font-medium text-muted-foreground">Obra Social</th>
                  <th class="px-4 py-3 text-left font-medium text-muted-foreground">Estudio</th>
                  <th class="px-4 py-3 text-right font-medium text-muted-foreground">Efectivo</th>
                  <th class="px-4 py-3 text-right font-medium text-muted-foreground">Electrónico</th>
                  <th class="px-4 py-3 text-right font-medium text-muted-foreground">Coseguro</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in itemsNormales" :key="item.turnoId"
                  class="border-b hover:bg-muted/30 transition-colors">
                  <td class="px-4 py-2 font-mono text-xs">{{ item.hora }}</td>
                  <td class="px-4 py-2">
                    <div class="font-medium">{{ item.pacienteNombre }}</div>
                    <div v-if="item.esParticular" class="text-xs text-muted-foreground">Particular</div>
                  </td>
                  <td class="px-4 py-2 text-muted-foreground text-xs">{{ item.obraSocialNombre }}</td>
                  <td class="px-4 py-2 text-xs">{{ item.estudioNombre || "—" }}</td>
                  <td class="px-4 py-2 text-right font-mono text-green-700">
                    {{ item.efectivo > 0 ? fmt(item.efectivo) : "—" }}
                  </td>
                  <td class="px-4 py-2 text-right font-mono text-blue-700">
                    {{ item.electronico > 0 ? fmt(item.electronico) : "—" }}
                  </td>
                  <td class="px-4 py-2 text-right font-mono text-purple-700">
                    {{ item.coseguro > 0 ? fmt(item.coseguro) : "—" }}
                  </td>
                </tr>
                <!-- Subtotales -->
                <tr class="bg-muted/70 font-semibold text-sm">
                  <td class="px-4 py-2 text-xs text-muted-foreground" colspan="4">Subtotal</td>
                  <td class="px-4 py-2 text-right font-mono text-green-700">{{ fmt(resumen.totalEfectivo) }}</td>
                  <td class="px-4 py-2 text-right font-mono text-blue-700">{{ fmt(resumen.totalElectronico) }}</td>
                  <td class="px-4 py-2 text-right font-mono text-purple-700">{{ fmt(resumen.totalCoseguro) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>

      <!-- Depósitos pendientes -->
      <Card v-if="itemsDepositos.length > 0">
        <CardHeader>
          <CardTitle class="text-base text-orange-700">
            Depósitos pendientes de recupero
            <span class="text-xs font-normal text-muted-foreground ml-2">(la obra social aún no pagó)</span>
          </CardTitle>
        </CardHeader>
        <CardContent class="p-0">
          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="border-b bg-orange-50">
                <tr>
                  <th class="px-4 py-3 text-left font-medium text-muted-foreground">Hora</th>
                  <th class="px-4 py-3 text-left font-medium text-muted-foreground">Paciente</th>
                  <th class="px-4 py-3 text-left font-medium text-muted-foreground">Obra Social</th>
                  <th class="px-4 py-3 text-right font-medium text-muted-foreground">Valor depósito</th>
                  <th class="px-4 py-3 text-center font-medium text-muted-foreground print:hidden">Acción</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in itemsDepositos" :key="item.turnoId"
                  class="border-b hover:bg-muted/30 transition-colors">
                  <td class="px-4 py-2 font-mono text-xs">{{ item.hora }}</td>
                  <td class="px-4 py-2 font-medium">{{ item.pacienteNombre }}</td>
                  <td class="px-4 py-2 text-muted-foreground text-xs">{{ item.obraSocialNombre }}</td>
                  <td class="px-4 py-2 text-right font-mono text-orange-700">
                    {{ fmt(item.valorDeposito) }}
                  </td>
                  <td class="px-4 py-2 text-center print:hidden">
                    <button v-if="item.pagoId" @click="convertirARecupero(item.pagoId)"
                      class="inline-flex items-center gap-1 text-xs px-2 py-1 rounded border border-orange-300 text-orange-700 hover:bg-orange-50 transition-colors">
                      <RotateCcw class="h-3 w-3" />
                      Recuperado
                    </button>
                  </td>
                </tr>
                <tr class="bg-orange-50/70 font-semibold text-sm">
                  <td class="px-4 py-2 text-xs text-muted-foreground" colspan="3">Total depósitos</td>
                  <td class="px-4 py-2 text-right font-mono text-orange-700">{{ fmt(resumen.totalDepositos) }}</td>
                  <td class="print:hidden"></td>
                </tr>
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>

      <!-- Firma y observaciones -->
      <Card class="print:border-t-2">
        <CardContent class="pt-4 space-y-3">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div class="space-y-1">
              <label class="text-sm font-medium">Firma del profesional</label>
              <input v-model="firmaTexto" type="text"
                :disabled="resumen.estado === 'CERRADA'"
                placeholder="Nombre y apellido del profesional"
                class="w-full text-sm border rounded-md px-3 py-2 bg-background focus:outline-none focus:ring-2 focus:ring-ring disabled:opacity-60" />
            </div>
            <div class="space-y-1">
              <label class="text-sm font-medium">Observaciones</label>
              <input v-model="observaciones" type="text"
                :disabled="resumen.estado === 'CERRADA'"
                placeholder="Notas adicionales..."
                class="w-full text-sm border rounded-md px-3 py-2 bg-background focus:outline-none focus:ring-2 focus:ring-ring disabled:opacity-60" />
            </div>
          </div>
          <!-- Print area firma -->
          <div class="hidden print:flex justify-between items-end pt-8 border-t mt-6">
            <div class="text-center">
              <div class="border-t border-black w-48 mb-1 mx-auto"></div>
              <p class="text-xs">{{ resumen.profesionalNombre }}</p>
            </div>
            <div class="text-right text-xs text-gray-500">
              <p>Total: {{ fmt(resumen.totalGeneral) }}</p>
              <p>{{ formatDate(resumen.fecha) }}</p>
            </div>
          </div>
        </CardContent>
      </Card>
    </template>

    <!-- Cerrar caja modal -->
    <Teleport to="body">
      <div v-if="showCerrarModal"
        class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50"
        @click.self="showCerrarModal = false">
        <div class="bg-background rounded-xl shadow-2xl w-full max-w-md">
          <div class="flex items-center justify-between px-6 py-4 border-b">
            <h2 class="font-semibold flex items-center gap-2">
              <Lock class="h-5 w-5 text-primary" />
              Cerrar Caja Diaria
            </h2>
          </div>
          <div class="px-6 py-5 space-y-4">
            <p class="text-sm text-muted-foreground">
              Al cerrar la caja no podrá modificar los registros. Se guardará el estado actual.
            </p>
            <div class="space-y-1">
              <label class="text-sm font-medium">Firma del profesional</label>
              <input v-model="firmaTexto" type="text" placeholder="Nombre y apellido"
                class="w-full text-sm border rounded-md px-3 py-2 bg-background focus:outline-none focus:ring-2 focus:ring-ring" />
            </div>
            <div class="space-y-1">
              <label class="text-sm font-medium">Observaciones</label>
              <textarea v-model="observaciones" rows="2" placeholder="Notas..."
                class="w-full text-sm border rounded-md px-3 py-2 bg-background focus:outline-none focus:ring-2 focus:ring-ring resize-none" />
            </div>
            <!-- Summary in modal -->
            <div class="rounded-lg bg-muted/50 px-4 py-3 text-sm space-y-1">
              <div class="flex justify-between">
                <span>Efectivo:</span><span class="font-semibold text-green-700">{{ fmt(resumen?.totalEfectivo) }}</span>
              </div>
              <div class="flex justify-between">
                <span>Electrónico:</span><span class="font-semibold text-blue-700">{{ fmt(resumen?.totalElectronico) }}</span>
              </div>
              <div class="flex justify-between">
                <span>Coseguro:</span><span class="font-semibold text-purple-700">{{ fmt(resumen?.totalCoseguro) }}</span>
              </div>
              <div class="flex justify-between border-t pt-1 font-bold">
                <span>Total:</span><span>{{ fmt(resumen?.totalGeneral) }}</span>
              </div>
            </div>
            <div class="flex justify-end gap-2">
              <button @click="showCerrarModal = false"
                class="px-4 py-2 text-sm rounded-md border hover:bg-muted transition-colors">
                Cancelar
              </button>
              <button @click="cerrarCaja" :disabled="saving"
                class="px-4 py-2 text-sm rounded-md bg-primary text-primary-foreground hover:bg-primary/90 disabled:opacity-50 flex items-center gap-2 transition-colors">
                <span v-if="saving" class="w-3 h-3 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
                {{ saving ? "Cerrando..." : "Confirmar cierre" }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<style>
@media print {
  .print\:hidden { display: none !important; }
  .print\:block { display: block !important; }
  .print\:flex { display: flex !important; }
  .print\:border-t-2 { border-top: 2px solid #e5e7eb; }
}
</style>
