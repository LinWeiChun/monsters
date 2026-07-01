package com.monsters.common.exception;

import static org.assertj.core.api.Assertions.assertThat;

import com.monsters.common.dto.ApiResponse;
import jakarta.validation.ConstraintViolationException;
import java.util.Collections;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

class GlobalExceptionHandlerTest {

    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

    @Test
    void businessExceptionShouldReturnBadRequest() {
        ResponseEntity<ApiResponse<Void>> response =
                handler.handleBusinessException(new BusinessException("商業邏輯錯誤"));

        assertErrorResponse(response, HttpStatus.BAD_REQUEST, "商業邏輯錯誤");
    }

    @Test
    void resourceNotFoundExceptionShouldReturnNotFound() {
        ResponseEntity<ApiResponse<Void>> response =
                handler.handleBusinessException(new ResourceNotFoundException("資料不存在"));

        assertErrorResponse(response, HttpStatus.NOT_FOUND, "資料不存在");
    }

    @Test
    void conflictExceptionShouldReturnConflict() {
        ResponseEntity<ApiResponse<Void>> response =
                handler.handleBusinessException(new ConflictException("資料已存在"));

        assertErrorResponse(response, HttpStatus.CONFLICT, "資料已存在");
    }

    @Test
    void unauthorizedExceptionShouldReturnUnauthorized() {
        ResponseEntity<ApiResponse<Void>> response =
                handler.handleBusinessException(new UnauthorizedException("尚未登入"));

        assertErrorResponse(response, HttpStatus.UNAUTHORIZED, "尚未登入");
    }

    @Test
    void forbiddenExceptionShouldReturnForbidden() {
        ResponseEntity<ApiResponse<Void>> response =
                handler.handleBusinessException(new ForbiddenException("權限不足"));

        assertErrorResponse(response, HttpStatus.FORBIDDEN, "權限不足");
    }

    @Test
    void constraintViolationExceptionShouldReturnBadRequest() {
        ConstraintViolationException exception = new ConstraintViolationException(Collections.emptySet());

        ResponseEntity<ApiResponse<Void>> response = handler.handleConstraintViolationException(exception);

        assertErrorResponse(response, HttpStatus.BAD_REQUEST, "請確認輸入資料");
    }

    @Test
    void unhandledExceptionShouldReturnInternalServerError() {
        ResponseEntity<ApiResponse<Void>> response = handler.handleException(new RuntimeException("hidden"));

        assertErrorResponse(response, HttpStatus.INTERNAL_SERVER_ERROR, "系統發生錯誤");
    }

    private void assertErrorResponse(
            ResponseEntity<ApiResponse<Void>> response,
            HttpStatus expectedStatus,
            String expectedMessage
    ) {
        assertThat(response.getStatusCode()).isEqualTo(expectedStatus);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().success()).isFalse();
        assertThat(response.getBody().message()).isEqualTo(expectedMessage);
        assertThat(response.getBody().data()).isNull();
    }
}
