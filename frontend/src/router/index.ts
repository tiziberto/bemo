// src/router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '../stores/auth'

// Mapa rol → ruta del dashboard (nombres exactos del backend)
const ROLE_REDIRECT: Record<string, string> = {
  ROLE_ADMIN:       '/dashboard/admin',
  ROLE_DOCTOR:      '/dashboard/doctor',
  ROLE_RECEPCION:   '/dashboard/reception',
  ROLE_FACTURACION: '/dashboard/billing',
  ROLE_PACIENTE:    '/dashboard/patient',
}

const routes: RouteRecordRaw[] = [

  // ── Raíz ────────────────────────────────────────────────────
  { path: '/', redirect: '/dashboard' },

  // ── Públicas ────────────────────────────────────────────────
  {
    path: '/login',
    component: () => import('../views/LoginView.vue'),
    meta: { public: true }
  },
  {
    path: '/unauthorized',
    component: () => import('../views/UnauthorizedView.vue'),
    meta: { public: true }
  },

  // ── /dashboard → el guard resuelve a qué dashboard ir ───────
  {
    path: '/dashboard',
    redirect: () => '/login'   // fallback; el beforeEach lo maneja primero
  },

  // ── ADMIN ────────────────────────────────────────────────────
  {
    path: '/dashboard/admin',
    component: () => import('../views/dashboard/AdminDashboard.vue'),
    meta: { roles: ['ROLE_ADMIN'] }
  },

  // ── DOCTOR ───────────────────────────────────────────────────
  {
    path: '/dashboard/doctor',
    component: () => import('../views/dashboard/DoctorDashboard.vue'),
    meta: { roles: ['ROLE_DOCTOR', 'ROLE_ADMIN'] }
  },

  // ── RECEPCIÓN ────────────────────────────────────────────────
  {
    path: '/dashboard/reception',
    component: () => import('../views/dashboard/ReceptionDashboard.vue'),
    meta: { roles: ['ROLE_RECEPCION', 'ROLE_ADMIN'] }
  },

  // ── FACTURACIÓN ──────────────────────────────────────────────
  {
    path: '/dashboard/billing',
    component: () => import('../views/dashboard/BillingDashboard.vue'),
    meta: { roles: ['ROLE_FACTURACION', 'ROLE_ADMIN'] }
  },

  // ── PACIENTE ─────────────────────────────────────────────────
  {
    path: '/dashboard/patient',
    component: () => import('../views/dashboard/PatientDashboard.vue'),
    meta: { roles: ['ROLE_PACIENTE', 'ROLE_ADMIN'] }
  },

  // ── Catch-all ────────────────────────────────────────────────
  { path: '/:pathMatch(.*)*', redirect: '/' }
  
]
