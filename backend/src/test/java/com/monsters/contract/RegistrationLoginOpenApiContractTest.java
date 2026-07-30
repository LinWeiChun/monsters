package com.monsters.contract;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.yaml.snakeyaml.Yaml;

class RegistrationLoginOpenApiContractTest {

    private static final Path CONTRACT_PATH =
            Path.of("..", "docs", "openapi", "registration-login.yaml");

    @Test
    void envelopeSchemaShouldBeValidAndContainRequiredContractFields() throws IOException {
        Map<String, Object> document;
        try (var reader = Files.newBufferedReader(CONTRACT_PATH)) {
            document = new Yaml().load(reader);
        }

        assertThat(document.get("openapi")).isEqualTo("3.1.0");
        Map<String, Object> envelope = mapAt(document, "components", "schemas", "ApiEnvelope");
        List<String> required = listAt(envelope, "required");
        Map<String, Object> properties = mapAt(envelope, "properties");

        assertThat(required).contains(
                "success",
                "code",
                "message",
                "fieldErrors",
                "requestId"
        );
        assertThat(properties.keySet()).containsAll(required);
        assertThat(mapAt(properties, "fieldErrors"))
                .containsEntry("type", "object")
                .containsKey("additionalProperties");
        assertThat(mapAt(properties, "requestId"))
                .containsEntry("type", "string")
                .containsEntry("format", "uuid");
    }

    @Test
    void loginContractShouldSeparateAuthenticatedAndContinuationResponses() throws IOException {
        Map<String, Object> document;
        try (var reader = Files.newBufferedReader(CONTRACT_PATH)) {
            document = new Yaml().load(reader);
        }

        Map<String, Object> authenticated = mapAt(
                document,
                "components",
                "schemas",
                "AuthenticatedLoginData"
        );
        assertThat(listAt(authenticated, "required")).contains(
                "accessToken",
                "refreshToken",
                "tokenType",
                "expiresIn",
                "user"
        );

        Map<String, Object> continuation = mapAt(
                document,
                "components",
                "schemas",
                "ContinuationLoginData"
        );
        assertThat(listAt(continuation, "required")).containsExactlyInAnyOrder(
                "nextAction",
                "continuationCredential",
                "expiresIn"
        );
        assertThat(mapAt(continuation, "properties").keySet())
                .doesNotContain("accessToken", "refreshToken");

        Map<String, Object> successResponse = mapAt(
                document,
                "paths",
                "/api/auth/login",
                "post",
                "responses",
                "200"
        );
        assertThat(successResponse).containsKey("content");
    }

    @Test
    void registrationContractShouldDefinePolicyRegisterResendAndVerification() throws IOException {
        Map<String, Object> document;
        try (var reader = Files.newBufferedReader(CONTRACT_PATH)) {
            document = new Yaml().load(reader);
        }

        Map<String, Object> paths = mapAt(document, "paths");
        assertThat(paths.keySet()).contains(
                "/api/v1/auth/registration-policy",
                "/api/v1/auth/register",
                "/api/v1/auth/email-verification-requests",
                "/api/v1/auth/email-verifications"
        );
        Map<String, Object> registrationRequest = mapAt(
                document,
                "components",
                "schemas",
                "RegistrationRequest"
        );
        assertThat(listAt(registrationRequest, "required")).containsExactlyInAnyOrder(
                "email",
                "password",
                "acceptedTermsVersion",
                "acceptedPrivacyVersion"
        );
        assertThat(mapAt(registrationRequest, "properties").keySet())
                .doesNotContain("account", "userName", "birthday", "guardianEmail");
        assertThat(registrationRequest).containsEntry("additionalProperties", false);
        assertThat(mapAt(
                document,
                "paths",
                "/api/v1/auth/register",
                "post",
                "responses"
        )).containsKeys("202", "400", "409", "429", "503");
        assertThat(mapAt(
                document,
                "paths",
                "/api/v1/auth/email-verifications",
                "post",
                "responses"
        )).containsKeys("200", "400");
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> mapAt(Map<String, Object> source, String... path) {
        Object current = source;
        for (String key : path) {
            assertThat(current).as("OpenAPI node before %s", key).isInstanceOf(Map.class);
            current = ((Map<String, Object>) current).get(key);
            assertThat(current).as("OpenAPI node %s", key).isNotNull();
        }
        assertThat(current).isInstanceOf(Map.class);
        return (Map<String, Object>) current;
    }

    @SuppressWarnings("unchecked")
    private List<String> listAt(Map<String, Object> source, String key) {
        Object value = source.get(key);
        assertThat(value).isInstanceOf(List.class);
        return (List<String>) value;
    }
}
