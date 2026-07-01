package com.monsters.common.entity;

import static org.assertj.core.api.Assertions.assertThat;

import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.MappedSuperclass;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.time.LocalDateTime;
import org.junit.jupiter.api.Test;

class BaseEntityTest {

    @Test
    void baseEntityShouldBeMappedSuperclass() {
        assertThat(BaseEntity.class).hasAnnotation(MappedSuperclass.class);
    }

    @Test
    void idShouldUseIdentityPrimaryKey() throws NoSuchFieldException {
        Field idField = BaseEntity.class.getDeclaredField("id");

        assertThat(idField.getAnnotation(Id.class)).isNotNull();

        GeneratedValue generatedValue = idField.getAnnotation(GeneratedValue.class);
        assertThat(generatedValue.strategy()).isEqualTo(GenerationType.IDENTITY);

        Column column = idField.getAnnotation(Column.class);
        assertThat(column.name()).isEqualTo("id");
        assertThat(column.nullable()).isFalse();
        assertThat(column.updatable()).isFalse();
    }

    @Test
    void timestampFieldsShouldUseSnakeCaseColumns() throws NoSuchFieldException {
        Field createdAtField = BaseEntity.class.getDeclaredField("createdAt");
        Column createdAtColumn = createdAtField.getAnnotation(Column.class);

        assertThat(createdAtColumn.name()).isEqualTo("created_at");
        assertThat(createdAtColumn.nullable()).isFalse();
        assertThat(createdAtColumn.updatable()).isFalse();

        Field updatedAtField = BaseEntity.class.getDeclaredField("updatedAt");
        Column updatedAtColumn = updatedAtField.getAnnotation(Column.class);

        assertThat(updatedAtColumn.name()).isEqualTo("updated_at");
        assertThat(updatedAtColumn.nullable()).isFalse();
    }

    @Test
    void lifecycleMethodsShouldUseJpaCallbacks() throws NoSuchMethodException {
        Method onCreate = BaseEntity.class.getDeclaredMethod("onCreate");
        Method onUpdate = BaseEntity.class.getDeclaredMethod("onUpdate");

        assertThat(onCreate.getAnnotation(PrePersist.class)).isNotNull();
        assertThat(onUpdate.getAnnotation(PreUpdate.class)).isNotNull();
    }

    @Test
    void onCreateShouldSetCreatedAtAndUpdatedAt() {
        TestEntity entity = new TestEntity();

        entity.onCreate();

        assertThat(entity.getCreatedAt()).isNotNull();
        assertThat(entity.getUpdatedAt()).isNotNull();
        assertThat(entity.getUpdatedAt()).isEqualTo(entity.getCreatedAt());
    }

    @Test
    void onUpdateShouldOnlyRefreshUpdatedAt() {
        TestEntity entity = new TestEntity();
        entity.onCreate();
        LocalDateTime createdAt = entity.getCreatedAt();

        entity.onUpdate();

        assertThat(entity.getCreatedAt()).isEqualTo(createdAt);
        assertThat(entity.getUpdatedAt()).isAfterOrEqualTo(createdAt);
    }

    private static class TestEntity extends BaseEntity {
    }
}
