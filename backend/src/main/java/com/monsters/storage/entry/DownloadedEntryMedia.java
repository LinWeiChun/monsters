package com.monsters.storage.entry;

import java.io.IOException;
import java.io.InputStream;

public record DownloadedEntryMedia(
        InputStream content,
        String contentType,
        long contentLength,
        String contentRange
) implements AutoCloseable {

    @Override
    public void close() throws IOException {
        content.close();
    }
}
