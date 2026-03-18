// src/stores/auth.store.ts
import { defineStore } from 'pinia'
import api from '../api/api'
import { jwtDecode } from 'jwt-decode'

const HIERARCHY = ['ROLE_ADMIN','ROLE_DOCTOR','ROLE_RECEPTION','ROLE_BILLING','ROLE_PATIENT']

interface JwtPayload {
  sub: string
  roles: string[]
  exp: number
}

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('token') || null as string | null,
    user:  null as any,
  }),

  getters: {
    isAuthenticated: (state): boolean => {
      if (!state.token) return false
      try {
        const { exp } = jwtDecode<JwtPayload>(state.token)
        return Date.now() < exp * 1000
      } catch { return false }
    },

    roles: (state): string[] => {
      if (!state.token) return []
      try { return jwtDecode<JwtPayload>(state.token).roles || [] }
      catch { return [] }
    },

    // El rol de mayor jerarquía del usuario
    primaryRole(): string | undefined {
      return HIERARCHY.find(r => this.roles.includes(r))
    },

    // Para compatibilidad con tu código anterior
    role(): string | null {
      return this.primaryRole || null
    }
  },

  actions: {
    hasRole(role: string): boolean {
      return this.roles.includes(role)
    },

    hasAnyRole(roles: string[]): boolean {
      return roles.some(r => this.roles.includes(r))
    },

   async login(email: string, password: string) {
  const res = await api.login({ email, password })
  this.token = res.data.token
  localStorage.setItem('token', res.data.token)
},

    logout() {
      this.token = null
      this.user  = null
      localStorage.clear()
    }
  }
})