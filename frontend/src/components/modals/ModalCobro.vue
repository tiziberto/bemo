<script setup lang="ts">
import { ref, computed, watch } from "vue";
import { X, DollarSign, Upload } from "lucide-vue-next";
import axios from "axios";
import { useAuthStore } from "@/stores/auth";

interface TurnoInfo {
  id: number;
  pacienteNombre: string;
  obraSocialNombre: string | null;
  estudioNombre: string | null;
  fechaHora: string;
}

const props = defineProps<{ turno: TurnoInfo | null }>();
const emit = defineEmits<{ close: []; saved: [] }>();

const API = "http://localhost:8080/api";
const auth = useAuthStore();
const headers = () => ({ Authorization: `Bearer ${auth.token}` });

const saving = ref(false);
const error = ref("");

const form = ref({
  estudioRealizado: "",
  metodoPago1: "EFECTIVO",
  monto1: "",
  metodoPago2: "",
  monto2: "",
  coseguro: "",
  esParticular: false,
  esDeposito: false,
  valorDeposito: "",
  recuperoDeposito: false,
  observacionesCobro: "",
});

watch(() => props.turno, (t) => {
  if (t) {
    error.value = "";
    form.value = {
      estudioRealizado: t.estudioNombre ?? "",
      metodoPago1: "EFECTIVO",
      monto1: "",
      metodoPago2: "",
      monto2: "",
      coseguro: "",
      esParticular: !t.obraSocialNombre,
      esDeposito: false,
      valorDeposito: "",
      recuperoDeposito: false,
      observacionesCobro: "",
    };
  }
});

const metodos = ["EFECTIVO", "DEBITO", "CREDITO", "TRANSFERENCIA", "DEPOSITO"];

const totalCalculado = computed(() => {
  const m1 = parseFloat(form.value.monto1) || 0;
  const m2 = parseFloat(form.value.monto2) || 0;
  const cos = parseFloat(form.value.coseguro) || 0;
  return m1 + m2 + cos;
});

async function guardar() {
  if (!form.value.metodoPago1 || !form.value.monto1) {
    error.value = "Método de pago y monto son obligatorios.";
    return;
  }
  saving.value = true;
  error.value = "";
  try {
    await axios.post(`${API}/turnos/${props.turno!.id}/cambiar-estado`, {
      nuevoEstado: "EN_ESPERA",
      estudioRealizado: form.value.estudioRealizado || null,
      metodoPago1: form.value.metodoPago1,
      monto1: parseFloat(form.value.monto1) || 0,
      metodoPago2: form.value.metodoPago2 || null,
      monto2: form.value.monto2 ? parseFloat(form.value.monto2) : null,
      coseguro: form.value.coseguro ? parseFloat(form.value.coseguro) : null,
      esParticular: form.value.esParticular,
      esDeposito: form.value.esDeposito,
      valorDeposito: form.value.valorDeposito ? parseFloat(form.value.valorDeposito) : null,
      recuperoDeposito: form.value.recuperoDeposito,
      observacionesCobro: form.value.observacionesCobro || null,
    }, { headers: headers() });
    emit("saved");
  } catch (e: any) {
    error.value = e?.response?.data?.error ?? "Error al registrar cobro.";
  } finally {
    saving.value = false;
  }
}
</script>

