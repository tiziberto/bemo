package com.bemo.backend.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/adjuntos")
@RequiredArgsConstructor
public class FileUploadController {

    @Value("${app.upload.dir:/app/uploads}")
    private String uploadDir;

    @PostMapping("/upload")
    @PreAuthorize("hasAnyRole('ADMIN', 'RECEPCION', 'DOCTOR')")
    public ResponseEntity<?> upload(@RequestParam("file") MultipartFile file,
                                    @RequestParam(value = "tipo", defaultValue = "doc") String tipo) {
        try {
            String ext = "";
            String orig = file.getOriginalFilename();
            if (orig != null && orig.contains(".")) {
                ext = orig.substring(orig.lastIndexOf('.'));
            }
            String filename = tipo + "_" + UUID.randomUUID() + ext;
            Path dir = Paths.get(uploadDir);
            Files.createDirectories(dir);
            Files.write(dir.resolve(filename), file.getBytes());
            String url = "/uploads/" + filename;
            return ResponseEntity.ok(Map.of("url", url, "filename", filename));
        } catch (IOException e) {
            return ResponseEntity.internalServerError().body(Map.of("error", "Error al guardar archivo: " + e.getMessage()));
        }
    }
}
