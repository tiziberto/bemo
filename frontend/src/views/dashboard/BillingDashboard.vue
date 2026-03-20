<!-- src/views/dashboard/BillingDashboard.vue -->
<template>
  <div class="dash-root">
    <div class="dash-header">
      <div>
        <div class="dash-tag">FACTURACIÓN</div>
        <h1 class="dash-title">Gestión Financiera</h1>
        <p class="dash-sub">{{ fecha }} · Obras sociales y liquidaciones</p>
      </div>
      <div class="header-stats">
        <div class="stat-pill"><span class="stat-val">${{ facturadoMes }}</span><span class="stat-lbl">facturado este mes</span></div>
      </div>
    </div>

    <div class="kpi-grid">
      <div class="kpi-card" v-for="k in kpis" :key="k.label">
        <div class="kpi-icon" :style="{ background: k.bg }"><v-icon :color="k.color" size="20">{{ k.icon }}</v-icon></div>
        <div><div class="kpi-value">{{ k.value }}</div><div class="kpi-label">{{ k.label }}</div></div>
        <div class="kpi-trend" :class="k.up ? 'up' : 'down'">{{ k.trend }}</div>
      </div>
    </div>

    <div class="main-grid">
      <div class="panel panel-wide">
        <div class="panel-header">
          <span class="panel-title">Obras Sociales — Estado de Cuentas</span>
        </div>
        <table class="eco-table">
          <thead><tr><th>Obra Social</th><th>Afiliados</th><th>Facturado</th><th>Cobrado</th><th>Pendiente</th><th>Estado</th></tr></thead>
          <tbody>
            <tr v-for="os in obrasSociales" :key="os.id">
              <td class="os-name">{{ os.nombre }}</td>
              <td>{{ os.afiliados }}</td>
              <td class="amount">${{ os.facturado }}</td>
              <td class="amount green">${{ os.cobrado }}</td>
              <td class="amount" :class="os.pendiente > 0 ? 'yellow' : ''">{{ os.pendiente > 0 ? '$'+os.pendiente : '—' }}</td>
              <td><v-chip size="x-small" :color="os.color" variant="tonal">{{ os.estado }}</v-chip></td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="panel">
        <div class="panel-header"><span class="panel-title">Últimas Liquidaciones</span></div>
        <div class="liquid-list">
          <div class="liquid-item" v-for="l in liquidaciones" :key="l.id">
            <div class="liquid-icon"><v-icon color="#00C896" size="18">mdi-file-document</v-icon></div>
            <div class="liquid-body">
              <div class="liquid-num">{{ l.numero }}</div>
              <div class="liquid-os">{{ l.os }} · {{ l.fecha }}</div>
            </div>
            <div class="liquid-monto">${{ l.monto }}</div>
          </div>
        </div>
      </div>

      <div class="panel">
        <div class="panel-header"><span class="panel-title">Acciones</span></div>
        <div class="acciones-grid">
          <div class="accion-btn" v-for="a in acciones" :key="a.label">
            <v-icon :color="a.color" size="22">{{ a.icon }}</v-icon>
            <span>{{ a.label }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
const fecha = computed(() => new Date().toLocaleDateString('es-AR', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }))
const facturadoMes = '1.284.500'
const kpis = [
  { label:'Facturado hoy',    value:'$84.200',  icon:'mdi-cash-multiple',   color:'#00C896', bg:'rgba(0,200,150,0.1)',  trend:'+8%',  up:true  },
  { label:'Cobrado mes',      value:'$920.000', icon:'mdi-check-circle',    color:'#10B981', bg:'rgba(16,185,129,0.1)', trend:'+12%', up:true  },
  { label:'Pendiente cobro',  value:'$364.500', icon:'mdi-clock-alert',     color:'#F59E0B', bg:'rgba(245,158,11,0.1)', trend:'-5%',  up:false },
  { label:'Liquidaciones',    value:'47',       icon:'mdi-file-document',   color:'#3B82F6', bg:'rgba(59,130,246,0.1)', trend:'+3',   up:true  },
]
const obrasSociales = [
  { id:1, nombre:'OSDE',         afiliados:284, facturado:'284.000', cobrado:'284.000', pendiente:0,      estado:'Al día',    color:'#10B981' },
  { id:2, nombre:'Swiss Medical',afiliados:156, facturado:'198.500', cobrado:'150.000', pendiente:48500,  estado:'Parcial',   color:'#F59E0B' },
  { id:3, nombre:'PAMI',         afiliados:412, facturado:'320.000', cobrado:'320.000', pendiente:0,      estado:'Al día',    color:'#10B981' },
  { id:4, nombre:'Galeno',       afiliados:98,  facturado:'145.000', cobrado:0,         pendiente:145000, estado:'Pendiente', color:'#EF4444' },
  { id:5, nombre:'Medicus',      afiliados:73,  facturado:'84.000',  cobrado:'84.000',  pendiente:0,      estado:'Al día',    color:'#10B981' },
]
const liquidaciones = [
  { id:1, numero:'LIQ-00847', os:'OSDE',          fecha:'01/07/2025', monto:'284.000' },
  { id:2, numero:'LIQ-00846', os:'Swiss Medical', fecha:'01/07/2025', monto:'150.000' },
  { id:3, numero:'LIQ-00845', os:'PAMI',          fecha:'30/06/2025', monto:'320.000' },
  { id:4, numero:'LIQ-00844', os:'Medicus',       fecha:'30/06/2025', monto:'84.000'  },
]
const acciones = [
  { label:'Nueva liquidación', icon:'mdi-file-plus',       color:'#00C896' },
  { label:'Importar padrones', icon:'mdi-database-import', color:'#3B82F6' },
  { label:'Exportar reporte',  icon:'mdi-file-export',     color:'#F59E0B' },
  { label:'Configurar OS',     icon:'mdi-cog',             color:'#6366F1' },
]
</script>

