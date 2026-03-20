// src/router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const ROLE_REDIRECT: Record<string, string> = {
  ROLE_ADMIN:     '/dashboard/admin',
  ROLE_DOCTOR:    '/dashboard/doctor',
  ROLE_RECEPTION: '/dashboard/reception',
  ROLE_BILLING:   '/dashboard/billing',
  ROLE_PATIENT:   '/dashboard/patient',
}

const routes: RouteRecordRaw[] = [
  // ── Públicas ──────────────────────────────────────
  { path: '/',             redirect: '/dashboard' },
  { path: '/login',        component: () => import('../views/LoginView.vue'),        meta: { public: true } },
  { path: '/unauthorized', component: () => import('../views/UnauthorizedView.vue'), meta: { public: true } },

  // ── Placeholder de redirección (el guard la resuelve) ──
  { path: '/dashboard', component: () => import('../views/LoginView.vue') },

  // ── ADMIN ─────────────────────────────────────────
  {
    path: '/dashboard/admin',
    component: () => import('../views/dashboard/AdminDashboard.vue'),
    meta: { roles: ['ROLE_ADMIN'] }
  },

  // ── DOCTOR ────────────────────────────────────────
  {
    path: '/dashboard/doctor',
    component: () => import('../views/dashboard/DoctorDashboard.vue'),
    meta: { roles: ['ROLE_DOCTOR', 'ROLE_ADMIN'] }
  },

  // ── RECEPCIÓN ─────────────────────────────────────
  {
    path: '/dashboard/reception',
    component: () => import('../views/dashboard/ReceptionDashboard.vue'),
    meta: { roles: ['ROLE_RECEPTION', 'ROLE_ADMIN'] }
  },

  // ── FACTURACIÓN ───────────────────────────────────
  {
    path: '/dashboard/billing',
    component: () => import('../views/dashboard/BillingDashboard.vue'),
    meta: { roles: ['ROLE_BILLING', 'ROLE_ADMIN'] }
  },

  // ── PACIENTE ──────────────────────────────────────
  {
    path: '/dashboard/patient',
    component: () => import('../views/dashboard/PatientDashboard.vue'),
    meta: { roles: ['ROLE_PATIENT', 'ROLE_ADMIN'] }
  },

  // ── Catch-all ─────────────────────────────────────
  { path: '/:pathMatch(.*)*', redirect: '/' }

]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

// Navigation Guard para manejar la lógica de roles que definiste
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token');
  const userRole = localStorage.getItem('role');

  // 1. Si la ruta es pública, dejar pasar
  if (to.meta.public) {
    return next();
  }

  // 2. Si no hay token, al login
  if (!token) {
    return next('/login');
  }

  // 3. Redirección lógica de /dashboard según rol
  if (to.path === '/dashboard') {
    const target = ROLE_REDIRECT[userRole || ''] || '/login';
    return next(target);
  }

  // 4. Verificación de permisos por rol
  if (to.meta.roles && !(to.meta.roles as string[]).includes(userRole || '')) {
    return next('/unauthorized');
  }

  next();
});

export default router;
