<template>
  <div class="d-root">
    <div class="d-header">
      <div>
        <div class="d-tag">MÉDICO</div>
        <h1 class="d-title">Buenos días, Dr. {{ auth.username }}</h1>
        <p class="d-sub">{{ fecha }} · {{ turnosHoy }} turnos programados</p>
      </div>
      <div class="live-pill"><span class="live-dot"/>EN VIVO</div>
    </div>

    <div class="kpi-row">
      <div class="kpi" v-for="k in kpis" :key="k.label">
        <div class="kpi-ico" :style="{background:k.bg}"><v-icon :color="k.color" size="20">{{k.icon}}</v-icon></div>
        <div class="kpi-val">{{k.value}}</div>
        <div class="kpi-lbl">{{k.label}}</div>
      </div>
    </div>

    <div class="grid2">
      <div class="card" style="grid-column:1/-1">
        <div class="card-hd">
          <span class="card-ttl">Agenda del Día</span>
          <v-chip size="x-small" color="primary" variant="tonal">{{fecha}}</v-chip>
        </div>
        <div class="agenda">
          <div class="ag-row" v-for="t in agenda" :key="t.id" :class="{current:t.current}">
            <div class="ag-time"><div class="ag-hr">{{t.hora}}</div><div class="ag-dur">{{t.dur}}</div></div>
            <div class="ag-dot-wrap"><div class="ag-dot" :class="{active:t.current}"/></div>
            <div class="flex1">
              <div class="row-main">{{t.paciente}}</div>
              <div class="row-sub">{{t.tipo}} · <span class="os-tag">{{t.os}}</span></div>
            </div>
            <v-chip size="x-small" :color="t.color" variant="tonal">{{t.estado}}</v-chip>
            <v-btn v-if="t.current" size="x-small" color="primary" variant="tonal">Ver HCE</v-btn>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-hd"><span class="card-ttl">Últimos Pacientes</span></div>
        <div class="pac-list">
          <div class="pac-row" v-for="p in pacientes" :key="p.id">
            <v-avatar size="36" color="rgba(59,130,246,0.15)">
              <v-icon size="18" color="#3B82F6">mdi-account</v-icon>
            </v-avatar>
            <div class="flex1">
              <div class="row-main">{{p.nombre}}</div>
              <div class="row-sub">{{p.edad}} años · {{p.os}}</div>
            </div>
            <div class="muted" style="font-size:11px">{{p.ultima}}</div>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-hd"><span class="card-ttl">Recordatorios</span></div>
        <div class="rem-list">
          <div class="rem-row" v-for="r in recordatorios" :key="r.id">
            <div class="rem-ico" :style="{background:r.bg}"><v-icon :color="r.color" size="16">{{r.icon}}</v-icon></div>
            <div class="flex1">
              <div class="row-main">{{r.texto}}</div>
              <div class="row-sub">{{r.tiempo}}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useAuthStore } from '../../stores/auth'
const auth = useAuthStore()
const fecha = computed(() => new Date().toLocaleDateString('es-AR',{weekday:'long',year:'numeric',month:'long',day:'numeric'}))
const turnosHoy = 8
const kpis = [
  {label:'Turnos hoy',    value:'8',   icon:'mdi-calendar-today',    color:'#3B82F6',bg:'rgba(59,130,246,0.12)'},
  {label:'Completados',   value:'3',   icon:'mdi-check-circle',      color:'#10B981',bg:'rgba(16,185,129,0.12)'},
  {label:'En espera',     value:'5',   icon:'mdi-clock-outline',     color:'#F59E0B',bg:'rgba(245,158,11,0.12)'},
  {label:'Mis pacientes', value:'142', icon:'mdi-account-multiple',  color:'#6366F1',bg:'rgba(99,102,241,0.12)'},
]
const agenda = [
  {id:1,hora:'08:00',dur:'30m',paciente:'García, María Elena',tipo:'Control cardiológico', estado:'Completado',color:'#10B981',os:'OSDE',  current:false},
  {id:2,hora:'08:30',dur:'30m',paciente:'López, Carlos',      tipo:'Primera consulta',     estado:'Completado',color:'#10B981',os:'Swiss', current:false},
  {id:3,hora:'09:00',dur:'45m',paciente:'Fernández, Roberto', tipo:'ECG + Control',        estado:'En curso',  color:'#3B82F6',os:'PAMI',  current:true},
  {id:4,hora:'09:45',dur:'30m',paciente:'Martínez, Ana',      tipo:'Resultado estudios',   estado:'Pendiente', color:'#F59E0B',os:'Galeno',current:false},
  {id:5,hora:'10:30',dur:'30m',paciente:'Rodríguez, Luis',    tipo:'Control rutina',       estado:'Pendiente', color:'#F59E0B',os:'OSDE',  current:false},
]
const pacientes = [
  {id:1,nombre:'García, María Elena',edad:58,os:'OSDE',  ultima:'hoy'},
  {id:2,nombre:'López, Carlos',      edad:42,os:'Swiss', ultima:'hoy'},
  {id:3,nombre:'Pérez, Susana',      edad:67,os:'PAMI',  ultima:'ayer'},
  {id:4,nombre:'Torres, Marcelo',    edad:35,os:'Galeno',ultima:'lunes'},
]
const recordatorios = [
  {id:1,texto:'Enviar resultado a García, María',   tiempo:'Urgente',    icon:'mdi-alert',        color:'#EF4444',bg:'rgba(239,68,68,0.12)'},
  {id:2,texto:'Reunión de staff 13:00 hs',          tiempo:'En 3 horas', icon:'mdi-account-group',color:'#3B82F6',bg:'rgba(59,130,246,0.12)'},
  {id:3,texto:'Actualizar protocolo HTA',           tiempo:'Esta semana',icon:'mdi-file-edit',    color:'#F59E0B',bg:'rgba(245,158,11,0.12)'},
]
</script>

