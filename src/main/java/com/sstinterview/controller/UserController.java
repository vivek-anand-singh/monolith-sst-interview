package com.sstinterview.controller;

import com.sstinterview.dto.request.AuthRequestDto;
import com.sstinterview.dto.response.AuthResponseDto;
import com.sstinterview.service.AuthProviderService;
import com.sstinterview.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/auth")
@Tag(name = "Authentication", description = "Google OAuth login and JWT issuance")
public class UserController
{
    private final AuthProviderService googleAuthProviderService;
    private final UserService userService;

    public UserController(AuthProviderService googleAuthProviderService, UserService userService)
    {
        this.googleAuthProviderService = googleAuthProviderService;
        this.userService = userService;
    }

    @Operation(summary = "Login with Google", description = "Verifies a Google ID token and returns a JWT")
    @PostMapping("/google")
    public ResponseEntity<AuthResponseDto> googleLogin(@Valid @RequestBody AuthRequestDto authRequestDto)
    {
        return ResponseEntity.ok(googleAuthProviderService.getJWT(authRequestDto));
    }

    @Operation(summary = "Get current user", description = "Returns name and email of the authenticated user")
    @GetMapping("/me")
    public ResponseEntity<AuthResponseDto> me(@RequestHeader("X-User-Id") String userId)
    {
        return ResponseEntity.ok(userService.getProfile(UUID.fromString(userId)));
    }
}
