package com.monsters.storage.entry;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.exception.common.BusinessException;
import com.monsters.exception.common.PayloadTooLargeException;
import com.monsters.exception.common.ValidationException;
import com.monsters.storage.common.R2Properties;
import com.monsters.entity.entry.EntryMediaType;
import java.io.ByteArrayInputStream;
import java.math.BigDecimal;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.mock.web.MockMultipartFile;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.http.AbortableInputStream;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Exception;

class R2EntryMediaStorageServiceTest {

    @Test
    void uploadImageShouldStorePrivateObjectKeyAndMetadata() {
        S3Client s3Client = mock(S3Client.class);
        MediaDurationProbe durationProbe = mock(MediaDurationProbe.class);
        R2EntryMediaStorageService service = service(s3Client, durationProbe, configuredProperties());

        StoredEntryMedia stored = service.upload(
                7L,
                EntryMediaType.IMAGE,
                file("image.png", "image/png")
        );

        assertThat(stored.objectKey()).startsWith("entries/media/7/image/");
        assertThat(stored.objectKey()).endsWith(".png");
        assertThat(stored.objectKey()).doesNotContain("http");
        assertThat(stored.contentType()).isEqualTo("image/png");
        assertThat(stored.sizeBytes()).isEqualTo(3);
        assertThat(stored.durationSeconds()).isNull();
        verify(durationProbe, never()).probe(any());
        verify(s3Client).putObject(any(PutObjectRequest.class), any(RequestBody.class));
    }

    @Test
    void uploadAudioShouldValidateAndReturnDuration() {
        S3Client s3Client = mock(S3Client.class);
        MediaDurationProbe durationProbe = mock(MediaDurationProbe.class);
        when(durationProbe.probe(any())).thenReturn(new BigDecimal("120.125"));
        R2EntryMediaStorageService service = service(s3Client, durationProbe, configuredProperties());

        StoredEntryMedia stored = service.upload(
                7L,
                EntryMediaType.AUDIO,
                file("audio.m4a", "audio/mp4")
        );

        assertThat(stored.objectKey()).startsWith("entries/media/7/audio/");
        assertThat(stored.durationSeconds()).isEqualByComparingTo("120.125");
        verify(durationProbe).probe(any());
    }

    @Test
    void uploadShouldRejectMismatchedMimeType() {
        S3Client s3Client = mock(S3Client.class);
        R2EntryMediaStorageService service = service(
                s3Client,
                mock(MediaDurationProbe.class),
                configuredProperties()
        );

        assertThatThrownBy(() -> service.upload(
                7L,
                EntryMediaType.DRAWING,
                file("drawing.jpg", "image/jpeg")
        ))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Entry media file type is not supported");
        verify(s3Client, never()).putObject(any(PutObjectRequest.class), any(RequestBody.class));
    }

    @Test
    void uploadShouldRejectExtensionThatDoesNotMatchMimeType() {
        S3Client s3Client = mock(S3Client.class);
        R2EntryMediaStorageService service = service(
                s3Client,
                mock(MediaDurationProbe.class),
                configuredProperties()
        );

        assertThatThrownBy(() -> service.upload(
                7L,
                EntryMediaType.IMAGE,
                file("image.mp4", "image/png")
        ))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Entry media file extension is not supported");
        verify(s3Client, never()).putObject(any(PutObjectRequest.class), any(RequestBody.class));
    }

    @Test
    void uploadShouldAcceptJpegAndAudioMp4ExtensionVariants() {
        S3Client s3Client = mock(S3Client.class);
        MediaDurationProbe durationProbe = mock(MediaDurationProbe.class);
        when(durationProbe.probe(any())).thenReturn(new BigDecimal("1.000"));
        R2EntryMediaStorageService service = service(
                s3Client,
                durationProbe,
                configuredProperties()
        );

        StoredEntryMedia jpeg = service.upload(
                7L,
                EntryMediaType.IMAGE,
                file("image.jpeg", "image/jpeg")
        );
        StoredEntryMedia audio = service.upload(
                7L,
                EntryMediaType.AUDIO,
                file("audio.mp4", "audio/mp4")
        );

        assertThat(jpeg.objectKey()).endsWith(".jpg");
        assertThat(audio.objectKey()).endsWith(".m4a");
    }

    @Test
    void uploadShouldRejectOversizedFile() {
        R2Properties properties = configuredProperties();
        properties.setMaxEntryImageSizeBytes(2);
        R2EntryMediaStorageService service = service(
                mock(S3Client.class),
                mock(MediaDurationProbe.class),
                properties
        );

        assertThatThrownBy(() -> service.upload(
                7L,
                EntryMediaType.IMAGE,
                file("image.png", "image/png")
        ))
                .isInstanceOf(PayloadTooLargeException.class)
                .hasMessage("Entry media file is too large");
    }

    @Test
    void uploadShouldRejectAudioLongerThanFiveMinutes() {
        MediaDurationProbe durationProbe = mock(MediaDurationProbe.class);
        when(durationProbe.probe(any())).thenReturn(new BigDecimal("300.001"));
        R2EntryMediaStorageService service = service(
                mock(S3Client.class),
                durationProbe,
                configuredProperties()
        );

        assertThatThrownBy(() -> service.upload(
                7L,
                EntryMediaType.AUDIO,
                file("audio.mp3", "audio/mpeg")
        ))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Entry media duration is too long");
    }

