// src/types/index.ts — Tipos del sistema ECOMED

export interface LoginRequest {
  username: string
  password: string
}

export interface LoginResponse {
  token: string
  username: string
  roles: string[]
}

export interface RegisterRequest {
  username: string
  password: string
  email: string
  roles?: string[]
}

export interface User {
  id: number
  username: string
  email: string
  isActive: boolean
  createdAt: string
  roles: Role[]
}

export interface Role {
  id: number
  name: string
  description: string
}
