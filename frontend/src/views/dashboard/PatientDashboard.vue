<template>
  <div class="d-root">
    <div class="d-header">
      <div>
        <div class="d-tag">PORTAL PACIENTE</div>
        <h1 class="d-title">Hola, {{ auth.username }}</h1>
        <p class="d-sub">Tu salud, siempre a mano</p>
      </div>
    </div>

    <div class="kpi-row">
      <div class="kpi" v-for="k in kpis" :key="k.label">
        <div class="kpi-ico" :style="{background:k.bg}"><v-icon :color="k.color" size="20">{{k.icon}}</v-icon></div>
        <div class="kpi-val">{{k.value}}</div>
        <div class="kpi-lbl">{{k.label}}</div>
      </div>
    </div>

    <div class="grid2">
      <div class="card">
        <div class="card-hd"><span class="card-ttl">Próximo Turno</span></div>
        <div class="prox-turno">
          <div class="pt-fecha">
            <div class="pt-dia">15</div>
            <div class="pt-mes">JUL</div>
          </div>
          <div class="pt-detalle">
            <div class="pt-hora">09:30 hs</div>
            <div class="pt-doctor">Dr. Ramos, Pablo</div>
            <div class="pt-esp">Cardiología</div>
            <v-chip size="x-small" color="success" variant="tonal" class="mt-2">Confirmado</v-chip>
          </div>
        </div>
        <div class="pt-lugar">
          <v-icon size="13" color="rgba(255,255,255,0.3)">mdi-map-marker</v-icon>
          <span>Consultorio 3 · Piso 2 · ECOMED Central</span>
        </div>
      </div>

      <div class="card">
        <div class="card-hd"><span class="card-ttl">Mis Turnos</span></div>
        <div class="t-list">
          <div class="t-row" v-for="t in misTurnos" :key="t.id">
            <div class="t-fecha">{{t.fecha}}</div>
            <div class="flex1">
              <div class="row-main">{{t.doctor}}</div>
              <div class="row-sub">{{t.especialidad}}</div>
            </div>
            <v-chip size="x-small" :color="t.color" variant="tonal">{{t.estado}}</v-chip>
          </div>
        </div>
      </div>

      <div class="card" style="grid-column:1/-1">
        <div class="card-hd"><span class="card-ttl">Indicadores de Salud</span></div>
        <div class="salud-grid">
          <div class="salud-card" v-for="s in saludInfo" :key="s.label">
            <div class="salud-ico" :style="{background:s.bg}"><v-icon :color="s.color" size="20">{{s.icon}}</v-icon></div>
            <div class="salud-val">{{s.value}}</div>
            <div class="salud-lbl">{{s.label}}</div>
            <div class="salud-date">{{s.fecha}}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useAuthStore } from '../../stores/auth'
const auth = useAuthStore()
const kpis = [
  {label:'Turnos pendientes',  value:'2',        icon:'mdi-calendar-clock',color:'#3B82F6',bg:'rgba(59,130,246,0.12)'},
  {label:'Obra social',        value:'OSDE 310', icon:'mdi-shield-check',  color:'#10B981',bg:'rgba(16,185,129,0.12)'},
  {label:'Médico de cabecera', value:'Dr. Ramos',icon:'mdi-doctor',        color:'#6366F1',bg:'rgba(99,102,241,0.12)'},
  {label:'Último turno',       value:'01/07',    icon:'mdi-history',       color:'#F59E0B',bg:'rgba(245,158,11,0.12)'},
]
const misTurnos = [
  {id:1,fecha:'15/07',doctor:'Dr. Ramos',    especialidad:'Cardiología',   estado:'Confirmado',color:'#10B981'},
  {id:2,fecha:'22/07',doctor:'Dra. Vidal',   especialidad:'Clínica Médica',estado:'Pendiente', color:'#F59E0B'},
  {id:3,fecha:'01/07',doctor:'Dr. Torres',   especialidad:'Pediatría',     estado:'Completado',color:'#6366F1'},
  {id:4,fecha:'15/06',doctor:'Dra. Morales', especialidad:'Neurología',    estado:'Completado',color:'#6366F1'},
]
const saludInfo = [
  {label:'Presión arterial',value:'120/80',   icon:'mdi-heart-pulse',    color:'#EF4444',bg:'rgba(239,68,68,0.12)',   fecha:'01/07'},
  {label:'Peso',            value:'72 kg',    icon:'mdi-scale-bathroom', color:'#3B82F6',bg:'rgba(59,130,246,0.12)', fecha:'01/07'},
  {label:'Glucemia',        value:'95 mg/dL', icon:'mdi-water',          color:'#F59E0B',bg:'rgba(245,158,11,0.12)', fecha:'28/06'},
  {label:'Colesterol',      value:'185 mg/dL',icon:'mdi-test-tube',      color:'#10B981',bg:'rgba(16,185,129,0.12)', fecha:'15/06'},
]
</script>

