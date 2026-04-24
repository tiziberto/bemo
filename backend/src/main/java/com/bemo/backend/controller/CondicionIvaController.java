package com.bemo.backend.controller;

import com.bemo.backend.model.CondicionIva;
import com.bemo.backend.repository.CondicionIvaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/condiciones-iva")
@RequiredArgsConstructor
public class CondicionIvaController {

    private final CondicionIvaRepository repo;

    @GetMapping
    @PreAuthorize("permitAll()")
    public ResponseEntity<List<CondicionIva>> getAll() {
        return ResponseEntity.ok(repo.findAll());
    }

    @GetMapping("/{id}")
    @PreAuthorize("permitAll()")
    public ResponseEntity<?> getById(@PathVariable Integer id) {
        return ResponseEntity.ok(repo.findById(id)
            .orElseThrow(() -> new RuntimeException("Condición IVA no encontrada")));
    }
}
