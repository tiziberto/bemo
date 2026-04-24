<script setup lang="ts">
import { ref, watch } from "vue";
import { X, FileText, Upload } from "lucide-vue-next";
import axios from "axios";
import { useAuthStore } from "@/stores/auth";

interface TurnoInfo {
  id: number;
  pacienteNombre: string;
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
const uploadingPdf = ref(false);
const uploadingFoto = ref(false);

const form = ref({
  preInforme: "",
  informeUrl: "",
  fotoUrl: "",
});

watch(() => props.turno, (t) => {
  if (t) {
    error.value = "";
    form.value = { preInforme: "", informeUrl: "", fotoUrl: "" };
  }
});

async function uploadFile(event: Event, tipo: "informe" | "foto") {
  const input = event.target as HTMLInputElement;
  if (!input.files?.length) return;
  const file = input.files[0];
  const fd = new FormData();
  fd.append("file", file);
  fd.append("tipo", tipo);

  if (tipo === "informe") uploadingPdf.value = true;
  else uploadingFoto.value = true;

  try {
    const res = await axios.post(`${API}/adjuntos/upload`, fd, {
      headers: { ...headers(), "Content-Type": "multipart/form-data" },
    });
    if (tipo === "informe") form.value.informeUrl = res.data.url;
    else form.value.fotoUrl = res.data.url;
  } catch (e: any) {
    error.value = e?.response?.data?.error ?? "Error al subir archivo.";
  } finally {
    if (tipo === "informe") uploadingPdf.value = false;
    else uploadingFoto.value = false;
  }
}

async function guardar() {
  saving.value = true;
  error.value = "";
  try {
    await axios.post(`${API}/turnos/${props.turno!.id}/cambiar-estado`, {
      nuevoEstado: "ATENDIDO",
      preInforme: form.value.preInforme || null,
      informeUrl: form.value.informeUrl || null,
      fotoUrl: form.value.fotoUrl || null,
    }, { headers: headers() });
    emit("saved");
  } catch (e: any) {
    error.value = e?.response?.data?.error ?? "Error al marcar como atendido.";
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
              <FileText class="h-5 w-5 text-green-600" />
              Informe Médico — Marcar Atendido
            </h2>
            <p class="text-xs text-muted-foreground mt-0.5">
              {{ turno.pacienteNombre }} — {{ turno.estudioNombre ?? "Sin estudio" }}
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

          <!-- Pre-informe -->
          <div class="space-y-1">
            <label class="text-sm font-medium">Pre-informe / Hallazgos</label>
            <textarea v-model="form.preInforme" rows="6"
              placeholder="Describa los hallazgos clínicos, diagnóstico preliminar, observaciones..."
              class="w-full text-sm border rounded-md px-3 py-2 bg-background focus:outline-none focus:ring-2 focus:ring-ring resize-none" />
            <p class="text-xs text-muted-foreground">Este texto quedará visible para el médico derivador al consultar el turno.</p>
          </div>

          <!-- Adjuntos -->
          <div class="space-y-3">
            <p class="text-sm font-medium">Adjuntos (opcional)</p>

            <!-- PDF del informe -->
            <div class="flex items-center gap-3">
              <label class="flex-1 flex items-center gap-2 px-3 py-2 border rounded-md cursor-pointer hover:bg-muted/50 transition-colors text-sm">
                <Upload class="h-4 w-4 text-muted-foreground" />
                <span class="text-muted-foreground">
                  {{ form.informeUrl ? "PDF cargado ✓" : "Subir PDF del informe" }}
                </span>
                <input type="file" accept=".pdf" class="hidden" @change="e => uploadFile(e, 'informe')" />
              </label>
              <span v-if="uploadingPdf" class="w-4 h-4 border-2 border-primary border-t-transparent rounded-full animate-spin"></span>
            </div>

            <!-- Foto / imagen -->
            <div class="flex items-center gap-3">
              <label class="flex-1 flex items-center gap-2 px-3 py-2 border rounded-md cursor-pointer hover:bg-muted/50 transition-colors text-sm">
                <Upload class="h-4 w-4 text-muted-foreground" />
                <span class="text-muted-foreground">
                  {{ form.fotoUrl ? "Imagen cargada ✓" : "Subir imagen / foto" }}
                </span>
                <input type="file" accept="image/*" class="hidden" @change="e => uploadFile(e, 'foto')" />
              </label>
              <span v-if="uploadingFoto" class="w-4 h-4 border-2 border-primary border-t-transparent rounded-full animate-spin"></span>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex justify-end gap-2 pt-2">
            <button type="button" @click="emit('close')"
              class="px-4 py-2 text-sm rounded-md border hover:bg-muted transition-colors">
              Cancelar
            </button>
            <button type="submit" :disabled="saving || uploadingPdf || uploadingFoto"
              class="px-4 py-2 text-sm rounded-md bg-green-600 text-white hover:bg-green-700 transition-colors disabled:opacity-50 flex items-center gap-2">
              <span v-if="saving" class="w-3 h-3 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
              {{ saving ? "Guardando..." : "Confirmar → Atendido" }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </Teleport>
</template>
