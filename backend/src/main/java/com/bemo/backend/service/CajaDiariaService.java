package com.bemo.backend.service;

import com.bemo.backend.dto.CajaItemDto;
import com.bemo.backend.dto.CajaResumenDto;
import com.bemo.backend.model.*;
import com.bemo.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class CajaDiariaService {

    private final CajaDiariaRepository cajaRepo;
    private final TurnoRepository turnoRepo;
    private final PagoTurnoRepository pagoRepo;
    private final ProfesionalRepository profRepo;

    @Transactional(readOnly = true)
    public CajaResumenDto getResumen(Long profesionalId, String fechaStr) {
        LocalDate fecha = fechaStr != null ? LocalDate.parse(fechaStr) : LocalDate.now();

        CajaDiaria caja = cajaRepo.findByFechaAndProfesionalId(fecha, profesionalId).orElse(null);

        List<Turno> turnos = turnoRepo.findCajaDiariaItems(profesionalId, fecha);

        Map<Long, PagoTurno> pagosMap = pagoRepo.findByProfesionalAndFecha(profesionalId, fecha)
            .stream().collect(Collectors.toMap(p -> p.getTurno().getId(), p -> p));

        List<CajaItemDto> items = turnos.stream().map(t -> {
            PagoTurno pago = pagosMap.get(t.getId());
            BigDecimal efectivo = BigDecimal.ZERO;
            BigDecimal electronico = BigDecimal.ZERO;
            BigDecimal coseguro = BigDecimal.ZERO;
            String mp1 = null, mp2 = null;
            Long pagoId = null;
            Boolean esDeposito = false, recupero = false;
            BigDecimal valorDep = null;

            if (pago != null) {
                pagoId = pago.getId();
                mp1 = pago.getMetodoPago1() != null ? pago.getMetodoPago1().name() : null;
                mp2 = pago.getMetodoPago2() != null ? pago.getMetodoPago2().name() : null;
                coseguro = pago.getCoseguro() != null ? pago.getCoseguro() : BigDecimal.ZERO;
                esDeposito = Boolean.TRUE.equals(pago.getEsDeposito());
                recupero = Boolean.TRUE.equals(pago.getRecuperoDeposito());
                valorDep = pago.getValorDeposito();

                if (MetodoPago.EFECTIVO.name().equals(mp1)) {
                    efectivo = efectivo.add(pago.getMonto1() != null ? pago.getMonto1() : BigDecimal.ZERO);
                } else if (mp1 != null) {
                    electronico = electronico.add(pago.getMonto1() != null ? pago.getMonto1() : BigDecimal.ZERO);
                }
                if (MetodoPago.EFECTIVO.name().equals(mp2)) {
                    efectivo = efectivo.add(pago.getMonto2() != null ? pago.getMonto2() : BigDecimal.ZERO);
                } else if (mp2 != null) {
                    electronico = electronico.add(pago.getMonto2() != null ? pago.getMonto2() : BigDecimal.ZERO);
                }
            }

            String hora = t.getHora() != null ? t.getHora().format(DateTimeFormatter.ofPattern("HH:mm")) : "";
            String pacNombre = t.getPaciente() != null ? t.getPaciente().getNombre() : "";
            String osSombre = t.getObraSocial() != null ? t.getObraSocial().getNombre() : "Particular";
            String estNombre = t.getEstudio() != null ? t.getEstudio().getNombre() : "";

            return new CajaItemDto(t.getId(), hora, pacNombre, osSombre, estNombre,
                efectivo, electronico, coseguro, esDeposito, recupero, valorDep, mp1, mp2, pagoId,
                pago != null && Boolean.TRUE.equals(pago.getEsParticular()));
        }).collect(Collectors.toList());

        BigDecimal totalEfectivo = items.stream().map(i -> i.getEfectivo() != null ? i.getEfectivo() : BigDecimal.ZERO).reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal totalElectronico = items.stream().map(i -> i.getElectronico() != null ? i.getElectronico() : BigDecimal.ZERO).reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal totalCoseguro = items.stream().map(i -> i.getCoseguro() != null ? i.getCoseguro() : BigDecimal.ZERO).reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal totalDepositos = items.stream()
            .filter(i -> Boolean.TRUE.equals(i.getEsDeposito()) && !Boolean.TRUE.equals(i.getRecuperoDeposito()))
            .map(i -> i.getValorDeposito() != null ? i.getValorDeposito() : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal totalRecuperos = items.stream()
            .filter(i -> Boolean.TRUE.equals(i.getRecuperoDeposito()))
            .map(i -> i.getValorDeposito() != null ? i.getValorDeposito() : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal totalGeneral = totalEfectivo.add(totalElectronico).add(totalCoseguro);

        Profesional prof = profRepo.findById(profesionalId)
            .orElseThrow(() -> new RuntimeException("Profesional no encontrado"));

        return new CajaResumenDto(
            caja != null ? caja.getId() : null,
            caja != null ? caja.getEstado().name() : "ABIERTA",
            fecha.toString(),
            profesionalId,
            prof.getNombre(),
            caja != null ? caja.getFirmaTexto() : null,
            caja != null ? caja.getObservaciones() : null,
            items,
            totalEfectivo, totalElectronico, totalCoseguro, totalDepositos, totalRecuperos, totalGeneral
        );
    }

    public CajaDiaria abrirCaja(Long profesionalId, LocalDate fecha) {
        return cajaRepo.findByFechaAndProfesionalId(fecha, profesionalId).orElseGet(() -> {
            Profesional prof = profRepo.findById(profesionalId)
                .orElseThrow(() -> new RuntimeException("Profesional no encontrado"));
            CajaDiaria caja = new CajaDiaria();
            caja.setFecha(fecha);
            caja.setProfesional(prof);
            caja.setEstado(EstadoCaja.ABIERTA);
            return cajaRepo.save(caja);
        });
    }

    public CajaDiaria cerrarCaja(Long cajaId, String firmaTexto, String observaciones) {
        CajaDiaria caja = cajaRepo.findById(cajaId)
            .orElseThrow(() -> new RuntimeException("Caja no encontrada"));
        caja.setEstado(EstadoCaja.CERRADA);
        caja.setCerradaAt(LocalDateTime.now());
        if (firmaTexto != null) caja.setFirmaTexto(firmaTexto);
        if (observaciones != null) caja.setObservaciones(observaciones);
        return cajaRepo.save(caja);
    }
}
