<script setup lang="ts">
import { ref, computed } from "vue";
import { cn } from "@/lib/utils";
import { ChevronDown, X } from "lucide-vue-next";

interface Option {
  value: string;
  label: string;
}

const props = defineProps<{
  modelValue?: string | number;
  placeholder?: string;
  class?: string;
  options: Option[];
}>();

const emit = defineEmits<{
  "update:modelValue": [value: string | number];
}>();

const isOpen = ref(false);
const searchQuery = ref("");

const filteredOptions = computed(() => {
  if (!searchQuery.value) return props.options;
  const query = searchQuery.value.toLowerCase();
  return props.options.filter(opt => opt.label.toLowerCase().includes(query));
});

const selectedLabel = computed(() => {
  const modelStr = String(props.modelValue);
  return props.options.find(opt => opt.value === modelStr)?.label || "";
});

function selectOption(value: string) {
  emit("update:modelValue", value);
  isOpen.value = false;
  searchQuery.value = "";
}

function clearSelection() {
  emit("update:modelValue", "");
  searchQuery.value = "";
}
</script>

<template>
  <div class="relative w-full">
    <div class="relative">
      <button
        @click="isOpen = !isOpen"
        @keydown.escape="isOpen = false"
        :class="cn(
          'flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 text-left',
          $props.class
        )"
        type="button"
      >
        <span :class="!selectedLabel && 'text-muted-foreground'">
          {{ selectedLabel || placeholder || "Seleccione..." }}
        </span>
        <div class="flex items-center gap-1">
          <X
            v-if="selectedLabel"
            class="h-4 w-4 opacity-50 hover:opacity-100"
            @click.stop="clearSelection"
          />
          <ChevronDown
            :class="['h-4 w-4 opacity-50 transition-transform', isOpen && 'rotate-180']"
          />
        </div>
      </button>

      <!-- Dropdown Menu -->
      <div
        v-if="isOpen"
        class="absolute top-full left-0 right-0 mt-1 z-50 rounded-md border border-input bg-background shadow-md"
      >
        <!-- Search Input -->
        <div class="p-2 border-b border-input">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Buscar..."
            class="w-full px-2 py-1 rounded border border-input bg-background text-sm focus:outline-none focus:ring-1 focus:ring-ring"
            @keydown.escape="isOpen = false"
            @keydown.enter.prevent="
              if (filteredOptions.length === 1) {
                selectOption(filteredOptions[0].value);
              }
            "
          />
        </div>

        <!-- Options List -->
        <div class="max-h-48 overflow-y-auto">
          <div v-if="filteredOptions.length === 0" class="px-3 py-2 text-sm text-muted-foreground text-center">
            No hay opciones
          </div>
          <button
            v-for="option in filteredOptions"
            :key="option.value"
            @click="selectOption(option.value)"
            :class="[
              'w-full px-3 py-2 text-sm text-left hover:bg-primary/10 transition-colors',
              modelValue === option.value && 'bg-primary/20 font-medium'
            ]"
            type="button"
          >
            {{ option.label }}
          </button>
        </div>
      </div>
    </div>

    <!-- Close dropdown when clicking outside -->
    <div
      v-if="isOpen"
      class="fixed inset-0 z-40"
      @click="isOpen = false"
    />
  </div>
</template>
