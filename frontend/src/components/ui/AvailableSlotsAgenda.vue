<script setup lang="ts">
import { ref, computed, watch, onMounted } from "vue";
import axios from "axios";
import { ChevronLeft, ChevronRight, Clock, Calendar, CalendarDays } from "lucide-vue-next";

const props = defineProps<{
  profesionalId: number | string;
  sucursalId: number | string;
  profesionalNombre?: string;
  headers: Record<string, string>;
  apiUrl: string;
}>();

const emit = defineEmits<{
  selected: [fechaHora: string];
  close: [];
}>();

const API = props.apiUrl || "http://localhost:8080/api";

interface TimeSlot {
  time: string;
  available: boolean;
}

interface DaySlots {
  date: string;
  dayName: string;
  slots: TimeSlot[];
}

type ViewMode = "day" | "week";

const currentDate = ref(new Date());
const viewMode = ref<ViewMode>("week");
const daysWithSlots = ref<DaySlots[]>([]);
const loading = ref(false);
const error = ref("");
const selectedDateTime = ref<string | null>(null);

const proximoTurno = ref<{ date: string; time: string; label: string } | null>(null);
const buscandoProximo = ref(false);

function findFirstAvailable(days: typeof daysWithSlots.value) {
  const now = new Date();
  for (const day of days) {
    for (const slot of day.slots) {
      if (slot.available !== "true" && slot.available !== true) continue;
      const slotDate = new Date(`${day.date}T${slot.time}:00`);
      if (slotDate > now) return { date: day.date, time: slot.time, label: day.dayName };
    }
  }
  return null;
}

async function buscarProximoTurno(fromDate: Date, weeksAhead = 0): Promise<void> {
  if (weeksAhead > 4) { proximoTurno.value = null; buscandoProximo.value = false; return; }
  const start = new Date(fromDate);
  start.setDate(start.getDate() + weeksAhead * 7);
  const day = start.getDay();
  start.setDate(start.getDate() - (day === 0 ? 6 : day - 1));
  const end = new Date(start);
  end.setDate(end.getDate() + 6);
  const desde = toLocalDateStr(start);
  const hasta = toLocalDateStr(end);
  try {
    const res = await axios.get(
      `${API}/agenda/-medica/disponibles?profesionalId=${props.profesionalId}&sucursalId=${props.sucursalId}&desde=${desde}&hasta=${hasta}`,
      { headers: props.headers }
    );
    const found = findFirstAvailable(res.data.map((d: any) => ({
      date: d.date,
      dayName: new Date(d.date + "T00:00:00").toLocaleDateString("es-AR", { weekday: "short", day: "2-digit", month: "short" }),
      slots: d.slots,
    })));
    if (found) { proximoTurno.value = found; buscandoProximo.value = false; }
    else await buscarProximoTurno(fromDate, weeksAhead + 1);
  } catch { proximoTurno.value = null; buscandoProximo.value = false; }
}

const startDate = computed(() => {
  const d = new Date(currentDate.value);
  d.setHours(0, 0, 0, 0);
  return d;
});

// Compute the date range based on view mode
const dateRange = computed(() => {
  const start = new Date(startDate.value);

  if (viewMode.value === "day") {
    return { start, end: new Date(start) };
  } else {
    // Normalize to Monday
    const day = start.getDay();
    start.setDate(start.getDate() - (day === 0 ? 6 : day - 1));
    const end = new Date(start);
    end.setDate(end.getDate() + 6);
    return { start, end };
  }
});

function toLocalDateStr(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}
const apiStartDate = computed(() => toLocalDateStr(dateRange.value.start));
const apiEndDate = computed(() => toLocalDateStr(dateRange.value.end));

// Get all unique hours from slots
const allHours = computed(() => {
  const hoursSet = new Set<string>();
  daysWithSlots.value.forEach(day => {
    day.slots.forEach(slot => hoursSet.add(slot.time));
  });
  return Array.from(hoursSet).sort();
});

// Get working hours range
const workingHours = computed(() => {
  if (daysWithSlots.value.length === 0 || daysWithSlots.value[0].slots.length === 0) {
    return { start: "08:00", end: "18:00" };
  }
  const slots = daysWithSlots.value[0].slots;
  return {
    start: slots[0].time,
    end: slots[slots.length - 1].time
  };
});

// All slot times across all days (respects the professional's duration)
const hoursToDisplay = computed(() => allHours.value);

// Days to display
const daysToDisplay = computed(() => {
  if (viewMode.value === "day") {
    return daysWithSlots.value.slice(0, 1);
  } else {
    return daysWithSlots.value;
  }
});

