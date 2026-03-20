<template>
  <div class="dash-root">
    <div class="dash-header">
      <div>
        <div class="dash-tag">MÉDICO</div>
        <h1 class="dash-title">Buenos días, Dr. Ramos</h1>
        <p class="dash-sub">{{ fecha }} · Tenés {{ turnosHoy }} turnos programados hoy</p>
      </div>
      <div class="live-badge"><span class="live-dot" />EN VIVO</div>
    </div>

    <div class="kpi-grid">
      <div class="kpi-card" v-for="k in kpis" :key="k.label">
        <div class="kpi-icon" :style="{ background: k.bg }"><v-icon :color="k.color" size="20">{{ k.icon }}</v-icon></div>
        <div><div class="kpi-value">{{ k.value }}</div><div class="kpi-label">{{ k.label }}</div></div>
      </div>
    </div>

    <div class="main-grid">
      <div class="panel" style="grid-column: 1 / -1">
        <div class="panel-header">
          <span class="panel-title">Agenda del Día</span>
          <v-chip size="x-small" color="#00C896" variant="tonal">{{ fecha }}</v-chip>
        </div>
        <div class="agenda-list">
          <div class="agenda-item" v-for="t in agenda" :key="t.id" :class="{ current: t.current }">
            <div class="agenda-time">
              <div class="time-main">{{ t.hora }}</div>
              <div class="time-dur">{{ t.duracion }}</div>
            </div>
            <div class="agenda-line"><div class="line-dot" :class="{ active: t.current }"/></div>
            <div class="agenda-body">
              <div class="agenda-paciente">{{ t.paciente }}</div>
              <div class="agenda-tipo">{{ t.tipo }}</div>
              <div class="agenda-tags">
                <v-chip size="x-small" :color="t.color" variant="tonal">{{ t.estado }}</v-chip>
                <span class="agenda-os">{{ t.os }}</span>
              </div>
            </div>
            <v-btn v-if="t.current" size="x-small" color="#00C896" variant="tonal">Ver HCE</v-btn>
          </div>
        </div>
      </div>

      <div class="panel">
        <div class="panel-header"><span class="panel-title">Últimos Pacientes</span></div>
        <div class="paciente-list">
          <div class="paciente-item" v-for="p in pacientes" :key="p.id">
            <v-avatar size="36" color="#1E293B">
              <v-icon size="18" color="#00C896">mdi-account</v-icon>
            </v-avatar>
            <div class="pac-body">
              <div class="pac-nombre">{{ p.nombre }}</div>
              <div class="pac-info">{{ p.edad }} años · {{ p.os }}</div>
            </div>
            <div class="pac-fecha">{{ p.ultima }}</div>
          </div>
        </div>
      </div>

      <div class="panel">
        <div class="panel-header"><span class="panel-title">Recordatorios</span></div>
        <div class="reminder-list">
          <div class="reminder-item" v-for="r in recordatorios" :key="r.id">
            <div class="reminder-icon" :style="{ background: r.bg }">
              <v-icon :color="r.color" size="16">{{ r.icon }}</v-icon>
            </div>
            <div class="reminder-body">
              <div class="reminder-text">{{ r.texto }}</div>
              <div class="reminder-time">{{ r.tiempo }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
const fecha = computed(() => new Date().toLocaleDateString('es-AR', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }))
const turnosHoy = 8
const kpis = [
  { label: 'Turnos hoy',      value: '8',  icon: 'mdi-calendar-today',  color: '#00C896', bg: 'rgba(0,200,150,0.1)'   },
  { label: 'Completados',     value: '3',  icon: 'mdi-check-circle',    color: '#10B981', bg: 'rgba(16,185,129,0.1)'  },
  { label: 'En espera',       value: '5',  icon: 'mdi-clock-outline',   color: '#F59E0B', bg: 'rgba(245,158,11,0.1)'  },
  { label: 'Pacientes total', value: '142',icon: 'mdi-account-multiple', color: '#3B82F6', bg: 'rgba(59,130,246,0.1)' },
]
const agenda = [
  { id:1, hora:'08:00', duracion:'30m', paciente:'García, María Elena', tipo:'Control cardiológico', estado:'Completado', color:'#10B981', os:'OSDE',   current:false },
  { id:2, hora:'08:30', duracion:'30m', paciente:'López, Carlos',       tipo:'Primera consulta',     estado:'Completado', color:'#10B981', os:'Swiss Medical', current:false },
  { id:3, hora:'09:00', duracion:'45m', paciente:'Fernández, Roberto',  tipo:'ECG + Control',        estado:'En curso',   color:'#00C896', os:'PAMI',   current:true  },
  { id:4, hora:'09:45', duracion:'30m', paciente:'Martínez, Ana',       tipo:'Resultado estudios',   estado:'Pendiente',  color:'#F59E0B', os:'Galeno', current:false },
  { id:5, hora:'10:30', duracion:'30m', paciente:'Rodríguez, Luis',     tipo:'Control rutina',       estado:'Pendiente',  color:'#F59E0B', os:'OSDE',   current:false },
]
const pacientes = [
  { id:1, nombre:'García, María Elena', edad:58, os:'OSDE',         ultima:'hoy' },
  { id:2, nombre:'López, Carlos',       edad:42, os:'Swiss Medical', ultima:'hoy' },
  { id:3, nombre:'Pérez, Susana',       edad:67, os:'PAMI',         ultima:'ayer' },
  { id:4, nombre:'Torres, Marcelo',     edad:35, os:'Galeno',       ultima:'lunes' },
]
const recordatorios = [
  { id:1, texto:'Enviar resultado a García, María', tiempo:'Urgente', icon:'mdi-alert', color:'#EF4444', bg:'rgba(239,68,68,0.1)' },
  { id:2, texto:'Reunión de staff 13:00hs', tiempo:'En 3 horas', icon:'mdi-account-group', color:'#3B82F6', bg:'rgba(59,130,246,0.1)' },
  { id:3, texto:'Actualizar protocolo HTA', tiempo:'Esta semana', icon:'mdi-file-edit', color:'#F59E0B', bg:'rgba(245,158,11,0.1)' },
]
</script>

