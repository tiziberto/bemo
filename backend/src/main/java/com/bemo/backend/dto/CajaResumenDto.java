package com.bemo.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CajaResumenDto {
    private Long cajaDiariaId;
    private String estado;
    private String fecha;
    private Long profesionalId;
    private String profesionalNombre;
    private String firmaTexto;
    private String observaciones;

    private List<CajaItemDto> items;

    private BigDecimal totalEfectivo;
    private BigDecimal totalElectronico;
    private BigDecimal totalCoseguro;
    private BigDecimal totalDepositos;
    private BigDecimal totalRecuperos;
    private BigDecimal totalGeneral;
}
