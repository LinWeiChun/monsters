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
                "tokenType",
                "expiresIn",
                "user"
        );
        assertThat(mapAt(authenticated, "properties")).containsKey("refreshToken");

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
                "/api/v1/auth/login",
                "post",
                "responses",
                "200"
        );
        assertThat(successResponse).containsKey("content");

        Map<String, Object> loginRequest = mapAt(
                document,
                "components",
                "schemas",
                "VerifiedEmailLoginRequest"
        );
        assertThat(loginRequest).containsEntry("additionalProperties", false);
        assertThat(listAt(loginRequest, "required"))
                .containsExactlyInAnyOrder("email", "password");
        assertThat(mapAt(loginRequest, "properties", "email"))
                .containsEntry("format", "email")
                .containsEntry("maxLength", 255);

        Map<String, Object> authenticatedMember = mapAt(
                document,
                "components",
                "schemas",
                "AuthenticatedMember"
        );
        assertThat(mapAt(authenticatedMember, "properties").keySet())
                .contains("publicId", "email", "userName")
                .doesNotContain("account", "userId");
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
        assertThat(mapAt(registrationRequest, "properties", "password"))
                .containsEntry("minLength", 15)
                .containsEntry("maxLength", 128)
                .containsEntry("writeOnly", true);
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

    @Test
    void sessionContractShouldDefineOpaqueRotationAndStableErrors() throws IOException {
        Map<String, Object> document;
        try (var reader = Files.newBufferedReader(CONTRACT_PATH)) {
            document = new Yaml().load(reader);
        }

        Map<String, Object> refreshOperation = mapAt(
                document,
                "paths",
                "/api/v1/auth/session-refreshes",
                "post"
        );
        assertThat(mapAt(refreshOperation, "responses"))
                .containsKeys("200", "400", "401", "403");
        assertThat(mapAt(refreshOperation, "requestBody")).containsEntry("required", false);
        assertThat(listAt(refreshOperation, "parameters")).hasSize(2);
        Map<String, Object> request = mapAt(
                document,
                "components",
                "schemas",
                "SessionRefreshRequest"
        );
        assertThat(request).containsEntry("additionalProperties", false);
        assertThat(listAt(request, "required")).containsExactly("refreshCredential");
        assertThat(mapAt(request, "properties", "refreshCredential"))
                .containsEntry("writeOnly", true)
                .containsEntry("minLength", 1);
        assertThat(mapAt(
                document,
                "components",
                "parameters",
                "SessionTransportHeader",
                "schema"
        )).containsEntry("const", "COOKIE");
        assertThat(mapAt(
                document,
                "components",
                "parameters",
                "CsrfProtectionHeader",
                "schema"
        )).containsEntry("const", "1");

        Map<String, Object> errorCode = mapAt(
                document,
                "components",
                "schemas",
                "AuthSessionErrorCode"
        );
        assertThat(listAt(errorCode, "enum")).containsExactlyInAnyOrder(
                "AUTH_SESSION_INVALID",
                "AUTH_REFRESH_REUSE_DETECTED"
        );
    }

    @Test
    void passwordResetContractShouldBeUniversalTokenlessAndSingleUse() throws IOException {
        Map<String, Object> document;
        try (var reader = Files.newBufferedReader(CONTRACT_PATH)) {
            document = new Yaml().load(reader);
        }

        Map<String, Object> paths = mapAt(document, "paths");
        assertThat(paths.keySet()).contains(
                "/api/v1/auth/password-reset-requests",
                "/api/v1/auth/password-resets"
        );
        assertThat(mapAt(
                document,
                "paths",
                "/api/v1/auth/password-reset-requests",
                "post",
                "responses"
        )).containsKeys("202", "400", "429", "503");
        Map<String, Object> acceptedEnvelope = mapAt(
                document,
                "components",
                "schemas",
                "PasswordResetRequestAcceptedEnvelope"
        );
        assertThat(acceptedEnvelope.toString()).doesNotContain("token", "resetToken");

        Map<String, Object> completionRequest = mapAt(
                document,
                "components",
                "schemas",
                "PasswordResetCompletionRequest"
        );
        assertThat(completionRequest).containsEntry("additionalProperties", false);
        assertThat(listAt(completionRequest, "required"))
                .containsExactlyInAnyOrder("token", "newPassword");
        assertThat(mapAt(completionRequest, "properties", "token"))
                .containsEntry("writeOnly", true)
                .containsEntry("maxLength", 512);
        assertThat(mapAt(completionRequest, "properties", "newPassword"))
                .containsEntry("minLength", 15)
                .containsEntry("maxLength", 128)
                .containsEntry("writeOnly", true);
        assertThat(listAt(mapAt(
                document,
                "components",
                "schemas",
                "PasswordResetTokenErrorCode"
        ), "enum")).containsExactlyInAnyOrder(
                "PASSWORD_RESET_TOKEN_INVALID",
                "PASSWORD_RESET_TOKEN_USED",
                "PASSWORD_RESET_TOKEN_EXPIRED"
        );
    }

    @Test
    void googleContractShouldRequireExplicitLinkingAndPurposeBoundReauthentication()
            throws IOException {
        Map<String, Object> document;
        try (var reader = Files.newBufferedReader(CONTRACT_PATH)) {
            document = new Yaml().load(reader);
        }

        Map<String, Object> paths = mapAt(document, "paths");
        assertThat(paths.keySet()).contains(
                "/api/v1/auth/google-logins",
                "/api/v1/auth/google-account-links"
        );
        Map<String, Object> linkRequest = mapAt(
                document,
                "components",
                "schemas",
                "GoogleAccountLinkRequest"
        );
        assertThat(listAt(linkRequest, "required"))
                .containsExactlyInAnyOrder("idToken", "confirmed");
        assertThat(mapAt(linkRequest, "properties", "confirmed"))
                .containsEntry("const", true);
        Map<String, Object> reauthenticationRequest = mapAt(
                document,
                "components",
                "schemas",
                "SessionReauthenticationRequest"
        );
        assertThat(listAt(mapAt(reauthenticationRequest, "properties", "purpose"), "enum"))
                .containsExactlyInAnyOrder(
                        "SESSION_MANAGEMENT",
                        "LOGIN_METHOD_LINK",
                        "EMAIL_CHANGE",
                        "BIRTHDAY_CORRECTION"
                );
        assertThat(mapAt(
                document,
                "components",
                "schemas",
                "GoogleAccountLinkRequiredData",
                "properties",
                "nextAction"
        )).containsEntry("const", "LINK_GOOGLE_ACCOUNT");
    }

    @Test
    void memberDataModificationContractShouldExposeResourceWorkflows() throws IOException {
        Map<String, Object> document;
        try (var reader = Files.newBufferedReader(CONTRACT_PATH)) {
            document = new Yaml().load(reader);
        }

        Map<String, Object> paths = mapAt(document, "paths");
        assertThat(paths.keySet()).contains(
                "/api/v1/members/me",
                "/api/v1/members/me/public-nickname",
                "/api/v1/auth/reauthentications/password",
                "/api/v1/auth/reauthentications/google",
                "/api/v1/members/me/email-change-requests",
                "/api/v1/auth/email-changes",
                "/api/v1/members/me/birthday-correction-requests",
                "/api/v1/members/me/deactivations",
                "/api/v1/auth/member-restorations"
        );

        Map<String, Object> nicknameRequest = mapAt(
                document,
                "components",
                "schemas",
                "PublicNicknameUpdateRequest"
        );
        assertThat(listAt(nicknameRequest, "required")).containsExactlyInAnyOrder(
                "publicNickname",
                "confirmExistingCommunityUpdate",
                "expectedVersion"
        );
        assertThat(mapAt(nicknameRequest, "properties", "confirmExistingCommunityUpdate"))
                .containsEntry("const", true);

        Map<String, Object> googleReauthentication = mapAt(
                document,
                "components",
                "schemas",
                "GoogleReauthenticationRequest"
        );
        assertThat(listAt(googleReauthentication, "required"))
                .containsExactlyInAnyOrder("idToken", "purpose");
        assertThat(listAt(mapAt(googleReauthentication, "properties", "purpose"), "enum"))
                .containsExactlyInAnyOrder("EMAIL_CHANGE", "BIRTHDAY_CORRECTION");

        assertThat(listAt(mapAt(
                document,
                "components",
                "schemas",
                "ContinuationNextAction"
        ), "enum")).contains("REVIEW_BIRTHDAY_CORRECTION", "REACTIVATE_ACCOUNT");

        Map<String, Object> restorationRequest = mapAt(
                document,
                "components",
                "schemas",
                "MemberRestorationRequest"
        );
        assertThat(listAt(restorationRequest, "required")).containsExactly("confirmed");
        assertThat(mapAt(restorationRequest, "properties")).containsOnlyKeys("confirmed");
        assertThat(restorationRequest).containsEntry("additionalProperties", false);

        assertThat(mapAt(
                document,
                "components",
                "schemas",
                "PendingMemberWorkflow",
                "properties"
        )).containsKeys("requestId", "status", "target");
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
