// src/stores/auth.ts
import { defineStore } from 'pinia'
import api from '../api/api'
import { jwtDecode } from 'jwt-decode'

// Roles tal como vienen del backend
const HIERARCHY = ['ROLE_ADMIN', 'ROLE_DOCTOR', 'ROLE_RECEPCION', 'ROLE_FACTURACION', 'ROLE_PACIENTE']

interface JwtPayload {
  sub: string
  roles: string[]
  exp: number
}

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('token') || null as string | null,
    user: null as any,
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

    username: (state): string => {
      if (!state.token) return ''
      try { return jwtDecode<JwtPayload>(state.token).sub || '' }
      catch { return '' }
    },

    primaryRole(): string | undefined {
      return HIERARCHY.find(r => this.roles.includes(r))
    },

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

    async login(username: string, password: string) {
      const res = await api.login({ username, password })
      this.token = res.data.token
      localStorage.setItem('token', res.data.token)
    },

    logout() {
      this.token = null
      this.user = null
      localStorage.clear()
    }
  }
})
