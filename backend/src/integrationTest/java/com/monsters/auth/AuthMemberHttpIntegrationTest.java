package com.monsters.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.monsters.job.AsyncJob;
import com.monsters.job.AsyncJobDispatcher;
import com.monsters.notification.email.EmailDeliveryPort;
import com.monsters.notification.email.EmailDeliveryRequest;
import com.monsters.exception.member.MemberStateConflictException;
import com.monsters.exception.member.VersionConflictException;
import com.monsters.security.common.GoogleIdTokenVerifier;
import com.monsters.security.common.GoogleUserInfo;
import com.monsters.service.member.MemberLifecycleService;
import com.monsters.support.AuthMemberControlledDependencies;
import com.monsters.support.AuthMemberControlledDependencies.RecordingAsyncJobDispatcher;
import com.monsters.support.AuthMemberControlledDependencies.RecordingEmailDelivery;
import java.time.Clock;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.system.CapturedOutput;
import org.springframework.boot.test.system.OutputCaptureExtension;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
@SpringBootTest
@AutoConfigureMockMvc
@Import(AuthMemberControlledDependencies.class)
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_CLASS)
@ExtendWith(OutputCaptureExtension.class)
class AuthMemberHttpIntegrationTest {

    @Container
    static final MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.4")
            .withDatabaseName("monsters_test")
            .withUsername("monsters_test")
            .withPassword("synthetic-password");

    @DynamicPropertySource
    static void configureMySql(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", mysql::getJdbcUrl);
        registry.add("spring.datasource.username", mysql::getUsername);
        registry.add("spring.datasource.password", mysql::getPassword);
        registry.add("spring.jpa.hibernate.ddl-auto", () -> "validate");
        registry.add("app.security.jwt.secret", () -> "synthetic-jwt-secret-for-integration-tests");
        registry.add("app.security.google.client-ids", () -> "synthetic-google-client");
    }

    private final MockMvc mockMvc;
    private final ObjectMapper objectMapper;
    private final Clock clock;
    private final GoogleIdTokenVerifier googleIdTokenVerifier;
    private final EmailDeliveryPort emailDeliveryPort;
    private final AsyncJobDispatcher asyncJobDispatcher;
    private final JdbcTemplate jdbcTemplate;
    private final MemberLifecycleService memberLifecycleService;

    @Autowired
    AuthMemberHttpIntegrationTest(
            MockMvc mockMvc,
            ObjectMapper objectMapper,
            Clock clock,
            GoogleIdTokenVerifier googleIdTokenVerifier,
            EmailDeliveryPort emailDeliveryPort,
            AsyncJobDispatcher asyncJobDispatcher,
            JdbcTemplate jdbcTemplate,
            MemberLifecycleService memberLifecycleService
    ) {
        this.mockMvc = mockMvc;
        this.objectMapper = objectMapper;
        this.clock = clock;
        this.googleIdTokenVerifier = googleIdTokenVerifier;
        this.emailDeliveryPort = emailDeliveryPort;
        this.asyncJobDispatcher = asyncJobDispatcher;
        this.jdbcTemplate = jdbcTemplate;
        this.memberLifecycleService = memberLifecycleService;
    }

