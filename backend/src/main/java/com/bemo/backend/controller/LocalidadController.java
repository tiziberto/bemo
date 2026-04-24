package com.bemo.backend.controller;

import com.bemo.backend.model.Localidad;
import com.bemo.backend.repository.LocalidadRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/localidades")
@RequiredArgsConstructor
public class LocalidadController {

    private final LocalidadRepository repo;

    @GetMapping
    @PreAuthorize("permitAll()")
    public ResponseEntity<List<Localidad>> getAll() {
        return ResponseEntity.ok(repo.findAll());
    }

    @GetMapping("/{id}")
    @PreAuthorize("permitAll()")
    public ResponseEntity<?> getById(@PathVariable Long id) {
        return ResponseEntity.ok(repo.findById(id)
            .orElseThrow(() -> new RuntimeException("Localidad no encontrada")));
    }
}
