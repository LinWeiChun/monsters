package com.monsters.entry.entity;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter
public class EntryMediaTypeConverter implements AttributeConverter<EntryMediaType, String> {

    @Override
    public String convertToDatabaseColumn(EntryMediaType attribute) {
        return attribute == null ? null : attribute.databaseValue();
    }

    @Override
    public EntryMediaType convertToEntityAttribute(String databaseValue) {
        return databaseValue == null ? null : EntryMediaType.fromDatabaseValue(databaseValue);
    }
}
