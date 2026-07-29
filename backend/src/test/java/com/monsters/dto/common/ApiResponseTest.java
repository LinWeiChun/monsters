package com.monsters.dto.common;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class ApiResponseTest {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Test
    void successShouldUseDefaultMessage() {
        ApiResponse<Map<String, String>> response = ApiResponse.success(Map.of("name", "monsters"));

        assertThat(response.success()).isTrue();
        assertThat(response.code()).isEqualTo("SUCCESS");
        assertThat(response.message()).isEqualTo("操作成功");
        assertThat(response.data()).containsEntry("name", "monsters");
        assertThat(response.fieldErrors()).isEmpty();
        assertThatCode(() -> UUID.fromString(response.requestId())).doesNotThrowAnyException();
    }

    @Test
    void successShouldUseCustomMessage() {
        ApiResponse<String> response = ApiResponse.success("建立成功", "ok");

        assertThat(response.success()).isTrue();
        assertThat(response.message()).isEqualTo("建立成功");
        assertThat(response.data()).isEqualTo("ok");
    }

    @Test
    void failureShouldUseNullData() {
        ApiResponse<Object> response = ApiResponse.failure(
                "VALIDATION_FAILED",
                "錯誤訊息",
                Map.of("email", "格式錯誤")
        );

        assertThat(response.success()).isFalse();
        assertThat(response.code()).isEqualTo("VALIDATION_FAILED");
        assertThat(response.message()).isEqualTo("錯誤訊息");
        assertThat(response.data()).isNull();
        assertThat(response.fieldErrors()).containsExactly(Map.entry("email", "格式錯誤"));
        assertThatCode(() -> UUID.fromString(response.requestId())).doesNotThrowAnyException();
    }

    @Test
    void responseShouldSerializeWithApiSpecFields() throws JsonProcessingException {
        ApiResponse<Map<String, String>> response = ApiResponse.success(Map.of("name", "monsters"));

        String json = objectMapper.writeValueAsString(response);

        assertThat(json).contains("\"success\":true");
        assertThat(json).contains("\"code\":\"SUCCESS\"");
        assertThat(json).contains("\"message\":\"操作成功\"");
        assertThat(json).contains("\"data\":{\"name\":\"monsters\"}");
        assertThat(json).contains("\"fieldErrors\":{}");
        assertThat(json).contains("\"requestId\":");
    }
}
