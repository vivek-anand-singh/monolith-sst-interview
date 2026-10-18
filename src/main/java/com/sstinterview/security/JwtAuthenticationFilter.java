package com.sstinterview.security;

import com.sstinterview.service.JwtService;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletRequestWrapper;
import jakarta.servlet.http.HttpServletResponse;
import org.jspecify.annotations.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.Enumeration;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * Validates the bearer JWT once per request and exposes the caller as {@code X-User-Id} /
 * {@code X-User-Role} request headers, which is what controllers read. Any client-supplied
 * values for those headers are discarded, so they can only ever come from a verified token.
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter
{
    private static final String USER_ID_HEADER = "X-User-Id";
    private static final String USER_ROLE_HEADER = "X-User-Role";
    private static final String BEARER_PREFIX = "Bearer ";

    private final JwtService jwtService;

    public JwtAuthenticationFilter(JwtService jwtService)
    {
        this.jwtService = jwtService;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request)
    {
        String path = request.getRequestURI();
        return "OPTIONS".equals(request.getMethod())
                || path.equals("/auth/google")
                || path.startsWith("/swagger-ui")
                || path.startsWith("/v3/api-docs")
                || path.equals("/actuator/health");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, @NonNull HttpServletResponse response, @NonNull FilterChain filterChain)
            throws ServletException, IOException
    {
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith(BEARER_PREFIX))
        {
            sendUnauthorized(response);
            return;
        }

        String userId;
        String role;
        try
        {
            Claims claims = jwtService.parseToken(authHeader.substring(BEARER_PREFIX.length()));
            userId = claims.getSubject();
            role = claims.get("role", String.class);
        }
        catch (JwtException | IllegalArgumentException e)
        {
            sendUnauthorized(response);
            return;
        }

        if (userId == null || userId.isBlank() || role == null || role.isBlank())
        {
            sendUnauthorized(response);
            return;
        }

        // Outside the try block: only token problems are 401s, not whatever the controller throws.
        filterChain.doFilter(new AuthenticatedRequest(request, userId, role), response);
    }

    private void sendUnauthorized(HttpServletResponse response) throws IOException
    {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json");
        response.getWriter().write("{\"error\": \"Unauthorized\"}");
    }

    private static class AuthenticatedRequest extends HttpServletRequestWrapper
    {
        private final String userId;
        private final String role;

        AuthenticatedRequest(HttpServletRequest request, String userId, String role)
        {
            super(request);
            this.userId = userId;
            this.role = role;
        }

        @Override
        public String getHeader(String name)
        {
            if (USER_ID_HEADER.equalsIgnoreCase(name)) return userId;
            if (USER_ROLE_HEADER.equalsIgnoreCase(name)) return role;
            return super.getHeader(name);
        }

        @Override
        public Enumeration<String> getHeaders(String name)
        {
            if (USER_ID_HEADER.equalsIgnoreCase(name)) return Collections.enumeration(List.of(userId));
            if (USER_ROLE_HEADER.equalsIgnoreCase(name)) return Collections.enumeration(List.of(role));
            return super.getHeaders(name);
        }

        @Override
        public Enumeration<String> getHeaderNames()
        {
            Set<String> names = new LinkedHashSet<>();
            for (String name : Collections.list(super.getHeaderNames()))
            {
                if (!USER_ID_HEADER.equalsIgnoreCase(name) && !USER_ROLE_HEADER.equalsIgnoreCase(name)) names.add(name);
            }
            names.add(USER_ID_HEADER);
            names.add(USER_ROLE_HEADER);
            return Collections.enumeration(names);
        }
    }
}
