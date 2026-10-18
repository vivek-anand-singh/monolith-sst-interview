package com.sstinterview.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.sstinterview.dto.request.AuthRequestDto;
import com.sstinterview.dto.response.AuthResponseDto;
import com.sstinterview.exception.GoogleTokenVerificationException;
import com.sstinterview.exception.InvalidGoogleTokenException;
import com.sstinterview.models.AuthType;
import com.sstinterview.models.User;
import com.sstinterview.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Service
public class GoogleOAuthProviderService implements AuthProviderService
{
    private final UserRepository userRepository;
    private final JwtService jwtService;
    private final GoogleIdTokenVerifier verifier;

    public GoogleOAuthProviderService(UserRepository userRepository, JwtService jwtService, @Value("${google.client-id}") String googleClientId)
    {
        this.userRepository = userRepository;
        this.jwtService = jwtService;
        this.verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(), new GsonFactory()).setAudience(Collections.singletonList(googleClientId)).build();
    }

    @Override
    public AuthResponseDto getJWT(AuthRequestDto authRequestDto)
    {
        GoogleIdToken.Payload payload = verifyToken(authRequestDto.getIdToken());

        String googleSub = payload.getSubject();
        String email = payload.getEmail();
        String name = (String) payload.get("name");

        User user = userRepository.findByAuthProviderId(googleSub).orElseGet(() -> createUser(googleSub, email, name));

        AuthResponseDto response = new AuthResponseDto();
        response.setAccessToken(jwtService.generateToken(user));
        response.setUserId(user.getId().toString());
        response.setName(user.getName());
        response.setEmail(user.getEmail());
        return response;
    }

    private GoogleIdToken.Payload verifyToken(String idToken)
    {
        try
        {
            GoogleIdToken googleIdToken = verifier.verify(idToken);
            if (googleIdToken == null)
            {
                throw new InvalidGoogleTokenException("Invalid Google ID token");
            }
            return googleIdToken.getPayload();
        }
        catch (InvalidGoogleTokenException e)
        {
            throw e;
        }
        catch (Exception e)
        {
            throw new GoogleTokenVerificationException("Failed to verify Google ID token", e);
        }
    }

    private User createUser(String googleSub, String email, String name)
    {
        User user = new User();
        user.setEmail(email);
        user.setName(name);
        user.setAuthType(AuthType.GOOGLE);
        user.setAuthProviderId(googleSub);
        return userRepository.save(user);
    }
}
