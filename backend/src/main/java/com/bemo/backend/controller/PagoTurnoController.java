package com.bemo.backend.controller;

import com.bemo.backend.dto.PagoTurnoDto;
import com.bemo.backend.service.PagoTurnoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/pagos")
@RequiredArgsConstructor
public class PagoTurnoController {

    private final PagoTurnoService service;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'RECEPCION', 'DOCTOR')")
    public ResponseEntity<?> getByTurno(@RequestParam Long turnoId) {
        return service.getByTurnoId(turnoId)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'RECEPCION')")
    public ResponseEntity<?> createOrUpdate(@RequestBody PagoTurnoDto dto) {
        try {
            return ResponseEntity.ok(service.createOrUpdate(dto));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PutMapping("/{id}/recupero")
    @PreAuthorize("hasAnyRole('ADMIN', 'RECEPCION')")
    public ResponseEntity<?> convertirARecupero(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.convertirARecupero(id));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