<style scoped>
.d-root{padding:32px 36px;min-height:100vh;background:#040D1F;color:#E8EDF5}
.d-header{margin-bottom:28px}
.d-tag{font-size:10px;letter-spacing:2.5px;color:#3B82F6;font-weight:600;margin-bottom:6px}
.d-title{font-size:26px;font-weight:700;color:#F1F5F9;margin:0 0 4px}
.d-sub{font-size:13px;color:rgba(241,245,249,0.4);margin:0}
.kpi-row{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:24px}
.kpi{background:#071628;border:1px solid rgba(255,255,255,0.07);border-radius:16px;padding:18px 16px;display:flex;flex-direction:column;gap:8px;transition:border-color .2s,transform .2s}
.kpi:hover{border-color:rgba(59,130,246,0.3);transform:translateY(-2px)}
.kpi-ico{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;justify-content:center}
.kpi-val{font-size:18px;font-weight:700;color:#F1F5F9}
.kpi-lbl{font-size:11px;color:rgba(241,245,249,0.45)}
.grid2{display:grid;grid-template-columns:1fr 1fr;gap:18px}
.card{background:#071628;border:1px solid rgba(255,255,255,0.07);border-radius:16px;padding:22px}
.card-hd{display:flex;justify-content:space-between;align-items:center;margin-bottom:16px}
.card-ttl{font-size:13px;font-weight:600;color:#F1F5F9}
.flex1{flex:1}
.row-main{font-size:13px;color:#E8EDF5;font-weight:500}
.row-sub{font-size:11px;color:rgba(241,245,249,0.4);margin-top:2px}
.prox-turno{display:flex;gap:20px;align-items:center;padding:16px;background:rgba(59,130,246,0.06);border:1px solid rgba(59,130,246,0.15);border-radius:12px;margin-bottom:12px}
.pt-fecha{text-align:center;min-width:48px}
.pt-dia{font-size:38px;font-weight:700;color:#3B82F6;line-height:1}
.pt-mes{font-size:11px;color:#3B82F6;letter-spacing:2px;font-weight:600}
.pt-hora{font-size:18px;font-weight:700;color:#F1F5F9}
.pt-doctor{font-size:14px;color:#E8EDF5;font-weight:500;margin-top:2px}
.pt-esp{font-size:12px;color:rgba(241,245,249,0.4)}
.pt-lugar{display:flex;align-items:center;gap:6px;font-size:11px;color:rgba(241,245,249,0.3)}
.t-list{display:flex;flex-direction:column;gap:8px}
.t-row{display:flex;align-items:center;gap:12px;padding:10px;background:rgba(255,255,255,0.03);border-radius:10px}
.t-fecha{font-size:12px;font-weight:700;color:#3B82F6;min-width:40px;font-family:monospace}
.salud-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:14px}
.salud-card{background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.06);border-radius:12px;padding:18px;text-align:center}
.salud-ico{width:40px;height:40px;border-radius:10px;display:flex;align-items:center;justify-content:center;margin:0 auto 10px}
.salud-val{font-size:16px;font-weight:700;color:#F1F5F9}
.salud-lbl{font-size:11px;color:rgba(241,245,249,0.45);margin-top:2px}
.salud-date{font-size:10px;color:rgba(241,245,249,0.2);margin-top:4px}
</style>
