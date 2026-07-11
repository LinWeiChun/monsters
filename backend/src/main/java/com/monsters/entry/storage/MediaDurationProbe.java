package com.monsters.entry.storage;

import java.math.BigDecimal;
import org.springframework.web.multipart.MultipartFile;

public interface MediaDurationProbe {

    BigDecimal probe(MultipartFile file);
}
