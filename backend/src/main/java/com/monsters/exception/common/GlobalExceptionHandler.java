package com.monsters.exception.common;

import com.monsters.dto.common.ApiResponse;
import com.monsters.dto.common.RateLimitResponse;
import com.monsters.security.password.PasswordPolicyException;
import jakarta.validation.ConstraintViolationException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Objects;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.support.DefaultMessageSourceResolvable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.multipart.MultipartException;
import org.springframework.web.multipart.support.MissingServletRequestPartException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import com.monsters.service.eligibility.EligibilityValidationException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);
    private static final String DEFAULT_VALIDATION_MESSAGE = "Request validation failed";
    private static final String DEFAULT_ERROR_MESSAGE = "Internal server error";

    @ExceptionHandler(PasswordPolicyException.class)
    public ResponseEntity<ApiResponse<Void>> handlePasswordPolicyException(
            PasswordPolicyException exception
    ) {
        log.warn("Password policy validation failed: reason={}", exception.getFieldErrorCode());
        return buildErrorResponse(
                HttpStatus.BAD_REQUEST,
                "VALIDATION_FAILED",
                exception.getMessage(),
                Map.of("password", exception.getFieldErrorCode())
        );
    }

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiResponse<Void>> handleBusinessException(BusinessException exception) {
        log.warn("Business request rejected: status={}, type={}",
                exception.getStatus().value(), exception.getClass().getSimpleName());
        return buildErrorResponse(
                exception.getStatus(),
                exception.getCode() == null ? errorCode(exception.getStatus()) : exception.getCode(),
                exception.getMessage(),
                Map.of()
        );
    }

    @ExceptionHandler(RateLimitException.class)
    public ResponseEntity<ApiResponse<RateLimitResponse>> handleRateLimitException(
            RateLimitException exception
    ) {
        log.warn("Registration request rate limited");
        return ResponseEntity
                .status(HttpStatus.TOO_MANY_REQUESTS)
                .header("Retry-After", Long.toString(exception.getRetryAfter()))
                .body(ApiResponse.failure(
                        exception.getCode(),
                        exception.getMessage(),
                        Map.of(),
                        new RateLimitResponse(exception.getRetryAfter())
                ));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Void>> handleMethodArgumentNotValidException(
            MethodArgumentNotValidException exception
    ) {
        String message = exception.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(DefaultMessageSourceResolvable::getDefaultMessage)
                .filter(Objects::nonNull)
                .findFirst()
                .orElse(DEFAULT_VALIDATION_MESSAGE);

        Map<String, String> fieldErrors = exception.getBindingResult()
                .getFieldErrors()
                .stream()
                .collect(
                        LinkedHashMap::new,
                        (errors, error) -> errors.putIfAbsent(
                                error.getField(),
                                Objects.requireNonNullElse(error.getDefaultMessage(), DEFAULT_VALIDATION_MESSAGE)
                        ),
                        Map::putAll
                );

        log.warn("Request validation failed: fields={}", fieldErrors.keySet());
        return buildErrorResponse(HttpStatus.BAD_REQUEST, "VALIDATION_FAILED", message, fieldErrors);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ApiResponse<Void>> handleConstraintViolationException(
            ConstraintViolationException exception
    ) {
        String message = exception.getConstraintViolations()
                .stream()
                .map(violation -> violation.getMessage())
                .filter(Objects::nonNull)
                .findFirst()
                .orElse(DEFAULT_VALIDATION_MESSAGE);

        log.warn("Constraint validation failed: count={}", exception.getConstraintViolations().size());
        return buildErrorResponse(HttpStatus.BAD_REQUEST, "VALIDATION_FAILED", message, Map.of());
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ApiResponse<Void>> handleHttpMessageNotReadableException(
            HttpMessageNotReadableException exception
    ) {
        log.warn("Request body is not readable");
        return buildErrorResponse(
                HttpStatus.BAD_REQUEST,
                "REQUEST_BODY_INVALID",
                "Request body is not readable",
                Map.of()
        );
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<ApiResponse<Void>> handleMaxUploadSizeExceededException(
            MaxUploadSizeExceededException exception
    ) {
        log.warn("Upload exceeds request size limit");
        return buildErrorResponse(
                HttpStatus.PAYLOAD_TOO_LARGE,
                "PAYLOAD_TOO_LARGE",
                "Uploaded file is too large",
                Map.of()
        );
    }

    @ExceptionHandler(MultipartException.class)
    public ResponseEntity<ApiResponse<Void>> handleMultipartException(
            MultipartException exception
    ) {
        log.warn("Multipart request is invalid");
        return buildErrorResponse(
                HttpStatus.BAD_REQUEST,
                "MULTIPART_REQUEST_INVALID",
                "Multipart request is invalid",
                Map.of()
        );
    }

    @ExceptionHandler(MissingServletRequestPartException.class)
    public ResponseEntity<ApiResponse<Void>> handleMissingServletRequestPartException(
            MissingServletRequestPartException exception
    ) {
        log.warn("Required multipart request part is missing");
        return buildErrorResponse(
                HttpStatus.BAD_REQUEST,
                "MULTIPART_PART_MISSING",
                "Required multipart request part is missing",
                Map.of()
        );
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ApiResponse<Void>> handleMethodArgumentTypeMismatchException(
            MethodArgumentTypeMismatchException exception
    ) {
        log.warn("Request parameter type is invalid: parameter={}", exception.getName());
        return buildErrorResponse(
                HttpStatus.BAD_REQUEST,
                "REQUEST_PARAMETER_INVALID",
                "Request parameter is invalid",
                Map.of()
        );
    }

    @ExceptionHandler(EligibilityValidationException.class)
    public ResponseEntity<ApiResponse<Void>> handleEligibilityValidationException(
            EligibilityValidationException exception
    ) {
        log.warn("Eligibility validation failed: field={}", exception.getField());
        return buildErrorResponse(
                exception.getStatus(),
                exception.getCode(),
                exception.getMessage(),
                Map.of(exception.getField(), exception.getFieldError())
        );
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleException(Exception exception) {
        log.error("Unhandled exception", exception);
        return buildErrorResponse(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "INTERNAL_SERVER_ERROR",
                DEFAULT_ERROR_MESSAGE,
                Map.of()
        );
    }

    private ResponseEntity<ApiResponse<Void>> buildErrorResponse(
            HttpStatus status,
            String code,
            String message,
            Map<String, String> fieldErrors
    ) {
        return ResponseEntity
                .status(status)
                .body(ApiResponse.failure(code, message, fieldErrors));
    }

    private String errorCode(HttpStatus status) {
        return switch (status) {
            case UNAUTHORIZED -> "AUTH_INVALID_CREDENTIALS";
            case FORBIDDEN -> "PERMISSION_DENIED";
            case NOT_FOUND -> "RESOURCE_NOT_FOUND";
            case CONFLICT -> "RESOURCE_CONFLICT";
            default -> "REQUEST_FAILED";
        };
    }
}
