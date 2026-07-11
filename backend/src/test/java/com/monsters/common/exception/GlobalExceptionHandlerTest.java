package com.monsters.common.exception;

import static org.assertj.core.api.Assertions.assertThat;

import com.monsters.common.dto.ApiResponse;
import jakarta.validation.ConstraintViolationException;
import java.util.Collections;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.mock.http.MockHttpInputMessage;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.multipart.MultipartException;
import org.springframework.web.multipart.support.MissingServletRequestPartException;

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

    @Test
    void unreadableRequestShouldReturnBadRequest() {
        ResponseEntity<ApiResponse<Void>> response = handler.handleHttpMessageNotReadableException(
                new HttpMessageNotReadableException(
                        "invalid json",
                        new MockHttpInputMessage(new byte[0])
                )
        );

        assertErrorResponse(response, HttpStatus.BAD_REQUEST, "Request body is not readable");
    }

    @Test
    void oversizedUploadShouldReturnPayloadTooLarge() {
        ResponseEntity<ApiResponse<Void>> response = handler.handleMaxUploadSizeExceededException(
                new MaxUploadSizeExceededException(50)
        );

        assertErrorResponse(response, HttpStatus.PAYLOAD_TOO_LARGE, "Uploaded file is too large");
    }

    @Test
    void invalidMultipartShouldReturnBadRequest() {
        ResponseEntity<ApiResponse<Void>> response = handler.handleMultipartException(
                new MultipartException("invalid multipart")
        );

        assertErrorResponse(response, HttpStatus.BAD_REQUEST, "Multipart request is invalid");
    }

    @Test
    void missingMultipartPartShouldReturnBadRequest() {
        ResponseEntity<ApiResponse<Void>> response = handler.handleMissingServletRequestPartException(
                new MissingServletRequestPartException("request")
        );

        assertErrorResponse(
                response,
                HttpStatus.BAD_REQUEST,
                "Required multipart request part is missing"
        );
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