// Prepare grid data
interface GridCell {
  date: string;
  hour: string;
  slot: TimeSlot | null;
}

const gridData = computed(() => {
  const grid: GridCell[] = [];
  for (const day of daysToDisplay.value) {
    for (const hour of hoursToDisplay.value) {
      const slot = day.slots.find(s => s.time === hour);
      grid.push({
        date: day.date,
        hour,
        slot: slot || null,
      });
    }
  }
  return grid;
});

async function loadAvailableSlots() {
  if (!props.profesionalId || !props.sucursalId) return;
  loading.value = true;
  error.value = "";
  try {
    const res = await axios.get(
      `${API}/agenda/-medica/disponibles?profesionalId=${props.profesionalId}&sucursalId=${props.sucursalId}&desde=${apiStartDate.value}&hasta=${apiEndDate.value}`,
      { headers: props.headers }
    );

    daysWithSlots.value = res.data.map((day: any) => ({
      date: day.date,
      dayName: new Date(day.date + "T00:00:00").toLocaleDateString("es-AR", { weekday: "short", day: "2-digit" }),
      slots: day.slots.map((slot: any) => ({
        time: slot.time,
        available: slot.available,
      })),
    }));
    // Buscar próximo turno disponible desde hoy
    proximoTurno.value = null;
    buscandoProximo.value = true;
    buscarProximoTurno(new Date());
  } catch (e: any) {
    error.value = e?.response?.data?.error ?? "Error al cargar horarios disponibles";
    daysWithSlots.value = [];
  } finally {
    loading.value = false;
  }
}

function navigate(direction: 1 | -1) {
  const d = new Date(currentDate.value);

  if (viewMode.value === "day") {
    d.setDate(d.getDate() + direction);
  } else {
    d.setDate(d.getDate() + direction * 7);
  }

  currentDate.value = d;
}

function selectSlot(date: string, time: string) {
  const isoString = `${date}T${time}:00`;
  selectedDateTime.value = isoString;
  emit("selected", isoString);
}

function handleClose() {
  emit("close");
}

function getSlotForDayAndHour(date: string, hour: string): TimeSlot | undefined {
  const day = daysWithSlots.value.find(d => d.date === date);
  return day ? day.slots.find(s => s.time === hour) : undefined;
}

watch([() => props.profesionalId, () => props.sucursalId, apiStartDate, apiEndDate], loadAvailableSlots);

onMounted(loadAvailableSlots);
</script>

