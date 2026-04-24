package com.bemo.backend.dto;

import com.bemo.backend.model.TipoBloqueo;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class BloqueoAgendaDto {
    private Long id;
    private Long profesionalId;
    private String profesionalNombre;
    private String fechaDesde;
    private String fechaHasta;
    private String motivo;
    private TipoBloqueo tipo;
}
