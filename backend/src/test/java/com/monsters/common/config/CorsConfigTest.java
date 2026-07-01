package com.monsters.common.config;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.options;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.monsters.common.dto.ApiResponse;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@WebMvcTest(CorsConfigTest.TestController.class)
@Import(CorsConfig.class)
@EnableConfigurationProperties(CorsProperties.class)
@TestPropertySource(properties = {
        "app.cors.allowed-origin-patterns=http://localhost:*,http://127.0.0.1:*",
        "app.cors.allowed-methods=GET,POST,PUT,PATCH,DELETE,OPTIONS",
        "app.cors.allowed-headers=Authorization,Content-Type",
        "app.cors.exposed-headers=Authorization",
        "app.cors.allow-credentials=true",
        "app.cors.max-age=3600"
})
class CorsConfigTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private CorsProperties corsProperties;

    @Test
    void corsPropertiesShouldBindFromConfiguration() {
        assertThat(corsProperties.allowedOriginPatterns())
                .containsExactly("http://localhost:*", "http://127.0.0.1:*");
        assertThat(corsProperties.allowedMethods())
                .containsExactly("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS");
        assertThat(corsProperties.allowedHeaders()).containsExactly("Authorization", "Content-Type");
        assertThat(corsProperties.exposedHeaders()).containsExactly("Authorization");
        assertThat(corsProperties.allowCredentials()).isTrue();
        assertThat(corsProperties.maxAge()).isEqualTo(3600);
    }

    @Test
    void allowedOriginShouldPassPreflightRequest() throws Exception {
        mockMvc.perform(options("/api/test-cors")
                        .header(HttpHeaders.ORIGIN, "http://localhost:5173")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_METHOD, HttpMethod.GET.name())
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_HEADERS, HttpHeaders.AUTHORIZATION))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://localhost:5173"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_CREDENTIALS, "true"));
    }

    @Test
    void disallowedOriginShouldFailPreflightRequest() throws Exception {
        mockMvc.perform(options("/api/test-cors")
                        .header(HttpHeaders.ORIGIN, "https://example.com")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_METHOD, HttpMethod.GET.name()))
                .andExpect(status().isForbidden());
    }

    @RestController
    @RequestMapping("/api/test-cors")
    static class TestController {

        @GetMapping
        ApiResponse<Map<String, String>> get() {
            return ApiResponse.success(Map.of("status", "ok"));
        }
    }
}
