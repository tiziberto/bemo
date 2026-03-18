<template>
  <v-card
    class="pa-4 rounded-lg"
    style="
      background: rgba(30,41,59,0.8);
      border: 1px solid rgba(255,255,255,0.05);
    "
  >
    <div class="text-caption text-grey">
      {{ title }}
    </div>

    <div
      class="text-h6 font-weight-bold mt-1"
      :class="highlightClass"
    >
      {{ value }}
    </div>
  </v-card>
</template>

<script setup lang="ts">
import { computed } from "vue"

const props = defineProps({
  title: String,
  value: String,
  highlight: String
})

const highlightClass = computed(() => {
  if (props.highlight === "warning") return "text-warning"
  if (props.highlight === "error") return "text-error"
  if (props.highlight === "success") return "text-success"
  return ""
})
</script>

