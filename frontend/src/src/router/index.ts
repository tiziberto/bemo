import { createRouter, createWebHistory } from "vue-router";
import LoginView from "../views/LoginView.vue";
import DashboardView from "../views/DashboardView.vue";
import AlarmsView from "../views/AlarmsView.vue";
import UsersView from "../views/UsersView.vue";
import OrdersView from "../views/OrdersView.vue";


const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: "/", redirect: "/login" },
    { path: "/login", component: LoginView },
    { path: "/dashboard", component: DashboardView },
    { path: "/alarms", component: AlarmsView },
    { path: "/users", component: UsersView },
    { path: "/ordenes", name: "ordenes", component: OrdersView },
    {path: '/ordenes/:id',name: 'detalle-orden', component: () => import('../views/OrdersView.vue') },

  ]
});

router.beforeEach((to, _, next) => {
  const token = localStorage.getItem("token");
  if (!token && to.path !== "/login") {
    next("/login");
  } else {
    next();
  }
});

export default router;