<template>
  <Teleport to="body">
    <div v-if="turno" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50"
      @click.self="emit('close')">
      <div class="bg-background rounded-xl shadow-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto">

        <!-- Header -->
        <div class="flex items-center justify-between px-6 py-4 border-b sticky top-0 bg-background z-10">
          <div>
            <h2 class="font-semibold flex items-center gap-2">
              <DollarSign class="h-5 w-5 text-orange-600" />
              Registrar Cobro
            </h2>
            <p class="text-xs text-muted-foreground mt-0.5">
              {{ turno.pacienteNombre }} — {{ turno.fechaHora?.substring(11, 16) }}
            </p>
          </div>
          <button @click="emit('close')" class="p-1.5 rounded hover:bg-muted transition-colors text-muted-foreground">
            <X class="h-4 w-4" />
          </button>
        </div>

        <!-- Form -->
        <form @submit.prevent="guardar" class="px-6 py-5 space-y-4">
          <div v-if="error" class="rounded-md bg-destructive/10 border border-destructive/30 px-3 py-2 text-sm text-destructive">
            {{ error }}
          </div>

          <!-- Info strip -->
          <div class="rounded-lg bg-muted/50 px-4 py-3 text-sm space-y-1">
            <div class="flex justify-between">
              <span class="text-muted-foreground">Obra Social:</span>
              <span class="font-medium">{{ turno.obraSocialNombre ?? "Particular" }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-muted-foreground">Estudio solicitado:</span>
              <span class="font-medium">{{ turno.estudioNombre ?? "—" }}</span>
            </div>
          </div>

          <!-- Estudio realizado -->
          <div class="space-y-1">
            <label class="text-sm font-medium">Estudio realizado</label>
            <input v-model="form.estudioRealizado" type="text" placeholder="Descripción del estudio..."
              class="w-full text-sm border rounded-md px-3 py-2 bg-background focus:outline-none focus:ring-2 focus:ring-ring" />
          </div>

          <!-- Particular toggle -->
          <label class="flex items-center gap-2 text-sm cursor-pointer">
            <input v-model="form.esParticular" type="checkbox"
              class="w-4 h-4 rounded border accent-primary" />
            <span>Es particular (sin obra social)</span>
          </label>

          <!-- Método de pago 1 -->
          <div class="grid grid-cols-2 gap-3">
            <div class="space-y-1">
              <label class="text-sm font-medium">Método de pago <span class="text-destructive">*</span></label>
              <select v-model="form.metodoPago1"
                class="w-full text-sm border rounded-md px-3 py-2 bg-background focus:outline-none focus:ring-2 focus:ring-ring">
                <option v-for="m in metodos" :key="m" :value="m">{{ m }}</option>
              </select>
            </div>
            <div class="space-y-1">
              <label class="text-sm font-medium">Monto <span class="text-destructive">*</span></label>
              <input v-model="form.monto1" type="number" min="0" step="0.01" placeholder="0.00"
                class="w-full text-sm border rounded-md px-3 py-2 bg-background focus:outline-none focus:ring-2 focus:ring-ring" />
            </div>
          </div>

          <!-- Método de pago 2 (opcional) -->
          <div class="grid grid-cols-2 gap-3">
            <div class="space-y-1">
              <label class="text-sm font-medium text-muted-foreground">2º Método (opcional)</label>
              <select v-model="form.metodoPago2"
                class="w-full text-sm border rounded-md px-3 py-2 bg-background focus:outline-none focus:ring-2 focus:ring-ring">
                <option value="">Sin 2º método</option>
                <option v-for="m in metodos" :key="m" :value="m">{{ m }}</option>
              </select>
            </div>
            <div class="space-y-1">
              <label class="text-sm font-medium text-muted-foreground">2º Monto</label>
              <input v-model="form.monto2" type="number" min="0" step="0.01" placeholder="0.00"
                :disabled="!form.metodoPago2"
                class="w-full text-sm border rounded-md px-3 py-2 bg-background focus:outline-none focus:ring-2 focus:ring-ring disabled:opacity-50" />
            </div>
          </div>

          <!-- Coseguro -->
          <div class="space-y-1">
            <label class="text-sm font-medium text-muted-foreground">Coseguro</label>
            <input v-model="form.coseguro" type="number" min="0" step="0.01" placeholder="0.00"
              class="w-full text-sm border rounded-md px-3 py-2 bg-background focus:outline-none focus:ring-2 focus:ring-ring" />
          </div>

          <!-- Depósito -->
          <div class="space-y-2 border rounded-lg p-3 bg-muted/30">
            <label class="flex items-center gap-2 text-sm cursor-pointer font-medium">
              <input v-model="form.esDeposito" type="checkbox" class="w-4 h-4 rounded border accent-primary" />
              <span>Pago como depósito (obra social pagará después)</span>
            </label>
            <div v-if="form.esDeposito" class="grid grid-cols-2 gap-3 mt-2">
              <div class="space-y-1">
                <label class="text-xs text-muted-foreground">Valor del depósito</label>
                <input v-model="form.valorDeposito" type="number" min="0" step="0.01" placeholder="0.00"
                  class="w-full text-sm border rounded-md px-3 py-2 bg-background focus:outline-none focus:ring-2 focus:ring-ring" />
              </div>
              <div class="flex items-end">
                <label class="flex items-center gap-2 text-sm cursor-pointer">
                  <input v-model="form.recuperoDeposito" type="checkbox" class="w-4 h-4 rounded border accent-primary" />
                  <span class="text-xs">Ya recuperado</span>
                </label>
              </div>
            </div>
          </div>

          <!-- Observaciones -->
          <div class="space-y-1">
            <label class="text-sm font-medium text-muted-foreground">Observaciones del cobro</label>
            <textarea v-model="form.observacionesCobro" rows="2" placeholder="Notas adicionales..."
              class="w-full text-sm border rounded-md px-3 py-2 bg-background focus:outline-none focus:ring-2 focus:ring-ring resize-none" />
          </div>

          <!-- Total -->
          <div class="flex items-center justify-between rounded-lg bg-primary/5 border border-primary/20 px-4 py-3">
            <span class="text-sm font-medium">Total cobrado:</span>
            <span class="text-lg font-bold text-primary">${{ totalCalculado.toFixed(2) }}</span>
          </div>

          <!-- Actions -->
          <div class="flex justify-end gap-2 pt-1">
            <button type="button" @click="emit('close')"
              class="px-4 py-2 text-sm rounded-md border hover:bg-muted transition-colors">
              Cancelar
            </button>
            <button type="submit" :disabled="saving"
              class="px-4 py-2 text-sm rounded-md bg-orange-600 text-white hover:bg-orange-700 transition-colors disabled:opacity-50 flex items-center gap-2">
              <span v-if="saving" class="w-3 h-3 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
              {{ saving ? "Guardando..." : "Registrar cobro → En Espera" }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </Teleport>
</template>
