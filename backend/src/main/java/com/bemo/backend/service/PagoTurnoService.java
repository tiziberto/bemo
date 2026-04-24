package com.bemo.backend.service;

import com.bemo.backend.dto.PagoTurnoDto;
import com.bemo.backend.model.MetodoPago;
import com.bemo.backend.model.PagoTurno;
import com.bemo.backend.model.Turno;
import com.bemo.backend.repository.PagoTurnoRepository;
import com.bemo.backend.repository.TurnoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class PagoTurnoService {

    private final PagoTurnoRepository repo;
    private final TurnoRepository turnoRepo;

    @Transactional(readOnly = true)
    public Optional<PagoTurnoDto> getByTurnoId(Long turnoId) {
        return repo.findByTurnoId(turnoId).map(this::toDto);
    }

    public PagoTurnoDto createOrUpdate(PagoTurnoDto dto) {
        Turno turno = turnoRepo.findById(dto.getTurnoId())
            .orElseThrow(() -> new RuntimeException("Turno no encontrado"));

        PagoTurno pago = repo.findByTurnoId(dto.getTurnoId()).orElse(new PagoTurno());
        pago.setTurno(turno);
        pago.setEstudioRealizado(dto.getEstudioRealizado());
        pago.setMetodoPago1(MetodoPago.valueOf(dto.getMetodoPago1()));
        pago.setMonto1(dto.getMonto1());
        if (dto.getMetodoPago2() != null) pago.setMetodoPago2(MetodoPago.valueOf(dto.getMetodoPago2()));
        pago.setMonto2(dto.getMonto2());
        pago.setCoseguro(dto.getCoseguro());
        pago.setEsParticular(Boolean.TRUE.equals(dto.getEsParticular()));
        pago.setEsDeposito(Boolean.TRUE.equals(dto.getEsDeposito()));
        pago.setValorDeposito(dto.getValorDeposito());
        pago.setRecuperoDeposito(Boolean.TRUE.equals(dto.getRecuperoDeposito()));
        pago.setObservacionesCobro(dto.getObservacionesCobro());
        return toDto(repo.save(pago));
    }

    public PagoTurnoDto convertirARecupero(Long pagoId) {
        PagoTurno pago = repo.findById(pagoId)
            .orElseThrow(() -> new RuntimeException("Pago no encontrado"));
        pago.setRecuperoDeposito(true);
        return toDto(repo.save(pago));
    }

    public PagoTurnoDto toDto(PagoTurno p) {
        return new PagoTurnoDto(
            p.getId(),
            p.getTurno().getId(),
            p.getEstudioRealizado(),
            p.getMetodoPago1() != null ? p.getMetodoPago1().name() : null,
            p.getMonto1(),
            p.getMetodoPago2() != null ? p.getMetodoPago2().name() : null,
            p.getMonto2(),
            p.getCoseguro(),
            p.getEsParticular(),
            p.getEsDeposito(),
            p.getValorDeposito(),
            p.getRecuperoDeposito(),
            p.getObservacionesCobro()
        );
    }
}
