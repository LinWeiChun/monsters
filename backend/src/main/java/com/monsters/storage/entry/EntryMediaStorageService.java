package com.monsters.storage.entry;

import com.monsters.entity.entry.EntryMediaType;
import org.springframework.web.multipart.MultipartFile;

public interface EntryMediaStorageService {

    StoredEntryMedia upload(Long userId, EntryMediaType mediaType, MultipartFile file);

    DownloadedEntryMedia download(String objectKey, String rangeHeader);

    void delete(String objectKey);
}
