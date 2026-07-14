package com.monsters.storage.common;

import com.monsters.exception.common.BusinessException;
import com.monsters.exception.common.ValidationException;
import java.io.IOException;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.exception.SdkException;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

@Service
public class R2AvatarStorageService implements AvatarStorageService {

    private static final Set<String> ALLOWED_CONTENT_TYPES = Set.of(
            "image/jpeg",
            "image/png",
            "image/webp"
    );

    private final S3Client s3Client;
    private final R2Properties properties;

    public R2AvatarStorageService(S3Client s3Client, R2Properties properties) {
        this.s3Client = s3Client;
        this.properties = properties;
    }

    @Override
    public String uploadAvatar(Long userId, MultipartFile file) {
        validateConfigured();
        validateFile(file);

        String contentType = file.getContentType().toLowerCase(Locale.ROOT);
        String key = buildAvatarKey(userId, contentType);
        PutObjectRequest request = PutObjectRequest.builder()
                .bucket(properties.bucket())
                .key(key)
                .contentType(contentType)
                .contentLength(file.getSize())
                .build();

        try {
            s3Client.putObject(request, RequestBody.fromInputStream(file.getInputStream(), file.getSize()));
        } catch (IOException | SdkException exception) {
            throw new BusinessException(HttpStatus.INTERNAL_SERVER_ERROR, "Avatar upload failed");
        }

        return properties.publicBaseUrl().replaceAll("/+$", "") + "/" + key;
    }

    private void validateConfigured() {
        if (properties.accountId().isBlank()
                || properties.accessKeyId().isBlank()
                || properties.secretAccessKey().isBlank()
                || properties.bucket().isBlank()
                || properties.publicBaseUrl().isBlank()) {
            throw new BusinessException(HttpStatus.INTERNAL_SERVER_ERROR, "R2 storage is not configured");
        }
    }

    private void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new ValidationException("Avatar file is required");
        }
        if (file.getSize() > properties.maxAvatarSizeBytes()) {
            throw new ValidationException("Avatar file is too large");
        }
        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_CONTENT_TYPES.contains(contentType.toLowerCase(Locale.ROOT))) {
            throw new ValidationException("Avatar file type is not supported");
        }
    }

    private String buildAvatarKey(Long userId, String contentType) {
        String prefix = properties.avatarKeyPrefix().replaceAll("^/+", "").replaceAll("/+$", "");
        return prefix + "/" + userId + "/" + UUID.randomUUID() + extension(contentType);
    }

    private String extension(String contentType) {
        return switch (contentType) {
            case "image/jpeg" -> ".jpg";
            case "image/png" -> ".png";
            case "image/webp" -> ".webp";
            default -> "";
        };
    }
}
