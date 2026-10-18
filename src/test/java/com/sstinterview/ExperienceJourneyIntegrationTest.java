package com.sstinterview;

import com.sstinterview.models.AuthType;
import com.sstinterview.models.Company;
import com.sstinterview.models.Role;
import com.sstinterview.models.RoundType;
import com.sstinterview.models.User;
import com.sstinterview.repository.CompanyRepository;
import com.sstinterview.repository.RoundTypeRepository;
import com.sstinterview.repository.UserRepository;
import com.sstinterview.service.JwtService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.postgresql.PostgreSQLContainer;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Runs the real application against a real PostgreSQL (Flyway migrations included) and walks the main
 * user journey: a user submits an experience, it stays hidden while pending, an admin approves it, and it
 * then shows up in the public listing.
 */
@Testcontainers
@SpringBootTest(properties = {
        "jwt.secret=integration-test-secret-that-is-at-least-32-bytes",
        "google.client-id=integration-test-client-id"
})
@AutoConfigureMockMvc
class ExperienceJourneyIntegrationTest
{
    @Container
    @ServiceConnection
    static PostgreSQLContainer postgres = new PostgreSQLContainer("postgres:16");

    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;
    @Autowired private JwtService jwtService;
    @Autowired private UserRepository userRepository;
    @Autowired private CompanyRepository companyRepository;
    @Autowired private RoundTypeRepository roundTypeRepository;
    @Autowired private JdbcTemplate jdbcTemplate;

    private User createUser(Role role)
    {
        User user = new User();
        user.setEmail(UUID.randomUUID() + "@example.com");
        user.setName(role.name().toLowerCase() + " tester");
        user.setAuthType(AuthType.GOOGLE);
        user.setAuthProviderId(UUID.randomUUID().toString());
        user.setRole(role);
        return userRepository.save(user);
    }

    private String bearer(User user)
    {
        return "Bearer " + jwtService.generateToken(user);
    }

    @Test
    void allFlywayMigrationsApplyToARealDatabase()
    {
        Integer applied = jdbcTemplate.queryForObject(
                "SELECT count(*) FROM flyway_schema_history WHERE success", Integer.class);

        assertEquals(8, applied);
    }

    @Test
    void healthEndpointIsPublic() throws Exception
    {
        mockMvc.perform(get("/actuator/health")).andExpect(status().isOk());
    }

    @Test
    void protectedEndpointRejectsRequestsWithoutAToken() throws Exception
    {
        mockMvc.perform(get("/experiences")).andExpect(status().isUnauthorized());
    }

    @Test
    void submittedExperienceIsHiddenUntilAnAdminApprovesIt() throws Exception
    {
        User author = createUser(Role.USER);
        User admin = createUser(Role.ADMIN);

        Company company = new Company();
        company.setName("Journey Corp " + UUID.randomUUID());
        company = companyRepository.save(company);
        RoundType roundType = new RoundType();
        roundType.setName("Technical");
        roundType = roundTypeRepository.save(roundType);

        String body = objectMapper.writeValueAsString(java.util.Map.of(
                "companyId", company.getId(),
                "roundTypeId", roundType.getId(),
                "roundNumber", 1,
                "content", "Two coding rounds and a system design round.",
                "questions", java.util.List.of("Design a rate limiter")));

        MvcResult created = mockMvc.perform(post("/experiences")
                        .header("Authorization", bearer(author))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated())
                .andReturn();
        JsonNode createdJson = objectMapper.readTree(created.getResponse().getContentAsString());
        String experienceId = createdJson.get("id").asString();
        assertEquals("PENDING", createdJson.get("status").asString());

        assertPublicListingSize(author, company.getId(), 0);

        mockMvc.perform(post("/admin/experiences/" + experienceId + "/review")
                        .header("Authorization", bearer(author))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\":\"APPROVED\"}"))
                .andExpect(status().isForbidden());

        mockMvc.perform(post("/admin/experiences/" + experienceId + "/review")
                        .header("Authorization", bearer(admin))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\":\"APPROVED\"}"))
                .andExpect(status().isOk());

        assertPublicListingSize(author, company.getId(), 1);
    }

    private void assertPublicListingSize(User caller, UUID companyId, int expected) throws Exception
    {
        MvcResult listing = mockMvc.perform(get("/experiences")
                        .param("companyId", companyId.toString())
                        .header("Authorization", bearer(caller)))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode content = objectMapper.readTree(listing.getResponse().getContentAsString()).get("content");
        assertEquals(expected, content.size());
    }
}