<style scoped>
.dash-root { padding: 32px 36px; min-height: 100vh; background: #0A0F1E; font-family: 'DM Sans', sans-serif; }
.dash-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 28px; }
.dash-tag { font-size: 10px; letter-spacing: 2.5px; color: #00C896; font-weight: 600; margin-bottom: 6px; }
.dash-title { font-family: 'Playfair Display', serif; font-size: 26px; color: #E8EDF5; margin: 0 0 4px; font-weight: 600; }
.dash-sub { font-size: 13px; color: rgba(255,255,255,0.35); margin: 0; text-transform: capitalize; }
.live-badge { display: flex; align-items: center; gap: 6px; font-size: 11px; font-weight: 600; color: #00C896; background: rgba(0,200,150,0.08); border: 1px solid rgba(0,200,150,0.2); padding: 6px 12px; border-radius: 20px; }
.live-dot { width: 6px; height: 6px; background: #00C896; border-radius: 50%; animation: pd 1.5s infinite; }
@keyframes pd { 0%,100%{opacity:1} 50%{opacity:0.3} }
.kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px; }
.kpi-card { background: #111827; border: 1px solid rgba(255,255,255,0.06); border-radius: 14px; padding: 18px 16px; display: flex; gap: 14px; align-items: center; transition: border-color 0.2s; }
.kpi-card:hover { border-color: rgba(0,200,150,0.25); }
.kpi-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.kpi-value { font-size: 22px; font-weight: 700; color: #E8EDF5; }
.kpi-label { font-size: 11.5px; color: rgba(255,255,255,0.4); }
.main-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.panel { background: #111827; border: 1px solid rgba(255,255,255,0.06); border-radius: 14px; padding: 20px; }
.panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.panel-title { font-size: 13px; font-weight: 600; color: #E8EDF5; }
.agenda-list { display: flex; flex-direction: column; gap: 0; }
.agenda-item { display: flex; align-items: flex-start; gap: 14px; padding: 12px; border-radius: 10px; transition: background 0.15s; }
.agenda-item:hover { background: rgba(255,255,255,0.03); }
.agenda-item.current { background: rgba(0,200,150,0.06); border: 1px solid rgba(0,200,150,0.15); }
.agenda-time { min-width: 50px; }
.time-main { font-size: 13px; font-weight: 700; color: #00C896; font-family: monospace; }
.time-dur { font-size: 10px; color: rgba(255,255,255,0.25); }
.agenda-line { display: flex; flex-direction: column; align-items: center; padding-top: 4px; }
.line-dot { width: 8px; height: 8px; border-radius: 50%; background: rgba(255,255,255,0.15); }
.line-dot.active { background: #00C896; box-shadow: 0 0 8px rgba(0,200,150,0.5); }
.agenda-body { flex: 1; }
.agenda-paciente { font-size: 13.5px; color: #E8EDF5; font-weight: 500; }
.agenda-tipo { font-size: 11.5px; color: rgba(255,255,255,0.35); margin: 2px 0 6px; }
.agenda-tags { display: flex; align-items: center; gap: 8px; }
.agenda-os { font-size: 10.5px; color: rgba(255,255,255,0.25); }
.paciente-list { display: flex; flex-direction: column; gap: 10px; }
.paciente-item { display: flex; align-items: center; gap: 12px; padding: 8px; border-radius: 8px; }
.paciente-item:hover { background: rgba(255,255,255,0.03); }
.pac-body { flex: 1; }
.pac-nombre { font-size: 13px; color: #E8EDF5; font-weight: 500; }
.pac-info { font-size: 11px; color: rgba(255,255,255,0.3); margin-top: 2px; }
.pac-fecha { font-size: 11px; color: rgba(255,255,255,0.25); }
.reminder-list { display: flex; flex-direction: column; gap: 10px; }
.reminder-item { display: flex; align-items: center; gap: 12px; padding: 10px; border-radius: 8px; background: rgba(255,255,255,0.03); }
.reminder-icon { width: 32px; height: 32px; border-radius: 8px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.reminder-text { font-size: 12.5px; color: rgba(255,255,255,0.65); }
.reminder-time { font-size: 11px; color: rgba(255,255,255,0.25); margin-top: 2px; }
</style>