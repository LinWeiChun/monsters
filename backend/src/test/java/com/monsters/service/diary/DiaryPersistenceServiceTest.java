package com.monsters.service.diary;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.dto.diary.CreateDiaryRequest;
import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryMediaType;
import com.monsters.repository.entry.EntryMediaRepository;
import com.monsters.repository.entry.EntryRepository;
import com.monsters.storage.entry.StoredEntryMedia;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@ExtendWith(MockitoExtension.class)
class DiaryPersistenceServiceTest {

    @Mock private EntryRepository entryRepository;
    @Mock private EntryMediaRepository entryMediaRepository;

    @Test
    void shouldKeepDatabaseTransactionBehindSeparateSpringBean() throws NoSuchMethodException {
        Method persistenceCreate = DiaryPersistenceService.class.getMethod(
                "create",
                Long.class,
                Long.class,
                String.class,
                boolean.class,
                LocalDateTime.class,
                List.class
        );
        Method orchestrationCreate = DiaryService.class.getMethod(
                "create",
                Long.class,
                CreateDiaryRequest.class,
                MultipartFile.class,
                MultipartFile.class
        );

        assertThat(persistenceCreate.isAnnotationPresent(Transactional.class)).isTrue();
        assertThat(orchestrationCreate.isAnnotationPresent(Transactional.class)).isFalse();
    }

    @Test
    void shouldPersistDiaryAndMediaInOneTransactionBoundary() {
        LocalDateTime occurredAt = LocalDateTime.of(2026, 7, 19, 12, 0);
        List<NewDiaryMedia> newMedia = List.of(
                new NewDiaryMedia(
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

        CreatedDiary created = service().create(
                1L,
                3L,
                null,
                true,
                occurredAt,
                newMedia
        );

        assertThat(created.entry().getId()).isEqualTo(10L);
        assertThat(created.entry().getAnnoyanceTypeId()).isNull();
        assertThat(created.entry().isSolved()).isFalse();
        assertThat(created.entry().isShared()).isTrue();
        assertThat(created.media()).singleElement().satisfies(media -> {
            assertThat(media.getEntryId()).isEqualTo(10L);
            assertThat(media.getMediaType()).isEqualTo(EntryMediaType.AUDIO);
            assertThat(media.getObjectKey()).isEqualTo("entries/media/1/audio/key.mp3");
            assertThat(media.getDurationSeconds()).isEqualByComparingTo("12.500");
        });
        verify(entryMediaRepository).saveAllAndFlush(any());
    }

    private DiaryPersistenceService service() {
        return new DiaryPersistenceService(entryRepository, entryMediaRepository);
    }
}
