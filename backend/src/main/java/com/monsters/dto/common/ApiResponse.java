package com.monsters.dto.common;

import java.util.Map;
import java.util.UUID;

public record ApiResponse<T>(
        boolean success,
        String code,
        String message,
        T data,
        Map<String, String> fieldErrors,
        String requestId
) {

    private static final String DEFAULT_SUCCESS_MESSAGE = "操作成功";
    private static final String DEFAULT_SUCCESS_CODE = "SUCCESS";

    public static <T> ApiResponse<T> success(T data) {
        return success(DEFAULT_SUCCESS_CODE, DEFAULT_SUCCESS_MESSAGE, data);
    }

    public static <T> ApiResponse<T> success(String message, T data) {
        return success(DEFAULT_SUCCESS_CODE, message, data);
    }

    public static <T> ApiResponse<T> success(String code, String message, T data) {
        return new ApiResponse<>(true, code, message, data, Map.of(), newRequestId());
    }

    public static <T> ApiResponse<T> failure(String message) {
        return failure("REQUEST_FAILED", message, Map.of());
    }

    public static <T> ApiResponse<T> failure(String code, String message) {
        return failure(code, message, Map.of());
    }

    public static <T> ApiResponse<T> failure(
            String code,
            String message,
            Map<String, String> fieldErrors
    ) {
        return new ApiResponse<>(false, code, message, null, Map.copyOf(fieldErrors), newRequestId());
    }

    private static String newRequestId() {
        return UUID.randomUUID().toString();
    }
}
