package com.monsters.entry.storage;

import com.monsters.common.exception.BusinessException;
import com.monsters.common.exception.PayloadTooLargeException;
import com.monsters.common.exception.ResourceNotFoundException;
import com.monsters.common.exception.ValidationException;
import com.monsters.common.storage.R2Properties;
import com.monsters.entry.entity.EntryMediaType;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.core.exception.SdkException;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import software.amazon.awssdk.services.s3.model.NoSuchKeyException;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Exception;

@Service
public class R2EntryMediaStorageService implements EntryMediaStorageService {

    private static final Pattern RANGE_PATTERN = Pattern.compile("^bytes=(\\d*)-(\\d*)$");
    private static final Map<EntryMediaType, Set<String>> ALLOWED_CONTENT_TYPES = Map.of(
            EntryMediaType.IMAGE, Set.of("image/jpeg", "image/png", "image/webp"),
            EntryMediaType.AUDIO, Set.of("audio/mp4", "audio/aac", "audio/mpeg", "audio/wav"),
            EntryMediaType.VIDEO, Set.of("video/mp4", "video/quicktime", "video/webm"),
            EntryMediaType.DRAWING, Set.of("image/png", "image/webp")
    );
    private static final Map<String, String> FILE_EXTENSIONS = Map.ofEntries(
            Map.entry("image/jpeg", ".jpg"),
            Map.entry("image/png", ".png"),
            Map.entry("image/webp", ".webp"),
            Map.entry("audio/mp4", ".m4a"),
            Map.entry("audio/aac", ".aac"),
            Map.entry("audio/mpeg", ".mp3"),
            Map.entry("audio/wav", ".wav"),
            Map.entry("video/mp4", ".mp4"),
            Map.entry("video/quicktime", ".mov"),
            Map.entry("video/webm", ".webm")
    );
    private static final Map<String, Set<String>> ALLOWED_FILE_EXTENSIONS = Map.ofEntries(
            Map.entry("image/jpeg", Set.of(".jpg", ".jpeg")),
            Map.entry("image/png", Set.of(".png")),
            Map.entry("image/webp", Set.of(".webp")),
            Map.entry("audio/mp4", Set.of(".m4a", ".mp4")),
            Map.entry("audio/aac", Set.of(".aac")),
            Map.entry("audio/mpeg", Set.of(".mp3")),
            Map.entry("audio/wav", Set.of(".wav")),
            Map.entry("video/mp4", Set.of(".mp4")),
            Map.entry("video/quicktime", Set.of(".mov")),
            Map.entry("video/webm", Set.of(".webm"))
    );

    private final S3Client s3Client;
    private final R2Properties properties;
    private final MediaDurationProbe durationProbe;

    public R2EntryMediaStorageService(
            S3Client s3Client,
            R2Properties properties,
            MediaDurationProbe durationProbe
    ) {
        this.s3Client = s3Client;
        this.properties = properties;
        this.durationProbe = durationProbe;
    }

    @Override
    public StoredEntryMedia upload(
            Long userId,
            EntryMediaType mediaType,
            MultipartFile file
    ) {
        validateConfigured();
        validateUserId(userId);
        String contentType = validateFile(mediaType, file);
        BigDecimal duration = validateDuration(mediaType, file);
        String objectKey = buildObjectKey(userId, mediaType, contentType);
        PutObjectRequest request = PutObjectRequest.builder()
                .bucket(properties.entryMediaBucket())
                .key(objectKey)
                .contentType(contentType)
                .contentLength(file.getSize())
                .build();

        try {
            s3Client.putObject(
                    request,
                    RequestBody.fromInputStream(file.getInputStream(), file.getSize())
            );
        } catch (IOException | SdkException exception) {
            throw new BusinessException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Entry media upload failed"
            );
        }

