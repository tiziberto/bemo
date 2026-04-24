package com.bemo.backend.controller;

import com.bemo.backend.dto.BloqueoAgendaDto;
import com.bemo.backend.service.BloqueoAgendaService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/bloqueos")
@RequiredArgsConstructor
public class BloqueoAgendaController {

    private final BloqueoAgendaService service;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'RECEPCION', 'DOCTOR')")
    public ResponseEntity<List<BloqueoAgendaDto>> getAll(
            @RequestParam(required = false) Long profesionalId) {
        if (profesionalId != null) {
            return ResponseEntity.ok(service.getByProfesional(profesionalId));
        }
        return ResponseEntity.ok(service.getAll());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'RECEPCION')")
    public ResponseEntity<?> create(@RequestBody BloqueoAgendaDto dto) {
        try {
            return ResponseEntity.ok(service.create(dto));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'RECEPCION')")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        try {
            service.delete(id);
            return ResponseEntity.ok(Map.of("message", "Bloqueo eliminado"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
