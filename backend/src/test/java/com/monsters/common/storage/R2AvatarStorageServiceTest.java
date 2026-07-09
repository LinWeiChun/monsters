package com.monsters.common.storage;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import com.monsters.common.exception.BusinessException;
import com.monsters.common.exception.ValidationException;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockMultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

class R2AvatarStorageServiceTest {

    @Test
    void uploadAvatarShouldReturnPublicUrlAfterR2Upload() {
        S3Client s3Client = mock(S3Client.class);
        R2AvatarStorageService service = new R2AvatarStorageService(
                s3Client,
                configuredProperties()
        );
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "avatar.png",
                "image/png",
                new byte[]{1, 2, 3}
        );

        String avatarUrl = service.uploadAvatar(1L, file);

        assertThat(avatarUrl).startsWith("https://cdn.example.com/users/avatars/1/");
        assertThat(avatarUrl).endsWith(".png");
        verify(s3Client).putObject(any(PutObjectRequest.class), any(RequestBody.class));
    }

    @Test
    void uploadAvatarShouldRejectMissingR2Configuration() {
        R2AvatarStorageService service = new R2AvatarStorageService(
                mock(S3Client.class),
                new R2Properties()
        );
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "avatar.png",
                "image/png",
                new byte[]{1, 2, 3}
        );

        assertThatThrownBy(() -> service.uploadAvatar(1L, file))
                .isInstanceOf(BusinessException.class)
                .hasMessage("R2 storage is not configured");
    }

    @Test
    void uploadAvatarShouldRejectEmptyFile() {
        R2AvatarStorageService service = new R2AvatarStorageService(
                mock(S3Client.class),
                configuredProperties()
        );
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "avatar.png",
                "image/png",
                new byte[]{}
        );

        assertThatThrownBy(() -> service.uploadAvatar(1L, file))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Avatar file is required");
    }

    @Test
    void uploadAvatarShouldRejectUnsupportedFileType() {
        R2AvatarStorageService service = new R2AvatarStorageService(
                mock(S3Client.class),
                configuredProperties()
        );
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "avatar.gif",
                "image/gif",
                new byte[]{1, 2, 3}
        );

        assertThatThrownBy(() -> service.uploadAvatar(1L, file))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Avatar file type is not supported");
    }

    @Test
    void uploadAvatarShouldRejectTooLargeFile() {
        R2Properties properties = configuredProperties();
        properties.setMaxAvatarSizeBytes(2);
        R2AvatarStorageService service = new R2AvatarStorageService(
                mock(S3Client.class),
                properties
        );
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "avatar.png",
                "image/png",
                new byte[]{1, 2, 3}
        );

        assertThatThrownBy(() -> service.uploadAvatar(1L, file))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Avatar file is too large");
    }

    @Test
    void r2PropertiesShouldUseAvatarDefaults() {
        R2Properties properties = new R2Properties();

        assertThat(properties.avatarKeyPrefix()).isEqualTo("users/avatars");
        assertThat(properties.maxAvatarSizeBytes()).isEqualTo(5 * 1024 * 1024);
    }

    private R2Properties configuredProperties() {
        R2Properties properties = new R2Properties();
        properties.setAccountId("account");
        properties.setAccessKeyId("access-key");
        properties.setSecretAccessKey("secret-key");
        properties.setBucket("bucket");
        properties.setPublicBaseUrl("https://cdn.example.com");
        return properties;
    }
}
