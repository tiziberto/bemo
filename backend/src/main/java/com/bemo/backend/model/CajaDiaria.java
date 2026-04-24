package com.bemo.backend.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "caja_diaria",
       uniqueConstraints = @UniqueConstraint(columnNames = {"fecha", "profesional_id"}))
public class CajaDiaria {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "fecha", nullable = false)
    private LocalDate fecha;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "profesional_id", nullable = false)
    private Profesional profesional;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado", nullable = false, length = 10)
    private EstadoCaja estado = EstadoCaja.ABIERTA;

    @Column(name = "abierta_at")
    private LocalDateTime abiertaAt;

    @Column(name = "cerrada_at")
    private LocalDateTime cerradaAt;

    @Column(name = "firma_texto", length = 200)
    private String firmaTexto;

    @Column(name = "observaciones", length = 500)
    private String observaciones;

    @PrePersist
    protected void onCreate() {
        if (this.abiertaAt == null) this.abiertaAt = LocalDateTime.now();
    }
}
