package com.monsters.repository.entry;

import static org.assertj.core.api.Assertions.assertThat;

import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryType;
import java.lang.reflect.Method;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

class EntryRepositoryTest {

    @Test
    void shouldExposeTypeScopedSoftDeleteLookupForMediaAuthorization()
            throws NoSuchMethodException {
        Method method = EntryRepository.class.getMethod(
                "findByIdAndEntryTypeAndDeletedFalse",
                Long.class,
                EntryType.class
        );

        assertThat(method.getReturnType()).isEqualTo(Optional.class);
        assertThat(method.getGenericReturnType().getTypeName()).contains(Entry.class.getName());
    }

    @Test
    void shouldExposeOwnerScopedSoftDeleteLookup() throws NoSuchMethodException {
        assertThat(JpaRepository.class).isAssignableFrom(EntryRepository.class);

        Method method = EntryRepository.class.getMethod(
                "findByIdAndUserIdAndEntryTypeAndDeletedFalse",
                Long.class,
                Long.class,
                EntryType.class
        );

        assertThat(method.getReturnType()).isEqualTo(Optional.class);
        assertThat(method.getGenericReturnType().getTypeName()).contains(Entry.class.getName());
    }

    @Test
    void shouldExposeOwnerScopedFilteredEntryPageQuery() throws NoSuchMethodException {
        Method method = EntryRepository.class.getMethod(
                "findEntryPage",
                Long.class,
                EntryType.class,
                Boolean.class,
                Boolean.class,
                String.class,
                String.class,
                Pageable.class
        );
        Query query = method.getAnnotation(Query.class);

        assertThat(method.getReturnType()).isEqualTo(Page.class);
        assertThat(query).isNotNull();
        assertThat(query.value())
                .contains(
                        "e.userId = :userId",
                        "e.entryType = :entryType",
                        "e.deleted = false",
                        ":solved IS NULL",
                        ":shared IS NULL",
                        "mood.score",
                        "e.id DESC"
                );
        assertThat(query.countQuery()).contains("COUNT(e)", "e.deleted = false");
    }
}
