<template>
  <v-container fluid class="fill-height align-start pa-6 bg-background">
    <div class="mb-6 w-100 d-flex justify-space-between align-center">
      <div>
        <h1 class="text-h4 font-weight-bold text-white">Gestión de Usuarios</h1>
        <p class="text-grey">Administración de accesos y roles del sistema</p>
      </div>
      <v-btn color="primary" @click="cargarUsuarios" :loading="loading" prepend-icon="mdi-refresh">
        Actualizar
      </v-btn>
    </div>
    
    <v-card class="glass-card" elevation="0">
      <v-data-table 
        :headers="headers" 
        :items="usuarios" 
        :loading="loading"
        class="premium-table bg-transparent"
        hover
      >
        <template v-slot:item.username="{ item }">
          <div class="d-flex align-center">
            <v-avatar color="grey-darken-3" size="32" class="mr-3">
              <span class="text-caption font-weight-bold">{{ item.username.substring(0,2).toUpperCase() }}</span>
            </v-avatar>
            <span class="font-weight-bold text-white">{{ item.username }}</span>
          </div>
        </template>

        <template v-slot:item.roles="{ item }">
          <v-chip-group>
            <v-chip 
              v-for="rol in item.roles" 
              :key="rol.id" 
              size="small" 
              :color="getRoleColor(rol.name)"
              label
              class="font-weight-bold"
            >
              {{ rol.name.replace('ROLE_', '') }}
            </v-chip>
          </v-chip-group>
        </template>

        <template v-slot:item.enabled="{ item }">
          <v-switch
            v-model="item.enabled"
            color="success"
            hide-details
            density="compact"
            @update:model-value="guardarCambios(item)"
            inset
          ></v-switch>
        </template>

        <template v-slot:item.acciones="{ item }">
          <v-btn 
            icon 
            variant="text" 
            color="primary" 
            @click="abrirEditor(item)"
          >
            <v-icon>mdi-pencil</v-icon>
            <v-tooltip activator="parent" location="top">Editar Roles</v-tooltip>
          </v-btn>
        </template>
      </v-data-table>
    </v-card>

    <v-dialog v-model="dialogoEditar" max-width="500">
      <v-card class="glass-card pa-4">
        <v-card-title class="text-white">Editar Usuario: {{ usuarioEditando?.username }}</v-card-title>
        <v-card-text>
          <v-select
            v-model="rolesSeleccionados"
            :items="rolesDisponibles"
            label="Asignar Roles"
            multiple
            chips
            closable-chips
            variant="outlined"
            bg-color="surface"
          ></v-select>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="grey" variant="text" @click="dialogoEditar = false">Cancelar</v-btn>
          <v-btn color="primary" variant="flat" @click="guardarRoles">Guardar</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

  </v-container>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import api from '../api/api';

const usuarios = ref([]);
const loading = ref(false);
const dialogoEditar = ref(false);
const usuarioEditando = ref<any>(null);
const rolesSeleccionados = ref<string[]>([]);

const rolesDisponibles = ['ROLE_ADMIN', 'ROLE_SAP', 'ROLE_TMS', 'ROLE_CLI', 'ROLE_USER'];

const headers = [
  { title: 'Usuario', key: 'username', width: '200px' },
  { title: 'Email', key: 'email' },
  { title: 'Roles', key: 'roles' },
  { title: 'Activo', key: 'enabled', width: '100px' },
  { title: 'Acciones', key: 'acciones', align: 'end', width: '100px' }
];

const cargarUsuarios = async () => {
  loading.value = true;
  try {
    const { data } = await api.getUsers();
    usuarios.value = data;
  } catch (e) {
    console.error(e);
  } finally {
    loading.value = false;
  }
};

const abrirEditor = (item: any) => {
  usuarioEditando.value = item;
  rolesSeleccionados.value = item.roles.map((r: any) => r.name);
  dialogoEditar.value = true;
};

const guardarRoles = async () => {
  if (!usuarioEditando.value) return;
  
  // Convertir strings de roles a objetos si el backend lo espera así, 
  // o enviar la lista de nombres y que el backend resuelva.
  // Asumiremos que el backend espera objetos Role con al menos el nombre
  const nuevosRoles = rolesSeleccionados.value.map(nombre => ({ name: nombre }));
  
  const usuarioActualizado = {
    ...usuarioEditando.value,
    roles: nuevosRoles
  };

  await api.updateUser(usuarioActualizado);
  dialogoEditar.value = false;
  await cargarUsuarios();
};

const guardarCambios = async (item: any) => {
  try {
    await api.updateUser(item);
  } catch(e) {
    // Revertir si falla
    item.enabled = !item.enabled; 
    alert("Error al actualizar estado");
  }
};

const getRoleColor = (rol: string) => {
  if (rol.includes('ADMIN')) return 'red';
  if (rol.includes('SAP')) return 'blue';
  if (rol.includes('TMS')) return 'purple';
  return 'grey';
};

onMounted(cargarUsuarios);
</script>

<style scoped>
.bg-background { background-color: #121212 !important; min-height: 100vh; }
.glass-card { background: #1E1E1E; border: 1px solid #333; border-radius: 8px; }
:deep(.premium-table) { background: transparent !important; color: #E0E0E0; }
</style>