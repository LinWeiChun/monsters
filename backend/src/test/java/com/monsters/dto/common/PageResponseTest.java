package com.monsters.dto.common;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.Test;

class PageResponseTest {

    @Test
    void shouldCopyContentAndExposePaginationMetadata() {
        List<String> source = new ArrayList<>(List.of("first"));

        PageResponse<String> response = new PageResponse<>(source, 1, 20, 21, 2, false, true);
        source.add("second");

        assertThat(response.content()).containsExactly("first");
        assertThat(response.page()).isEqualTo(1);
        assertThat(response.size()).isEqualTo(20);
        assertThat(response.totalElements()).isEqualTo(21);
        assertThat(response.totalPages()).isEqualTo(2);
        assertThat(response.first()).isFalse();
        assertThat(response.last()).isTrue();
        assertThatThrownBy(() -> response.content().add("third"))
                .isInstanceOf(UnsupportedOperationException.class);
    }
}
