package com.monsters.service.annoyance;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.dto.annoyance.CreateAnnoyanceRequest;
import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMedia;
import com.monsters.entity.entry.EntryMediaType;
import com.monsters.repository.entry.EntryMediaRepository;
import com.monsters.repository.entry.EntryRepository;
import com.monsters.storage.entry.StoredEntryMedia;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@ExtendWith(MockitoExtension.class)
class AnnoyancePersistenceServiceTest {

    @Mock private EntryRepository entryRepository;
    @Mock private EntryMediaRepository entryMediaRepository;

    @Test
    void shouldKeepDatabaseTransactionBehindSeparateSpringBean() throws NoSuchMethodException {
        Method persistenceCreate = AnnoyancePersistenceService.class.getMethod(
                "create",
                Long.class,
                Long.class,
                Long.class,
                String.class,
                boolean.class,
                LocalDateTime.class,
                List.class
        );
        Method orchestrationCreate = AnnoyanceService.class.getMethod(
                "create",
                Long.class,
                CreateAnnoyanceRequest.class,
                MultipartFile.class,
                MultipartFile.class
        );
        Method persistenceUpdate = AnnoyancePersistenceService.class.getMethod(
                "update",
                Entry.class,
                Long.class,
                Long.class,
                String.class,
                boolean.class,
                LocalDateTime.class,
                List.class,
                Set.class,
                List.class
        );

        assertThat(persistenceCreate.isAnnotationPresent(Transactional.class)).isTrue();
        assertThat(persistenceUpdate.isAnnotationPresent(Transactional.class)).isTrue();
        assertThat(orchestrationCreate.isAnnotationPresent(Transactional.class)).isFalse();
    }

    @Test
    void shouldPersistEntryAndMediaInOneTransactionBoundary() {
        LocalDateTime occurredAt = LocalDateTime.of(2026, 7, 11, 12, 0);
        List<NewEntryMedia> newMedia = List.of(
                new NewEntryMedia(
                        EntryMediaType.AUDIO,
                        new StoredEntryMedia(
                                "entries/media/1/audio/key.mp3",
                                "audio/mpeg",
                                1024,
                                new BigDecimal("12.500")
                        ),
                        0
                )
        );
        when(entryRepository.saveAndFlush(any(Entry.class))).thenAnswer(invocation -> {
            Entry entry = invocation.getArgument(0);
            ReflectionTestUtils.setField(entry, "id", 10L);
            return entry;
        });
        when(entryMediaRepository.saveAllAndFlush(any())).thenAnswer(invocation -> invocation.getArgument(0));

        CreatedAnnoyance created = service().create(
                1L,
                2L,
                3L,
                null,
                true,
                occurredAt,
                newMedia
        );

        assertThat(created.entry().getId()).isEqualTo(10L);
        assertThat(created.entry().isShared()).isTrue();
        assertThat(created.media()).singleElement().satisfies(media -> {
            assertThat(media.getEntryId()).isEqualTo(10L);
            assertThat(media.getMediaType()).isEqualTo(EntryMediaType.AUDIO);
            assertThat(media.getObjectKey()).isEqualTo("entries/media/1/audio/key.mp3");
            assertThat(media.getDurationSeconds()).isEqualByComparingTo("12.500");
        });
        verify(entryMediaRepository).saveAllAndFlush(any());
    }

    @Test
    void shouldReplaceMediaAndReturnOldObjectKeysAfterTransactionalUpdate() {
        Entry entry = Entry.annoyance(
                1L,
                2L,
                3L,
                null,
                false,
                LocalDateTime.of(2026, 7, 11, 12, 0)
        );
        ReflectionTestUtils.setField(entry, "id", 10L);
        EntryMedia oldImage = media(
                21L,
                EntryMediaType.IMAGE,
                "entries/media/1/image/old.png",
                0
        );
        EntryMedia drawing = media(
                22L,
                EntryMediaType.DRAWING,
                "entries/media/1/drawing/keep.webp",
                1
        );
        NewEntryMedia newImage = new NewEntryMedia(
                EntryMediaType.IMAGE,
                new StoredEntryMedia(
                        "entries/media/1/image/new.png",
                        "image/png",
                        2048,
                        null
                ),
                0
        );
        when(entryRepository.saveAndFlush(entry)).thenReturn(entry);
        when(entryMediaRepository.saveAllAndFlush(any())).thenAnswer(invocation -> invocation.getArgument(0));

        UpdatedAnnoyance updated = service().update(
                entry,
                4L,
                5L,
                null,
                true,
                LocalDateTime.of(2026, 7, 12, 13, 0),
                List.of(oldImage, drawing),
                Set.of(22L),
                List.of(newImage)
        );

        assertThat(updated.entry().getAnnoyanceTypeId()).isEqualTo(4L);
        assertThat(updated.entry().getMoodId()).isEqualTo(5L);
        assertThat(updated.entry().isShared()).isTrue();
        assertThat(oldImage.isDeleted()).isTrue();
        assertThat(drawing.isDeleted()).isFalse();
        assertThat(updated.removedObjectKeys())
                .containsExactly("entries/media/1/image/old.png");
        assertThat(updated.media())
                .extracting(EntryMedia::getObjectKey)
                .containsExactly(
                        "entries/media/1/image/new.png",
                        "entries/media/1/drawing/keep.webp"
                );
    }

    private EntryMedia media(
            Long id,
            EntryMediaType mediaType,
            String objectKey,
            int displayOrder
    ) {
        EntryMedia media = new EntryMedia(
                10L,
                mediaType,
                objectKey,
                mediaType == EntryMediaType.DRAWING ? "image/webp" : "image/png",
                1024,
                null,
                displayOrder
        );
        ReflectionTestUtils.setField(media, "id", id);
        return media;
    }

    private AnnoyancePersistenceService service() {
        return new AnnoyancePersistenceService(entryRepository, entryMediaRepository);
    }
}
