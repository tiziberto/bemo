package com.bemo.backend.repository;

import com.bemo.backend.model.CajaDiaria;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.Optional;

public interface CajaDiariaRepository extends JpaRepository<CajaDiaria, Long> {

    Optional<CajaDiaria> findByFechaAndProfesionalId(LocalDate fecha, Long profesionalId);
}
