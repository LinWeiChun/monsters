package com.monsters.entry.storage;

import com.monsters.entry.entity.EntryMediaType;
import org.springframework.web.multipart.MultipartFile;

public interface EntryMediaStorageService {

    StoredEntryMedia upload(Long userId, EntryMediaType mediaType, MultipartFile file);

    DownloadedEntryMedia download(String objectKey, String rangeHeader);

    void delete(String objectKey);
}
