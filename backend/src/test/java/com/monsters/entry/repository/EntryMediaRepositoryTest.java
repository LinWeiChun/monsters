package com.monsters.entry.repository;

import static org.assertj.core.api.Assertions.assertThat;

import com.monsters.entry.entity.EntryMedia;
import java.lang.reflect.Method;
import java.lang.reflect.ParameterizedType;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.data.jpa.repository.JpaRepository;

class EntryMediaRepositoryTest {

    @Test
    void shouldUseJpaRepositoryWithLongId() {
        ParameterizedType repositoryType = (ParameterizedType)
                EntryMediaRepository.class.getGenericInterfaces()[0];

        assertThat(repositoryType.getRawType()).isEqualTo(JpaRepository.class);
        assertThat(repositoryType.getActualTypeArguments())
                .containsExactly(EntryMedia.class, Long.class);
    }

    @Test
    void shouldQueryActiveMediaInDisplayOrder() throws NoSuchMethodException {
        Method method = EntryMediaRepository.class.getMethod(
                "findAllByEntryIdAndDeletedFalseOrderByDisplayOrderAsc",
                Long.class
        );
        ParameterizedType returnType = (ParameterizedType) method.getGenericReturnType();

        assertThat(returnType.getRawType()).isEqualTo(List.class);
        assertThat(returnType.getActualTypeArguments()).containsExactly(EntryMedia.class);
    }

    @Test
    void shouldConstrainSingleMediaLookupToEntryOwnerRelation() throws NoSuchMethodException {
        Method method = EntryMediaRepository.class.getMethod(
                "findByIdAndEntryIdAndDeletedFalse",
                Long.class,
                Long.class
        );
        ParameterizedType returnType = (ParameterizedType) method.getGenericReturnType();

        assertThat(returnType.getRawType()).isEqualTo(Optional.class);
        assertThat(returnType.getActualTypeArguments()).containsExactly(EntryMedia.class);
    }
}