    @Test
    void memberEndpointShouldUseRealSecurityFilter() throws Exception {
        mockMvc.perform(get("/api/users/me"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.code").value("AUTHENTICATION_REQUIRED"))
                .andExpect(jsonPath("$.fieldErrors").isMap())
                .andExpect(jsonPath("$.requestId").isString());
    }

    @Test
    void authRequestShouldReachMySqlAndReturnPublicErrorEnvelope(CapturedOutput output) throws Exception {
        String syntheticEmail = "missing.member@example.test";
        String syntheticPassword = "synthetic-password";

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", syntheticPassword
                        ))))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.code").value("AUTH_INVALID_CREDENTIALS"))
                .andExpect(jsonPath("$.fieldErrors").isMap())
                .andExpect(jsonPath("$.requestId").isString());

        assertThat(output.getAll()).doesNotContain(syntheticEmail, syntheticPassword);
    }

    @Test
    void clockAndGoogleIdentityShouldBeControllable(CapturedOutput output) throws Exception {
        String syntheticGoogleToken = "synthetic-google-token";
        String syntheticGoogleEmail = "google.member@example.test";

        assertThat(clock.instant()).isEqualTo(AuthMemberControlledDependencies.TEST_NOW);
        when(googleIdTokenVerifier.verify(syntheticGoogleToken))
                .thenReturn(new GoogleUserInfo(
                        "synthetic-google-subject",
                        syntheticGoogleEmail,
                        "Synthetic Member",
                        null
                ));

        mockMvc.perform(post("/api/auth/google-login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "idToken", syntheticGoogleToken
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        assertThat(output.getAll()).doesNotContain(syntheticGoogleToken, syntheticGoogleEmail);
    }

    @Test
    void emailAndAsyncPortsShouldBeReplaceableWithoutExternalSideEffects() {
        EmailDeliveryRequest emailRequest = new EmailDeliveryRequest(
                "synthetic.member@example.test",
                "verify-email",
                Map.of("verificationReference", "synthetic-reference")
        );
        AsyncJob asyncJob = new AsyncJob("email-delivery", "synthetic-request-id");

        emailDeliveryPort.deliver(emailRequest);
        asyncJobDispatcher.dispatch(asyncJob);

        assertThat(emailDeliveryPort)
                .isInstanceOf(RecordingEmailDelivery.class);
        assertThat(((RecordingEmailDelivery) emailDeliveryPort).requests())
                .containsExactly(emailRequest);
        assertThat(asyncJobDispatcher)
                .isInstanceOf(RecordingAsyncJobDispatcher.class);
        assertThat(((RecordingAsyncJobDispatcher) asyncJobDispatcher).jobs())
                .containsExactly(asyncJob);
    }

    @Test
    void pendingEligibilityMemberShouldReceiveOnlyAContinuationCredential() throws Exception {
        String syntheticEmail = "pending.eligibility@example.test";
        String syntheticPassword = "synthetic-password";

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "pending_eligibility",
                                "email", syntheticEmail,
                                "password", syntheticPassword,
                                "userName", "Synthetic Pending Member"
                        ))))
                .andExpect(status().isCreated());

        jdbcTemplate.update(
                "UPDATE users SET member_state = 'PENDING_ELIGIBILITY' WHERE email = ?",
                syntheticEmail
        );

        String response = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", syntheticPassword
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.code").value("AUTH_CONTINUATION_REQUIRED"))
                .andExpect(jsonPath("$.data.nextAction").value("COMPLETE_ELIGIBILITY"))
                .andExpect(jsonPath("$.data.continuationCredential").isNotEmpty())
                .andExpect(jsonPath("$.data.expiresIn").value(600))
                .andExpect(jsonPath("$.data.accessToken").doesNotExist())
                .andExpect(jsonPath("$.data.refreshToken").doesNotExist())
                .andReturn()
                .getResponse()
                .getContentAsString();

        String continuationCredential = objectMapper.readTree(response)
                .path("data")
                .path("continuationCredential")
                .asText();

        mockMvc.perform(get("/api/users/me")
                        .header("Authorization", "Bearer " + continuationCredential))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("AUTHENTICATION_REQUIRED"));
    }

    @Test
    void completingEligibilityShouldCommitStateVersionCredentialRevocationAuditAndOutboxTogether()
            throws Exception {
        String syntheticEmail = "eligibility.transition@example.test";

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "eligibility_transition",
                                "email", syntheticEmail,
                                "password", "synthetic-password",
                                "userName", "Synthetic Eligibility Member"
                        ))))
                .andExpect(status().isCreated());

        jdbcTemplate.update(
                "UPDATE users SET member_state = 'PENDING_ELIGIBILITY' WHERE email = ?",
                syntheticEmail
        );

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", "synthetic-password"
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("AUTH_CONTINUATION_REQUIRED"));

        Map<String, Object> member = jdbcTemplate.queryForMap(
                "SELECT id, public_id, version FROM users WHERE email = ?",
                syntheticEmail
        );
        long memberId = ((Number) member.get("id")).longValue();
        long expectedVersion = ((Number) member.get("version")).longValue();

        memberLifecycleService.completeEligibility(memberId, expectedVersion);

        assertThat(jdbcTemplate.queryForMap(
                "SELECT member_state, version FROM users WHERE id = ?",
                memberId
        )).containsEntry("member_state", "ACTIVE")
                .containsEntry("version", expectedVersion + 1);
        assertThat(jdbcTemplate.queryForObject(
                """
                SELECT COUNT(*)
                FROM member_continuation_credentials
                WHERE user_id = ? AND revoked_at IS NOT NULL
                """,
                Integer.class,
                memberId
        )).isEqualTo(1);
        assertThat(jdbcTemplate.queryForMap(
                """
                SELECT from_state, to_state, reason_code, actor_type
                FROM member_state_audits
                WHERE user_id = ?
                """,
                memberId
        )).containsEntry("from_state", "PENDING_ELIGIBILITY")
                .containsEntry("to_state", "ACTIVE")
                .containsEntry("reason_code", "ELIGIBILITY_COMPLETED")
                .containsEntry("actor_type", "SYSTEM");
        assertThat(jdbcTemplate.queryForMap(
                """
                SELECT aggregate_id, event_type, status
                FROM outbox_events
                WHERE aggregate_id = ?
                """,
                member.get("public_id")
        )).containsEntry("aggregate_id", member.get("public_id"))
                .containsEntry("event_type", "MEMBER_STATE_CHANGED")
                .containsEntry("status", "PENDING");
    }

    @Test
    void completingEligibilityFromAnIllegalStateShouldReturnConflictWithoutPartialWrites()
            throws Exception {
        String syntheticEmail = "illegal.transition@example.test";

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "illegal_transition",
                                "email", syntheticEmail,
                                "password", "synthetic-password",
                                "userName", "Synthetic Active Member"
                        ))))
                .andExpect(status().isCreated());

        Map<String, Object> member = jdbcTemplate.queryForMap(
                "SELECT id, public_id, version FROM users WHERE email = ?",
                syntheticEmail
        );
        long memberId = ((Number) member.get("id")).longValue();
        long expectedVersion = ((Number) member.get("version")).longValue();

        assertThatThrownBy(() -> memberLifecycleService.completeEligibility(memberId, expectedVersion))
                .isInstanceOfSatisfying(MemberStateConflictException.class, exception -> {
                    assertThat(exception.getStatus()).isEqualTo(HttpStatus.CONFLICT);
                    assertThat(exception.getCode()).isEqualTo("MEMBER_STATE_CONFLICT");
                });

        assertThat(jdbcTemplate.queryForMap(
                "SELECT member_state, version FROM users WHERE id = ?",
                memberId
        )).containsEntry("member_state", "ACTIVE")
                .containsEntry("version", expectedVersion);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM member_state_audits WHERE user_id = ?",
                Integer.class,
                memberId
        )).isZero();
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM outbox_events WHERE aggregate_id = ?",
                Integer.class,
                member.get("public_id")
        )).isZero();
    }

    @Test
    void completingEligibilityWithAStaleVersionShouldReturnConflictWithoutRevokingCredential()
            throws Exception {
        String syntheticEmail = "stale.version@example.test";

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "stale_version",
                                "email", syntheticEmail,
                                "password", "synthetic-password",
                                "userName", "Synthetic Stale Member"
                        ))))
                .andExpect(status().isCreated());

        jdbcTemplate.update(
                "UPDATE users SET member_state = 'PENDING_ELIGIBILITY' WHERE email = ?",
                syntheticEmail
        );
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", "synthetic-password"
                        ))))
                .andExpect(status().isOk());

        Map<String, Object> member = jdbcTemplate.queryForMap(
                "SELECT id, public_id, version FROM users WHERE email = ?",
                syntheticEmail
        );
        long memberId = ((Number) member.get("id")).longValue();
        long currentVersion = ((Number) member.get("version")).longValue();

        assertThatThrownBy(() -> memberLifecycleService.completeEligibility(
                memberId,
                currentVersion + 1
        )).isInstanceOfSatisfying(VersionConflictException.class, exception -> {
            assertThat(exception.getStatus()).isEqualTo(HttpStatus.CONFLICT);
            assertThat(exception.getCode()).isEqualTo("VERSION_CONFLICT");
        });

        assertThat(jdbcTemplate.queryForMap(
                "SELECT member_state, version FROM users WHERE id = ?",
                memberId
        )).containsEntry("member_state", "PENDING_ELIGIBILITY")
                .containsEntry("version", currentVersion);
        assertThat(jdbcTemplate.queryForObject(
                """
                SELECT COUNT(*)
                FROM member_continuation_credentials
                WHERE user_id = ? AND revoked_at IS NULL
                """,
                Integer.class,
                memberId
        )).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM member_state_audits WHERE user_id = ?",
                Integer.class,
                memberId
        )).isZero();
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM outbox_events WHERE aggregate_id = ?",
                Integer.class,
                member.get("public_id")
        )).isZero();
    }

}
