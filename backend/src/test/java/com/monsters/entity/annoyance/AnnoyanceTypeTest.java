package com.monsters.entity.annoyance;

import static org.assertj.core.api.Assertions.assertThat;

import com.monsters.entity.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import org.junit.jupiter.api.Test;

class AnnoyanceTypeTest {

    @Test
    void shouldMapToAnnoyanceTypesTableAndExtendBaseEntity() {
        assertThat(AnnoyanceType.class).hasAnnotation(Entity.class);
        assertThat(AnnoyanceType.class.getAnnotation(Table.class).name())
                .isEqualTo("annoyance_types");
        assertThat(AnnoyanceType.class.getSuperclass()).isEqualTo(BaseEntity.class);
    }

    @Test
    void shouldMapStableCodeAndDisplayFields() throws NoSuchFieldException {
        assertColumn("code", "code", 50, true);
        assertColumn("typeName", "type_name", 80, true);

        Field displayOrderField = AnnoyanceType.class.getDeclaredField("displayOrder");
        Column displayOrderColumn = displayOrderField.getAnnotation(Column.class);
        assertThat(displayOrderColumn.name()).isEqualTo("display_order");
        assertThat(displayOrderColumn.nullable()).isFalse();
    }

    @Test
    void shouldExposeImmutableLookupValues() {
        AnnoyanceType annoyanceType = new AnnoyanceType("ACADEMIC", "課業", 1);

        assertThat(annoyanceType.getCode()).isEqualTo("ACADEMIC");
        assertThat(annoyanceType.getTypeName()).isEqualTo("課業");
        assertThat(annoyanceType.getDisplayOrder()).isEqualTo(1);
    }

    @Test
    void jpaConstructorShouldBeProtected() throws NoSuchMethodException {
        Constructor<AnnoyanceType> constructor = AnnoyanceType.class.getDeclaredConstructor();

        assertThat(Modifier.isProtected(constructor.getModifiers())).isTrue();
    }

    private void assertColumn(
            String fieldName,
            String columnName,
            int length,
            boolean unique
    ) throws NoSuchFieldException {
        Field field = AnnoyanceType.class.getDeclaredField(fieldName);
        Column column = field.getAnnotation(Column.class);

        assertThat(column.name()).isEqualTo(columnName);
        assertThat(column.nullable()).isFalse();
        assertThat(column.length()).isEqualTo(length);
        assertThat(column.unique()).isEqualTo(unique);
    }
}