        return new StoredEntryMedia(objectKey, contentType, file.getSize(), duration);
    }

    @Override
    public DownloadedEntryMedia download(String objectKey, String rangeHeader) {
        validateConfigured();
        validateObjectKey(objectKey);
        String validatedRange = validateRange(rangeHeader);
        GetObjectRequest.Builder request = GetObjectRequest.builder()
                .bucket(properties.entryMediaBucket())
                .key(objectKey);
        if (validatedRange != null) {
            request.range(validatedRange);
        }

        try {
            ResponseInputStream<GetObjectResponse> response = s3Client.getObject(request.build());
            GetObjectResponse metadata = response.response();
            return new DownloadedEntryMedia(
                    response,
                    valueOrDefault(metadata.contentType(), "application/octet-stream"),
                    metadata.contentLength(),
                    metadata.contentRange()
            );
        } catch (NoSuchKeyException exception) {
            throw new ResourceNotFoundException("Entry media not found");
        } catch (S3Exception exception) {
            if (exception.statusCode() == HttpStatus.NOT_FOUND.value()) {
                throw new ResourceNotFoundException("Entry media not found");
            }
            if (exception.statusCode() == HttpStatus.REQUESTED_RANGE_NOT_SATISFIABLE.value()) {
                throw new BusinessException(
                        HttpStatus.REQUESTED_RANGE_NOT_SATISFIABLE,
                        "Media range is not satisfiable"
                );
            }
            throw storageFailure("Entry media download failed");
        } catch (SdkException exception) {
            throw storageFailure("Entry media download failed");
        }
    }

    @Override
    public void delete(String objectKey) {
        validateConfigured();
        validateObjectKey(objectKey);
        DeleteObjectRequest request = DeleteObjectRequest.builder()
                .bucket(properties.entryMediaBucket())
                .key(objectKey)
                .build();
        try {
            s3Client.deleteObject(request);
        } catch (SdkException exception) {
            throw storageFailure("Entry media deletion failed");
        }
    }

    private void validateConfigured() {
        if (isBlank(properties.accountId())
                || isBlank(properties.accessKeyId())
                || isBlank(properties.secretAccessKey())
                || isBlank(properties.entryMediaBucket())
                || isBlank(properties.entryMediaKeyPrefix())) {
            throw storageFailure("R2 storage is not configured");
        }
        normalizedPrefix();
    }

    private void validateUserId(Long userId) {
        if (userId == null || userId <= 0) {
            throw new ValidationException("Valid user id is required for entry media");
        }
    }

    private String validateFile(EntryMediaType mediaType, MultipartFile file) {
        if (mediaType == null) {
            throw new ValidationException("Entry media type is required");
        }
        if (file == null || file.isEmpty()) {
            throw new ValidationException("Entry media file is required");
        }
        if (file.getSize() > maximumSize(mediaType)) {
            throw new PayloadTooLargeException("Entry media file is too large");
        }
        String contentType = file.getContentType();
        if (contentType == null) {
            throw new ValidationException("Entry media file type is not supported");
        }
        String normalizedContentType = contentType.toLowerCase(Locale.ROOT);
        if (!ALLOWED_CONTENT_TYPES.get(mediaType).contains(normalizedContentType)) {
            throw new ValidationException("Entry media file type is not supported");
        }
        validateFileExtension(file.getOriginalFilename(), normalizedContentType);
        return normalizedContentType;
    }

    private void validateFileExtension(String originalFilename, String contentType) {
        if (isBlank(originalFilename)) {
            throw new ValidationException("Entry media file extension is not supported");
        }
        String normalizedFilename = originalFilename.toLowerCase(Locale.ROOT);
        boolean supported = ALLOWED_FILE_EXTENSIONS.get(contentType)
                .stream()
                .anyMatch(normalizedFilename::endsWith);
        if (!supported) {
            throw new ValidationException("Entry media file extension is not supported");
        }
    }

    private BigDecimal validateDuration(EntryMediaType mediaType, MultipartFile file) {
        if (mediaType != EntryMediaType.AUDIO && mediaType != EntryMediaType.VIDEO) {
            return null;
        }
        BigDecimal duration = durationProbe.probe(file);
        long maximumDuration = mediaType == EntryMediaType.AUDIO
                ? properties.maxEntryAudioDurationSeconds()
                : properties.maxEntryVideoDurationSeconds();
        if (duration.compareTo(BigDecimal.valueOf(maximumDuration)) > 0) {
            throw new ValidationException("Entry media duration is too long");
        }
        return duration;
    }

    private long maximumSize(EntryMediaType mediaType) {
        return switch (mediaType) {
            case IMAGE -> properties.maxEntryImageSizeBytes();
            case AUDIO -> properties.maxEntryAudioSizeBytes();
            case VIDEO -> properties.maxEntryVideoSizeBytes();
            case DRAWING -> properties.maxEntryDrawingSizeBytes();
        };
    }

    private String buildObjectKey(
            Long userId,
            EntryMediaType mediaType,
            String contentType
    ) {
        return normalizedPrefix()
                + "/" + userId
                + "/" + mediaType.databaseValue()
                + "/" + UUID.randomUUID()
                + FILE_EXTENSIONS.get(contentType);
    }

    private void validateObjectKey(String objectKey) {
        String prefix = normalizedPrefix() + "/";
        if (isBlank(objectKey)
                || objectKey.startsWith("/")
                || objectKey.contains("..")
                || !objectKey.startsWith(prefix)) {
            throw new ValidationException("Entry media object key is invalid");
        }
    }

    private String validateRange(String rangeHeader) {
        if (isBlank(rangeHeader)) {
            return null;
        }
        Matcher matcher = RANGE_PATTERN.matcher(rangeHeader.trim());
        if (!matcher.matches() || (matcher.group(1).isEmpty() && matcher.group(2).isEmpty())) {
            throw new ValidationException("Media range is invalid");
        }
        if (!matcher.group(1).isEmpty() && !matcher.group(2).isEmpty()) {
            try {
                long start = Long.parseLong(matcher.group(1));
                long end = Long.parseLong(matcher.group(2));
                if (start > end) {
                    throw new ValidationException("Media range is invalid");
                }
            } catch (NumberFormatException exception) {
                throw new ValidationException("Media range is invalid");
            }
        }
        return rangeHeader.trim();
    }

    private String normalizedPrefix() {
        String prefix = properties.entryMediaKeyPrefix()
                .replaceAll("^/+", "")
                .replaceAll("/+$", "");
        if (prefix.isBlank()
                || prefix.contains("..")
                || !prefix.matches("[A-Za-z0-9/_-]+")) {
            throw storageFailure("R2 entry media key prefix is invalid");
        }
        return prefix;
    }

    private BusinessException storageFailure(String message) {
        return new BusinessException(HttpStatus.INTERNAL_SERVER_ERROR, message);
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private String valueOrDefault(String value, String defaultValue) {
        return isBlank(value) ? defaultValue : value;
    }
}
