package com.monsters.service.entry;

import java.io.InputStream;

public record EntryMediaDownloadResult(
        InputStream content,
        String contentType,
        long contentLength,
        String contentRange
) {
}
