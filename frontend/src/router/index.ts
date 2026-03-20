import { createRouter, createWebHistory } from "vue-router";

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: "/",
      component: () => import("@/components/PublicLayout.vue"),
      children: [
        { path: "", component: () => import("@/pages/Index.vue") },
        { path: "servicios", component: () => import("@/pages/Servicios.vue") },
        { path: "reservar", component: () => import("@/pages/ReservarTurno.vue") },
        { path: "portal", component: () => import("@/pages/PortalPaciente.vue") },
        { path: "contacto", component: () => import("@/pages/Contacto.vue") },
      ],
    },
    { path: "/login", component: () => import("@/pages/Login.vue") },
    { path: "/acceso-denegado", component: () => import("@/pages/AccessDenied.vue") },
    {
      path: "/dashboard",
      component: () => import("@/components/DashboardLayout.vue"),
      meta: { requiresAuth: true },
      children: [
        { path: "", component: () => import("@/pages/dashboard/DashboardHome.vue") },
        { path: ":section(.*)", component: () => import("@/pages/dashboard/DashboardPlaceholder.vue") },
      ],
    },
    { path: "/:pathMatch(.*)*", component: () => import("@/pages/NotFound.vue") },
  ],
});

// Navigation guard for protected routes
router.beforeEach((to, from, next) => {
  if (to.matched.some((r) => r.meta.requiresAuth)) {
    const stored = localStorage.getItem("ecomed_user");
    if (!stored) {
      next("/login");
      return;
    }
  }
  next();
});

export default router;
