package com.bemo.backend.repository;

import com.bemo.backend.model.PagoTurno;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.Optional;

public interface PagoTurnoRepository extends JpaRepository<PagoTurno, Long> {

    Optional<PagoTurno> findByTurnoId(Long turnoId);

    @Query("""
        SELECT p FROM PagoTurno p
        WHERE p.turno.profesional.id = :profId
          AND p.turno.fecha = :fecha
        ORDER BY p.turno.hora ASC
    """)
    java.util.List<PagoTurno> findByProfesionalAndFecha(
        @Param("profId") Long profesionalId,
        @Param("fecha") java.time.LocalDate fecha
    );
}
