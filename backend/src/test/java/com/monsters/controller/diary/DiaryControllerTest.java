package com.monsters.controller.diary;

import static org.assertj.core.api.Assertions.assertThat;

import com.monsters.service.diary.DiaryService;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

class DiaryControllerTest {

    @Test
    void shouldProvideDiaryApiControllerSkeleton() {
        assertThat(DiaryController.class).hasAnnotation(RestController.class);
        assertThat(DiaryController.class.getAnnotation(RequestMapping.class).value())
                .containsExactly("/api/diaries");

        DiaryService service = org.mockito.Mockito.mock(DiaryService.class);
        DiaryController controller = new DiaryController(service);

        assertThat(ReflectionTestUtils.getField(controller, "diaryService")).isSameAs(service);
    }
}
