package com.sstinterview.security;

import com.sstinterview.models.Role;
import com.sstinterview.models.User;
import com.sstinterview.service.JwtService;
import jakarta.servlet.http.HttpServletRequest;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class JwtAuthenticationFilterTest
{
    private final JwtService jwtService = new JwtService("unit-test-secret-that-is-at-least-32-bytes-long");
    private final JwtAuthenticationFilter filter = new JwtAuthenticationFilter(jwtService);

    private String tokenFor(UUID id, Role role)
    {
        User user = new User();
        user.setId(id);
        user.setRole(role);
        return jwtService.generateToken(user);
    }

    private MockHttpServletRequest request(String path)
    {
        return new MockHttpServletRequest("GET", path);
    }

    @Test
    void missingTokenIsUnauthorized() throws Exception
    {
        MockHttpServletResponse response = new MockHttpServletResponse();
        MockFilterChain chain = new MockFilterChain();

        filter.doFilter(request("/experiences"), response, chain);

        assertEquals(401, response.getStatus());
        assertNull(chain.getRequest());
    }

    @Test
    void invalidTokenIsUnauthorized() throws Exception
    {
        MockHttpServletRequest request = request("/experiences");
        request.addHeader("Authorization", "Bearer not-a-jwt");
        MockHttpServletResponse response = new MockHttpServletResponse();
        MockFilterChain chain = new MockFilterChain();

        filter.doFilter(request, response, chain);

        assertEquals(401, response.getStatus());
        assertNull(chain.getRequest());
    }

    @Test
    void validTokenSetsIdentityHeadersFromTheToken() throws Exception
    {
        UUID userId = UUID.randomUUID();
        MockHttpServletRequest request = request("/experiences");
        request.addHeader("Authorization", "Bearer " + tokenFor(userId, Role.USER));
        MockHttpServletResponse response = new MockHttpServletResponse();
        MockFilterChain chain = new MockFilterChain();

        filter.doFilter(request, response, chain);

        HttpServletRequest forwarded = (HttpServletRequest) chain.getRequest();
        assertNotNull(forwarded);
        assertEquals(userId.toString(), forwarded.getHeader("X-User-Id"));
        assertEquals("USER", forwarded.getHeader("X-User-Role"));
    }

    @Test
    void clientSuppliedIdentityHeadersAreDiscarded() throws Exception
    {
        UUID realUserId = UUID.randomUUID();
        MockHttpServletRequest request = request("/experiences");
        request.addHeader("Authorization", "Bearer " + tokenFor(realUserId, Role.USER));
        request.addHeader("X-User-Id", UUID.randomUUID().toString());
        request.addHeader("X-User-Role", "SUPERADMIN");
        MockHttpServletResponse response = new MockHttpServletResponse();
        MockFilterChain chain = new MockFilterChain();

        filter.doFilter(request, response, chain);

        HttpServletRequest forwarded = (HttpServletRequest) chain.getRequest();
        assertEquals(realUserId.toString(), forwarded.getHeader("X-User-Id"));
        assertEquals("USER", forwarded.getHeader("X-User-Role"));
    }

    @Test
    void healthEndpointNeedsNoToken() throws Exception
    {
        MockHttpServletResponse response = new MockHttpServletResponse();
        MockFilterChain chain = new MockFilterChain();

        filter.doFilter(request("/actuator/health"), response, chain);

        assertEquals(200, response.getStatus());
        assertNotNull(chain.getRequest());
    }
}
