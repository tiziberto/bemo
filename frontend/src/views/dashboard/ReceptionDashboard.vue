<template>
  <div class="d-root">
    <div class="d-header">
      <div>
        <div class="d-tag">RECEPCIÓN</div>
        <h1 class="d-title">Gestión de Turnos</h1>
        <p class="d-sub">{{ fecha }} · {{ enEspera }} pacientes en sala de espera</p>
      </div>
      <v-btn color="primary" variant="flat" prepend-icon="mdi-plus" size="small">
        Nuevo Turno
      </v-btn>
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
          <span class="card-ttl">Turnos del Día</span>
          <div style="display:flex;gap:8px">
            <v-chip v-for="f in filtros" :key="f.label"
              size="x-small" :color="filtroActivo===f.val?'primary':'default'"
              :variant="filtroActivo===f.val?'flat':'tonal'"
              style="cursor:pointer" @click="filtroActivo=f.val">
              {{f.label}}
            </v-chip>
          </div>
        </div>
        <table class="tbl">
          <thead><tr><th>Hora</th><th>Paciente</th><th>Médico</th><th>Especialidad</th><th>Obra Social</th><th>Estado</th><th>Acción</th></tr></thead>
          <tbody>
            <tr v-for="t in turnosFiltrados" :key="t.id">
              <td class="time-col">{{t.hora}}</td>
              <td class="name-col">{{t.paciente}}</td>
              <td class="muted">{{t.medico}}</td>
              <td class="muted">{{t.esp}}</td>
              <td class="muted">{{t.os}}</td>
              <td><v-chip size="x-small" :color="t.color" variant="tonal">{{t.estado}}</v-chip></td>
              <td>
                <v-btn size="x-small" variant="text" color="primary"
                  v-if="t.estado==='Confirmado'">Recibir</v-btn>
                <v-btn size="x-small" variant="text" color="warning"
                  v-if="t.estado==='Pendiente'">Confirmar</v-btn>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="card">
        <div class="card-hd"><span class="card-ttl">Sala de Espera</span>
          <v-chip size="x-small" color="warning" variant="tonal">{{enEspera}} pacientes</v-chip>
        </div>
        <div class="wait-list">
          <div class="wait-row" v-for="p in espera" :key="p.id">
            <v-avatar size="34" color="rgba(59,130,246,0.15)">
              <v-icon size="16" color="#3B82F6">mdi-account</v-icon>
            </v-avatar>
            <div class="flex1">
              <div class="row-main">{{p.nombre}}</div>
              <div class="row-sub">{{p.medico}} · {{p.esp}}</div>
            </div>
            <div class="wait-time">{{p.espera}}</div>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-hd"><span class="card-ttl">Acciones Rápidas</span></div>
        <div class="acc-grid">
          <div class="acc-btn" v-for="a in acciones" :key="a.label">
            <div class="acc-ico" :style="{background:a.bg}">
              <v-icon :color="a.color" size="22">{{a.icon}}</v-icon>
            </div>
            <span class="acc-lbl">{{a.label}}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
const fecha = computed(() => new Date().toLocaleDateString('es-AR',{weekday:'long',year:'numeric',month:'long',day:'numeric'}))
const enEspera = 4
const filtroActivo = ref('todos')
const filtros = [
  {label:'Todos',      val:'todos'},
  {label:'Pendientes', val:'Pendiente'},
  {label:'Confirmados',val:'Confirmado'},
  {label:'En curso',   val:'En curso'},
]
const kpis = [
  {label:'Turnos hoy',      value:'32',icon:'mdi-calendar-today',   color:'#3B82F6',bg:'rgba(59,130,246,0.12)'},
  {label:'Pendientes',      value:'8', icon:'mdi-clock-alert',       color:'#F59E0B',bg:'rgba(245,158,11,0.12)'},
  {label:'En sala de espera',value:'4',icon:'mdi-seat',              color:'#6366F1',bg:'rgba(99,102,241,0.12)'},
  {label:'Completados',     value:'20',icon:'mdi-check-circle',      color:'#10B981',bg:'rgba(16,185,129,0.12)'},
]
const turnos = [
  {id:1, hora:'08:00',paciente:'García, María',   medico:'Dr. Ramos',    esp:'Cardiología',  os:'OSDE',   estado:'Completado', color:'#10B981'},
  {id:2, hora:'08:30',paciente:'López, Carlos',   medico:'Dra. Vidal',   esp:'Clínica',      os:'Swiss',  estado:'Completado', color:'#10B981'},
  {id:3, hora:'09:00',paciente:'Fernández, Ana',  medico:'Dr. Torres',   esp:'Pediatría',    os:'PAMI',   estado:'En curso',   color:'#3B82F6'},
  {id:4, hora:'09:30',paciente:'Martínez, Luis',  medico:'Dra. Morales', esp:'Neurología',   os:'Galeno', estado:'Confirmado', color:'#06B6D4'},
  {id:5, hora:'10:00',paciente:'Suárez, Elena',   medico:'Dr. Ramos',    esp:'Cardiología',  os:'OSDE',   estado:'Confirmado', color:'#06B6D4'},
  {id:6, hora:'10:30',paciente:'Rodríguez, Pablo',medico:'Dr. Sánchez',  esp:'Traumatología',os:'Swiss',  estado:'Pendiente',  color:'#F59E0B'},
  {id:7, hora:'11:00',paciente:'Díaz, Sofía',     medico:'Dra. Vidal',   esp:'Clínica',      os:'PAMI',   estado:'Pendiente',  color:'#F59E0B'},
]
const turnosFiltrados = computed(() =>
  filtroActivo.value === 'todos' ? turnos : turnos.filter(t => t.estado === filtroActivo.value)
)
const espera = [
  {id:1,nombre:'Fernández, Ana',  medico:'Dr. Torres',   esp:'Pediatría',  espera:'5 min'},
  {id:2,nombre:'Martínez, Luis',  medico:'Dra. Morales', esp:'Neurología', espera:'12 min'},
  {id:3,nombre:'Suárez, Elena',   medico:'Dr. Ramos',    esp:'Cardiología',espera:'18 min'},
  {id:4,nombre:'Rodríguez, Pablo',medico:'Dr. Sánchez',  esp:'Traumato',   espera:'25 min'},
]
const acciones = [
  {label:'Nuevo Turno',      icon:'mdi-calendar-plus',   color:'#3B82F6',bg:'rgba(59,130,246,0.12)'},
  {label:'Buscar Paciente',  icon:'mdi-account-search',  color:'#6366F1',bg:'rgba(99,102,241,0.12)'},
  {label:'Cancelar Turno',   icon:'mdi-calendar-remove', color:'#EF4444',bg:'rgba(239,68,68,0.12)'},
  {label:'Llamar Paciente',  icon:'mdi-bell-ring',       color:'#F59E0B',bg:'rgba(245,158,11,0.12)'},
]
</script>

