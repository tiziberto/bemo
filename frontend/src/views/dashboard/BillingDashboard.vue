<template>
  <div class="d-root">
    <div class="d-header">
      <div>
        <div class="d-tag">FACTURACIÓN</div>
        <h1 class="d-title">Gestión Financiera</h1>
        <p class="d-sub">{{ fecha }} · Obras sociales y liquidaciones</p>
      </div>
      <div class="total-pill">
        <div class="tp-lbl">Facturado este mes</div>
        <div class="tp-val">$1.284.500</div>
      </div>
    </div>

    <div class="kpi-row">
      <div class="kpi" v-for="k in kpis" :key="k.label">
        <div class="kpi-ico" :style="{background:k.bg}"><v-icon :color="k.color" size="20">{{k.icon}}</v-icon></div>
        <div class="kpi-val">{{k.value}}</div>
        <div class="kpi-lbl">{{k.label}}</div>
        <div class="kpi-tr" :class="k.up?'up':'dn'">{{k.trend}}</div>
      </div>
    </div>

    <div class="grid2">
      <div class="card" style="grid-column:1/-1">
        <div class="card-hd"><span class="card-ttl">Obras Sociales — Estado de Cuentas</span></div>
        <table class="tbl">
          <thead><tr><th>Obra Social</th><th>Afiliados</th><th>Facturado</th><th>Cobrado</th><th>Pendiente</th><th>Estado</th></tr></thead>
          <tbody>
            <tr v-for="os in obrasSociales" :key="os.id">
              <td class="name-col">{{os.nombre}}</td>
              <td>{{os.afiliados}}</td>
              <td class="amt">$ {{os.facturado}}</td>
              <td class="amt green">$ {{os.cobrado}}</td>
              <td class="amt" :class="os.pendiente>0?'warn':''">{{os.pendiente>0?'$ '+os.pendiente:'—'}}</td>
              <td><v-chip size="x-small" :color="os.color" variant="tonal">{{os.estado}}</v-chip></td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="card">
        <div class="card-hd"><span class="card-ttl">Últimas Liquidaciones</span></div>
        <div class="liq-list">
          <div class="liq-row" v-for="l in liquidaciones" :key="l.id">
            <div class="liq-ico"><v-icon color="#3B82F6" size="18">mdi-file-document</v-icon></div>
            <div class="flex1">
              <div class="row-main">{{l.numero}}</div>
              <div class="row-sub">{{l.os}} · {{l.fecha}}</div>
            </div>
            <div class="liq-monto">$ {{l.monto}}</div>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-hd"><span class="card-ttl">Acciones</span></div>
        <div class="acc-grid">
          <div class="acc-btn" v-for="a in acciones" :key="a.label">
            <div class="acc-ico" :style="{background:a.bg}"><v-icon :color="a.color" size="22">{{a.icon}}</v-icon></div>
            <span class="acc-lbl">{{a.label}}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
const fecha = computed(() => new Date().toLocaleDateString('es-AR',{weekday:'long',year:'numeric',month:'long',day:'numeric'}))
const kpis = [
  {label:'Facturado hoy',   value:'$84.200',  icon:'mdi-cash-multiple',  color:'#3B82F6',bg:'rgba(59,130,246,0.12)', trend:'+8%', up:true},
  {label:'Cobrado mes',     value:'$920.000', icon:'mdi-check-circle',   color:'#10B981',bg:'rgba(16,185,129,0.12)', trend:'+12%',up:true},
  {label:'Pendiente cobro', value:'$364.500', icon:'mdi-clock-alert',    color:'#F59E0B',bg:'rgba(245,158,11,0.12)', trend:'-5%', up:false},
  {label:'Liquidaciones',   value:'47',       icon:'mdi-file-document',  color:'#6366F1',bg:'rgba(99,102,241,0.12)', trend:'+3',  up:true},
]
const obrasSociales = [
  {id:1,nombre:'OSDE',         afiliados:284,facturado:'284.000',cobrado:'284.000',pendiente:0,      estado:'Al día',    color:'#10B981'},
  {id:2,nombre:'Swiss Medical',afiliados:156,facturado:'198.500',cobrado:'150.000',pendiente:48500,  estado:'Parcial',   color:'#F59E0B'},
  {id:3,nombre:'PAMI',         afiliados:412,facturado:'320.000',cobrado:'320.000',pendiente:0,      estado:'Al día',    color:'#10B981'},
  {id:4,nombre:'Galeno',       afiliados:98, facturado:'145.000',cobrado:'0',      pendiente:145000, estado:'Pendiente', color:'#EF4444'},
  {id:5,nombre:'Medicus',      afiliados:73, facturado:'84.000', cobrado:'84.000', pendiente:0,      estado:'Al día',    color:'#10B981'},
]
const liquidaciones = [
  {id:1,numero:'LIQ-00847',os:'OSDE',         fecha:'01/07/2025',monto:'284.000'},
  {id:2,numero:'LIQ-00846',os:'Swiss Medical',fecha:'01/07/2025',monto:'150.000'},
  {id:3,numero:'LIQ-00845',os:'PAMI',         fecha:'30/06/2025',monto:'320.000'},
  {id:4,numero:'LIQ-00844',os:'Medicus',      fecha:'30/06/2025',monto:'84.000'},
]
const acciones = [
  {label:'Nueva liquidación',icon:'mdi-file-plus',      color:'#3B82F6',bg:'rgba(59,130,246,0.12)'},
  {label:'Importar padrones',icon:'mdi-database-import',color:'#6366F1',bg:'rgba(99,102,241,0.12)'},
  {label:'Exportar reporte', icon:'mdi-file-export',    color:'#10B981',bg:'rgba(16,185,129,0.12)'},
  {label:'Configurar OS',    icon:'mdi-cog',            color:'#F59E0B',bg:'rgba(245,158,11,0.12)'},
]
</script>

