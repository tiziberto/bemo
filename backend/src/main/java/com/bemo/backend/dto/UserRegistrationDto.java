package com.bemo.backend.dto;

import lombok.Data;
import java.util.Set;

/**
 * Objeto de Transferencia de Datos (DTO) para el registro de usuarios.
 * Se utiliza para mapear el JSON de entrada en la petición de registro.
 */
@Data
public class UserRegistrationDto {

    private String username;
    private String password;
    private String email;
    
    // Lista de nombres de roles (ej: ["ADMIN", "USER"])
    private Set<String> roles;

}