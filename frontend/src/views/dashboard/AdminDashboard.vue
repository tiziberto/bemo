<template>
  <div class="dash-root">
    <!-- Header -->
    <div class="dash-header">
      <div>
        <div class="dash-tag">ADMINISTRACIÓN</div>
        <h1 class="dash-title">Panel de Control</h1>
        <p class="dash-sub">{{ fecha }} · Vista general del sistema</p>
      </div>
      <div class="header-actions">
        <div class="live-badge"><span class="live-dot" />EN VIVO</div>
      </div>
    </div>

    <!-- KPIs -->
    <div class="kpi-grid">
      <div class="kpi-card" v-for="k in kpis" :key="k.label">
        <div class="kpi-icon" :style="{ background: k.bg }">
          <v-icon :color="k.color" size="20">{{ k.icon }}</v-icon>
        </div>
        <div class="kpi-body">
          <div class="kpi-value">{{ k.value }}</div>
          <div class="kpi-label">{{ k.label }}</div>
        </div>
        <div class="kpi-trend" :class="k.up ? 'up' : 'down'">
          <v-icon size="12">{{ k.up ? 'mdi-trending-up' : 'mdi-trending-down' }}</v-icon>
          {{ k.trend }}
        </div>
      </div>
    </div>

    <!-- Main grid -->
    <div class="main-grid">
      <!-- Próximos turnos -->
      <div class="panel">
        <div class="panel-header">
          <span class="panel-title">Próximos Turnos</span>
          <v-chip size="x-small" color="#00C896" variant="tonal">HOY</v-chip>
        </div>
        <div class="turno-list">
          <div class="turno-item" v-for="t in turnos" :key="t.id">
            <div class="turno-hora">{{ t.hora }}</div>
            <div class="turno-body">
              <div class="turno-paciente">{{ t.paciente }}</div>
              <div class="turno-doctor">{{ t.doctor }} · {{ t.especialidad }}</div>
            </div>
            <v-chip size="x-small" :color="t.color" variant="tonal">{{ t.estado }}</v-chip>
          </div>
        </div>
      </div>

      <!-- Actividad reciente -->
      <div class="panel">
        <div class="panel-header">
          <span class="panel-title">Actividad Reciente</span>
        </div>
        <div class="activity-list">
          <div class="activity-item" v-for="a in actividad" :key="a.id">
            <div class="activity-dot" :style="{ background: a.color }" />
            <div class="activity-body">
              <div class="activity-text">{{ a.texto }}</div>
              <div class="activity-time">{{ a.tiempo }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Usuarios del sistema -->
      <div class="panel panel-wide">
        <div class="panel-header">
          <span class="panel-title">Usuarios del Sistema</span>
          <v-btn size="x-small" variant="tonal" color="#00C896" to="/users">Ver todos</v-btn>
        </div>
        <table class="eco-table">
          <thead>
            <tr>
              <th>Usuario</th><th>Rol</th><th>Estado</th><th>Último acceso</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="u in usuarios" :key="u.id">
              <td>
                <div class="user-cell">
                  <v-avatar size="28" color="#00C896">
                    <span style="font-size:10px;color:#0A0F1E;font-weight:700">{{ u.initials }}</span>
                  </v-avatar>
                  {{ u.nombre }}
                </div>
              </td>
              <td><v-chip size="x-small" :color="u.roleColor" variant="tonal">{{ u.rol }}</v-chip></td>
              <td><span class="status-dot" :class="u.activo ? 'online' : 'offline'" />{{ u.activo ? 'Activo' : 'Inactivo' }}</td>
              <td class="text-muted">{{ u.acceso }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const fecha = computed(() => new Date().toLocaleDateString('es-AR', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }))

const kpis = [
  { label: 'Turnos hoy',      value: '47',   icon: 'mdi-calendar-check',  color: '#00C896', bg: 'rgba(0,200,150,0.1)',   trend: '+12%', up: true  },
  { label: 'Pacientes',       value: '1.284', icon: 'mdi-account-group',   color: '#3B82F6', bg: 'rgba(59,130,246,0.1)', trend: '+5%',  up: true  },
  { label: 'Médicos activos', value: '18',   icon: 'mdi-doctor',          color: '#F59E0B', bg: 'rgba(245,158,11,0.1)', trend: '0%',   up: true  },
  { label: 'Facturado hoy',   value: '$284k', icon: 'mdi-cash-multiple',   color: '#10B981', bg: 'rgba(16,185,129,0.1)', trend: '+8%',  up: true  },
  { label: 'Alertas',         value: '3',    icon: 'mdi-alert-circle',    color: '#EF4444', bg: 'rgba(239,68,68,0.1)',  trend: '-2',   up: false },
]

const turnos = [
  { id:1, hora:'08:30', paciente:'García, María',    doctor:'Dr. Ramos',    especialidad:'Cardiología',   estado:'Confirmado', color:'#00C896' },
  { id:2, hora:'09:00', paciente:'López, Carlos',    doctor:'Dra. Vidal',   especialidad:'Clínica Médica',estado:'En sala',    color:'#3B82F6' },
  { id:3, hora:'09:30', paciente:'Fernández, Ana',   doctor:'Dr. Torres',   especialidad:'Pediatría',     estado:'Pendiente',  color:'#F59E0B' },
  { id:4, hora:'10:00', paciente:'Martínez, Luis',   doctor:'Dra. Morales', especialidad:'Neurología',    estado:'Confirmado', color:'#00C896' },
  { id:5, hora:'10:30', paciente:'Rodríguez, Elena', doctor:'Dr. Sánchez',  especialidad:'Traumatología', estado:'Cancelado',  color:'#EF4444' },
]

const actividad = [
  { id:1, texto:'Nuevo paciente registrado: Gómez, Roberto', tiempo:'hace 5 min',  color:'#00C896' },
  { id:2, texto:'Turno cancelado: García, María — Cardiología', tiempo:'hace 12 min', color:'#EF4444' },
  { id:3, texto:'Historia clínica actualizada: López, Carlos', tiempo:'hace 18 min', color:'#3B82F6' },
  { id:4, texto:'Factura emitida: OS OSDE #00847', tiempo:'hace 25 min', color:'#10B981' },
  { id:5, texto:'Dr. Ramos inició sesión', tiempo:'hace 1 hora', color:'#F59E0B' },
]

const usuarios = [
  { id:1, nombre:'Dr. Ramos, Pablo',    initials:'DR', rol:'DOCTOR',    roleColor:'#3B82F6', activo:true,  acceso:'hace 5 min'  },
  { id:2, nombre:'Vidal, Claudia',      initials:'VC', rol:'RECEPCIÓN', roleColor:'#00C896', activo:true,  acceso:'hace 10 min' },
  { id:3, nombre:'Gómez, Sebastián',    initials:'GS', rol:'BILLING',   roleColor:'#F59E0B', activo:false, acceso:'ayer 17:30'  },
  { id:4, nombre:'Admin, Sistema',      initials:'AS', rol:'ADMIN',     roleColor:'#EF4444', activo:true,  acceso:'ahora'       },
]
</script>

<style scoped>
.dash-root { padding: 32px 36px; min-height: 100vh; background: #0A0F1E; font-family: 'DM Sans', sans-serif; }

.dash-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 32px; }
.dash-tag { font-size: 10px; letter-spacing: 2.5px; color: #00C896; font-weight: 600; margin-bottom: 6px; }
.dash-title { font-family: 'Playfair Display', serif; font-size: 28px; color: #E8EDF5; margin: 0 0 4px; font-weight: 600; }
.dash-sub { font-size: 13px; color: rgba(255,255,255,0.35); margin: 0; text-transform: capitalize; }

.live-badge { display: flex; align-items: center; gap: 6px; font-size: 11px; font-weight: 600; color: #00C896; letter-spacing: 1.5px; background: rgba(0,200,150,0.08); border: 1px solid rgba(0,200,150,0.2); padding: 6px 12px; border-radius: 20px; }
.live-dot { width: 6px; height: 6px; background: #00C896; border-radius: 50%; animation: pulse-dot 1.5s infinite; }
@keyframes pulse-dot { 0%,100%{opacity:1} 50%{opacity:0.3} }

.kpi-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 16px; margin-bottom: 24px; }
.kpi-card {
  background: #111827; border: 1px solid rgba(255,255,255,0.06);
  border-radius: 14px; padding: 18px 16px;
  display: flex; flex-direction: column; gap: 10px;
  transition: border-color 0.2s, transform 0.2s;
}
.kpi-card:hover { border-color: rgba(0,200,150,0.25); transform: translateY(-2px); }
.kpi-icon { width: 38px; height: 38px; border-radius: 10px; display: flex; align-items: center; justify-content: center; }
.kpi-value { font-size: 22px; font-weight: 700; color: #E8EDF5; font-family: 'Playfair Display', serif; }
.kpi-label { font-size: 11.5px; color: rgba(255,255,255,0.4); margin-top: 1px; }
.kpi-trend { font-size: 11px; font-weight: 600; display: flex; align-items: center; gap: 3px; }
.kpi-trend.up { color: #10B981; }
.kpi-trend.down { color: #EF4444; }

.main-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.panel { background: #111827; border: 1px solid rgba(255,255,255,0.06); border-radius: 14px; padding: 20px; }
.panel-wide { grid-column: 1 / -1; }
.panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.panel-title { font-size: 13px; font-weight: 600; color: #E8EDF5; letter-spacing: 0.3px; }

.turno-list { display: flex; flex-direction: column; gap: 10px; }
.turno-item { display: flex; align-items: center; gap: 12px; padding: 10px; background: rgba(255,255,255,0.03); border-radius: 8px; }
.turno-hora { font-size: 12px; font-weight: 700; color: #00C896; min-width: 44px; font-family: monospace; }
.turno-body { flex: 1; }
.turno-paciente { font-size: 13px; color: #E8EDF5; font-weight: 500; }
.turno-doctor { font-size: 11px; color: rgba(255,255,255,0.35); margin-top: 2px; }

.activity-list { display: flex; flex-direction: column; gap: 12px; }
.activity-item { display: flex; align-items: flex-start; gap: 10px; }
.activity-dot { width: 8px; height: 8px; border-radius: 50%; margin-top: 4px; flex-shrink: 0; }
.activity-text { font-size: 12.5px; color: rgba(255,255,255,0.65); }
.activity-time { font-size: 11px; color: rgba(255,255,255,0.25); margin-top: 2px; }

.eco-table { width: 100%; border-collapse: collapse; }
.eco-table th { font-size: 10.5px; color: rgba(255,255,255,0.3); font-weight: 600; letter-spacing: 1px; text-transform: uppercase; padding: 8px 12px; text-align: left; border-bottom: 1px solid rgba(255,255,255,0.05); }
.eco-table td { padding: 12px; font-size: 13px; color: rgba(255,255,255,0.7); border-bottom: 1px solid rgba(255,255,255,0.04); }
.user-cell { display: flex; align-items: center; gap: 8px; color: #E8EDF5; font-weight: 500; }
.status-dot { display: inline-block; width: 6px; height: 6px; border-radius: 50%; margin-right: 6px; }
.status-dot.online { background: #10B981; }
.status-dot.offline { background: rgba(255,255,255,0.2); }
.text-muted { color: rgba(255,255,255,0.3) !important; font-size: 12px !important; }
</style>