<style scoped>
.d-root{padding:32px 36px;min-height:100vh;background:#040D1F;color:#E8EDF5}
.d-header{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:28px}
.d-tag{font-size:10px;letter-spacing:2.5px;color:#3B82F6;font-weight:600;margin-bottom:6px}
.d-title{font-size:26px;font-weight:700;color:#F1F5F9;margin:0 0 4px}
.d-sub{font-size:13px;color:rgba(241,245,249,0.4);margin:0;text-transform:capitalize}
.total-pill{background:rgba(59,130,246,0.08);border:1px solid rgba(59,130,246,0.2);border-radius:14px;padding:12px 20px;text-align:right}
.tp-lbl{font-size:10px;color:rgba(241,245,249,0.4)}
.tp-val{font-size:22px;font-weight:700;color:#3B82F6}
.kpi-row{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:24px}
.kpi{background:#071628;border:1px solid rgba(255,255,255,0.07);border-radius:16px;padding:18px 16px;display:flex;flex-direction:column;gap:8px;transition:border-color .2s,transform .2s}
.kpi:hover{border-color:rgba(59,130,246,0.3);transform:translateY(-2px)}
.kpi-ico{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;justify-content:center}
.kpi-val{font-size:22px;font-weight:700;color:#F1F5F9}
.kpi-lbl{font-size:11px;color:rgba(241,245,249,0.45)}
.kpi-tr{font-size:11px;font-weight:600}.kpi-tr.up{color:#10B981}.kpi-tr.dn{color:#EF4444}
.grid2{display:grid;grid-template-columns:1fr 1fr;gap:18px}
.card{background:#071628;border:1px solid rgba(255,255,255,0.07);border-radius:16px;padding:22px}
.card-hd{display:flex;justify-content:space-between;align-items:center;margin-bottom:16px}
.card-ttl{font-size:13px;font-weight:600;color:#F1F5F9}
.tbl{width:100%;border-collapse:collapse}
.tbl th{font-size:10px;color:rgba(241,245,249,0.3);font-weight:600;letter-spacing:1px;text-transform:uppercase;padding:8px 12px;text-align:left;border-bottom:1px solid rgba(255,255,255,0.05)}
.tbl td{padding:12px;font-size:13px;color:rgba(241,245,249,0.7);border-bottom:1px solid rgba(255,255,255,0.04)}
.name-col{color:#F1F5F9!important;font-weight:500}
.amt{font-family:monospace;font-size:12px!important}
.green{color:#10B981!important}.warn{color:#F59E0B!important}
.flex1{flex:1}
.row-main{font-size:13px;color:#E8EDF5;font-weight:500}
.row-sub{font-size:11px;color:rgba(241,245,249,0.4);margin-top:2px}
.liq-list{display:flex;flex-direction:column;gap:10px}
.liq-row{display:flex;align-items:center;gap:12px;padding:10px;background:rgba(255,255,255,0.03);border-radius:10px}
.liq-ico{width:34px;height:34px;background:rgba(59,130,246,0.12);border-radius:8px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.liq-monto{font-size:13px;font-weight:700;color:#3B82F6;font-family:monospace}
.acc-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px}
.acc-btn{display:flex;flex-direction:column;align-items:center;gap:8px;padding:18px 12px;background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.06);border-radius:12px;cursor:pointer;transition:all .18s}
.acc-btn:hover{background:rgba(59,130,246,0.08);border-color:rgba(59,130,246,0.25)}
.acc-ico{width:42px;height:42px;border-radius:12px;display:flex;align-items:center;justify-content:center}
.acc-lbl{font-size:12px;color:rgba(241,245,249,0.6);text-align:center}
</style>
