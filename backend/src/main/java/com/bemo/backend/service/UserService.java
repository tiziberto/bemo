package com.bemo.backend.service;

import com.bemo.backend.model.Role;
import com.bemo.backend.model.User;
import com.bemo.backend.repository.RoleRepository;
import com.bemo.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.util.HashSet;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

    public User createUser(User user, Set<String> roleNames) {
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        
        Set<Role> roles = new HashSet<>();
        if (roleNames != null) {
            roleNames.forEach(name -> {
                Role role = roleRepository.findByName(name)
                        .orElseThrow(() -> new RuntimeException("Error: Rol " + name + " no encontrado."));
                roles.add(role);
            });
        }
        
        user.setRoles(roles);
        return userRepository.save(user);
    }
}