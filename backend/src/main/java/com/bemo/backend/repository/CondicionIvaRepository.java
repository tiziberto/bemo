package com.bemo.backend.repository;

import com.bemo.backend.model.CondicionIva;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CondicionIvaRepository extends JpaRepository<CondicionIva, Integer> {
}