    @Test
    void uploadShouldRejectVideoLongerThanSixtySeconds() {
        MediaDurationProbe durationProbe = mock(MediaDurationProbe.class);
        when(durationProbe.probe(any())).thenReturn(new BigDecimal("60.001"));
        R2EntryMediaStorageService service = service(
                mock(S3Client.class),
                durationProbe,
                configuredProperties()
        );

        assertThatThrownBy(() -> service.upload(
                7L,
                EntryMediaType.VIDEO,
                file("video.mp4", "video/mp4")
        ))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Entry media duration is too long");
    }

    @Test
    void downloadShouldForwardValidatedSingleRange() throws Exception {
        S3Client s3Client = mock(S3Client.class);
        GetObjectResponse response = GetObjectResponse.builder()
                .contentType("video/mp4")
                .contentLength(2L)
                .contentRange("bytes 0-1/3")
                .build();
        ResponseInputStream<GetObjectResponse> inputStream = new ResponseInputStream<>(
                response,
                AbortableInputStream.create(new ByteArrayInputStream(new byte[]{1, 2}))
        );
        when(s3Client.getObject(any(GetObjectRequest.class))).thenReturn(inputStream);
        R2EntryMediaStorageService service = service(
                s3Client,
                mock(MediaDurationProbe.class),
                configuredProperties()
        );

        try (DownloadedEntryMedia downloaded = service.download(
                "entries/media/7/video/key.mp4",
                "bytes=0-1"
        )) {
            assertThat(downloaded.contentType()).isEqualTo("video/mp4");
            assertThat(downloaded.contentLength()).isEqualTo(2);
            assertThat(downloaded.contentRange()).isEqualTo("bytes 0-1/3");
        }

        ArgumentCaptor<GetObjectRequest> captor = ArgumentCaptor.forClass(GetObjectRequest.class);
        verify(s3Client).getObject(captor.capture());
        assertThat(captor.getValue().range()).isEqualTo("bytes=0-1");
    }

    @Test
    void downloadShouldRejectMultipleRanges() {
        R2EntryMediaStorageService service = service(
                mock(S3Client.class),
                mock(MediaDurationProbe.class),
                configuredProperties()
        );

        assertThatThrownBy(() -> service.download(
                "entries/media/7/video/key.mp4",
                "bytes=0-1,3-4"
        ))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Media range is invalid");
    }

    @Test
    void downloadShouldRejectReversedRange() {
        R2EntryMediaStorageService service = service(
                mock(S3Client.class),
                mock(MediaDurationProbe.class),
                configuredProperties()
        );

        assertThatThrownBy(() -> service.download(
                "entries/media/7/video/key.mp4",
                "bytes=10-1"
        ))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Media range is invalid");
    }

    @Test
    void deleteShouldRejectObjectOutsideEntryPrefix() {
        R2EntryMediaStorageService service = service(
                mock(S3Client.class),
                mock(MediaDurationProbe.class),
                configuredProperties()
        );

        assertThatThrownBy(() -> service.delete("users/avatars/7/avatar.png"))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Entry media object key is invalid");
    }

    @Test
    void deleteShouldRemoveValidatedPrivateObject() {
        S3Client s3Client = mock(S3Client.class);
        R2EntryMediaStorageService service = service(
                s3Client,
                mock(MediaDurationProbe.class),
                configuredProperties()
        );

        service.delete("entries/media/7/image/key.png");

        ArgumentCaptor<DeleteObjectRequest> captor = ArgumentCaptor.forClass(DeleteObjectRequest.class);
        verify(s3Client).deleteObject(captor.capture());
        assertThat(captor.getValue().key()).isEqualTo("entries/media/7/image/key.png");
    }

    @Test
    void uploadShouldHideR2FailureDetails() {
        S3Client s3Client = mock(S3Client.class);
        when(s3Client.putObject(any(PutObjectRequest.class), any(RequestBody.class)))
                .thenThrow(S3Exception.builder().message("private bucket detail").build());
        R2EntryMediaStorageService service = service(
                s3Client,
                mock(MediaDurationProbe.class),
                configuredProperties()
        );

        assertThatThrownBy(() -> service.upload(
                7L,
                EntryMediaType.IMAGE,
                file("image.png", "image/png")
        ))
                .isInstanceOf(BusinessException.class)
                .hasMessage("Entry media upload failed")
                .hasMessageNotContaining("private bucket detail");
    }

    private R2EntryMediaStorageService service(
            S3Client s3Client,
            MediaDurationProbe durationProbe,
            R2Properties properties
    ) {
        return new R2EntryMediaStorageService(s3Client, properties, durationProbe);
    }

    private R2Properties configuredProperties() {
        R2Properties properties = new R2Properties();
        properties.setAccountId("account");
        properties.setAccessKeyId("access-key");
        properties.setSecretAccessKey("secret-key");
        properties.setBucket("private-bucket");
        properties.setEntryMediaBucket("private-entry-media-bucket");
        return properties;
    }

    private MockMultipartFile file(String filename, String contentType) {
        return new MockMultipartFile(
                "file",
                filename,
                contentType,
                new byte[]{1, 2, 3}
        );
    }
}
