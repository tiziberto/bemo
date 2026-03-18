<template>
  <v-container class="fill-height justify-center bg-background">
    <v-card width="800" class="glass-card pa-6" elevation="10">
      
      <div class="d-flex justify-space-between align-center mb-6">
        <div>
          <h2 class="text-h4 font-weight-bold text-white">Conciliación de Carga</h2>
          <div class="text-subtitle-1 text-grey">Orden #{{ conciliacion?.numeroOrden }}</div>
        </div>
        <v-chip color="success" variant="flat" size="large">FINALIZADA</v-chip>
      </div>

      <v-divider class="mb-6 border-opacity-25"></v-divider>

      <v-row v-if="conciliacion">
        <v-col cols="6">
          <div class="text-caption text-grey text-uppercase mb-1">Pesaje Inicial (Tara)</div>
          <div class="text-h5 text-white font-weight-medium">{{ conciliacion.pesajeInicial }} kg</div>
        </v-col>
        <v-col cols="6" class="text-right">
          <div class="text-caption text-grey text-uppercase mb-1">Pesaje Final</div>
          <div class="text-h5 text-white font-weight-medium">{{ conciliacion.pesajeFinal }} kg</div>
        </v-col>
      </v-row>

      <v-sheet color="rgba(255,255,255,0.05)" class="rounded-lg pa-4 my-6">
        <v-row>
          <v-col cols="4" class="text-center border-e">
            <div class="text-caption text-grey">Neto Balanza</div>
            <div class="text-h6 text-white">{{ conciliacion?.netoBalanza }} kg</div>
          </v-col>
          <v-col cols="4" class="text-center border-e">
            <div class="text-caption text-grey">Total Caudalímetro</div>
            <div class="text-h6 text-white">{{ conciliacion?.productoCargado }} kg</div>
          </v-col>
          <v-col cols="4" class="text-center">
            <div class="text-caption text-grey">Diferencia</div>
            <div class="text-h6" :class="Math.abs(conciliacion?.diferenciaBalanzaCaudalimetro || 0) > 50 ? 'text-red' : 'text-green'">
              {{ conciliacion?.diferenciaBalanzaCaudalimetro.toFixed(2) }} kg
            </div>
          </v-col>
        </v-row>
      </v-sheet>

      <div class="text-overline text-grey mb-2">Promedios del Proceso</div>
      <v-row dense>
        <v-col cols="4">
          <v-card color="surface" variant="outlined" class="pa-3 text-center border-grey">
            <v-icon color="red" class="mb-1">mdi-thermometer</v-icon>
            <div class="text-h6 text-white">{{ conciliacion?.promedioTemperatura?.toFixed(1) }} °C</div>
            <div class="text-caption text-grey">Temp. Media</div>
          </v-card>
        </v-col>
        <v-col cols="4">
          <v-card color="surface" variant="outlined" class="pa-3 text-center border-grey">
            <v-icon color="blue" class="mb-1">mdi-beaker</v-icon>
            <div class="text-h6 text-white">{{ conciliacion?.promedioDensidad?.toFixed(3) }}</div>
            <div class="text-caption text-grey">Densidad Media</div>
          </v-card>
        </v-col>
        <v-col cols="4">
          <v-card color="surface" variant="outlined" class="pa-3 text-center border-grey">
            <v-icon color="cyan" class="mb-1">mdi-speedometer</v-icon>
            <div class="text-h6 text-white">{{ conciliacion?.promedioCaudal?.toFixed(0) }}</div>
            <div class="text-caption text-grey">Caudal Medio</div>
          </v-card>
        </v-col>
      </v-row>

      <div class="d-flex justify-end gap-4 mt-8">
        <v-btn variant="text" color="grey" to="/ordenes">Volver</v-btn>
        <v-btn 
          color="primary" 
          prepend-icon="mdi-file-pdf-box" 
          size="large"
          @click="generarPDF"
        >
          Exportar PDF
        </v-btn>
      </div>

    </v-card>
  </v-container>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import api from '../api/api';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

const route = useRoute();
const conciliacion = ref<any>(null);

onMounted(async () => {
  const idOrden = Number(route.params.id);
  try {
    const { data } = await api.getConciliacion(idOrden);
    conciliacion.value = data;
  } catch (e) {
    alert("Error cargando conciliación");
  }
});

const generarPDF = () => {
  if (!conciliacion.value) return;
  const doc = new jsPDF();
  const c = conciliacion.value;

  doc.setFontSize(18);
  doc.text(`Certificado de Conciliación - Orden #${c.numeroOrden}`, 14, 20);
  
  doc.setFontSize(12);
  doc.text(`Fecha de Emisión: ${new Date().toLocaleDateString()}`, 14, 30);

  autoTable(doc, {
    startY: 40,
    head: [['Concepto', 'Valor', 'Unidad']],
    body: [
      ['Pesaje Inicial (Tara)', c.pesajeInicial, 'kg'],
      ['Pesaje Final', c.pesajeFinal, 'kg'],
      ['Neto Balanza', c.netoBalanza, 'kg'],
      ['Total por Caudalímetro', c.productoCargado, 'kg'],
      ['Diferencia', c.diferenciaBalanzaCaudalimetro.toFixed(2), 'kg'],
      ['Temperatura Promedio', c.promedioTemperatura.toFixed(1), '°C'],
      ['Densidad Promedio', c.promedioDensidad.toFixed(3), 'kg/m³'],
    ],
    theme: 'grid',
    headStyles: { fillColor: [41, 128, 185] }
  });

  doc.save(`conciliacion_orden_${c.numeroOrden}.pdf`);
};
</script>

<style scoped>
.bg-background { background-color: #0f172a !important; }
.glass-card {
  background: #1e293b !important;
  border: 1px solid rgba(255, 255, 255, 0.1);
}
.border-grey { border-color: rgba(255,255,255,0.1) !important; }
</style>