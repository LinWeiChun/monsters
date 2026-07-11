package com.monsters.storage.common;

import org.springframework.web.multipart.MultipartFile;

public interface AvatarStorageService {

    String uploadAvatar(Long userId, MultipartFile file);
}
