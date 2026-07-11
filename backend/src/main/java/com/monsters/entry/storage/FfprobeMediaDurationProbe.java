package com.monsters.entry.storage;

import com.monsters.common.exception.BusinessException;
import com.monsters.common.exception.ValidationException;
import com.monsters.common.storage.R2Properties;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.concurrent.TimeUnit;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class FfprobeMediaDurationProbe implements MediaDurationProbe {

    private final R2Properties properties;

    public FfprobeMediaDurationProbe(R2Properties properties) {
        this.properties = properties;
    }

    @Override
    public BigDecimal probe(MultipartFile file) {
        Path temporaryFile = null;
        try {
            temporaryFile = Files.createTempFile("entry-media-", ".upload");
            try (var inputStream = file.getInputStream()) {
                Files.copy(inputStream, temporaryFile, StandardCopyOption.REPLACE_EXISTING);
            }
            return executeProbe(temporaryFile);
        } catch (IOException exception) {
            throw new BusinessException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Media duration validation is unavailable"
            );
        } finally {
            deleteTemporaryFile(temporaryFile);
        }
    }

    private BigDecimal executeProbe(Path temporaryFile) {
        Process process;
        try {
            process = new ProcessBuilder(
                    properties.ffprobePath(),
                    "-v", "error",
                    "-show_entries", "format=duration",
                    "-of", "default=noprint_wrappers=1:nokey=1",
                    temporaryFile.toString()
            ).redirectErrorStream(true).start();
        } catch (IOException exception) {
            throw new BusinessException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Media duration validation is unavailable"
            );
        }

        try {
            boolean completed = process.waitFor(
                    properties.ffprobeTimeoutSeconds(),
                    TimeUnit.SECONDS
            );
            if (!completed) {
                process.destroyForcibly();
                throw new ValidationException("Media duration validation timed out");
            }

            String output = new String(
                    process.getInputStream().readAllBytes(),
                    StandardCharsets.UTF_8
            ).trim();
            if (process.exitValue() != 0) {
                throw new ValidationException("Media duration could not be read");
            }
            BigDecimal duration = new BigDecimal(output).setScale(3, RoundingMode.HALF_UP);
            if (duration.signum() <= 0) {
                throw new ValidationException("Media duration must be positive");
            }
            return duration;
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new BusinessException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Media duration validation was interrupted"
            );
        } catch (IOException | NumberFormatException exception) {
            throw new ValidationException("Media duration could not be read");
        }
    }

    private void deleteTemporaryFile(Path temporaryFile) {
        if (temporaryFile == null) {
            return;
        }
        try {
            Files.deleteIfExists(temporaryFile);
        } catch (IOException ignored) {
            // Temporary file cleanup is best effort and must not expose its path.
        }
    }
}
