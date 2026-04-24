package com.bemo.backend.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
public class CambiarEstadoRequest {
    private String nuevoEstado;

    // Campos para EN_ESPERA (cobro)
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

    // Campos para ATENDIDO (informe médico)
    private String preInforme;
    private String informeUrl;
    private String fotoUrl;
}
