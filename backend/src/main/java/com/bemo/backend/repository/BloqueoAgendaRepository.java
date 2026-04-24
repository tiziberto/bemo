package com.bemo.backend.repository;

import com.bemo.backend.model.BloqueoAgenda;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface BloqueoAgendaRepository extends JpaRepository<BloqueoAgenda, Long> {

    @Query("SELECT b FROM BloqueoAgenda b WHERE b.profesional.id = :profId ORDER BY b.fechaDesde DESC")
    List<BloqueoAgenda> findByProfesionalId(@Param("profId") Long profesionalId);

    @Query("""
        SELECT b FROM BloqueoAgenda b
        WHERE b.profesional.id = :profId
          AND b.fechaDesde <= :fecha
          AND b.fechaHasta >= :fecha
    """)
    List<BloqueoAgenda> findActivoEnFecha(@Param("profId") Long profesionalId, @Param("fecha") LocalDate fecha);
}
