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
