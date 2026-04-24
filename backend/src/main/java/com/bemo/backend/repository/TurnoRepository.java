package com.bemo.backend.repository;

import com.bemo.backend.model.Turno;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public interface TurnoRepository extends JpaRepository<Turno, Long> {

    @Query("SELECT t FROM Turno t WHERE t.fecha = :fecha ORDER BY t.hora ASC")
    List<Turno> findByFecha(@Param("fecha") LocalDate fecha);

    @Query("SELECT t FROM Turno t WHERE t.profesional.id = :profId AND t.fecha = :fecha ORDER BY t.hora ASC")
    List<Turno> findByProfesionalAndFecha(@Param("profId") Long profesionalId, @Param("fecha") LocalDate fecha);

    @Query("SELECT t FROM Turno t WHERE t.paciente.id = :pacId ORDER BY t.fecha DESC, t.hora DESC")
    List<Turno> findByPacienteId(@Param("pacId") Long pacienteId);

    @Query("SELECT t FROM Turno t WHERE t.profesional.id = :profId AND t.fecha = :fecha AND t.hora = :hora")
    List<Turno> findConflictos(@Param("profId") Long profesionalId, @Param("fecha") LocalDate fecha, @Param("hora") LocalTime hora);

    @Query("SELECT t FROM Turno t WHERE t.fecha >= :desde AND t.fecha <= :hasta ORDER BY t.fecha ASC, t.hora ASC")
    List<Turno> findByRango(@Param("desde") LocalDate desde, @Param("hasta") LocalDate hasta);

    @Query("SELECT t FROM Turno t WHERE t.profesional.id = :profId AND t.fecha >= :desde AND t.fecha <= :hasta ORDER BY t.fecha ASC, t.hora ASC")
    List<Turno> findByProfesionalAndRango(@Param("profId") Long profesionalId, @Param("desde") LocalDate desde, @Param("hasta") LocalDate hasta);

    @Query("""
        SELECT t FROM Turno t
        JOIN FETCH t.paciente p
        WHERE t.fecha = :fecha
          AND (:profId IS NULL OR t.profesional.id = :profId)
          AND (:estado IS NULL OR t.estadoTurno.descripcion = :estado)
          AND p.email IS NOT NULL
          AND p.email != ''
        ORDER BY t.hora ASC
    """)
    List<Turno> findTurnosParaConfirmar(
        @Param("fecha") LocalDate fecha,
        @Param("profId") Long profesionalId,
        @Param("estado") String estado
    );

    @Query("""
        SELECT t FROM Turno t
        WHERE t.estadoTurno.descripcion IN ('ATENDIDO', 'CERRADO')
          AND (:profId IS NULL OR t.profesional.id = :profId)
          AND (:desde IS NULL OR t.fecha >= :desde)
          AND (:hasta IS NULL OR t.fecha <= :hasta)
        ORDER BY t.fecha DESC, t.hora DESC
    """)
    Page<Turno> findHistorial(
        @Param("profId") Long profesionalId,
        @Param("desde") LocalDate desde,
        @Param("hasta") LocalDate hasta,
        Pageable pageable
    );

    @Query("""
        SELECT t FROM Turno t
        WHERE t.profesional.id = :profId
          AND t.fecha = :fecha
          AND t.estadoTurno.descripcion IN ('EN_ESPERA', 'ATENDIDO', 'CERRADO')
        ORDER BY t.hora ASC
    """)
    List<Turno> findCajaDiariaItems(
        @Param("profId") Long profesionalId,
        @Param("fecha") LocalDate fecha
    );

    @Query("""
        SELECT t FROM Turno t
        WHERE t.medicoSolicitanteId = :medicoId
          AND (:desde IS NULL OR t.fecha >= :desde)
          AND (:hasta IS NULL OR t.fecha <= :hasta)
        ORDER BY t.fecha DESC, t.hora DESC
    """)
    Page<Turno> findByMedicoSolicitante(
        @Param("medicoId") Long medicoSolicitanteId,
        @Param("desde") LocalDate desde,
        @Param("hasta") LocalDate hasta,
        Pageable pageable
    );
}