<template>
  <div class="space-y-4">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h3 class="text-lg font-bold">Horarios Disponibles</h3>
        <p v-if="props.profesionalNombre" class="text-base font-semibold text-primary">{{ props.profesionalNombre }}</p>
      </div>
      <button @click="handleClose" class="text-xs text-muted-foreground hover:text-foreground">Cerrar</button>
    </div>

    <!-- Próximo turno disponible -->
    <div v-if="buscandoProximo" class="text-sm text-muted-foreground italic">Buscando próximo turno disponible...</div>
    <div v-else-if="proximoTurno" class="rounded-md bg-green-50 border border-green-200 px-4 py-3 flex items-center gap-3">
      <Clock class="h-5 w-5 text-green-600 shrink-0" />
      <div>
        <p class="text-xs text-green-700 font-medium uppercase tracking-wide">Turno más cercano</p>
        <button
          @click="selectSlot(proximoTurno.date, proximoTurno.time)"
          class="text-base font-bold text-green-800 hover:underline"
        >
          {{ proximoTurno.label }} — {{ proximoTurno.time }} hs
        </button>
      </div>
    </div>
    <div v-else class="rounded-md bg-muted/40 border px-4 py-3 text-sm text-muted-foreground">
      Sin disponibilidad en las próximas semanas
    </div>

    <!-- Error -->
    <div v-if="error" class="rounded-md bg-destructive/10 border border-destructive/30 px-3 py-2 text-xs text-destructive">
      {{ error }}
    </div>

    <!-- Loading -->
    <div v-if="loading" class="text-xs text-muted-foreground text-center py-4">Cargando horarios...</div>

    <!-- Content -->
    <div v-else-if="daysWithSlots.length > 0" class="space-y-3">
      <!-- View toggle -->
      <div class="flex gap-2 border-b">
        <button
          @click="viewMode = 'day'"
          :class="[
            'px-3 py-2 text-sm font-medium transition-colors flex items-center gap-2',
            viewMode === 'day'
              ? 'text-primary border-b-2 border-primary -mb-px'
              : 'text-muted-foreground hover:text-foreground',
          ]"
        >
          <Calendar class="h-4 w-4" />
          Día
        </button>
        <button
          @click="viewMode = 'week'"
          :class="[
            'px-3 py-2 text-sm font-medium transition-colors flex items-center gap-2',
            viewMode === 'week'
              ? 'text-primary border-b-2 border-primary -mb-px'
              : 'text-muted-foreground hover:text-foreground',
          ]"
        >
          <CalendarDays class="h-4 w-4" />
          Semana
        </button>
      </div>

      <!-- Navigation -->
      <div class="flex items-center justify-between">
        <button @click="navigate(-1)" class="p-1 rounded border hover:bg-muted transition-colors">
          <ChevronLeft class="h-4 w-4" />
        </button>
        <span class="text-xs font-medium">
          {{
            viewMode === "day"
              ? new Date(currentDate).toLocaleDateString("es-AR", {
                  weekday: "long",
                  day: "2-digit",
                  month: "long",
                })
              : `Semana del ${dateRange.start.toLocaleDateString("es-AR", {
                  day: "2-digit",
                  month: "short",
                })}`
          }}
        </span>
        <button @click="navigate(1)" class="p-1 rounded border hover:bg-muted transition-colors">
          <ChevronRight class="h-4 w-4" />
        </button>
      </div>

      <!-- Timeline Grid -->
      <div class="overflow-x-auto border rounded-md bg-white">
        <div class="flex min-w-max">
          <!-- Hour column -->
          <div class="w-16 border-r bg-muted/20 shrink-0">
            <div class="h-8 flex items-center justify-center text-xs font-semibold border-b">Hora</div>
            <div v-for="hour in hoursToDisplay" :key="hour" class="h-8 border-t flex items-center justify-center text-xs">
              {{ hour }}
            </div>
          </div>

          <!-- Day columns -->
          <div class="flex">
            <div v-for="day in daysToDisplay" :key="day.date" class="border-r">
              <!-- Day header -->
              <div class="w-20 h-8 border-b flex flex-col items-center justify-center text-xs font-semibold p-1 bg-muted/10">
                <div class="text-center">{{ day.dayName }}</div>
              </div>

              <!-- Slots -->
              <div class="w-20">
                <div
                  v-for="hour in hoursToDisplay"
                  :key="`${day.date}-${hour}`"
                  class="h-8 border-t p-0.5"
                >
                  <!-- Find slot for this hour -->
                  <template v-if="getSlotForDayAndHour(day.date, hour)">
                    <button
                      @click="selectSlot(day.date, getSlotForDayAndHour(day.date, hour)!.time)"
                      :disabled="!getSlotForDayAndHour(day.date, hour)!.available"
                      :class="[
                        'w-full h-full rounded text-xs transition-colors font-medium',
                        getSlotForDayAndHour(day.date, hour)!.available
                          ? 'bg-green-100 hover:bg-green-200 border border-green-300 text-green-900 cursor-pointer'
                          : 'bg-gray-100 border border-gray-200 text-gray-400 cursor-not-allowed opacity-50',
                        selectedDateTime === `${day.date}T${getSlotForDayAndHour(day.date, hour)!.time}:00`
                          ? 'ring-2 ring-primary ring-offset-0'
                          : '',
                      ]"
                      :title="`${day.dayName} ${getSlotForDayAndHour(day.date, hour)!.time}`"
                    >
                      <div class="text-[10px]">{{ getSlotForDayAndHour(day.date, hour)!.time }}</div>
                    </button>
                  </template>
                  <div v-else class="w-full h-full bg-gray-50 border border-gray-100 rounded"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Legend -->
      <div class="flex gap-4 text-xs">
        <div class="flex items-center gap-2">
          <div class="w-4 h-4 bg-green-100 border border-green-300 rounded"></div>
          <span>Disponible</span>
        </div>
        <div class="flex items-center gap-2">
          <div class="w-4 h-4 bg-gray-100 border border-gray-200 rounded"></div>
          <span>Ocupado</span>
        </div>
      </div>

      <!-- Selected Info -->
      <div v-if="selectedDateTime" class="bg-primary/10 border border-primary/30 rounded-md p-3 text-xs">
        <p class="text-primary font-medium">
          ✓ Horario seleccionado:
          <span class="font-semibold">{{ new Date(selectedDateTime).toLocaleString("es-AR") }}</span>
        </p>
      </div>
    </div>

    <!-- No slots message -->
    <div v-else class="text-center py-4">
      <p class="text-xs text-muted-foreground">No hay horarios disponibles para los criterios seleccionados</p>
    </div>
  </div>
</template>
