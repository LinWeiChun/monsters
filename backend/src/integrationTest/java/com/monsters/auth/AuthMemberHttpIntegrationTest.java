package com.monsters.auth;

import static org.assertj.core.api.Assertions.assertThat;
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
import com.monsters.security.common.GoogleIdTokenVerifier;
import com.monsters.security.common.GoogleUserInfo;
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
        registry.add("spring.jpa.hibernate.ddl-auto", () -> "create-drop");
        registry.add("app.security.jwt.secret", () -> "synthetic-jwt-secret-for-integration-tests");
        registry.add("app.security.google.client-ids", () -> "synthetic-google-client");
    }

    private final MockMvc mockMvc;
    private final ObjectMapper objectMapper;
    private final Clock clock;
    private final GoogleIdTokenVerifier googleIdTokenVerifier;
    private final EmailDeliveryPort emailDeliveryPort;
    private final AsyncJobDispatcher asyncJobDispatcher;

    @Autowired
    AuthMemberHttpIntegrationTest(
            MockMvc mockMvc,
            ObjectMapper objectMapper,
            Clock clock,
            GoogleIdTokenVerifier googleIdTokenVerifier,
            EmailDeliveryPort emailDeliveryPort,
            AsyncJobDispatcher asyncJobDispatcher
    ) {
        this.mockMvc = mockMvc;
        this.objectMapper = objectMapper;
        this.clock = clock;
        this.googleIdTokenVerifier = googleIdTokenVerifier;
        this.emailDeliveryPort = emailDeliveryPort;
        this.asyncJobDispatcher = asyncJobDispatcher;
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

}
