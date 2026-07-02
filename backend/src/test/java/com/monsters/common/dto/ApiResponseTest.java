package com.monsters.common.dto;

import static org.assertj.core.api.Assertions.assertThat;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.Map;
import org.junit.jupiter.api.Test;

class ApiResponseTest {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Test
    void successShouldUseDefaultMessage() {
        ApiResponse<Map<String, String>> response = ApiResponse.success(Map.of("name", "monsters"));

        assertThat(response.success()).isTrue();
        assertThat(response.message()).isEqualTo("操作成功");
        assertThat(response.data()).containsEntry("name", "monsters");
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
        ApiResponse<Object> response = ApiResponse.failure("錯誤訊息");

        assertThat(response.success()).isFalse();
        assertThat(response.message()).isEqualTo("錯誤訊息");
        assertThat(response.data()).isNull();
    }

    @Test
    void responseShouldSerializeWithApiSpecFields() throws JsonProcessingException {
        ApiResponse<Map<String, String>> response = ApiResponse.success(Map.of("name", "monsters"));

        String json = objectMapper.writeValueAsString(response);

        assertThat(json).contains("\"success\":true");
        assertThat(json).contains("\"message\":\"操作成功\"");
        assertThat(json).contains("\"data\":{\"name\":\"monsters\"}");
    }
}
