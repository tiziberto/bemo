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

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// ── Guard global de navegación ──────────────────────────────────
router.beforeEach((to) => {
  const auth = useAuthStore()

  // 1. Rutas públicas → siempre permitidas
  if (to.meta.public) return true

  // 2. No autenticado → redirigir al login
  if (!auth.isAuthenticated) return '/login'

  // 3. /dashboard → redirigir al dashboard según el rol principal
  if (to.path === '/dashboard') {
    const dest = ROLE_REDIRECT[auth.primaryRole ?? '']
    return dest ?? '/unauthorized'
  }

  // 4. Ruta con roles requeridos → verificar que el usuario tenga uno
  const requiredRoles = to.meta.roles as string[] | undefined
  if (requiredRoles && !auth.hasAnyRole(requiredRoles)) {
    return '/unauthorized'
  }

  return true
})

export default router
