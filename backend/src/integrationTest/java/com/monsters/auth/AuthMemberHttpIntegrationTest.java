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
import com.monsters.service.registration.EmailVerificationOutboxWorker;
import com.monsters.service.registration.UnverifiedMemberCleanupService;
import com.monsters.support.AuthMemberControlledDependencies;
import com.monsters.support.AuthMemberControlledDependencies.RecordingAsyncJobDispatcher;
import com.monsters.support.AuthMemberControlledDependencies.RecordingEmailDelivery;
import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
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
                WHERE event_type = 'EMAIL_VERIFICATION_REQUESTED'
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
