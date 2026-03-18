package com.bemo.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // 1. Deshabilitar CSRF (Crucial para POST)
            .csrf(AbstractHttpConfigurer::disable)
            
            // 2. Deshabilitar CORS para pruebas
            .cors(AbstractHttpConfigurer::disable)
            
            // 3. Hacer que la API sea apátrida (evita el JSESSIONID)
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            
            // 4. Autorizar el registro sin condiciones
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/users/**").permitAll() 
                .anyRequest().authenticated()
            );

        return http.build();
    }
}