<style scoped>
.dash-root { padding: 32px 36px; min-height: 100vh; background: #0A0F1E; font-family: 'DM Sans', sans-serif; }
.dash-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 28px; }
.dash-tag { font-size: 10px; letter-spacing: 2.5px; color: #00C896; font-weight: 600; margin-bottom: 6px; }
.dash-title { font-family: 'Playfair Display', serif; font-size: 26px; color: #E8EDF5; margin: 0 0 4px; font-weight: 600; }
.dash-sub { font-size: 13px; color: rgba(255,255,255,0.35); margin: 0; text-transform: capitalize; }
.stat-pill { background: rgba(0,200,150,0.08); border: 1px solid rgba(0,200,150,0.2); border-radius: 12px; padding: 10px 18px; text-align: right; }
.stat-val { display: block; font-size: 20px; font-weight: 700; color: #00C896; }
.stat-lbl { font-size: 10px; color: rgba(255,255,255,0.35); }
.kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px; }
.kpi-card { background: #111827; border: 1px solid rgba(255,255,255,0.06); border-radius: 14px; padding: 18px 16px; display: flex; gap: 14px; align-items: center; }
.kpi-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.kpi-value { font-size: 20px; font-weight: 700; color: #E8EDF5; }
.kpi-label { font-size: 11px; color: rgba(255,255,255,0.4); }
.kpi-trend { font-size: 11px; font-weight: 600; margin-left: auto; }
.kpi-trend.up { color: #10B981; }
.kpi-trend.down { color: #EF4444; }
.main-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.panel { background: #111827; border: 1px solid rgba(255,255,255,0.06); border-radius: 14px; padding: 20px; }
.panel-wide { grid-column: 1 / -1; }
.panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.panel-title { font-size: 13px; font-weight: 600; color: #E8EDF5; }
.eco-table { width: 100%; border-collapse: collapse; }
.eco-table th { font-size: 10px; color: rgba(255,255,255,0.3); font-weight: 600; letter-spacing: 1px; text-transform: uppercase; padding: 8px 12px; text-align: left; border-bottom: 1px solid rgba(255,255,255,0.05); }
.eco-table td { padding: 12px; font-size: 13px; color: rgba(255,255,255,0.65); border-bottom: 1px solid rgba(255,255,255,0.04); }
.os-name { color: #E8EDF5 !important; font-weight: 500; }
.amount { font-family: monospace; font-size: 12px !important; }
.green { color: #10B981 !important; }
.yellow { color: #F59E0B !important; }
.liquid-list { display: flex; flex-direction: column; gap: 10px; }
.liquid-item { display: flex; align-items: center; gap: 12px; padding: 10px; background: rgba(255,255,255,0.03); border-radius: 8px; }
.liquid-icon { width: 34px; height: 34px; background: rgba(0,200,150,0.1); border-radius: 8px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.liquid-body { flex: 1; }
.liquid-num { font-size: 13px; color: #E8EDF5; font-weight: 500; }
.liquid-os { font-size: 11px; color: rgba(255,255,255,0.3); margin-top: 2px; }
.liquid-monto { font-size: 13px; font-weight: 700; color: #00C896; font-family: monospace; }
.acciones-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.accion-btn { display: flex; flex-direction: column; align-items: center; gap: 8px; padding: 16px; background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.06); border-radius: 10px; cursor: pointer; transition: all 0.18s; font-size: 12px; color: rgba(255,255,255,0.55); }
.accion-btn:hover { background: rgba(0,200,150,0.08); border-color: rgba(0,200,150,0.2); color: #00C896; }
</style>