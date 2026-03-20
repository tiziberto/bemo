<template>
  <v-container class="fill-height" fluid>
    <v-row align="center" justify="center">
      <v-col cols="12" sm="6" class="text-center">
        <v-icon size="80" color="error">mdi-shield-off</v-icon>
        <h2 class="mt-4 text-h5">Acceso denegado</h2>
        <p class="text-medium-emphasis mt-2">No tenés permisos para ver esta página.</p>
        <v-btn color="primary" class="mt-4" to="/login">Volver al login</v-btn>
      </v-col>
    </v-row>
  </v-container>
</template>
