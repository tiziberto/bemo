package com.bemo.backend.model;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "pago_turno")
public class PagoTurno {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "turno_id", nullable = false, unique = true)
    private Turno turno;

    @Column(name = "estudio_realizado", length = 200)
    private String estudioRealizado;

    @Enumerated(EnumType.STRING)
    @Column(name = "metodo_pago1", nullable = false, length = 20)
    private MetodoPago metodoPago1;

    @Column(name = "monto1", nullable = false, precision = 10, scale = 2)
    private BigDecimal monto1 = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(name = "metodo_pago2", length = 20)
    private MetodoPago metodoPago2;

    @Column(name = "monto2", precision = 10, scale = 2)
    private BigDecimal monto2;

    @Column(name = "coseguro", precision = 10, scale = 2)
    private BigDecimal coseguro;

    @Column(name = "es_particular", nullable = false)
    private Boolean esParticular = false;

    @Column(name = "es_deposito", nullable = false)
    private Boolean esDeposito = false;

    @Column(name = "valor_deposito", precision = 10, scale = 2)
    private BigDecimal valorDeposito;

    @Column(name = "recupero_deposito", nullable = false)
    private Boolean recuperoDeposito = false;

    @Column(name = "observaciones_cobro", length = 500)
    private String observacionesCobro;

    @Column(name = "creado_at", updatable = false)
    private LocalDateTime creadoAt;

    @PrePersist
    protected void onCreate() {
        this.creadoAt = LocalDateTime.now();
    }
}
