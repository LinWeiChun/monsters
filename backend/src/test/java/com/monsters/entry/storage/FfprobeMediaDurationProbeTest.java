package com.monsters.entry.storage;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.monsters.common.exception.BusinessException;
import com.monsters.common.exception.ValidationException;
import com.monsters.common.storage.R2Properties;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledOnOs;
import org.junit.jupiter.api.condition.OS;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.mock.web.MockMultipartFile;

@EnabledOnOs({OS.LINUX, OS.MAC})
class FfprobeMediaDurationProbeTest {

    @TempDir
    Path temporaryDirectory;

    @Test
    void shouldParseAndRoundDuration() throws IOException {
        R2Properties properties = propertiesWithExecutable("echo 12.3456", 0);
        FfprobeMediaDurationProbe probe = new FfprobeMediaDurationProbe(properties);

        assertThat(probe.probe(mediaFile())).isEqualByComparingTo("12.346");
    }

    @Test
    void shouldRejectUnreadableDuration() throws IOException {
        R2Properties properties = propertiesWithExecutable("echo invalid", 0);
        FfprobeMediaDurationProbe probe = new FfprobeMediaDurationProbe(properties);

        assertThatThrownBy(() -> probe.probe(mediaFile()))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Media duration could not be read");
    }

    @Test
    void shouldRejectFfprobeFailureWithoutExposingOutput() throws IOException {
        R2Properties properties = propertiesWithExecutable("echo private-path", 1);
        FfprobeMediaDurationProbe probe = new FfprobeMediaDurationProbe(properties);

        assertThatThrownBy(() -> probe.probe(mediaFile()))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Media duration could not be read")
                .hasMessageNotContaining("private-path");
    }

    @Test
    void shouldReportMissingFfprobeAsServerConfigurationFailure() {
        R2Properties properties = new R2Properties();
        properties.setFfprobePath(temporaryDirectory.resolve("missing-ffprobe").toString());
        FfprobeMediaDurationProbe probe = new FfprobeMediaDurationProbe(properties);

        assertThatThrownBy(() -> probe.probe(mediaFile()))
                .isInstanceOf(BusinessException.class)
                .hasMessage("Media duration validation is unavailable");
    }

    private R2Properties propertiesWithExecutable(String command, int exitCode) throws IOException {
        Path executable = temporaryDirectory.resolve("fake-ffprobe-" + exitCode + "-" + command.hashCode());
        Files.writeString(executable, "#!/bin/sh\n" + command + "\nexit " + exitCode + "\n");
        assertThat(executable.toFile().setExecutable(true)).isTrue();

        R2Properties properties = new R2Properties();
        properties.setFfprobePath(executable.toString());
        return properties;
    }

    private MockMultipartFile mediaFile() {
        return new MockMultipartFile(
                "file",
                "audio.m4a",
                "audio/mp4",
                new byte[]{1, 2, 3}
        );
    }
}
