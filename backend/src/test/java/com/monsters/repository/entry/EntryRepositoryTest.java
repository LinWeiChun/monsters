package com.monsters.repository.entry;

import static org.assertj.core.api.Assertions.assertThat;

import com.monsters.entity.entry.Entry;
import com.monsters.entity.entry.EntryType;
import java.lang.reflect.Method;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.data.jpa.repository.JpaRepository;

class EntryRepositoryTest {

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
}
