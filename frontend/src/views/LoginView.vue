<template>
  <div class="login-root">
    <div class="login-left">
      <div class="brand">
        <div class="brand-icon"><v-icon color="#00C896" size="28">mdi-hospital-box</v-icon></div>
        <span class="brand-name"><span style="color:#E8EDF5">ECO</span><span style="color:#00C896">MED</span></span>
      </div>
      <div class="hero-content">
        <h1 class="hero-title">Atención médica<br/><span class="hero-accent">inteligente.</span></h1>
        <p class="hero-sub">Sistema integral de gestión clínica. Turnos, historias clínicas y facturación en una sola plataforma.</p>
        <div class="features">
          <div class="feature-item" v-for="f in features" :key="f.text">
            <v-icon color="#00C896" size="16">{{ f.icon }}</v-icon>
            <span>{{ f.text }}</span>
          </div>
        </div>
      </div>
      <div class="login-footer-brand">© 2025 Ecomed · Sistema Médico Integral</div>
    </div>

    <div class="login-right">
      <div class="login-card">
        <div class="card-header">
          <div class="card-tag">ACCESO SEGURO</div>
          <h2 class="card-title">Bienvenido de vuelta</h2>
          <p class="card-sub">Ingresá tus credenciales para continuar</p>
        </div>

        <div class="form-group">
          <label class="form-label">Usuario</label>
          <div class="input-wrap" :class="{ focus: focusUser }">
            <v-icon size="16" color="rgba(255,255,255,0.3)">mdi-account-outline</v-icon>
            <input
              v-model="username"
              type="text"
              placeholder="nombre.apellido"
              class="eco-input"
              @focus="focusUser = true"
              @blur="focusUser = false"
              @keyup.enter="handleLogin"
            />
          </div>
        </div>

        <div class="form-group">
          <label class="form-label">Contraseña</label>
          <div class="input-wrap" :class="{ focus: focusPass }">
            <v-icon size="16" color="rgba(255,255,255,0.3)">mdi-lock-outline</v-icon>
            <input
              v-model="password"
              :type="showPass ? 'text' : 'password'"
              placeholder="••••••••"
              class="eco-input"
              @focus="focusPass = true"
              @blur="focusPass = false"
              @keyup.enter="handleLogin"
            />
            <v-icon
              size="16"
              color="rgba(255,255,255,0.3)"
              style="cursor:pointer"
              @click="showPass = !showPass"
            >{{ showPass ? 'mdi-eye-off' : 'mdi-eye' }}</v-icon>
          </div>
        </div>

        <div v-if="errorMessage" class="error-msg">
          <v-icon size="14" color="#EF4444">mdi-alert-circle</v-icon>
          {{ errorMessage }}
        </div>

        <button class="login-btn" :class="{ loading }" @click="handleLogin" :disabled="loading">
          <span v-if="!loading">Ingresar al sistema</span>
          <span v-else class="btn-loading">
            <span class="dot" /><span class="dot" /><span class="dot" />
          </span>
        </button>

        <div class="login-card-footer">
          <v-icon size="12" color="rgba(255,255,255,0.2)">mdi-shield-check</v-icon>
          <span>Conexión cifrada · JWT · BCrypt</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const auth   = useAuthStore()

const username  = ref('')
const password  = ref('')
const loading   = ref(false)
const showPass  = ref(false)
const focusUser = ref(false)
const focusPass = ref(false)
const errorMessage = ref('')

const features = [
  { icon: 'mdi-calendar-check', text: 'Gestión de turnos en tiempo real' },
  { icon: 'mdi-file-medical',   text: 'Historias clínicas digitales' },
  { icon: 'mdi-shield-check',   text: 'Datos protegidos y encriptados' },
]

