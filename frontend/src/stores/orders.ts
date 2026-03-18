import { defineStore } from 'pinia';
import api from '../api/api';

export const useOrdersStore = defineStore('orders', {
  state: () => ({
    // Inicializamos como array vacío para evitar errores de .length
    ordenes: [] as any[], 
    loading: false,
    pollingInterval: null as any,
  }),

  getters: {
    ordenesProcesadas(state): any[] {
      const lista = state.ordenes || [];
      
      const nombres: Record<number, string> = { 
        1: 'ESPERA TARA', 
        2: 'EN CARGA', 
        3: 'CERRADA', 
        4: 'FINALIZADA' 
      };

      return lista.map(orden => {
        const masa = orden?.ultimaMasaAcumulada || 0;
        const preset = orden?.preset || 0;
        // IMPORTANTE: Capturamos el caudal del backend
        const caudal = orden?.ultimoCaudal || 0; 
        
        // 1. Detección robusta de Estado (Número o String)
        let estadoId = 1;
        const rawEstado = orden?.estado;
        if (typeof rawEstado === 'number') {
            estadoId = rawEstado;
        } else if (typeof rawEstado === 'string') {
            if (rawEstado.includes('ESTADO_1')) estadoId = 1;
            else if (rawEstado.includes('ESTADO_2')) estadoId = 2;
            else if (rawEstado.includes('ESTADO_3')) estadoId = 3;
            else if (rawEstado.includes('ESTADO_4')) estadoId = 4;
        }

        // 2. Lógica de Progreso: Si está FINALIZADA (4), forzamos 100%.
        let progreso = 0;
        if (estadoId === 4) {
            progreso = 100;
        } else if (preset > 0) {
            progreso = Math.min((masa / preset) * 100, 100);
        }

        // 3. Cálculo de ETA (Tiempo estimado)
        let etaStr = '--';
        if (estadoId === 2 && caudal > 0) {
          const minutos = Math.round(((preset - masa) / caudal) * 60);
          etaStr = minutos <= 0 ? 'Lleno' : (minutos < 60 ? `${minutos} m` : `${Math.floor(minutos / 60)}h ${minutos % 60}m`);
        } else if (estadoId >= 3) {
          etaStr = 'Completado';
        }

        return {
          ...orden,
          // Exponemos los datos procesados para la vista
          _progreso: progreso,
          _eta: etaStr,
          _caudal: caudal, // Dato para el velocímetro
          _estadoId: estadoId,
          _estadoNombre: nombres[estadoId as keyof typeof nombres] || 'DESCONOCIDO',
          _tieneAlarma: !!(orden?.alarmaTemperaturaEnviada && !orden?.alarmaTemperaturaAceptada)
        };
      });
    },

    stats(): any {
      const procesadas = (this as any).ordenesProcesadas || [];
      return {
        total: procesadas.length,
        activas: procesadas.filter((o: any) => o._estadoId === 2).length,
        alertas: procesadas.filter((o: any) => o._tieneAlarma).length,
        cargaTotal: procesadas.reduce((acc: number, o: any) => acc + (o.ultimaMasaAcumulada || 0), 0)
      };
    },

    alarmasActivas(): any[] {
      return (this as any).ordenesProcesadas.filter((o: any) => o._tieneAlarma);
    }
  },

  actions: {
    async fetchOrders(showLoading = true) {
      if (showLoading) this.loading = true;
      try {
        const { data } = await api.getOrdenes();
        this.ordenes = Array.isArray(data) ? data : [];
      } catch (error) {
        console.error("Error API:", error);
        this.ordenes = [];
      } finally {
        this.loading = false;
      }
    },

    startPolling() {
      if (this.pollingInterval) return;
      this.fetchOrders();
      this.pollingInterval = setInterval(() => this.fetchOrders(false), 5000);
    },

    stopPolling() {
      if (this.pollingInterval) {
        clearInterval(this.pollingInterval);
        this.pollingInterval = null;
      }
    },

    // ... dentro de actions: ...

    async acknowledgeAlarm(numeroOrden: number) {
      try {
        // 1. Llamamos al backend
        await api.aceptarAlarma(numeroOrden);
        
        // 2. Actualizamos localmente
        const orden = this.ordenes.find((o: any) => o.numeroOrden === numeroOrden);
        if (orden) {
          orden.alarmaTemperaturaAceptada = true; 
        }
        
        // 3. Refrescamos
        await this.fetchOrders(false);
        return true; 

      } catch (error: any) {
        console.error("Error al aceptar alarma:", error);
        
        // Mensaje de error genérico
        if (error.response && error.response.status === 403) {
          alert("Error: El servidor rechazó la solicitud (403 Forbidden). Revisá el código Java.");
        } else {
          alert("Hubo un error al intentar desactivar la alarma.");
        }
        return false; 
      }
    }
  }
});