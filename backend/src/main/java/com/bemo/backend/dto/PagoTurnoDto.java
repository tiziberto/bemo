package com.bemo.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PagoTurnoDto {
    private Long id;
    private Long turnoId;
    private String estudioRealizado;
    private String metodoPago1;
    private BigDecimal monto1;
    private String metodoPago2;
    private BigDecimal monto2;
    private BigDecimal coseguro;
    private Boolean esParticular;
    private Boolean esDeposito;
    private BigDecimal valorDeposito;
    private Boolean recuperoDeposito;
    private String observacionesCobro;
}
