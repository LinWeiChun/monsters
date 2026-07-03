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
                handler.handleBusinessException(new BusinessException("Business error"));

        assertErrorResponse(response, HttpStatus.BAD_REQUEST, "Business error");
    }

    @Test
    void resourceNotFoundExceptionShouldReturnNotFound() {
        ResponseEntity<ApiResponse<Void>> response =
                handler.handleBusinessException(new ResourceNotFoundException("Resource not found"));

        assertErrorResponse(response, HttpStatus.NOT_FOUND, "Resource not found");
    }

    @Test
    void conflictExceptionShouldReturnConflict() {
        ResponseEntity<ApiResponse<Void>> response =
                handler.handleBusinessException(new ConflictException("Resource conflict"));

        assertErrorResponse(response, HttpStatus.CONFLICT, "Resource conflict");
    }

    @Test
    void unauthorizedExceptionShouldReturnUnauthorized() {
        ResponseEntity<ApiResponse<Void>> response =
                handler.handleBusinessException(new UnauthorizedException("Unauthorized"));

        assertErrorResponse(response, HttpStatus.UNAUTHORIZED, "Unauthorized");
    }

    @Test
    void forbiddenExceptionShouldReturnForbidden() {
        ResponseEntity<ApiResponse<Void>> response =
                handler.handleBusinessException(new ForbiddenException("Forbidden"));

        assertErrorResponse(response, HttpStatus.FORBIDDEN, "Forbidden");
    }

    @Test
    void constraintViolationExceptionShouldReturnBadRequest() {
        ConstraintViolationException exception = new ConstraintViolationException(Collections.emptySet());

        ResponseEntity<ApiResponse<Void>> response = handler.handleConstraintViolationException(exception);

        assertErrorResponse(response, HttpStatus.BAD_REQUEST, "Request validation failed");
    }

    @Test
    void unhandledExceptionShouldReturnInternalServerError() {
        ResponseEntity<ApiResponse<Void>> response = handler.handleException(new RuntimeException("hidden"));

        assertErrorResponse(response, HttpStatus.INTERNAL_SERVER_ERROR, "Internal server error");
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
