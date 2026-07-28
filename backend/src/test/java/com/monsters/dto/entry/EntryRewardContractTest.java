package com.monsters.dto.entry;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.monsters.dto.annoyance.AnnoyanceCategoryResponse;
import com.monsters.dto.annoyance.AnnoyanceRecordMethod;
import com.monsters.dto.annoyance.AnnoyanceResponse;
import com.monsters.dto.diary.DiaryRecordMethod;
import com.monsters.dto.diary.DiaryResponse;
import java.time.OffsetDateTime;
import java.util.List;
import org.junit.jupiter.api.Test;

class EntryRewardContractTest {

    private final ObjectMapper objectMapper = new ObjectMapper()
            .registerModule(new JavaTimeModule());

    @Test
    void annoyanceResponseShouldSerializeExplicitNullReward() throws Exception {
        AnnoyanceResponse response = new AnnoyanceResponse(
                101L,
                new AnnoyanceCategoryResponse("ACADEMIC", "學業"),
                AnnoyanceRecordMethod.TEXT,
                "content",
                3,
                false,
                false,
                OffsetDateTime.parse("2026-07-24T10:00:00+08:00"),
                List.of(),
                null
        );

        assertExplicitNullReward(response);
    }

    @Test
    void diaryResponseShouldSerializeExplicitNullReward() throws Exception {
        DiaryResponse response = new DiaryResponse(
                301L,
                DiaryRecordMethod.TEXT,
                "diary content",
                4,
                false,
                OffsetDateTime.parse("2026-07-24T10:00:00+08:00"),
                List.of(),
                null
        );

        assertExplicitNullReward(response);
    }

    @Test
    void responsesShouldRejectPrematureRewards() {
        assertThatThrownBy(() -> new AnnoyanceResponse(
                101L,
                new AnnoyanceCategoryResponse("ACADEMIC", "學業"),
                AnnoyanceRecordMethod.TEXT,
                "content",
                3,
                false,
                false,
                OffsetDateTime.parse("2026-07-24T10:00:00+08:00"),
                List.of(),
                "premature reward"
        ))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("Annoyance reward must remain null until Phase 6");

        assertThatThrownBy(() -> new DiaryResponse(
                301L,
                DiaryRecordMethod.TEXT,
                "diary content",
                4,
                false,
                OffsetDateTime.parse("2026-07-24T10:00:00+08:00"),
                List.of(),
                "premature reward"
        ))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("Diary reward must remain null until Phase 6");
    }

    private void assertExplicitNullReward(Object response) throws Exception {
        JsonNode json = objectMapper.readTree(objectMapper.writeValueAsString(response));

        assertThat(json.has("reward")).isTrue();
        assertThat(json.get("reward").isNull()).isTrue();
    }
}