<style scoped>
.d-root{padding:32px 36px;min-height:100vh;background:#040D1F;color:#E8EDF5}
.d-header{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:28px}
.d-tag{font-size:10px;letter-spacing:2.5px;color:#3B82F6;font-weight:600;margin-bottom:6px}
.d-title{font-size:26px;font-weight:700;color:#F1F5F9;margin:0 0 4px}
.d-sub{font-size:13px;color:rgba(241,245,249,0.4);margin:0;text-transform:capitalize}
.kpi-row{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:24px}
.kpi{background:#071628;border:1px solid rgba(255,255,255,0.07);border-radius:16px;padding:18px 16px;display:flex;flex-direction:column;gap:8px;transition:border-color .2s,transform .2s}
.kpi:hover{border-color:rgba(59,130,246,0.3);transform:translateY(-2px)}
.kpi-ico{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;justify-content:center}
.kpi-val{font-size:22px;font-weight:700;color:#F1F5F9}
.kpi-lbl{font-size:11px;color:rgba(241,245,249,0.45)}
.grid2{display:grid;grid-template-columns:1fr 1fr;gap:18px}
.card{background:#071628;border:1px solid rgba(255,255,255,0.07);border-radius:16px;padding:22px}
.card-hd{display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;flex-wrap:wrap;gap:8px}
.card-ttl{font-size:13px;font-weight:600;color:#F1F5F9}
.tbl{width:100%;border-collapse:collapse}
.tbl th{font-size:10px;color:rgba(241,245,249,0.3);font-weight:600;letter-spacing:1px;text-transform:uppercase;padding:8px 12px;text-align:left;border-bottom:1px solid rgba(255,255,255,0.05)}
.tbl td{padding:11px 12px;font-size:13px;color:rgba(241,245,249,0.7);border-bottom:1px solid rgba(255,255,255,0.04)}
.time-col{font-family:monospace;font-weight:700;color:#3B82F6}
.name-col{color:#F1F5F9!important;font-weight:500}
.muted{color:rgba(241,245,249,0.4)!important}
.flex1{flex:1}
.row-main{font-size:13px;color:#E8EDF5;font-weight:500}
.row-sub{font-size:11px;color:rgba(241,245,249,0.4);margin-top:2px}
.wait-list{display:flex;flex-direction:column;gap:10px}
.wait-row{display:flex;align-items:center;gap:12px;padding:10px;background:rgba(255,255,255,0.03);border-radius:10px}
.wait-time{font-size:11px;color:#F59E0B;font-weight:600;white-space:nowrap}
.acc-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:4px}
.acc-btn{display:flex;flex-direction:column;align-items:center;gap:8px;padding:18px 12px;background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.06);border-radius:12px;cursor:pointer;transition:all .18s}
.acc-btn:hover{background:rgba(59,130,246,0.08);border-color:rgba(59,130,246,0.25)}
.acc-ico{width:42px;height:42px;border-radius:12px;display:flex;align-items:center;justify-content:center}
.acc-lbl{font-size:12px;color:rgba(241,245,249,0.6);text-align:center}
</style>
