// src/api/api.ts — Servicios del sistema ECOMED
import axios from 'axios'
import type { LoginRequest, RegisterRequest, User } from '../types'

const instance = axios.create({
  baseURL: 'http://localhost:8080/api/users'
})

// Inyecta el token JWT en cada petición protegida
instance.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

export default {
  // ── AUTH ────────────────────────────────────────────────────
  login:    (credentials: LoginRequest)  => instance.post('/login',    credentials),
  register: (data:        RegisterRequest) => instance.post('/register', data),

  // ── USUARIOS (solo ADMIN) ───────────────────────────────────
  getUsers:   ()           => instance.get<User[]>('/users'),
  updateUser: (user: User) => instance.put('/users/update', user),
}
