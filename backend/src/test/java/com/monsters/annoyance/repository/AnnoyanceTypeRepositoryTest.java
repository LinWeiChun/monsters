package com.monsters.annoyance.repository;

import static org.assertj.core.api.Assertions.assertThat;

import com.monsters.annoyance.entity.AnnoyanceType;
import java.lang.reflect.Method;
import java.lang.reflect.ParameterizedType;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.data.jpa.repository.JpaRepository;

class AnnoyanceTypeRepositoryTest {

    @Test
    void shouldUseJpaRepositoryWithLongId() {
        ParameterizedType repositoryType = (ParameterizedType)
                AnnoyanceTypeRepository.class.getGenericInterfaces()[0];

        assertThat(repositoryType.getRawType()).isEqualTo(JpaRepository.class);
        assertThat(repositoryType.getActualTypeArguments())
                .containsExactly(AnnoyanceType.class, Long.class);
    }

    @Test
    void shouldProvideStableCodeLookup() throws NoSuchMethodException {
        Method method = AnnoyanceTypeRepository.class.getMethod("findByCode", String.class);
        ParameterizedType returnType = (ParameterizedType) method.getGenericReturnType();

        assertThat(returnType.getRawType()).isEqualTo(Optional.class);
        assertThat(returnType.getActualTypeArguments()).containsExactly(AnnoyanceType.class);
    }

    @Test
    void shouldProvideDisplayOrderQuery() throws NoSuchMethodException {
        Method method = AnnoyanceTypeRepository.class
                .getMethod("findAllByOrderByDisplayOrderAsc");
        ParameterizedType returnType = (ParameterizedType) method.getGenericReturnType();

        assertThat(returnType.getRawType()).isEqualTo(List.class);
        assertThat(returnType.getActualTypeArguments()).containsExactly(AnnoyanceType.class);
    }
}
