package com.bemo.backend.repository;

import com.bemo.backend.model.EstadoTurno;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface EstadoTurnoRepository extends JpaRepository<EstadoTurno, Integer> {
    Optional<EstadoTurno> findByDescripcion(String descripcion);
}
