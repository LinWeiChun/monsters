package com.monsters.service.entry;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMedia;
import com.monsters.entity.entry.EntryMediaType;
import com.monsters.entity.entry.EntryType;
import com.monsters.entity.user.User;
import com.monsters.exception.common.ResourceNotFoundException;
import com.monsters.repository.entry.EntryMediaRepository;
import com.monsters.repository.entry.EntryRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.storage.entry.DownloadedEntryMedia;
import com.monsters.storage.entry.EntryMediaStorageService;
import java.io.ByteArrayInputStream;
import java.time.LocalDateTime;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class EntryMediaDownloadServiceTest {

    @Mock
    private EntryRepository entryRepository;

    @Mock
    private EntryMediaRepository entryMediaRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private EntryMediaStorageService entryMediaStorageService;

    @Test
    void ownerShouldDownloadPrivateAnnoyanceMedia() throws Exception {
        prepareUser();
        Entry entry = annoyance(1L, false);
        EntryMedia media = media(10L, 20L, "image/png");
        when(entryRepository.findByIdAndEntryTypeAndDeletedFalse(10L, EntryType.ANNOYANCE))
                .thenReturn(Optional.of(entry));
        when(entryMediaRepository.findByIdAndEntryIdAndDeletedFalse(20L, 10L))
                .thenReturn(Optional.of(media));
        when(entryMediaStorageService.download(media.getObjectKey(), null)).thenReturn(
                download("application/octet-stream", 3, null)
        );

        EntryMediaDownloadResult result = service().download(
                1L,
                EntryType.ANNOYANCE,
                10L,
                20L,
                null
        );

        assertThat(result.content().readAllBytes()).containsExactly(1, 2, 3);
        assertThat(result.contentType()).isEqualTo("image/png");
        assertThat(result.contentLength()).isEqualTo(3);
        assertThat(result.contentRange()).isNull();
        verify(entryMediaStorageService).download(media.getObjectKey(), null);
    }

    @Test
    void authenticatedUserShouldDownloadSharedDiaryRange() {
        prepareUser();
        Entry entry = diary(2L, true);
        EntryMedia media = media(10L, 20L, "video/mp4");
        when(entryRepository.findByIdAndEntryTypeAndDeletedFalse(10L, EntryType.DIARY))
                .thenReturn(Optional.of(entry));
        when(entryMediaRepository.findByIdAndEntryIdAndDeletedFalse(20L, 10L))
                .thenReturn(Optional.of(media));
        when(entryMediaStorageService.download(media.getObjectKey(), "bytes=0-1"))
                .thenReturn(download("video/mp4", 2, "bytes 0-1/3"));

        EntryMediaDownloadResult result = service().download(
                1L,
                EntryType.DIARY,
                10L,
                20L,
                "bytes=0-1"
        );

        assertThat(result.contentType()).isEqualTo("video/mp4");
        assertThat(result.contentLength()).isEqualTo(2);
        assertThat(result.contentRange()).isEqualTo("bytes 0-1/3");
        verify(entryMediaStorageService).download(media.getObjectKey(), "bytes=0-1");
    }

    @Test
    void nonOwnerShouldNotDownloadPrivateEntryMedia() {
        prepareUser();
        Entry entry = diary(2L, false);
        when(entryRepository.findByIdAndEntryTypeAndDeletedFalse(10L, EntryType.DIARY))
                .thenReturn(Optional.of(entry));

        assertThatThrownBy(() -> service().download(
                1L,
                EntryType.DIARY,
                10L,
                20L,
                null
        )).isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("Entry media not found");

        verify(entryMediaRepository, never()).findByIdAndEntryIdAndDeletedFalse(20L, 10L);
        verify(entryMediaStorageService, never()).download(mediaKey(), null);
    }

    @Test
    void mediaFromAnotherEntryShouldBeHiddenAsNotFound() {
        prepareUser();
        Entry entry = annoyance(1L, false);
        when(entryRepository.findByIdAndEntryTypeAndDeletedFalse(10L, EntryType.ANNOYANCE))
                .thenReturn(Optional.of(entry));
        when(entryMediaRepository.findByIdAndEntryIdAndDeletedFalse(20L, 10L))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> service().download(
                1L,
                EntryType.ANNOYANCE,
                10L,
                20L,
                null
        )).isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("Entry media not found");

        verify(entryMediaStorageService, never()).download(mediaKey(), null);
    }

    @Test
    void deletedUserShouldBeRejectedBeforeEntryLookup() {
        when(userRepository.findByIdAndDeletedFalse(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service().download(
                1L,
                EntryType.ANNOYANCE,
                10L,
                20L,
                null
        )).isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("User not found");

        verify(entryRepository, never())
                .findByIdAndEntryTypeAndDeletedFalse(10L, EntryType.ANNOYANCE);
    }

    private EntryMediaDownloadService service() {
        return new EntryMediaDownloadService(
                entryRepository,
                entryMediaRepository,
                userRepository,
                entryMediaStorageService
        );
    }

    private void prepareUser() {
        when(userRepository.findByIdAndDeletedFalse(1L))
                .thenReturn(Optional.of(new User("account", "user@example.com", "User")));
    }

    private Entry annoyance(Long ownerId, boolean shared) {
        Entry entry = Entry.annoyance(
                ownerId,
                3L,
                4L,
                "content",
                shared,
                LocalDateTime.of(2026, 7, 22, 10, 0)
        );
        ReflectionTestUtils.setField(entry, "id", 10L);
        return entry;
    }

    private Entry diary(Long ownerId, boolean shared) {
        Entry entry = Entry.diary(
                ownerId,
                4L,
                "content",
                shared,
                LocalDateTime.of(2026, 7, 22, 10, 0)
        );
        ReflectionTestUtils.setField(entry, "id", 10L);
        return entry;
    }

    private EntryMedia media(Long entryId, Long mediaId, String contentType) {
        EntryMedia media = new EntryMedia(
                entryId,
                EntryMediaType.IMAGE,
                mediaKey(),
                contentType,
                3,
                null,
                0
        );
        ReflectionTestUtils.setField(media, "id", mediaId);
        return media;
    }

    private DownloadedEntryMedia download(
            String contentType,
            long contentLength,
            String contentRange
    ) {
        return new DownloadedEntryMedia(
                new ByteArrayInputStream(new byte[]{1, 2, 3}),
                contentType,
                contentLength,
                contentRange
        );
    }

    private String mediaKey() {
        return "entries/media/1/image/file.png";
    }
}
