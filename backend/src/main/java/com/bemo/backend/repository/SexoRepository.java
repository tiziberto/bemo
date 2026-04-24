package com.bemo.backend.repository;

import com.bemo.backend.model.Sexo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface SexoRepository extends JpaRepository<Sexo, Integer> {
    Optional<Sexo> findByDescripcion(String descripcion);

    @Query("SELECT s FROM Sexo s WHERE UPPER(s.descripcion) = UPPER(?1)")
    Optional<Sexo> findByDescripcionIgnoreCase(String descripcion);
}
