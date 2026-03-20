<script setup lang="ts">
import { RouterLink } from "vue-router";
import Button from "@/components/ui/Button.vue";
import Card from "@/components/ui/Card.vue";
import CardContent from "@/components/ui/CardContent.vue";
import { Stethoscope, Scan, BrainCircuit, Bone, Heart, Zap } from "lucide-vue-next";

const services = [
  {
    icon: Stethoscope, name: "Ecografía",
    desc: "Estudios por ultrasonido para evaluar órganos internos, embarazo, tiroides, partes blandas y sistema vascular. Procedimiento no invasivo, indoloro y sin radiación.",
  },
  {
    icon: Scan, name: "Radiología Digital",
    desc: "Radiografías digitales de alta resolución con mínima exposición a radiación. Incluye radiología general, ósea, torácica y contrastada.",
  },
  {
    icon: BrainCircuit, name: "Tomografía Computada",
    desc: "Tomografía multicorte de alta velocidad para estudios cerebrales, torácicos, abdominales y vasculares. Diagnósticos precisos con tiempos de adquisición mínimos.",
  },
  {
    icon: Zap, name: "Resonancia Magnética",
    desc: "Resonancia magnética de alto campo (1.5T) para estudios neurológicos, musculoesqueléticos, abdominales y cardíacos. Sin exposición a radiación.",
  },
  {
    icon: Heart, name: "Mamografía Digital",
    desc: "Mamografía digital de alta definición para detección temprana de cáncer de mama. Incluye tomosíntesis mamaria para mayor precisión diagnóstica.",
  },
  {
    icon: Bone, name: "Densitometría Ósea",
    desc: "Evaluación de la densidad mineral ósea para diagnóstico y seguimiento de osteoporosis. Método rápido, preciso y con mínima exposición.",
  },
];
</script>

<template>
  <section class="bg-muted/50 py-12 md:py-16">
    <div class="container text-center max-w-2xl">
      <h1 class="text-3xl md:text-4xl font-bold mb-3">Nuestros Servicios</h1>
      <p class="text-muted-foreground">Contamos con equipamiento de última generación para brindarle estudios de diagnóstico por imágenes con la máxima calidad y precisión.</p>
    </div>
  </section>

  <section class="py-12 md:py-20">
    <div class="container">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card v-for="s in services" :key="s.name" class="hover:shadow-md transition-shadow">
          <CardContent class="p-6 flex gap-4">
            <div class="rounded-lg bg-accent p-3 shrink-0 h-fit">
              <component :is="s.icon" class="h-7 w-7 text-accent-foreground" />
            </div>
            <div class="space-y-2 flex-1">
              <h2 class="text-xl font-semibold">{{ s.name }}</h2>
              <p class="text-sm text-muted-foreground leading-relaxed">{{ s.desc }}</p>
              <RouterLink to="/reservar">
                <Button size="sm" class="mt-2">Reservar Turno</Button>
              </RouterLink>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  </section>
</template>
