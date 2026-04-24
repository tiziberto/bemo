package com.bemo.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CajaItemDto {
    private Long turnoId;
    private String hora;
    private String pacienteNombre;
    private String obraSocialNombre;
    private String estudioNombre;
    private BigDecimal efectivo;
    private BigDecimal electronico;
    private BigDecimal coseguro;
    private Boolean esDeposito;
    private Boolean recuperoDeposito;
    private BigDecimal valorDeposito;
    private String metodoPago1;
    private String metodoPago2;
    private Long pagoId;
    private Boolean esParticular;
}
