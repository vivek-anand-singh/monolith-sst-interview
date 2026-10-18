package com.sstinterview.service;

import com.sstinterview.models.Role;
import com.sstinterview.models.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class JwtServiceTest
{
    private static final String SECRET = "unit-test-secret-that-is-at-least-32-bytes-long";

    private final JwtService jwtService = new JwtService(SECRET);

    private User userWithRole(Role role)
    {
        User user = new User();
        user.setId(UUID.randomUUID());
        user.setRole(role);
        return user;
    }

    @Test
    void tokenCarriesUserIdAndRole()
    {
        User user = userWithRole(Role.ADMIN);

        Claims claims = jwtService.parseToken(jwtService.generateToken(user));

        assertEquals(user.getId().toString(), claims.getSubject());
        assertEquals("ADMIN", claims.get("role", String.class));
    }

    @Test
    void tokenSignedWithAnotherSecretIsRejected()
    {
        String token = new JwtService("a-completely-different-secret-of-32-bytes!!")
                .generateToken(userWithRole(Role.USER));

        assertThrows(JwtException.class, () -> jwtService.parseToken(token));
    }

    @Test
    void tamperedTokenIsRejected()
    {
        String token = jwtService.generateToken(userWithRole(Role.USER));
        String tampered = token.substring(0, token.length() - 2) + "xx";

        assertThrows(JwtException.class, () -> jwtService.parseToken(tampered));
    }
}
