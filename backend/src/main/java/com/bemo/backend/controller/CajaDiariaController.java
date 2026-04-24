package com.bemo.backend.controller;

import com.bemo.backend.service.CajaDiariaService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/api/caja")
@RequiredArgsConstructor
public class CajaDiariaController {

    private final CajaDiariaService service;

    @GetMapping("/resumen")
    @PreAuthorize("hasAnyRole('ADMIN', 'RECEPCION', 'DOCTOR')")
    public ResponseEntity<?> getResumen(
            @RequestParam Long profesionalId,
            @RequestParam(required = false) String fecha) {
        try {
            return ResponseEntity.ok(service.getResumen(profesionalId, fecha));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/abrir")
    @PreAuthorize("hasAnyRole('ADMIN', 'RECEPCION')")
    public ResponseEntity<?> abrir(@RequestBody Map<String, Object> body) {
        try {
            Long profesionalId = Long.parseLong(body.get("profesionalId").toString());
            String fechaStr = body.containsKey("fecha") ? body.get("fecha").toString() : null;
            LocalDate fecha = fechaStr != null ? LocalDate.parse(fechaStr) : LocalDate.now();
            return ResponseEntity.ok(service.abrirCaja(profesionalId, fecha));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/{id}/cerrar")
    @PreAuthorize("hasAnyRole('ADMIN', 'RECEPCION', 'DOCTOR')")
    public ResponseEntity<?> cerrar(@PathVariable Long id, @RequestBody Map<String, String> body) {
        try {
            return ResponseEntity.ok(service.cerrarCaja(id, body.get("firmaTexto"), body.get("observaciones")));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
