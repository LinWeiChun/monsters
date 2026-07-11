package com.monsters.common.exception;

import com.monsters.common.dto.ApiResponse;
import jakarta.validation.ConstraintViolationException;
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
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);
    private static final String DEFAULT_VALIDATION_MESSAGE = "Request validation failed";
    private static final String DEFAULT_ERROR_MESSAGE = "Internal server error";

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiResponse<Void>> handleBusinessException(BusinessException exception) {
        log.error("Business exception", exception);
        return buildErrorResponse(exception.getStatus(), exception.getMessage());
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

        log.error("Request validation failed", exception);
        return buildErrorResponse(HttpStatus.BAD_REQUEST, message);
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

        log.error("Constraint validation failed", exception);
        return buildErrorResponse(HttpStatus.BAD_REQUEST, message);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ApiResponse<Void>> handleHttpMessageNotReadableException(
            HttpMessageNotReadableException exception
    ) {
        log.error("Request body is not readable", exception);
        return buildErrorResponse(HttpStatus.BAD_REQUEST, "Request body is not readable");
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<ApiResponse<Void>> handleMaxUploadSizeExceededException(
            MaxUploadSizeExceededException exception
    ) {
        log.error("Upload exceeds request size limit", exception);
        return buildErrorResponse(HttpStatus.PAYLOAD_TOO_LARGE, "Uploaded file is too large");
    }

    @ExceptionHandler(MultipartException.class)
    public ResponseEntity<ApiResponse<Void>> handleMultipartException(
            MultipartException exception
    ) {
        log.error("Multipart request is invalid", exception);
        return buildErrorResponse(HttpStatus.BAD_REQUEST, "Multipart request is invalid");
    }

    @ExceptionHandler(MissingServletRequestPartException.class)
    public ResponseEntity<ApiResponse<Void>> handleMissingServletRequestPartException(
            MissingServletRequestPartException exception
    ) {
        log.error("Required multipart request part is missing", exception);
        return buildErrorResponse(HttpStatus.BAD_REQUEST, "Required multipart request part is missing");
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleException(Exception exception) {
        log.error("Unhandled exception", exception);
        return buildErrorResponse(HttpStatus.INTERNAL_SERVER_ERROR, DEFAULT_ERROR_MESSAGE);
    }

    private ResponseEntity<ApiResponse<Void>> buildErrorResponse(HttpStatus status, String message) {
        return ResponseEntity
                .status(status)
                .body(ApiResponse.failure(message));
    }
}
