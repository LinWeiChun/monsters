package com.monsters.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.monsters.job.AsyncJob;
import com.monsters.job.AsyncJobDispatcher;
import com.monsters.notification.email.EmailDeliveryPort;
import com.monsters.notification.email.EmailDeliveryRequest;
import com.monsters.exception.member.MemberStateConflictException;
import com.monsters.exception.member.VersionConflictException;
import com.monsters.security.common.GoogleIdTokenVerifier;
import com.monsters.security.common.GoogleUserInfo;
import com.monsters.service.member.MemberLifecycleService;
import com.monsters.service.member.MemberEmailChangeOutboxWorker;
import com.monsters.service.auth.PasswordResetOutboxWorker;
import com.monsters.service.registration.EmailVerificationOutboxWorker;
import com.monsters.service.registration.UnverifiedMemberCleanupService;
import com.monsters.support.AuthMemberControlledDependencies;
import com.monsters.support.AuthMemberControlledDependencies.RecordingAsyncJobDispatcher;
import com.monsters.support.AuthMemberControlledDependencies.RecordingEmailDelivery;
import jakarta.servlet.http.Cookie;
import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Base64;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.AfterEach;
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
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
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
        registry.add(
                "app.security.session.refresh-derivation-key",
                () -> "synthetic-refresh-derivation-key-for-integration-tests"
        );
        registry.add(
                "app.security.web-session.trusted-origin-patterns",
                () -> "https://app.example.test"
        );
        registry.add("app.cors.allowed-origin-patterns", () -> "https://*.example.test");
        registry.add("app.security.google.client-ids", () -> "synthetic-google-client");
        registry.add("app.registration.documents.terms.version", () -> "terms-synthetic-v1");
        registry.add("app.registration.documents.terms.url", () -> "https://example.test/terms/v1");
        registry.add("app.registration.documents.privacy.version", () -> "privacy-synthetic-v1");
        registry.add("app.registration.documents.privacy.url", () -> "https://example.test/privacy/v1");
        registry.add(
                "app.registration.email-verification.public-url",
                () -> "https://example.test/verify-email"
        );
        registry.add(
                "app.registration.rate-limit.hash-key",
                () -> "synthetic-registration-rate-limit-key"
        );
        registry.add(
                "app.password-reset.public-url",
                () -> "https://example.test/reset-password"
        );
        registry.add(
                "app.member.email-change.public-url",
                () -> "https://example.test/change-email"
        );
        registry.add(
                "app.password-reset.rate-limit-hash-key",
                () -> "synthetic-password-reset-rate-limit-key"
        );
        registry.add("app.registration.eligibility.minor-notice-version", () -> "minor-v1");
        registry.add("app.registration.eligibility.minor-notice-url", () -> "https://example.test/minor-v1");
        registry.add("app.registration.eligibility.guardian-consent-version", () -> "guardian-v1");
        registry.add("app.registration.eligibility.guardian-consent-url", () -> "https://example.test/guardian-v1");
        registry.add("app.registration.eligibility.public-nickname-disclosure-version", () -> "nickname-v1");
        registry.add("app.registration.eligibility.public-nickname-disclosure-url", () -> "https://example.test/nickname-v1");
        registry.add("app.registration.eligibility.guardian-action-public-url", () -> "https://example.test/guardian-action");
    }

    private final MockMvc mockMvc;
    private final ObjectMapper objectMapper;
    private final Clock clock;
    private final GoogleIdTokenVerifier googleIdTokenVerifier;
    private final EmailDeliveryPort emailDeliveryPort;
    private final AsyncJobDispatcher asyncJobDispatcher;
    private final JdbcTemplate jdbcTemplate;
    private final MemberLifecycleService memberLifecycleService;
    private final EmailVerificationOutboxWorker emailVerificationOutboxWorker;
    private final PasswordResetOutboxWorker passwordResetOutboxWorker;
    private final MemberEmailChangeOutboxWorker memberEmailChangeOutboxWorker;
    private final UnverifiedMemberCleanupService unverifiedMemberCleanupService;

    @Autowired
    AuthMemberHttpIntegrationTest(
            MockMvc mockMvc,
            ObjectMapper objectMapper,
            Clock clock,
            GoogleIdTokenVerifier googleIdTokenVerifier,
            EmailDeliveryPort emailDeliveryPort,
            AsyncJobDispatcher asyncJobDispatcher,
            JdbcTemplate jdbcTemplate,
            MemberLifecycleService memberLifecycleService,
            EmailVerificationOutboxWorker emailVerificationOutboxWorker,
            PasswordResetOutboxWorker passwordResetOutboxWorker,
            MemberEmailChangeOutboxWorker memberEmailChangeOutboxWorker,
            UnverifiedMemberCleanupService unverifiedMemberCleanupService
    ) {
        this.mockMvc = mockMvc;
        this.objectMapper = objectMapper;
        this.clock = clock;
        this.googleIdTokenVerifier = googleIdTokenVerifier;
        this.emailDeliveryPort = emailDeliveryPort;
        this.asyncJobDispatcher = asyncJobDispatcher;
        this.jdbcTemplate = jdbcTemplate;
        this.memberLifecycleService = memberLifecycleService;
        this.emailVerificationOutboxWorker = emailVerificationOutboxWorker;
        this.passwordResetOutboxWorker = passwordResetOutboxWorker;
        this.memberEmailChangeOutboxWorker = memberEmailChangeOutboxWorker;
        this.unverifiedMemberCleanupService = unverifiedMemberCleanupService;
    }

    @AfterEach
    void isolateRegistrationDeliveryState() {
        ((RecordingEmailDelivery) emailDeliveryPort).reset();
        ((RecordingAsyncJobDispatcher) asyncJobDispatcher).reset();
        jdbcTemplate.update(
                """
                UPDATE outbox_events
                SET status = 'FAILED', attempts = 5
                WHERE event_type IN (
                    'EMAIL_VERIFICATION_REQUESTED',
                    'PASSWORD_RESET_REQUESTED',
                    'MEMBER_EMAIL_CHANGE_REQUESTED',
                    'MEMBER_EMAIL_CHANGED_OLD_NOTIFICATION',
                    'MEMBER_EMAIL_CHANGED_NEW_NOTIFICATION'
                )
                  AND status IN ('PENDING', 'PROCESSING')
                """
        );
        jdbcTemplate.update("DELETE FROM registration_rate_limit_buckets");
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
    void registrationPolicyShouldExposeConfiguredRequiredDocuments() throws Exception {
        mockMvc.perform(get("/api/v1/auth/registration-policy"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.code").value("REGISTRATION_POLICY_AVAILABLE"))
                .andExpect(jsonPath("$.data.termsVersion").value("terms-synthetic-v1"))
                .andExpect(jsonPath("$.data.termsUrl").value("https://example.test/terms/v1"))
                .andExpect(jsonPath("$.data.privacyVersion").value("privacy-synthetic-v1"))
                .andExpect(jsonPath("$.data.privacyUrl").value("https://example.test/privacy/v1"))
                .andExpect(jsonPath("$.fieldErrors").isMap())
                .andExpect(jsonPath("$.requestId").isString());
    }

    @Test
    void verifiedEmailLoginShouldCoexistWithTheLegacyAccountMigrationPath()
            throws Exception {
        String syntheticEmail = "first.last+tag@gmail.com";
        String syntheticPassword = "synthetic-password";

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "legacy_login_member",
                                "email", syntheticEmail,
                                "password", syntheticPassword,
                                "userName", "Synthetic Member"
                        ))))
                .andExpect(status().isCreated());

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", "FIRST.LAST+TAG@GMAIL.COM",
                                "password", syntheticPassword
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("AUTHENTICATED"))
                .andExpect(jsonPath("$.data.user.publicId").isString())
                .andExpect(jsonPath("$.data.user.email").value(syntheticEmail))
                .andExpect(jsonPath("$.data.user.account").doesNotExist())
                .andExpect(jsonPath("$.data.user.userId").doesNotExist());

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", "firstlast@gmail.com",
                                "password", syntheticPassword
                        ))))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("AUTH_INVALID_CREDENTIALS"));

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", "legacy_login_member",
                                "password", syntheticPassword
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("AUTHENTICATED"))
                .andExpect(jsonPath("$.data.user.account").value("legacy_login_member"));

        registerWithoutDelivery("pending.v1.login@example.test", syntheticPassword);
        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", "pending.v1.login@example.test",
                                "password", syntheticPassword
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("AUTH_CONTINUATION_REQUIRED"))
                .andExpect(jsonPath("$.data.nextAction").value("VERIFY_EMAIL"))
                .andExpect(jsonPath("$.data.accessToken").doesNotExist());
    }

    @Test
    void opaqueRefreshFamilyShouldRotateTolerateConcurrencyAndContainReuse()
            throws Exception {
        String syntheticEmail = "session.family@example.test";
        String syntheticPassword = "synthetic-password";

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "session_family_member",
                                "email", syntheticEmail,
                                "password", syntheticPassword,
                                "userName", "Session Family Member"
                        ))))
                .andExpect(status().isCreated());

        JsonNode firstLogin = responseData(mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", syntheticPassword
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("AUTHENTICATED"))
                .andReturn().getResponse().getContentAsString());

        String firstAccess = firstLogin.path("accessToken").asText();
        String firstRefresh = firstLogin.path("refreshToken").asText();
        JsonNode accessClaims = objectMapper.readTree(Base64.getUrlDecoder().decode(
                firstAccess.split("\\.")[1]
        ));
        assertThat(accessClaims.has("sid")).isTrue();
        assertThat(accessClaims.has("email")).isFalse();
        assertThat(accessClaims.path("exp").asLong() - accessClaims.path("iat").asLong())
                .isEqualTo(600);
        mockMvc.perform(get("/api/users/me")
                        .header("Authorization", "Bearer " + firstAccess))
                .andExpect(status().isOk());

        Map<String, Object> firstSession = jdbcTemplate.queryForMap(
                """
                SELECT public_id, last_activity_at, idle_expires_at, absolute_expires_at, revoked_at
                FROM user_sessions
                WHERE user_id = (SELECT id FROM users WHERE email = ?)
                """,
                syntheticEmail
        );
        assertThat(firstSession.get("revoked_at")).isNull();
        assertThat(firstSession.get("idle_expires_at")).isEqualTo(
                LocalDateTime.ofInstant(AuthMemberControlledDependencies.TEST_NOW, ZoneOffset.UTC)
                        .plusDays(30)
        );
        assertThat(firstSession.get("absolute_expires_at")).isEqualTo(
                LocalDateTime.ofInstant(AuthMemberControlledDependencies.TEST_NOW, ZoneOffset.UTC)
                        .plusDays(90)
        );
        String storedHash = jdbcTemplate.queryForObject(
                "SELECT token_hash FROM refresh_session_credentials WHERE sequence_number = 0 "
                        + "AND session_id = (SELECT id FROM user_sessions WHERE public_id = ?)",
                String.class,
                firstSession.get("public_id")
        );
        assertThat(storedHash).hasSize(64).isNotEqualTo(firstRefresh);

        JsonNode rotated = refresh(firstRefresh, 200, "AUTHENTICATED");
        JsonNode concurrent = refresh(firstRefresh, 200, "AUTHENTICATED");
        assertThat(concurrent.path("accessToken").asText())
                .isEqualTo(rotated.path("accessToken").asText());
        assertThat(concurrent.path("refreshToken").asText())
                .isEqualTo(rotated.path("refreshToken").asText());
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM refresh_session_credentials WHERE session_id = "
                        + "(SELECT id FROM user_sessions WHERE public_id = ?)",
                Integer.class,
                firstSession.get("public_id")
        )).isEqualTo(2);

        jdbcTemplate.update(
                """
                UPDATE refresh_session_credentials
                SET grace_expires_at = ?
                WHERE sequence_number = 0
                  AND session_id = (SELECT id FROM user_sessions WHERE public_id = ?)
                """,
                LocalDateTime.ofInstant(AuthMemberControlledDependencies.TEST_NOW, ZoneOffset.UTC).minusSeconds(1),
                firstSession.get("public_id")
        );
        refresh(firstRefresh, 401, "AUTH_REFRESH_REUSE_DETECTED");
        assertThat(jdbcTemplate.queryForObject(
                "SELECT revoked_at IS NOT NULL FROM user_sessions WHERE public_id = ?",
                Boolean.class,
                firstSession.get("public_id")
        )).isTrue();
        mockMvc.perform(get("/api/users/me")
                        .header("Authorization", "Bearer " + firstAccess))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("AUTHENTICATION_REQUIRED"));
        refresh(rotated.path("refreshToken").asText(), 401, "AUTH_SESSION_INVALID");

        JsonNode secondLogin = responseData(mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", syntheticPassword
                        ))))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString());
        refresh(secondLogin.path("refreshToken").asText(), 200, "AUTHENTICATED");
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM user_sessions WHERE user_id = "
                        + "(SELECT id FROM users WHERE email = ?)",
                Integer.class,
                syntheticEmail
        )).isEqualTo(2);

        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM session_security_audits WHERE session_id = "
                        + "(SELECT id FROM user_sessions WHERE public_id = ?)",
                Integer.class,
                firstSession.get("public_id")
        )).isEqualTo(3);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM outbox_events WHERE aggregate_id = ? "
                        + "AND event_type IN ('SESSION_CREATED', 'SESSION_REFRESH_ROTATED', "
                        + "'SESSION_REFRESH_REUSE_DETECTED')",
                Integer.class,
                firstSession.get("public_id")
        )).isEqualTo(3);
    }

    @Test
    void deviceSessionListShouldExposeOnlySafeOwnerScopedMetadata() throws Exception {
        String syntheticEmail = "device.sessions@example.test";
        String syntheticPassword = "synthetic-password";
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "device_session_member",
                                "email", syntheticEmail,
                                "password", syntheticPassword,
                                "userName", "Device Session Member"
                        ))))
                .andExpect(status().isCreated());

        JsonNode webSession = responseData(mockMvc.perform(post("/api/v1/auth/login")
                        .header("X-Client-Platform", "WEB")
                        .header("User-Agent", "Mozilla/5.0 (Macintosh) Chrome/126.0")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", syntheticPassword
                        ))))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString());
        JsonNode androidSession = responseData(mockMvc.perform(post("/api/v1/auth/login")
                        .header("X-Client-Platform", "ANDROID")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", syntheticPassword
                        ))))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString());

        String androidAccessToken = androidSession.path("accessToken").asText();
        String androidSessionId = accessSessionId(androidAccessToken);
        String webSessionId = accessSessionId(webSession.path("accessToken").asText());

        mockMvc.perform(get("/api/v1/auth/sessions")
                        .header("Authorization", "Bearer " + androidAccessToken)
                        .queryParam("page", "0")
                        .queryParam("size", "3"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("DEVICE_SESSIONS_RETRIEVED"))
                .andExpect(jsonPath("$.data.items.length()").value(2))
                .andExpect(jsonPath("$.data.items[0].sessionId").value(androidSessionId))
                .andExpect(jsonPath("$.data.items[0].deviceType").value("ANDROID"))
                .andExpect(jsonPath("$.data.items[0].deviceSummary").value("Android App"))
                .andExpect(jsonPath("$.data.items[0].current").value(true))
                .andExpect(jsonPath("$.data.items[0].lastActivityAt").isString())
                .andExpect(jsonPath("$.data.items[0].refreshToken").doesNotExist())
                .andExpect(jsonPath("$.data.items[0].tokenHash").doesNotExist())
                .andExpect(jsonPath("$.data.items[1].sessionId").value(webSessionId))
                .andExpect(jsonPath("$.data.items[1].deviceType").value("WEB"))
                .andExpect(jsonPath("$.data.items[1].deviceSummary").value("Chrome on macOS"))
                .andExpect(jsonPath("$.data.items[1].current").value(false))
                .andExpect(jsonPath("$.data.page").value(0))
                .andExpect(jsonPath("$.data.size").value(3))
                .andExpect(jsonPath("$.data.totalItems").value(2))
                .andExpect(jsonPath("$.data.totalPages").value(1));
    }

    @Test
    void reauthenticationAndSessionRevocationShouldPreserveOnlyTheSelectedFamilies()
            throws Exception {
        String syntheticEmail = "session.commands@example.test";
        String syntheticPassword = "synthetic-password";
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "session_commands_member",
                                "email", syntheticEmail,
                                "password", syntheticPassword,
                                "userName", "Session Commands Member"
                        ))))
                .andExpect(status().isCreated());

        JsonNode firstSession = responseData(mockMvc.perform(post("/api/v1/auth/login")
                        .header("X-Client-Platform", "WEB")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", syntheticPassword
                        ))))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString());
        JsonNode currentSession = responseData(mockMvc.perform(post("/api/v1/auth/login")
                        .header("X-Client-Platform", "ANDROID")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", syntheticPassword
                        ))))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString());

        String currentAccessToken = currentSession.path("accessToken").asText();
        JsonNode reauthentication = responseData(mockMvc.perform(
                        post("/api/v1/auth/reauthentications/password")
                                .header("Authorization", "Bearer " + currentAccessToken)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(Map.of(
                                        "password", syntheticPassword
                                ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("SESSION_REAUTHENTICATED"))
                .andExpect(jsonPath("$.data.expiresIn").value(300))
                .andReturn().getResponse().getContentAsString());
        String reauthenticationCredential = reauthentication.path("credential").asText();

        mockMvc.perform(post("/api/v1/auth/session-revocations/others")
                        .header("Authorization", "Bearer " + currentAccessToken)
                        .header("X-Reauthentication-Credential", reauthenticationCredential))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("OTHER_SESSIONS_REVOKED"));
        mockMvc.perform(post("/api/v1/auth/session-revocations/others")
                        .header("Authorization", "Bearer " + currentAccessToken)
                        .header("X-Reauthentication-Credential", reauthenticationCredential))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("OTHER_SESSIONS_REVOKED"));

        mockMvc.perform(get("/api/v1/auth/sessions")
                        .header("Authorization", "Bearer " + currentAccessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.totalItems").value(1))
                .andExpect(jsonPath("$.data.items[0].current").value(true));

        mockMvc.perform(post("/api/v1/auth/session-refreshes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "refreshCredential", firstSession.path("refreshToken").asText()
                        ))))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(post("/api/v1/auth/logout")
                        .header("Authorization", "Bearer " + currentAccessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("CURRENT_SESSION_REVOKED"));

        mockMvc.perform(get("/api/v1/auth/sessions")
                        .header("Authorization", "Bearer " + currentAccessToken))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(post("/api/v1/auth/session-refreshes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "refreshCredential", currentSession.path("refreshToken").asText()
                        ))))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void webLoginShouldIssueHostCookieWithoutExposingRefreshCredential()
            throws Exception {
        String syntheticEmail = "web.cookie.login@example.test";
        String syntheticPassword = "synthetic-password";
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "web_cookie_login_member",
                                "email", syntheticEmail,
                                "password", syntheticPassword,
                                "userName", "Web Cookie Login Member"
                        ))))
                .andExpect(status().isCreated());

        var result = mockMvc.perform(post("/api/v1/auth/login")
                        .header("Origin", "https://app.example.test")
                        .header("X-Session-Transport", "COOKIE")
                        .header("X-CSRF-Protection", "1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", syntheticPassword
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("AUTHENTICATED"))
                .andReturn();

        String setCookie = result.getResponse().getHeader("Set-Cookie");
        assertThat(setCookie)
                .startsWith("__Host-monsters-refresh=")
                .contains("Path=/", "Secure", "HttpOnly", "SameSite=None");
        JsonNode data = responseData(result.getResponse().getContentAsString());
        assertThat(data.path("accessToken").asText()).isNotBlank();
        assertThat(data.has("refreshToken")).isFalse();

        mockMvc.perform(post("/api/v1/auth/logout")
                        .header("Authorization", "Bearer " + data.path("accessToken").asText())
                        .header("Origin", "https://app.example.test")
                        .header("X-Session-Transport", "COOKIE")
                        .header("X-CSRF-Protection", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("CURRENT_SESSION_REVOKED"))
                .andExpect(header().string("Set-Cookie", org.hamcrest.Matchers.allOf(
                        org.hamcrest.Matchers.containsString("__Host-monsters-refresh="),
                        org.hamcrest.Matchers.containsString("Max-Age=0")
                )));
    }

    @Test
    void webLoginShouldRejectUntrustedOriginOrMissingCsrfBeforeCreatingSession()
            throws Exception {
        String syntheticEmail = "web.cookie.rejected@example.test";
        String syntheticPassword = "synthetic-password";
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "web_cookie_rejected_member",
                                "email", syntheticEmail,
                                "password", syntheticPassword,
                                "userName", "Web Cookie Rejected Member"
                        ))))
                .andExpect(status().isCreated());

        String loginBody = objectMapper.writeValueAsString(Map.of(
                "email", syntheticEmail,
                "password", syntheticPassword
        ));
        mockMvc.perform(post("/api/v1/auth/login")
                        .header("Origin", "https://untrusted.example.test")
                        .header("X-Session-Transport", "COOKIE")
                        .header("X-CSRF-Protection", "1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(loginBody))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("WEB_SESSION_REQUEST_REJECTED"));

        mockMvc.perform(post("/api/v1/auth/login")
                        .header("Origin", "https://app.example.test")
                        .header("X-Session-Transport", "COOKIE")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(loginBody))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("WEB_SESSION_REQUEST_REJECTED"));

        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM user_sessions WHERE user_id = "
                        + "(SELECT id FROM users WHERE email = ?)",
                Integer.class,
                syntheticEmail
        )).isZero();
    }

    @Test
    void webContinuationLoginShouldExpireAnyExistingSessionCookie() throws Exception {
        String syntheticEmail = "web.cookie.continuation@example.test";
        registerWithoutDelivery(syntheticEmail);

        var result = mockMvc.perform(post("/api/v1/auth/login")
                        .header("Origin", "https://app.example.test")
                        .header("X-Session-Transport", "COOKIE")
                        .header("X-CSRF-Protection", "1")
                        .cookie(new Cookie(
                                "__Host-monsters-refresh",
                                "previous-member-refresh-credential"
                        ))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", "synthetic-password"
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("AUTH_CONTINUATION_REQUIRED"))
                .andReturn();

        assertThat(result.getResponse().getHeader("Set-Cookie"))
                .startsWith("__Host-monsters-refresh=;")
                .contains("Path=/", "Max-Age=0", "Secure", "HttpOnly", "SameSite=None");
    }

    @Test
    void webRefreshShouldRotateCookieWithoutExposingRefreshCredential()
            throws Exception {
        String syntheticEmail = "web.cookie.refresh@example.test";
        String syntheticPassword = "synthetic-password";
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "web_cookie_refresh_member",
                                "email", syntheticEmail,
                                "password", syntheticPassword,
                                "userName", "Web Cookie Refresh Member"
                        ))))
                .andExpect(status().isCreated());

        var loginResult = mockMvc.perform(post("/api/v1/auth/login")
                        .header("Origin", "https://app.example.test")
                        .header("X-Session-Transport", "COOKIE")
                        .header("X-CSRF-Protection", "1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", syntheticPassword
                        ))))
                .andExpect(status().isOk())
                .andReturn();
        Cookie firstCookie = loginResult.getResponse().getCookie("__Host-monsters-refresh");
        assertThat(firstCookie).isNotNull();

        var refreshResult = mockMvc.perform(post("/api/v1/auth/session-refreshes")
                        .header("Origin", "https://app.example.test")
                        .header("X-Session-Transport", "COOKIE")
                        .header("X-CSRF-Protection", "1")
                        .cookie(firstCookie))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("AUTHENTICATED"))
                .andReturn();

        Cookie rotatedCookie = refreshResult.getResponse().getCookie("__Host-monsters-refresh");
        assertThat(rotatedCookie).isNotNull();
        assertThat(rotatedCookie.getValue()).isNotEqualTo(firstCookie.getValue());
        JsonNode data = responseData(refreshResult.getResponse().getContentAsString());
        assertThat(data.path("accessToken").asText()).isNotBlank();
        assertThat(data.has("refreshToken")).isFalse();
    }

    @Test
    void webRefreshShouldExpireCookieWhenCredentialIsInvalid() throws Exception {
        var result = mockMvc.perform(post("/api/v1/auth/session-refreshes")
                        .header("Origin", "https://app.example.test")
                        .header("X-Session-Transport", "COOKIE")
                        .header("X-CSRF-Protection", "1")
                        .cookie(new Cookie(
                                "__Host-monsters-refresh",
                                "unknown-refresh-credential"
                        )))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("AUTH_SESSION_INVALID"))
                .andReturn();

        assertThat(result.getResponse().getHeader("Set-Cookie"))
                .startsWith("__Host-monsters-refresh=;")
                .contains("Path=/", "Max-Age=0", "Secure", "HttpOnly", "SameSite=None");
    }

    @Test
    void opaqueRefreshFamilyShouldRejectUnknownIdleAndAbsoluteExpiredCredentials()
            throws Exception {
        String syntheticEmail = "session.expiry@example.test";
        String syntheticPassword = "synthetic-password";
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "session_expiry_member",
                                "email", syntheticEmail,
                                "password", syntheticPassword,
                                "userName", "Session Expiry Member"
                        ))))
                .andExpect(status().isCreated());

        refresh("unknown-refresh-credential", 401, "AUTH_SESSION_INVALID");

        JsonNode idleSession = loginV1(syntheticEmail, syntheticPassword);
        jdbcTemplate.update(
                """
                UPDATE user_sessions
                SET idle_expires_at = ?
                WHERE public_id = ?
                """,
                LocalDateTime.ofInstant(AuthMemberControlledDependencies.TEST_NOW, ZoneOffset.UTC),
                accessSessionId(idleSession.path("accessToken").asText())
        );
        refresh(idleSession.path("refreshToken").asText(), 401, "AUTH_SESSION_INVALID");

        JsonNode absoluteSession = loginV1(syntheticEmail, syntheticPassword);
        jdbcTemplate.update(
                """
                UPDATE user_sessions
                SET absolute_expires_at = ?
                WHERE public_id = ?
                """,
                LocalDateTime.ofInstant(AuthMemberControlledDependencies.TEST_NOW, ZoneOffset.UTC),
                accessSessionId(absoluteSession.path("accessToken").asText())
        );
        refresh(absoluteSession.path("refreshToken").asText(), 401, "AUTH_SESSION_INVALID");
    }

    @Test
    void registrationShouldReturnAUniformAcceptedResponse(CapturedOutput output) throws Exception {
        String syntheticEmail = "new.registration@example.test";
        String syntheticPassword = "synthetic-password";

        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", syntheticPassword,
                                "acceptedTermsVersion", "terms-synthetic-v1",
                                "acceptedPrivacyVersion", "privacy-synthetic-v1"
                        ))))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.code").value("REGISTRATION_ACCEPTED"))
                .andExpect(jsonPath("$.data").doesNotExist())
                .andExpect(jsonPath("$.fieldErrors").isMap())
                .andExpect(jsonPath("$.requestId").isString());

        Map<String, Object> member = jdbcTemplate.queryForMap(
                """
                SELECT id, public_id, account, user_name, member_state
                FROM users
                WHERE email = ?
                """,
                syntheticEmail
        );
        long memberId = ((Number) member.get("id")).longValue();
        assertThat(member)
                .containsEntry("account", null)
                .containsEntry("user_name", null)
                .containsEntry("member_state", "PENDING_EMAIL_VERIFICATION");
        assertThat(jdbcTemplate.queryForObject(
                "SELECT password_hash FROM user_credentials WHERE user_id = ?",
                String.class,
                memberId
        )).startsWith("$argon2id$v=19$m=19456,t=2,p=1$")
                .doesNotContain(syntheticPassword);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM member_document_acceptances WHERE user_id = ?",
                Integer.class,
                memberId
        )).isEqualTo(2);
        Map<String, Object> outbox = jdbcTemplate.queryForMap(
                """
                SELECT event_type, payload, status
                FROM outbox_events
                WHERE aggregate_id = ?
                """,
                member.get("public_id")
        );
        assertThat(outbox)
                .containsEntry("event_type", "EMAIL_VERIFICATION_REQUESTED")
                .containsEntry("status", "PENDING");
        assertThat(outbox.get("payload").toString()).doesNotContain(syntheticEmail, syntheticPassword);
        assertThat(output.getAll()).contains("Registration request accepted");
        assertThat(output.getAll()).doesNotContain(syntheticEmail, syntheticPassword);
    }

    @Test
    void registrationShouldRejectPasswordOutsideUnicodePolicyWithoutLoggingIt(
            CapturedOutput output
    ) throws Exception {
        String syntheticPassword = "😀".repeat(14);

        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", "short.password@example.test",
                                "password", syntheticPassword,
                                "acceptedTermsVersion", "terms-synthetic-v1",
                                "acceptedPrivacyVersion", "privacy-synthetic-v1"
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
                .andExpect(jsonPath("$.fieldErrors.password").value("PASSWORD_TOO_SHORT"));

        assertThat(output.getAll()).doesNotContain(syntheticPassword);
    }

    @Test
    void registrationShouldAcceptFifteenAndOneHundredTwentyEightButRejectOneHundredTwentyNine()
            throws Exception {
        for (int codePointCount : new int[]{15, 128}) {
            mockMvc.perform(post("/api/v1/auth/register")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(Map.of(
                                    "email", "boundary." + codePointCount + "@example.test",
                                    "password", boundaryPassword(codePointCount),
                                    "acceptedTermsVersion", "terms-synthetic-v1",
                                    "acceptedPrivacyVersion", "privacy-synthetic-v1"
                            ))))
                    .andExpect(status().isAccepted())
                    .andExpect(jsonPath("$.code").value("REGISTRATION_ACCEPTED"));
        }

        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", "boundary.129@example.test",
                                "password", boundaryPassword(129),
                                "acceptedTermsVersion", "terms-synthetic-v1",
                                "acceptedPrivacyVersion", "privacy-synthetic-v1"
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
                .andExpect(jsonPath("$.fieldErrors.password").value("PASSWORD_TOO_LONG"));
    }

    @Test
    void registrationAndLoginShouldNormalizeNfcWithoutTrimmingSpaces() throws Exception {
        String spacedEmail = "spaces.password@example.test";
        String spacedPassword = " synthetic-password ";
        registerWithoutDelivery(spacedEmail, spacedPassword);

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", spacedEmail,
                                "password", spacedPassword
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("AUTH_CONTINUATION_REQUIRED"));

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", spacedEmail,
                                "password", spacedPassword.trim()
                        ))))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("AUTH_INVALID_CREDENTIALS"));

        String nfcEmail = "nfc.password@example.test";
        registerWithoutDelivery(nfcEmail, "cafe\u0301 synthetic-password");

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", nfcEmail,
                                "password", "café synthetic-password"
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("AUTH_CONTINUATION_REQUIRED"));
    }

    @Test
    void registrationShouldRejectExactLocalBlocklistMatch() throws Exception {
        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", "weak.password@example.test",
                                "password", "passwordpassword",
                                "acceptedTermsVersion", "terms-synthetic-v1",
                                "acceptedPrivacyVersion", "privacy-synthetic-v1"
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
                .andExpect(jsonPath("$.fieldErrors.password").value("PASSWORD_TOO_WEAK"));
    }

    @Test
    void successfulLoginShouldAtomicallyUpgradeBcryptButFailedLoginShouldNot(
            CapturedOutput output
    ) throws Exception {
        String syntheticEmail = "bcrypt.migration@example.test";
        String syntheticPassword = "synthetic-password";
        registerWithoutDelivery(syntheticEmail);
        jdbcTemplate.update(
                "UPDATE users SET member_state = 'ACTIVE' WHERE email = ?",
                syntheticEmail
        );
        String legacyHash = new BCryptPasswordEncoder().encode(syntheticPassword);
        jdbcTemplate.update(
                """
                UPDATE user_credentials
                SET password_hash = ?
                WHERE user_id = (SELECT id FROM users WHERE email = ?)
                """,
                legacyHash,
                syntheticEmail
        );

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", "incorrect-password"
                        ))))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("AUTH_INVALID_CREDENTIALS"));

        assertThat(passwordHashFor(syntheticEmail)).isEqualTo(legacyHash);

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", syntheticPassword
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("AUTHENTICATED"));

        assertThat(passwordHashFor(syntheticEmail))
                .startsWith("$argon2id$v=19$m=19456,t=2,p=1$")
                .isNotEqualTo(legacyHash);
        assertThat(output.getAll()).doesNotContain(
                syntheticEmail,
                syntheticPassword,
                legacyHash,
                passwordHashFor(syntheticEmail)
        );
    }

    @Test
    void emailVerificationOutboxShouldIssueHashedTokenAndCompleteOnlyAfterDelivery(
            CapturedOutput output
    ) throws Exception {
        String syntheticEmail = "verification.delivery@example.test";

        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", "synthetic-password",
                                "acceptedTermsVersion", "terms-synthetic-v1",
                                "acceptedPrivacyVersion", "privacy-synthetic-v1"
                        ))))
                .andExpect(status().isAccepted());

        assertThat(emailVerificationOutboxWorker.processPending()).isEqualTo(1);

        EmailDeliveryRequest delivery = ((RecordingEmailDelivery) emailDeliveryPort)
                .requests()
                .stream()
                .filter(request -> request.recipient().equals(syntheticEmail))
                .findFirst()
                .orElseThrow();
        assertThat(delivery.templateId()).isEqualTo("verify-email");
        String verificationUrl = delivery.variables().get("verificationUrl");
        assertThat(verificationUrl).startsWith("https://example.test/verify-email?token=");
        String rawToken = URLDecoder.decode(
                URI.create(verificationUrl).getRawQuery().substring("token=".length()),
                StandardCharsets.UTF_8
        );

        Map<String, Object> token = jdbcTemplate.queryForMap(
                """
                SELECT token_hash, expires_at, used_at, revoked_at
                FROM email_verification_tokens
                WHERE user_id = (SELECT id FROM users WHERE email = ?)
                """,
                syntheticEmail
        );
        assertThat(token.get("token_hash").toString())
                .hasSize(64)
                .doesNotContain(rawToken);
        assertThat(token.get("expires_at"))
                .isEqualTo(LocalDateTime.ofInstant(clock.instant(), ZoneOffset.UTC).plusHours(24));
        assertThat(token)
                .containsEntry("used_at", null)
                .containsEntry("revoked_at", null);
        assertThat(jdbcTemplate.queryForObject(
                """
                SELECT COUNT(*)
                FROM outbox_events
                WHERE aggregate_id = (
                    SELECT public_id FROM users WHERE email = ?
                )
                  AND event_type = 'EMAIL_VERIFICATION_REQUESTED'
                  AND status = 'COMPLETED'
                """,
                Integer.class,
                syntheticEmail
        )).isEqualTo(1);
        assertThat(output.getAll()).doesNotContain(syntheticEmail, rawToken);
    }

    @Test
    void emailVerificationShouldAtomicallyAdvanceStateAndIssueContinuationCredential(
            CapturedOutput output
    ) throws Exception {
        String syntheticEmail = "verification.success@example.test";

        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", "synthetic-password",
                                "acceptedTermsVersion", "terms-synthetic-v1",
                                "acceptedPrivacyVersion", "privacy-synthetic-v1"
                        ))))
                .andExpect(status().isAccepted());
        emailVerificationOutboxWorker.processPending();

        String rawToken = verificationTokenFor(syntheticEmail);
        String response = mockMvc.perform(post("/api/v1/auth/email-verifications")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("token", rawToken))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.code").value("EMAIL_VERIFIED"))
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

        Map<String, Object> member = jdbcTemplate.queryForMap(
                "SELECT id, public_id, member_state, version FROM users WHERE email = ?",
                syntheticEmail
        );
        long memberId = ((Number) member.get("id")).longValue();
        assertThat(member)
                .containsEntry("member_state", "PENDING_ELIGIBILITY")
                .containsEntry("version", 1L);
        assertThat(jdbcTemplate.queryForObject(
                """
                SELECT COUNT(*)
                FROM email_verification_tokens
                WHERE user_id = ? AND used_at IS NOT NULL
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
        )).containsEntry("from_state", "PENDING_EMAIL_VERIFICATION")
                .containsEntry("to_state", "PENDING_ELIGIBILITY")
                .containsEntry("reason_code", "EMAIL_VERIFIED")
                .containsEntry("actor_type", "SYSTEM");
        assertThat(jdbcTemplate.queryForObject(
                """
                SELECT COUNT(*)
                FROM outbox_events
                WHERE aggregate_id = ?
                  AND event_type = 'MEMBER_STATE_CHANGED'
                  AND status = 'PENDING'
                """,
                Integer.class,
                member.get("public_id")
        )).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT token_hash FROM member_continuation_credentials WHERE user_id = ?",
                String.class,
                memberId
        )).doesNotContain(continuationCredential);
        assertThat(output.getAll()).doesNotContain(syntheticEmail, rawToken, continuationCredential);
    }

    @Test
    void adultEligibilityShouldUseContinuationFilterAndCommitAtomicallyToMySql() throws Exception {
        String syntheticEmail = "eligibility.adult@example.test";
        registerAndDeliverVerification(syntheticEmail);
        String verificationResponse = mockMvc.perform(post("/api/v1/auth/email-verifications")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "token", verificationTokenFor(syntheticEmail)
                        ))))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        String continuation = objectMapper.readTree(verificationResponse)
                .path("data").path("continuationCredential").asText();

        assertThat(jdbcTemplate.queryForMap(
                """
                SELECT credential.next_action, credential.issued_for_state,
                       credential.issued_for_version, credential.revoked_at,
                       member.member_state, member.version
                FROM member_continuation_credentials credential
                JOIN users member ON member.id = credential.user_id
                WHERE member.email = ?
                """,
                syntheticEmail
        )).containsEntry("next_action", "COMPLETE_ELIGIBILITY")
                .containsEntry("issued_for_state", "PENDING_ELIGIBILITY")
                .containsEntry("issued_for_version", 1L)
                .containsEntry("member_state", "PENDING_ELIGIBILITY")
                .containsEntry("version", 1L)
                .containsEntry("revoked_at", null);

        mockMvc.perform(post("/api/v1/auth/eligibility-completions")
                        .header("Authorization", "Continuation " + continuation)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "serviceRegion", "TW",
                                "birthday", "2000-01-01",
                                "publicNickname", "  é貘  ",
                                "confirmPublicNicknameDisclosure", true,
                                "publicNicknameDisclosureVersion", "nickname-v1"
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.eligibilityStatus").value("ELIGIBLE_ADULT"))
                .andExpect(jsonPath("$.data.communityEligibilityStatus").value("ELIGIBLE"))
                .andExpect(jsonPath("$.data.nextAction").value("SIGN_IN"));

        assertThat(jdbcTemplate.queryForMap("""
                SELECT member_state, service_region, birthday, user_name,
                       eligibility_status, community_eligibility_status,
                       nickname_disclosure_version
                FROM users WHERE email = ?
                """, syntheticEmail))
                .containsEntry("member_state", "ACTIVE")
                .containsEntry("service_region", "TW")
                .containsEntry("user_name", "é貘")
                .containsEntry("eligibility_status", "ELIGIBLE_ADULT")
                .containsEntry("community_eligibility_status", "ELIGIBLE")
                .containsEntry("nickname_disclosure_version", "nickname-v1");
        assertThat(jdbcTemplate.queryForObject("""
                SELECT COUNT(*) FROM member_continuation_credentials credential
                JOIN users member ON member.id = credential.user_id
                WHERE member.email = ? AND credential.revoked_at IS NOT NULL
                """, Integer.class, syntheticEmail)).isEqualTo(1);
    }

    @Test
    void resendShouldRevokeOldTokenAndKeepThePublicResponseUniform() throws Exception {
        String knownEmail = "verification.resend@example.test";
        String unknownEmail = "verification.unknown@example.test";

        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", knownEmail,
                                "password", "synthetic-password",
                                "acceptedTermsVersion", "terms-synthetic-v1",
                                "acceptedPrivacyVersion", "privacy-synthetic-v1"
                        ))))
                .andExpect(status().isAccepted());
        emailVerificationOutboxWorker.processPending();
        String oldToken = verificationTokenFor(knownEmail);

        jdbcTemplate.update(
                """
                UPDATE registration_rate_limit_buckets
                SET last_attempt_at = DATE_SUB(last_attempt_at, INTERVAL 61 SECOND)
                WHERE bucket_scope = 'EMAIL'
                """
        );

        mockMvc.perform(post("/api/v1/auth/email-verification-requests")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("email", knownEmail))))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.code").value("EMAIL_VERIFICATION_REQUEST_ACCEPTED"))
                .andExpect(jsonPath("$.data").doesNotExist());
        emailVerificationOutboxWorker.processPending();

        assertThat(((RecordingEmailDelivery) emailDeliveryPort)
                .requests()
                .stream()
                .filter(request -> request.recipient().equals(knownEmail)))
                .hasSize(2);
        assertThat(jdbcTemplate.queryForObject(
                """
                SELECT COUNT(*)
                FROM email_verification_tokens
                WHERE user_id = (SELECT id FROM users WHERE email = ?)
                  AND revoked_at IS NOT NULL
                """,
                Integer.class,
                knownEmail
        )).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject(
                """
                SELECT COUNT(*)
                FROM email_verification_tokens
                WHERE user_id = (SELECT id FROM users WHERE email = ?)
                  AND used_at IS NULL
                  AND revoked_at IS NULL
                """,
                Integer.class,
                knownEmail
        )).isEqualTo(1);

        mockMvc.perform(post("/api/v1/auth/email-verification-requests")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("email", unknownEmail))))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.code").value("EMAIL_VERIFICATION_REQUEST_ACCEPTED"))
                .andExpect(jsonPath("$.data").doesNotExist());
        assertThat(emailVerificationOutboxWorker.processPending()).isZero();
        assertThat(oldToken).isNotEqualTo(verificationTokenFor(knownEmail));
    }

    @Test
    void repeatedRegistrationShouldRecoverPendingFlowWithoutChangingCredentials()
            throws Exception {
        String syntheticEmail = "registration.recovery@example.test";
        registerAndDeliverVerification(syntheticEmail);
        String originalHash = jdbcTemplate.queryForObject(
                """
                SELECT password_hash
                FROM user_credentials
                WHERE user_id = (SELECT id FROM users WHERE email = ?)
                """,
                String.class,
                syntheticEmail
        );
        jdbcTemplate.update(
                """
                UPDATE registration_rate_limit_buckets
                SET last_attempt_at = DATE_SUB(last_attempt_at, INTERVAL 61 SECOND)
                WHERE bucket_scope = 'EMAIL'
                """
        );

        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", "different-synthetic-password",
                                "acceptedTermsVersion", "terms-synthetic-v1",
                                "acceptedPrivacyVersion", "privacy-synthetic-v1"
                        ))))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.code").value("REGISTRATION_ACCEPTED"))
                .andExpect(jsonPath("$.data").doesNotExist());
        assertThat(emailVerificationOutboxWorker.processPending()).isEqualTo(1);

        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM users WHERE email = ?",
                Integer.class,
                syntheticEmail
        )).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject(
                """
                SELECT password_hash
                FROM user_credentials
                WHERE user_id = (SELECT id FROM users WHERE email = ?)
                """,
                String.class,
                syntheticEmail
        )).isEqualTo(originalHash);
        assertThat(((RecordingEmailDelivery) emailDeliveryPort)
                .requests()
                .stream()
                .filter(request -> request.recipient().equals(syntheticEmail)))
                .hasSize(2);
    }

    @Test
    void resendCooldownShouldTreatKnownAndUnknownEmailTheSame() throws Exception {
        String knownEmail = "verification.cooldown@example.test";
        String unknownEmail = "verification.cooldown.unknown@example.test";

        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", knownEmail,
                                "password", "synthetic-password",
                                "acceptedTermsVersion", "terms-synthetic-v1",
                                "acceptedPrivacyVersion", "privacy-synthetic-v1"
                        ))))
                .andExpect(status().isAccepted());

        mockMvc.perform(post("/api/v1/auth/email-verification-requests")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("email", knownEmail))))
                .andExpect(status().isTooManyRequests())
                .andExpect(jsonPath("$.code").value("RATE_LIMITED"))
                .andExpect(jsonPath("$.data.retryAfter").value(60));

        mockMvc.perform(post("/api/v1/auth/email-verification-requests")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("email", unknownEmail))))
                .andExpect(status().isAccepted());
        mockMvc.perform(post("/api/v1/auth/email-verification-requests")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("email", unknownEmail))))
                .andExpect(status().isTooManyRequests())
                .andExpect(jsonPath("$.code").value("RATE_LIMITED"))
                .andExpect(jsonPath("$.data.retryAfter").value(60));
    }

    @Test
    void registrationRateLimitsShouldPersistOnlyHashedEmailAndIpKeys()
            throws Exception {
        String syntheticEmail = "verification.rate.limit@example.test";
        registerWithoutDelivery(syntheticEmail);

        assertThat(jdbcTemplate.queryForList(
                """
                SELECT bucket_scope, key_hash
                FROM registration_rate_limit_buckets
                ORDER BY bucket_scope
                """
        )).allSatisfy(bucket -> {
            assertThat(bucket.get("key_hash").toString())
                    .hasSize(64)
                    .doesNotContain(syntheticEmail, "127.0.0.1");
        });

        jdbcTemplate.update(
                """
                UPDATE registration_rate_limit_buckets
                SET attempts = 5, last_attempt_at = NULL
                WHERE bucket_scope = 'EMAIL'
                """
        );
        mockMvc.perform(post("/api/v1/auth/email-verification-requests")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email",
                                syntheticEmail
                        ))))
                .andExpect(status().isTooManyRequests())
                .andExpect(jsonPath("$.code").value("RATE_LIMITED"))
                .andExpect(jsonPath("$.data.retryAfter").value(900));

        jdbcTemplate.update(
                """
                UPDATE registration_rate_limit_buckets
                SET attempts = 20, last_attempt_at = NULL
                WHERE bucket_scope = 'IP'
                """
        );
        mockMvc.perform(post("/api/v1/auth/email-verification-requests")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email",
                                "another.rate.limit@example.test"
                        ))))
                .andExpect(status().isTooManyRequests())
                .andExpect(jsonPath("$.code").value("RATE_LIMITED"))
                .andExpect(jsonPath("$.data.retryAfter").value(900));
    }

    @Test
    void emailVerificationShouldReturnStableExpiredAndReusedTokenErrors() throws Exception {
        String expiredEmail = "verification.expired@example.test";
        String usedEmail = "verification.used@example.test";

        registerAndDeliverVerification(expiredEmail);
        String expiredToken = verificationTokenFor(expiredEmail);
        jdbcTemplate.update(
                """
                UPDATE email_verification_tokens
                SET expires_at = ?
                WHERE user_id = (SELECT id FROM users WHERE email = ?)
                """,
                LocalDateTime.ofInstant(clock.instant(), ZoneOffset.UTC),
                expiredEmail
        );
        mockMvc.perform(post("/api/v1/auth/email-verifications")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("token", expiredToken))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("EMAIL_VERIFICATION_TOKEN_EXPIRED"));

        registerAndDeliverVerification(usedEmail);
        String usedToken = verificationTokenFor(usedEmail);
        mockMvc.perform(post("/api/v1/auth/email-verifications")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("token", usedToken))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("EMAIL_VERIFIED"));
        mockMvc.perform(post("/api/v1/auth/email-verifications")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("token", usedToken))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("EMAIL_VERIFICATION_TOKEN_INVALID"));
    }

    @Test
    void emailDeliveryFailureShouldRetryThenBecomeFailedWithoutLeavingAnActiveToken(
            CapturedOutput output
    ) throws Exception {
        String syntheticEmail = "verification.failure@example.test";
        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", "synthetic-password",
                                "acceptedTermsVersion", "terms-synthetic-v1",
                                "acceptedPrivacyVersion", "privacy-synthetic-v1"
                        ))))
                .andExpect(status().isAccepted());
        ((RecordingEmailDelivery) emailDeliveryPort).failNext(5);

        for (int attempt = 1; attempt <= 5; attempt++) {
            assertThat(emailVerificationOutboxWorker.processPending()).isZero();
            if (attempt < 5) {
                jdbcTemplate.update(
                        """
                        UPDATE outbox_events
                        SET available_at = ?
                        WHERE aggregate_id = (
                            SELECT public_id FROM users WHERE email = ?
                        )
                          AND event_type = 'EMAIL_VERIFICATION_REQUESTED'
                        """,
                        LocalDateTime.ofInstant(clock.instant(), ZoneOffset.UTC),
                        syntheticEmail
                );
            }
        }

        assertThat(jdbcTemplate.queryForMap(
                """
                SELECT status, attempts
                FROM outbox_events
                WHERE aggregate_id = (
                    SELECT public_id FROM users WHERE email = ?
                )
                  AND event_type = 'EMAIL_VERIFICATION_REQUESTED'
                """,
                syntheticEmail
        )).containsEntry("status", "FAILED")
                .containsEntry("attempts", 5);
        assertThat(jdbcTemplate.queryForObject(
                """
                SELECT COUNT(*)
                FROM email_verification_tokens
                WHERE user_id = (SELECT id FROM users WHERE email = ?)
                  AND used_at IS NULL
                  AND revoked_at IS NULL
                """,
                Integer.class,
                syntheticEmail
        )).isZero();
        assertThat(output.getAll())
                .contains(
                        "Email verification delivery failed",
                        "EMAIL_VERIFICATION_DELIVERY_FAILED",
                        "at com.monsters"
                )
                .doesNotContain("Synthetic email delivery failure");
        assertThat(output.getAll()).doesNotContain(syntheticEmail);
    }

    @Test
    void unverifiedCleanupShouldDeleteOnlySevenDayOldMembersWithoutPrivateData()
            throws Exception {
        String emptyEmail = "cleanup.empty@example.test";
        String protectedEmail = "cleanup.protected@example.test";
        String recentEmail = "cleanup.recent@example.test";
        registerWithoutDelivery(emptyEmail);
        registerWithoutDelivery(protectedEmail);
        registerWithoutDelivery(recentEmail);

        jdbcTemplate.update(
                """
                UPDATE users
                SET created_at = DATE_SUB(?, INTERVAL 8 DAY)
                WHERE email IN (?, ?)
                """,
                LocalDateTime.ofInstant(clock.instant(), ZoneOffset.UTC),
                emptyEmail,
                protectedEmail
        );
        jdbcTemplate.update(
                """
                INSERT INTO feedback (
                    user_id,
                    content,
                    status,
                    created_at,
                    updated_at
                )
                SELECT id, 'synthetic private feedback', 'open', ?, ?
                FROM users
                WHERE email = ?
                """,
                LocalDateTime.ofInstant(clock.instant(), ZoneOffset.UTC),
                LocalDateTime.ofInstant(clock.instant(), ZoneOffset.UTC),
                protectedEmail
        );

        assertThat(unverifiedMemberCleanupService.cleanup()).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM users WHERE email = ?",
                Integer.class,
                emptyEmail
        )).isZero();
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM users WHERE email IN (?, ?)",
                Integer.class,
                protectedEmail,
                recentEmail
        )).isEqualTo(2);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM feedback WHERE content = 'synthetic private feedback'",
                Integer.class
        )).isEqualTo(1);
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
    void googleExistingMemberLinkingShouldRequireExplicitPurposeBoundReauthentication(
            CapturedOutput output
    ) throws Exception {
        String syntheticEmail = "google.link.member@example.test";
        String syntheticPassword = "synthetic-password";
        String syntheticGoogleToken = "synthetic-google-link-token";
        String syntheticGoogleSubject = "synthetic-google-link-subject";

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "google_link_member",
                                "email", syntheticEmail,
                                "password", syntheticPassword,
                                "userName", "Synthetic Google Link Member"
                        ))))
                .andExpect(status().isCreated());
        when(googleIdTokenVerifier.verify(syntheticGoogleToken))
                .thenReturn(new GoogleUserInfo(
                        syntheticGoogleSubject,
                        syntheticEmail,
                        "Synthetic Google Link Member",
                        null
                ));

        mockMvc.perform(post("/api/v1/auth/google-logins")
                        .header("X-Client-Platform", "ANDROID")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "idToken", syntheticGoogleToken
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("GOOGLE_ACCOUNT_LINK_REQUIRED"))
                .andExpect(jsonPath("$.data.nextAction").value("LINK_GOOGLE_ACCOUNT"))
                .andExpect(jsonPath("$.data.accessToken").doesNotExist())
                .andExpect(jsonPath("$.data.refreshToken").doesNotExist());
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM user_oauth_accounts WHERE provider_user_id = ?",
                Integer.class,
                syntheticGoogleSubject
        )).isZero();

        JsonNode otherSession = responseData(mockMvc.perform(post("/api/v1/auth/login")
                        .header("X-Client-Platform", "WEB")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", syntheticPassword
                        ))))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString());
        JsonNode currentSession = responseData(mockMvc.perform(post("/api/v1/auth/login")
                        .header("X-Client-Platform", "ANDROID")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", syntheticEmail,
                                "password", syntheticPassword
                        ))))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString());
        String otherAccessToken = otherSession.path("accessToken").asText();
        String currentAccessToken = currentSession.path("accessToken").asText();

        JsonNode sessionManagementProof = responseData(mockMvc.perform(
                        post("/api/v1/auth/reauthentications/password")
                                .header("Authorization", "Bearer " + currentAccessToken)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(Map.of(
                                        "password", syntheticPassword
                                ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.purpose").value("SESSION_MANAGEMENT"))
                .andReturn().getResponse().getContentAsString());
        mockMvc.perform(post("/api/v1/auth/google-account-links")
                        .header("Authorization", "Bearer " + currentAccessToken)
                        .header(
                                "X-Reauthentication-Credential",
                                sessionManagementProof.path("credential").asText()
                        )
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "idToken", syntheticGoogleToken,
                                "confirmed", true
                        ))))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("SESSION_REAUTHENTICATION_REQUIRED"));

        JsonNode linkProof = responseData(mockMvc.perform(
                        post("/api/v1/auth/reauthentications/password")
                                .header("Authorization", "Bearer " + currentAccessToken)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(Map.of(
                                        "password", syntheticPassword,
                                        "purpose", "LOGIN_METHOD_LINK"
                                ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.purpose").value("LOGIN_METHOD_LINK"))
                .andExpect(jsonPath("$.data.expiresIn").value(300))
                .andReturn().getResponse().getContentAsString());

        mockMvc.perform(post("/api/v1/auth/google-account-links")
                        .header("Authorization", "Bearer " + currentAccessToken)
                        .header(
                                "X-Reauthentication-Credential",
                                linkProof.path("credential").asText()
                        )
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "idToken", syntheticGoogleToken,
                                "confirmed", true
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("GOOGLE_ACCOUNT_LINKED"))
                .andExpect(jsonPath("$.data.linked").value(true))
                .andExpect(jsonPath("$.data.currentSessionPreserved").value(true))
                .andExpect(jsonPath("$.data.otherSessionsRevoked").value(true));

        mockMvc.perform(get("/api/v1/auth/sessions")
                        .header("Authorization", "Bearer " + currentAccessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.totalItems").value(1))
                .andExpect(jsonPath("$.data.items[0].current").value(true));
        mockMvc.perform(get("/api/v1/auth/sessions")
                        .header("Authorization", "Bearer " + otherAccessToken))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(post("/api/v1/auth/google-logins")
                        .header("X-Client-Platform", "IOS")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "idToken", syntheticGoogleToken
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("AUTHENTICATED"))
                .andExpect(jsonPath("$.data.accessToken").isString())
                .andExpect(jsonPath("$.data.refreshToken").isString());

        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM session_security_audits WHERE event_type = 'LOGIN_METHOD_LINKED'",
                Integer.class
        )).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT payload FROM outbox_events WHERE event_type = 'LOGIN_METHOD_LINKED'",
                String.class
        )).isEqualTo("{}");
        assertThat(output.getAll()).doesNotContain(syntheticGoogleToken, syntheticEmail);
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

    @Test
    void passwordResetRequestShouldBeUniversalAndStoreOnlyAHashedFifteenMinuteToken()
            throws Exception {
        String email = "password.reset.request@example.test";
        String password = "synthetic-password";
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "password_reset_request_member",
                                "email", email,
                                "password", password,
                                "userName", "Password Reset Request Member"
                        ))))
                .andExpect(status().isCreated());

        String unknownResponse = mockMvc.perform(post("/api/v1/auth/password-reset-requests")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", "missing.password.reset@example.test"
                        ))))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.code").value("PASSWORD_RESET_REQUEST_ACCEPTED"))
                .andExpect(jsonPath("$.data").doesNotExist())
                .andExpect(jsonPath("$.resetToken").doesNotExist())
                .andReturn().getResponse().getContentAsString();
        String existingResponse = mockMvc.perform(post("/api/v1/auth/password-reset-requests")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("email", email))))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.code").value("PASSWORD_RESET_REQUEST_ACCEPTED"))
                .andExpect(jsonPath("$.data").doesNotExist())
                .andExpect(jsonPath("$.resetToken").doesNotExist())
                .andReturn().getResponse().getContentAsString();
        assertThat(objectMapper.readTree(existingResponse).path("message"))
                .isEqualTo(objectMapper.readTree(unknownResponse).path("message"));
        mockMvc.perform(post("/api/v1/auth/password-reset-requests")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("email", email))))
                .andExpect(status().isTooManyRequests())
                .andExpect(header().string("Retry-After", "60"))
                .andExpect(jsonPath("$.code").value("RATE_LIMITED"))
                .andExpect(jsonPath("$.data.retryAfter").value(60));

        assertThat(passwordResetOutboxWorker.processPending()).isEqualTo(1);
        String firstToken = passwordResetTokenFor(email);
        Map<String, Object> storedToken = jdbcTemplate.queryForMap(
                """
                SELECT token_hash, expires_at, used_at, revoked_at
                FROM password_reset_tokens
                WHERE user_id = (SELECT id FROM users WHERE email = ?)
                """,
                email
        );
        assertThat(storedToken.get("token_hash")).isNotEqualTo(firstToken);
        assertThat(storedToken.get("expires_at")).isEqualTo(
                LocalDateTime.ofInstant(AuthMemberControlledDependencies.TEST_NOW, ZoneOffset.UTC)
                        .plusMinutes(15)
        );
        assertThat(storedToken.get("used_at")).isNull();
        assertThat(storedToken.get("revoked_at")).isNull();
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM password_reset_tokens WHERE token_hash = ?",
                Integer.class,
                firstToken
        )).isZero();

        jdbcTemplate.update("DELETE FROM registration_rate_limit_buckets");
        mockMvc.perform(post("/api/v1/auth/password-reset-requests")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("email", email))))
                .andExpect(status().isAccepted());
        assertThat(passwordResetOutboxWorker.processPending()).isEqualTo(1);
        String secondToken = passwordResetTokenFor(email);
        assertThat(secondToken).isNotEqualTo(firstToken);
        assertThat(jdbcTemplate.queryForObject(
                """
                SELECT COUNT(*)
                FROM password_reset_tokens
                WHERE user_id = (SELECT id FROM users WHERE email = ?)
                  AND revoked_at IS NOT NULL
                """,
                Integer.class,
                email
        )).isEqualTo(1);
        mockMvc.perform(post("/api/v1/auth/password-resets")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "token", firstToken,
                                "newPassword", "new-reset-password-2026"
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("PASSWORD_RESET_TOKEN_INVALID"));
    }

    @Test
    void passwordResetCompletionShouldUseStableErrorsAndRevokeEverySession()
            throws Exception {
        String email = "password.reset.complete@example.test";
        String oldPassword = "synthetic-password";
        String newPassword = "new-reset-password-2026";
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "password_reset_complete_member",
                                "email", email,
                                "password", oldPassword,
                                "userName", "Password Reset Complete Member"
                        ))))
                .andExpect(status().isCreated());
        JsonNode firstSession = loginV1(email, oldPassword);
        loginV1(email, oldPassword);

        mockMvc.perform(post("/api/v1/auth/password-reset-requests")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("email", email))))
                .andExpect(status().isAccepted());
        assertThat(passwordResetOutboxWorker.processPending()).isEqualTo(1);
        String token = passwordResetTokenFor(email);

        mockMvc.perform(post("/api/v1/auth/password-resets")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "token", token,
                                "newPassword", newPassword
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("PASSWORD_RESET_COMPLETED"));
        assertThat(passwordHashFor(email)).startsWith("$argon2id$");
        assertThat(jdbcTemplate.queryForObject(
                """
                SELECT COUNT(*)
                FROM password_reset_tokens
                WHERE user_id = (SELECT id FROM users WHERE email = ?)
                  AND used_at IS NOT NULL
                """,
                Integer.class,
                email
        )).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject(
                """
                SELECT COUNT(*)
                FROM user_sessions
                WHERE user_id = (SELECT id FROM users WHERE email = ?)
                  AND revoked_at IS NOT NULL
                  AND revocation_reason = 'PASSWORD_RESET'
                """,
                Integer.class,
                email
        )).isEqualTo(2);
        refresh(firstSession.path("refreshToken").asText(), 401, "AUTH_SESSION_INVALID");
        loginV1(email, newPassword);
        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", email,
                                "password", oldPassword
                        ))))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("AUTH_INVALID_CREDENTIALS"));

        mockMvc.perform(post("/api/v1/auth/password-resets")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "token", token,
                                "newPassword", "another-reset-password-2026"
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("PASSWORD_RESET_TOKEN_USED"));
        mockMvc.perform(post("/api/v1/auth/password-resets")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "token", "unknown-password-reset-token",
                                "newPassword", "another-reset-password-2026"
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("PASSWORD_RESET_TOKEN_INVALID"));

        jdbcTemplate.update("DELETE FROM registration_rate_limit_buckets");
        mockMvc.perform(post("/api/v1/auth/password-reset-requests")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("email", email))))
                .andExpect(status().isAccepted());
        assertThat(passwordResetOutboxWorker.processPending()).isEqualTo(1);
        String expiredToken = passwordResetTokenFor(email);
        jdbcTemplate.update(
                """
                UPDATE password_reset_tokens
                SET expires_at = ?
                WHERE user_id = (SELECT id FROM users WHERE email = ?)
                  AND used_at IS NULL
                  AND revoked_at IS NULL
                """,
                LocalDateTime.ofInstant(AuthMemberControlledDependencies.TEST_NOW, ZoneOffset.UTC),
                email
        );
        mockMvc.perform(post("/api/v1/auth/password-resets")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "token", expiredToken,
                                "newPassword", "another-reset-password-2026"
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("PASSWORD_RESET_TOKEN_EXPIRED"));
    }

    @Test
    void passwordResetDeliveryFailureShouldRetryThenAlertWithoutAnActiveToken(
            CapturedOutput output
    ) throws Exception {
        String email = "password.reset.failure@example.test";
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "password_reset_failure_member",
                                "email", email,
                                "password", "synthetic-password",
                                "userName", "Password Reset Failure Member"
                        ))))
                .andExpect(status().isCreated());
        mockMvc.perform(post("/api/v1/auth/password-reset-requests")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("email", email))))
                .andExpect(status().isAccepted());
        ((RecordingEmailDelivery) emailDeliveryPort).failNext(5);

        for (int attempt = 1; attempt <= 5; attempt++) {
            assertThat(passwordResetOutboxWorker.processPending()).isZero();
            if (attempt < 5) {
                jdbcTemplate.update(
                        """
                        UPDATE outbox_events
                        SET available_at = ?
                        WHERE aggregate_id = (
                            SELECT public_id FROM users WHERE email = ?
                        )
                          AND event_type = 'PASSWORD_RESET_REQUESTED'
                        """,
                        LocalDateTime.ofInstant(clock.instant(), ZoneOffset.UTC),
                        email
                );
            }
        }

        assertThat(jdbcTemplate.queryForMap(
                """
                SELECT status, attempts
                FROM outbox_events
                WHERE aggregate_id = (
                    SELECT public_id FROM users WHERE email = ?
                )
                  AND event_type = 'PASSWORD_RESET_REQUESTED'
                """,
                email
        )).containsEntry("status", "FAILED")
                .containsEntry("attempts", 5);
        assertThat(jdbcTemplate.queryForObject(
                """
                SELECT COUNT(*)
                FROM password_reset_tokens
                WHERE user_id = (SELECT id FROM users WHERE email = ?)
                  AND used_at IS NULL
                  AND revoked_at IS NULL
                """,
                Integer.class,
                email
        )).isZero();
        assertThat(output.getAll())
                .contains(
                        "Password reset delivery failed",
                        "PASSWORD_RESET_DELIVERY_FAILED",
                        "PASSWORD_RESET_DELIVERY_ALERT status=FAILED",
                        "at com.monsters"
                )
                .doesNotContain("Synthetic email delivery failure", email);
    }

    @Test
    void memberProfileAndEmailChangeShouldUseVersionedResourceWorkflow() throws Exception {
        String oldEmail = "member.data.old@example.test";
        String newEmail = "member.data.new@example.test";
        String password = "synthetic-password";
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "member_data_workflow",
                                "email", oldEmail,
                                "password", password,
                                "userName", "Old Nickname"
                        ))))
                .andExpect(status().isCreated());
        jdbcTemplate.update(
                """
                UPDATE users
                SET birthday = '1995-09-01', service_region = 'TW',
                    eligibility_status = 'ELIGIBLE_ADULT',
                    community_eligibility_status = 'ELIGIBLE',
                    nickname_disclosure_version = 'nickname-v1',
                    nickname_disclosure_confirmed_at = ?
                WHERE email = ?
                """,
                LocalDateTime.ofInstant(clock.instant(), ZoneOffset.UTC),
                oldEmail
        );
        JsonNode login = loginV1(oldEmail, password);
        String accessToken = login.path("accessToken").asText();

        JsonNode profile = responseData(mockMvc.perform(get("/api/v1/members/me")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("MEMBER_PROFILE_RETRIEVED"))
                .andExpect(jsonPath("$.data.email").value(oldEmail))
                .andExpect(jsonPath("$.data.password").doesNotExist())
                .andReturn().getResponse().getContentAsString());

        mockMvc.perform(put("/api/users/me")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "userName", "Legacy Bypass",
                                "birthday", "2020-01-01"
                        ))))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("CLIENT_UPGRADE_REQUIRED"));
        mockMvc.perform(get("/api/v1/members/me")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.birthday").value("1995-09-01"))
                .andExpect(jsonPath("$.data.publicNickname").value(profile.path("publicNickname").asText()))
                .andExpect(jsonPath("$.data.version").value(profile.path("version").asInt()));

        JsonNode renamed = responseData(mockMvc.perform(put("/api/v1/members/me/public-nickname")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "publicNickname", "New Nickname",
                                "confirmExistingCommunityUpdate", true,
                                "expectedVersion", profile.path("version").asLong()
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("PUBLIC_NICKNAME_UPDATED"))
                .andExpect(jsonPath("$.data.publicNickname").value("New Nickname"))
                .andReturn().getResponse().getContentAsString());

        JsonNode reauthentication = responseData(mockMvc.perform(
                        post("/api/v1/auth/reauthentications/password")
                                .header("Authorization", "Bearer " + accessToken)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(Map.of(
                                        "password", password,
                                        "purpose", "EMAIL_CHANGE"
                                ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.purpose").value("EMAIL_CHANGE"))
                .andReturn().getResponse().getContentAsString());
        mockMvc.perform(post("/api/v1/members/me/email-change-requests")
                        .header("Authorization", "Bearer " + accessToken)
                        .header(
                                "X-Reauthentication-Credential",
                                reauthentication.path("credential").asText()
                        )
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "newEmail", newEmail,
                                "expectedVersion", renamed.path("version").asLong()
                        ))))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.code").value("EMAIL_CHANGE_VERIFICATION_PENDING"));

        assertThat(memberEmailChangeOutboxWorker.processPending()).isEqualTo(1);
        String token = emailChangeTokenFor(newEmail);
        mockMvc.perform(post("/api/v1/auth/email-changes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("token", token))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("EMAIL_CHANGE_COMPLETED"));
        assertThat(memberEmailChangeOutboxWorker.processPending()).isEqualTo(2);

        mockMvc.perform(get("/api/v1/members/me")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.email").value(newEmail))
                .andExpect(jsonPath("$.data.publicNickname").value("New Nickname"));
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM users WHERE email = ?",
                Integer.class,
                oldEmail
        )).isZero();
        assertThat(jdbcTemplate.queryForList(
                """
                SELECT payload
                FROM outbox_events
                WHERE aggregate_type = 'MEMBER_EMAIL_CHANGE'
                  AND aggregate_id = (
                      SELECT public_id
                      FROM member_email_change_requests
                      WHERE new_email = ?
                  )
                """,
                newEmail
        )).allSatisfy(row -> assertThat(row.get("payload").toString())
                .doesNotContain(oldEmail, newEmail, token));
    }

    @Test
    void selfDeactivatedMemberShouldRestoreOnlyWithVersionBoundContinuation() throws Exception {
        String email = "member.restore@example.test";
        String password = "synthetic-password";
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "account", "member_restore_workflow",
                                "email", email,
                                "password", password,
                                "userName", "Restore Member"
                        ))))
                .andExpect(status().isCreated());
        JsonNode login = loginV1(email, password);
        String accessToken = login.path("accessToken").asText();
        JsonNode profile = responseData(mockMvc.perform(get("/api/v1/members/me")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString());

        JsonNode deactivated = responseData(mockMvc.perform(post("/api/v1/members/me/deactivations")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "confirmed", true,
                                "expectedVersion", profile.path("version").asLong()
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("MEMBER_DEACTIVATED"))
                .andExpect(jsonPath("$.data.memberState").value("USER_DEACTIVATED"))
                .andReturn().getResponse().getContentAsString());
        mockMvc.perform(get("/api/v1/members/me")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isUnauthorized());

        JsonNode continuation = responseData(mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", email,
                                "password", password
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("AUTH_CONTINUATION_REQUIRED"))
                .andExpect(jsonPath("$.data.nextAction").value("REACTIVATE_ACCOUNT"))
                .andExpect(jsonPath("$.data.accessToken").doesNotExist())
                .andReturn().getResponse().getContentAsString());

        mockMvc.perform(post("/api/v1/auth/member-restorations")
                        .header(
                                "Authorization",
                                "Continuation " + continuation.path("continuationCredential").asText()
                        )
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "confirmed", true
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("MEMBER_RESTORED"))
                .andExpect(jsonPath("$.data.memberState").value("ACTIVE"))
                .andExpect(jsonPath("$.data.nextAction").value("SIGN_IN"));
        loginV1(email, password);
    }

    private String verificationTokenFor(String recipient) {
        String verificationUrl = ((RecordingEmailDelivery) emailDeliveryPort)
                .requests()
                .stream()
                .filter(request -> request.recipient().equals(recipient))
                .reduce((first, second) -> second)
                .orElseThrow()
                .variables()
                .get("verificationUrl");
        return URLDecoder.decode(
                URI.create(verificationUrl).getRawQuery().substring("token=".length()),
                StandardCharsets.UTF_8
        );
    }

    private String passwordResetTokenFor(String recipient) {
        String resetUrl = ((RecordingEmailDelivery) emailDeliveryPort)
                .requests()
                .stream()
                .filter(request -> request.recipient().equals(recipient))
                .filter(request -> request.templateId().equals("password-reset"))
                .reduce((first, second) -> second)
                .orElseThrow()
                .variables()
                .get("resetUrl");
        return URLDecoder.decode(
                URI.create(resetUrl).getRawQuery().substring("token=".length()),
                StandardCharsets.UTF_8
        );
    }

    private String emailChangeTokenFor(String recipient) {
        String verificationUrl = ((RecordingEmailDelivery) emailDeliveryPort)
                .requests()
                .stream()
                .filter(request -> request.recipient().equals(recipient))
                .filter(request -> request.templateId().equals("email-change-verification"))
                .reduce((first, second) -> second)
                .orElseThrow()
                .variables()
                .get("verificationUrl");
        return URLDecoder.decode(
                URI.create(verificationUrl).getRawQuery().substring("token=".length()),
                StandardCharsets.UTF_8
        );
    }

    private JsonNode refresh(String credential, int expectedStatus, String expectedCode)
            throws Exception {
        String body = mockMvc.perform(post("/api/v1/auth/session-refreshes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "refreshCredential", credential
                        ))))
                .andExpect(status().is(expectedStatus))
                .andExpect(jsonPath("$.code").value(expectedCode))
                .andReturn().getResponse().getContentAsString();
        return responseData(body);
    }

    private JsonNode responseData(String responseBody) throws Exception {
        return objectMapper.readTree(responseBody).path("data");
    }

    private JsonNode loginV1(String email, String password) throws Exception {
        return responseData(mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", email,
                                "password", password
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("AUTHENTICATED"))
                .andReturn().getResponse().getContentAsString());
    }

    private String accessSessionId(String accessToken) throws Exception {
        return objectMapper.readTree(Base64.getUrlDecoder().decode(accessToken.split("\\.")[1]))
                .path("sid")
                .asText();
    }

    private void registerAndDeliverVerification(String email) throws Exception {
        registerWithoutDelivery(email);
        assertThat(emailVerificationOutboxWorker.processPending()).isEqualTo(1);
    }

    private void registerWithoutDelivery(String email) throws Exception {
        registerWithoutDelivery(email, "synthetic-password");
    }

    private void registerWithoutDelivery(String email, String password) throws Exception {
        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "email", email,
                                "password", password,
                                "acceptedTermsVersion", "terms-synthetic-v1",
                                "acceptedPrivacyVersion", "privacy-synthetic-v1"
                        ))))
                .andExpect(status().isAccepted());
    }

    private String passwordHashFor(String email) {
        return jdbcTemplate.queryForObject(
                """
                SELECT password_hash
                FROM user_credentials
                WHERE user_id = (SELECT id FROM users WHERE email = ?)
                """,
                String.class,
                email
        );
    }

    private String boundaryPassword(int codePointCount) {
        String suffix = "-Boundary9!";
        return "x".repeat(codePointCount - suffix.codePointCount(0, suffix.length())) + suffix;
    }

}