const handleLogin = async () => {
  if (!username.value || !password.value) {
    errorMessage.value = 'Completá todos los campos.'
    return
  }
  loading.value = true
  errorMessage.value = ''
  try {
    await auth.login(username.value, password.value)
    router.push('/dashboard')
  } catch (e: any) {
    errorMessage.value = e.response?.status === 401
      ? 'Credenciales incorrectas.'
      : 'Servidor no disponible.'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-root {
  display: flex; height: 100vh; width: 100vw;
  background: #0A0F1E; font-family: 'DM Sans', sans-serif;
}

/* LEFT */
.login-left {
  flex: 1; padding: 48px 56px;
  display: flex; flex-direction: column;
  background: linear-gradient(135deg, #0A0F1E 0%, #0D1B2A 100%);
  border-right: 1px solid rgba(0,200,150,0.1);
  position: relative; overflow: hidden;
}
.login-left::before {
  content: '';
  position: absolute; top: -200px; right: -100px;
  width: 500px; height: 500px; border-radius: 50%;
  background: radial-gradient(circle, rgba(0,200,150,0.06) 0%, transparent 70%);
  pointer-events: none;
}

.brand { display: flex; align-items: center; gap: 10px; }
.brand-icon {
  width: 40px; height: 40px; border-radius: 12px;
  background: rgba(0,200,150,0.12); border: 1px solid rgba(0,200,150,0.25);
  display: flex; align-items: center; justify-content: center;
}
.brand-name { font-family: 'Playfair Display', serif; font-size: 20px; font-weight: 700; letter-spacing: 3px; }

.hero-content { flex: 1; display: flex; flex-direction: column; justify-content: center; max-width: 440px; }
.hero-title {
  font-family: 'Playfair Display', serif;
  font-size: 48px; font-weight: 700; line-height: 1.15;
  color: #E8EDF5; margin: 0 0 20px;
}
.hero-accent { color: #00C896; }
.hero-sub { font-size: 15px; color: rgba(255,255,255,0.45); line-height: 1.7; margin: 0 0 36px; }

.features { display: flex; flex-direction: column; gap: 12px; }
.feature-item { display: flex; align-items: center; gap: 10px; font-size: 13px; color: rgba(255,255,255,0.55); }

.login-footer-brand { font-size: 11px; color: rgba(255,255,255,0.2); }

/* RIGHT */
.login-right {
  width: 480px; display: flex; align-items: center; justify-content: center;
  background: #0D1120; padding: 40px;
}

.login-card { width: 100%; max-width: 380px; }
.card-tag {
  font-size: 10px; letter-spacing: 2.5px; color: #00C896;
  font-weight: 600; margin-bottom: 12px;
}
.card-title { font-family: 'Playfair Display', serif; font-size: 26px; color: #E8EDF5; margin: 0 0 6px; font-weight: 600; }
.card-sub { font-size: 13px; color: rgba(255,255,255,0.35); margin: 0 0 36px; }

.form-group { margin-bottom: 18px; }
.form-label { display: block; font-size: 11.5px; font-weight: 600; color: rgba(255,255,255,0.5); letter-spacing: 0.5px; margin-bottom: 8px; text-transform: uppercase; }

.input-wrap {
  display: flex; align-items: center; gap: 10px;
  padding: 12px 14px; border-radius: 10px;
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(255,255,255,0.08);
  transition: border-color 0.2s, background 0.2s;
}
.input-wrap.focus { border-color: rgba(0,200,150,0.5); background: rgba(0,200,150,0.04); }

.eco-input {
  flex: 1; background: none; border: none; outline: none;
  font-family: 'DM Sans', sans-serif; font-size: 14px;
  color: #E8EDF5;
}
.eco-input::placeholder { color: rgba(255,255,255,0.2); }

.error-msg {
  display: flex; align-items: center; gap: 6px;
  font-size: 12px; color: #EF4444;
  background: rgba(239,68,68,0.08); border: 1px solid rgba(239,68,68,0.2);
  padding: 10px 12px; border-radius: 8px; margin-bottom: 18px;
}

.login-btn {
  width: 100%; padding: 14px;
  background: #00C896; border: none; border-radius: 10px;
  color: #0A0F1E; font-family: 'DM Sans', sans-serif;
  font-size: 14px; font-weight: 700; letter-spacing: 0.5px;
  cursor: pointer; transition: all 0.2s; margin-bottom: 20px;
}
.login-btn:hover:not(:disabled) { background: #00DBA6; transform: translateY(-1px); box-shadow: 0 8px 24px rgba(0,200,150,0.3); }
.login-btn:disabled { opacity: 0.7; cursor: not-allowed; }

.btn-loading { display: flex; align-items: center; justify-content: center; gap: 5px; }
.dot { width: 6px; height: 6px; background: #0A0F1E; border-radius: 50%; animation: bounce 0.8s infinite; }
.dot:nth-child(2) { animation-delay: 0.15s; }
.dot:nth-child(3) { animation-delay: 0.3s; }
@keyframes bounce { 0%,80%,100%{transform:scale(1)} 40%{transform:scale(1.4)} }

.login-card-footer { display: flex; align-items: center; gap: 6px; justify-content: center; font-size: 11px; color: rgba(255,255,255,0.2); }

@media (max-width: 768px) {
  .login-left { display: none; }
  .login-right { width: 100%; }
}
</style>