<style scoped>
.d-root{padding:32px 36px;min-height:100vh;background:#040D1F;color:#E8EDF5}
.d-header{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:28px}
.d-tag{font-size:10px;letter-spacing:2.5px;color:#3B82F6;font-weight:600;margin-bottom:6px}
.d-title{font-size:26px;font-weight:700;color:#F1F5F9;margin:0 0 4px}
.d-sub{font-size:13px;color:rgba(241,245,249,0.4);margin:0;text-transform:capitalize}
.live-pill{display:flex;align-items:center;gap:6px;font-size:11px;font-weight:600;color:#3B82F6;background:rgba(59,130,246,0.1);border:1px solid rgba(59,130,246,0.25);padding:7px 14px;border-radius:20px}
.live-dot{width:7px;height:7px;background:#3B82F6;border-radius:50%;animation:blink 1.5s infinite}
@keyframes blink{0%,100%{opacity:1}50%{opacity:0.3}}
.kpi-row{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:24px}
.kpi{background:#071628;border:1px solid rgba(255,255,255,0.07);border-radius:16px;padding:18px 16px;display:flex;flex-direction:column;gap:8px;transition:border-color .2s,transform .2s}
.kpi:hover{border-color:rgba(59,130,246,0.3);transform:translateY(-2px)}
.kpi-ico{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;justify-content:center}
.kpi-val{font-size:22px;font-weight:700;color:#F1F5F9}
.kpi-lbl{font-size:11px;color:rgba(241,245,249,0.45)}
.grid2{display:grid;grid-template-columns:1fr 1fr;gap:18px}
.card{background:#071628;border:1px solid rgba(255,255,255,0.07);border-radius:16px;padding:22px}
.card-hd{display:flex;justify-content:space-between;align-items:center;margin-bottom:16px}
.card-ttl{font-size:13px;font-weight:600;color:#F1F5F9}
.flex1{flex:1}
.row-main{font-size:13px;color:#E8EDF5;font-weight:500}
.row-sub{font-size:11px;color:rgba(241,245,249,0.4);margin-top:2px}
.muted{color:rgba(241,245,249,0.3)}
.agenda{display:flex;flex-direction:column;gap:4px}
.ag-row{display:flex;align-items:center;gap:14px;padding:12px;border-radius:10px;transition:background .15s}
.ag-row:hover{background:rgba(255,255,255,0.03)}
.ag-row.current{background:rgba(59,130,246,0.07);border:1px solid rgba(59,130,246,0.2)}
.ag-time{min-width:50px}
.ag-hr{font-size:13px;font-weight:700;color:#3B82F6;font-family:monospace}
.ag-dur{font-size:10px;color:rgba(241,245,249,0.25)}
.ag-dot-wrap{display:flex;align-items:center;padding-top:2px}
.ag-dot{width:8px;height:8px;border-radius:50%;background:rgba(255,255,255,0.15)}
.ag-dot.active{background:#3B82F6;box-shadow:0 0 8px rgba(59,130,246,0.5)}
.os-tag{color:rgba(241,245,249,0.3)}
.pac-list,.rem-list{display:flex;flex-direction:column;gap:10px}
.pac-row{display:flex;align-items:center;gap:12px;padding:8px;border-radius:8px}
.pac-row:hover{background:rgba(255,255,255,0.03)}
.rem-row{display:flex;align-items:center;gap:12px;padding:10px;background:rgba(255,255,255,0.03);border-radius:10px}
.rem-ico{width:32px;height:32px;border-radius:8px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
</style>
