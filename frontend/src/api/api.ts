// src/api/api.ts — Servicios del sistema ECOMED
import axios from 'axios'
import type { LoginRequest, RegisterRequest, User } from '../types'

const instance = axios.create({
  baseURL: "http://localhost:8080/api/v1"
});

// Inyecta el token JWT en cada petición protegida
instance.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

export default {
  // --- AUTH (AuthRestController) ---
  // Mapea a POST /api/v1/login [cite: 14, 15]
  login: (credentials: any) => instance.post('/login', credentials),
  // Mapea a POST /api/v1/register [cite: 14, 15]
  register: (user: any) => instance.post('/register', user),

  // --- ORDENES (OrdenRestController) ---
  // Obtiene la lista completa de órdenes (Requerido para el monitoreo en tiempo real) [cite: 16, 21]
  getOrdenes: () => instance.get<Orden[]>('/ordenes'),
  
  // Detalle de una orden específica por su número único [cite: 16, 21]
  getOrden: (numeroOrden: number) => instance.get<Orden>(`/ordenes/${numeroOrden}`),

  // Punto 4: Cierre de la orden para bloquear recepción de datos [cite: 12, 16]
  // Mapea a PUT /api/v1/ordenes/{numeroOrden}/close
  cerrarOrden: (numeroOrden: number) => instance.put(`/ordenes/${numeroOrden}/close`),

  // Punto 5: Obtener datos de conciliación calculados [cite: 12, 16]
  // Mapea a GET /api/v1/ordenes/{numeroOrden}/conciliacion
  getConciliacion: (numeroOrden: number) => instance.get<Conciliacion>(`/ordenes/${numeroOrden}/conciliacion`),

  // Gestión de alarmas: Aceptación por usuario autorizado [cite: 16, 21]
  // Mapea a PUT /api/v1/ordenes/{numeroOrden}/aceptar-alarma
  aceptarAlarma: (numeroOrden: number) => instance.put(`/ordenes/${numeroOrden}/aceptar-alarma`),

  // --- USUARIOS (UserRestController) ---
  // Administración de usuarios y roles según requerimiento 
  getUsers: () => instance.get('/users'),
  updateUser: (user: any) => instance.put('/users/update', user)


};