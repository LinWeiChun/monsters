package com.monsters.annoyance.controller;

import static org.assertj.core.api.Assertions.assertThat;

import com.monsters.annoyance.service.AnnoyanceService;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

class AnnoyanceControllerTest {

    @Test
    void shouldProvideAnnoyanceApiControllerSkeleton() {
        assertThat(AnnoyanceController.class).hasAnnotation(RestController.class);
        assertThat(AnnoyanceController.class.getAnnotation(RequestMapping.class).value())
                .containsExactly("/api/annoyances");

        AnnoyanceService service = org.mockito.Mockito.mock(AnnoyanceService.class);
        AnnoyanceController controller = new AnnoyanceController(service);

        assertThat(ReflectionTestUtils.getField(controller, "annoyanceService")).isSameAs(service);
    }
}
