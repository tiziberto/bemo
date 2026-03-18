package com.bemo.backend.controller;

import com.bemo.backend.dto.UserRegistrationDto;
import com.bemo.backend.model.User;
import com.bemo.backend.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody UserRegistrationDto registrationDto) {
        User user = new User();
        user.setUsername(registrationDto.getUsername());
        user.setPassword(registrationDto.getPassword());
        user.setEmail(registrationDto.getEmail());

        userService.createUser(user, registrationDto.getRoles());
        return ResponseEntity.ok("Usuario registrado exitosamente");
    }
}