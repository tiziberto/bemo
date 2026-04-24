package com.bemo.backend.service;

import com.bemo.backend.dto.BloqueoAgendaDto;
import com.bemo.backend.model.BloqueoAgenda;
import com.bemo.backend.model.Profesional;
import com.bemo.backend.model.TipoBloqueo;
import com.bemo.backend.repository.BloqueoAgendaRepository;
import com.bemo.backend.repository.ProfesionalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class BloqueoAgendaService {

    private final BloqueoAgendaRepository repo;
    private final ProfesionalRepository profRepo;

    @Transactional(readOnly = true)
    public List<BloqueoAgendaDto> getByProfesional(Long profesionalId) {
        return repo.findByProfesionalId(profesionalId).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<BloqueoAgendaDto> getAll() {
        return repo.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public BloqueoAgendaDto create(BloqueoAgendaDto dto) {
        Profesional prof = profRepo.findById(dto.getProfesionalId())
                .orElseThrow(() -> new RuntimeException("Profesional no encontrado"));

        if (dto.getFechaDesde() == null || dto.getFechaHasta() == null) {
            throw new RuntimeException("Fecha desde y fecha hasta son obligatorias");
        }

        LocalDate desde = LocalDate.parse(dto.getFechaDesde());
        LocalDate hasta = LocalDate.parse(dto.getFechaHasta());

        if (hasta.isBefore(desde)) {
            throw new RuntimeException("La fecha hasta no puede ser anterior a la fecha desde");
        }

        BloqueoAgenda bloqueo = new BloqueoAgenda();
        bloqueo.setProfesional(prof);
        bloqueo.setFechaDesde(desde);
        bloqueo.setFechaHasta(hasta);
        bloqueo.setMotivo(dto.getMotivo());
        bloqueo.setTipo(dto.getTipo() != null ? dto.getTipo() : TipoBloqueo.VACACIONES);

        return toDto(repo.save(bloqueo));
    }

    public void delete(Long id) {
        repo.findById(id).orElseThrow(() -> new RuntimeException("Bloqueo no encontrado"));
        repo.deleteById(id);
    }

    public boolean estaBloquead(Long profesionalId, LocalDate fecha) {
        return !repo.findActivoEnFecha(profesionalId, fecha).isEmpty();
    }

    private BloqueoAgendaDto toDto(BloqueoAgenda b) {
        return new BloqueoAgendaDto(
                b.getId(),
                b.getProfesional().getId(),
                b.getProfesional().getNombre(),
                b.getFechaDesde().toString(),
                b.getFechaHasta().toString(),
                b.getMotivo(),
                b.getTipo()
        );
    }
}
