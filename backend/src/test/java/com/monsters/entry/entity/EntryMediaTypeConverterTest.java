package com.monsters.entry.entity;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;

class EntryMediaTypeConverterTest {

    private final EntryMediaTypeConverter converter = new EntryMediaTypeConverter();

    @Test
    void shouldConvertEveryTypeToLowercaseDatabaseValue() {
        assertThat(converter.convertToDatabaseColumn(EntryMediaType.IMAGE)).isEqualTo("image");
        assertThat(converter.convertToDatabaseColumn(EntryMediaType.AUDIO)).isEqualTo("audio");
        assertThat(converter.convertToDatabaseColumn(EntryMediaType.VIDEO)).isEqualTo("video");
        assertThat(converter.convertToDatabaseColumn(EntryMediaType.DRAWING)).isEqualTo("drawing");
    }

    @Test
    void shouldConvertDatabaseValueToType() {
        assertThat(converter.convertToEntityAttribute("video")).isEqualTo(EntryMediaType.VIDEO);
    }

    @Test
    void shouldRejectUnknownDatabaseValue() {
        assertThatThrownBy(() -> converter.convertToEntityAttribute("public-url"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("Unsupported entry media type");
    }

    @Test
    void shouldKeepNullValuesNull() {
        assertThat(converter.convertToDatabaseColumn(null)).isNull();
        assertThat(converter.convertToEntityAttribute(null)).isNull();
    }
}
