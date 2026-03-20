<!-- src/views/dashboard/PatientDashboard.vue -->
<template>
  <div class="dash-root">
    <div class="dash-header">
      <div>
        <div class="dash-tag">PORTAL PACIENTE</div>
        <h1 class="dash-title">Hola, bienvenido</h1>
        <p class="dash-sub">Tu salud, siempre a mano</p>
      </div>
    </div>

    <div class="kpi-grid">
      <div class="kpi-card" v-for="k in kpis" :key="k.label">
        <div class="kpi-icon" :style="{ background: k.bg }"><v-icon :color="k.color" size="22">{{ k.icon }}</v-icon></div>
        <div><div class="kpi-value">{{ k.value }}</div><div class="kpi-label">{{ k.label }}</div></div>
      </div>
    </div>

    <div class="main-grid">
      <div class="panel">
        <div class="panel-header">
          <span class="panel-title">Próximo Turno</span>
        </div>
        <div class="proximo-turno">
          <div class="turno-fecha">
            <div class="fecha-dia">15</div>
            <div class="fecha-mes">JUL</div>
          </div>
          <div class="turno-detalle">
            <div class="turno-hora-big">09:30 hs</div>
            <div class="turno-doctor-big">Dr. Ramos, Pablo</div>
            <div class="turno-esp">Cardiología</div>
            <v-chip size="x-small" color="#00C896" variant="tonal" class="mt-2">Confirmado</v-chip>
          </div>
        </div>
        <div class="turno-lugar">
          <v-icon size="14" color="rgba(255,255,255,0.3)">mdi-map-marker</v-icon>
          <span>Consultorio 3 · Piso 2 · Ecomed Central</span>
        </div>
      </div>

      <div class="panel">
        <div class="panel-header"><span class="panel-title">Mis Turnos</span></div>
        <div class="mis-turnos">
          <div class="mi-turno-item" v-for="t in misTurnos" :key="t.id">
            <div class="mt-fecha">{{ t.fecha }}</div>
            <div class="mt-body">
              <div class="mt-doctor">{{ t.doctor }}</div>
              <div class="mt-esp">{{ t.especialidad }}</div>
            </div>
            <v-chip size="x-small" :color="t.color" variant="tonal">{{ t.estado }}</v-chip>
          </div>
        </div>
      </div>

      <div class="panel panel-wide">
        <div class="panel-header"><span class="panel-title">Información de Salud</span></div>
        <div class="salud-grid">
          <div class="salud-card" v-for="s in saludInfo" :key="s.label">
            <div class="salud-icon" :style="{ background: s.bg }"><v-icon :color="s.color" size="20">{{ s.icon }}</v-icon></div>
            <div class="salud-val">{{ s.value }}</div>
            <div class="salud-lbl">{{ s.label }}</div>
            <div class="salud-date">{{ s.fecha }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const kpis = [
  { label:'Turnos pendientes', value:'2',         icon:'mdi-calendar-clock',   color:'#00C896', bg:'rgba(0,200,150,0.1)'  },
  { label:'Obra social',       value:'OSDE 310',  icon:'mdi-shield-check',     color:'#3B82F6', bg:'rgba(59,130,246,0.1)' },
  { label:'Médico de cabecera',value:'Dr. Ramos', icon:'mdi-doctor',           color:'#F59E0B', bg:'rgba(245,158,11,0.1)' },
  { label:'Último turno',      value:'01/07',     icon:'mdi-history',          color:'#10B981', bg:'rgba(16,185,129,0.1)' },
]
const misTurnos = [
  { id:1, fecha:'15/07', doctor:'Dr. Ramos',    especialidad:'Cardiología',   estado:'Confirmado', color:'#00C896' },
  { id:2, fecha:'22/07', doctor:'Dra. Vidal',   especialidad:'Clínica Médica',estado:'Pendiente',  color:'#F59E0B' },
  { id:3, fecha:'01/07', doctor:'Dr. Torres',   especialidad:'Pediatría',     estado:'Completado', color:'#10B981' },
  { id:4, fecha:'15/06', doctor:'Dra. Morales', especialidad:'Neurología',    estado:'Completado', color:'#10B981' },
]
const saludInfo = [
  { label:'Presión arterial', value:'120/80',   icon:'mdi-heart-pulse',   color:'#EF4444', bg:'rgba(239,68,68,0.1)',  fecha:'01/07' },
  { label:'Peso',             value:'72 kg',    icon:'mdi-scale-bathroom',color:'#3B82F6', bg:'rgba(59,130,246,0.1)',fecha:'01/07' },
  { label:'Glucemia',         value:'95 mg/dL', icon:'mdi-water',         color:'#F59E0B', bg:'rgba(245,158,11,0.1)',fecha:'28/06' },
  { label:'Colesterol',       value:'185 mg/dL',icon:'mdi-test-tube',     color:'#10B981', bg:'rgba(16,185,129,0.1)',fecha:'15/06' },
]
</script>

<style scoped>
.dash-root { padding: 32px 36px; min-height: 100vh; background: #0A0F1E; font-family: 'DM Sans', sans-serif; }
.dash-header { margin-bottom: 28px; }
.dash-tag { font-size: 10px; letter-spacing: 2.5px; color: #00C896; font-weight: 600; margin-bottom: 6px; }
.dash-title { font-family: 'Playfair Display', serif; font-size: 26px; color: #E8EDF5; margin: 0 0 4px; font-weight: 600; }
.dash-sub { font-size: 13px; color: rgba(255,255,255,0.35); margin: 0; }
.kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px; }
.kpi-card { background: #111827; border: 1px solid rgba(255,255,255,0.06); border-radius: 14px; padding: 18px 16px; display: flex; gap: 14px; align-items: center; }
.kpi-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.kpi-value { font-size: 16px; font-weight: 700; color: #E8EDF5; }
.kpi-label { font-size: 11px; color: rgba(255,255,255,0.4); }
.main-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.panel { background: #111827; border: 1px solid rgba(255,255,255,0.06); border-radius: 14px; padding: 20px; }
.panel-wide { grid-column: 1 / -1; }
.panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.panel-title { font-size: 13px; font-weight: 600; color: #E8EDF5; }
.proximo-turno { display: flex; gap: 20px; align-items: center; padding: 16px; background: rgba(0,200,150,0.06); border: 1px solid rgba(0,200,150,0.15); border-radius: 12px; margin-bottom: 12px; }
.turno-fecha { text-align: center; }
.fecha-dia { font-family: 'Playfair Display', serif; font-size: 36px; color: #00C896; font-weight: 700; line-height: 1; }
.fecha-mes { font-size: 11px; color: #00C896; letter-spacing: 2px; font-weight: 600; }
.turno-hora-big { font-size: 18px; font-weight: 700; color: #E8EDF5; }
.turno-doctor-big { font-size: 14px; color: #E8EDF5; font-weight: 500; margin-top: 2px; }
.turno-esp { font-size: 12px; color: rgba(255,255,255,0.35); }
.turno-lugar { display: flex; align-items: center; gap: 6px; font-size: 11.5px; color: rgba(255,255,255,0.3); }
.mis-turnos { display: flex; flex-direction: column; gap: 10px; }
.mi-turno-item { display: flex; align-items: center; gap: 12px; padding: 10px; background: rgba(255,255,255,0.03); border-radius: 8px; }
.mt-fecha { font-size: 12px; font-weight: 700; color: #00C896; min-width: 40px; font-family: monospace; }
.mt-body { flex: 1; }
.mt-doctor { font-size: 13px; color: #E8EDF5; font-weight: 500; }
.mt-esp { font-size: 11px; color: rgba(255,255,255,0.3); margin-top: 2px; }
.salud-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
.salud-card { background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.06); border-radius: 12px; padding: 16px; text-align: center; }
.salud-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; margin: 0 auto 10px; }
.salud-val { font-size: 16px; font-weight: 700; color: #E8EDF5; }
.salud-lbl { font-size: 11px; color: rgba(255,255,255,0.4); margin-top: 2px; }
.salud-date { font-size: 10px; color: rgba(255,255,255,0.2); margin-top: 4px; }
</style>