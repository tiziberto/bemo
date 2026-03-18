// src/types/index.ts

export interface Camion {
  id: number;
  patente: string;
  descripcion?: string;
  cisternado?: string;
}

export interface Orden {
  id: number;
  numeroOrden: number;
  estado: 'ESTADO_1_PENDIENTE_PESAJE_INICIAL' | 'ESTADO_2_CON_PESAJE_INICIAL_REGISTRADO' | 'ESTADO_3_CERRADA_PARA_CARGA' | 'ESTADO_4_FINALIZADA';
  camion: Camion;
  preset: number;
  
  // Datos dinámicos (pueden venir null del backend si no arrancó la carga)
  ultimaMasaAcumulada: number | null;
  ultimaTemperatura: number | null;
  ultimaDensidad: number | null;
  ultimoCaudal: number | null;
  
  fechaInicioCarga?: string;
  alarmaTemperaturaEnviada: boolean;
  alarmaTemperaturaAceptada: boolean;
}

export interface Conciliacion {
  numeroOrden: number;
  pesajeInicial: number;
  pesajeFinal: number;
  productoCargado: number;
  netoBalanza: number;
  diferenciaBalanzaCaudalimetro: number;
  promedioTemperatura: number;
  promedioDensidad: number;
  promedioCaudal: number;
}