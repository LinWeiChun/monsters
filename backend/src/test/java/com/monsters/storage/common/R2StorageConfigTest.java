package com.monsters.storage.common;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import software.amazon.awssdk.services.s3.S3Client;

class R2StorageConfigTest {

    @Test
    void clientShouldUseCloudflareAutoRegion() {
        R2Properties properties = new R2Properties();
        properties.setAccountId("account");
        properties.setAccessKeyId("access-key");
        properties.setSecretAccessKey("secret-key");

        try (S3Client client = new R2StorageConfig().r2S3Client(properties)) {
            assertThat(client.serviceClientConfiguration().region().id()).isEqualTo("auto");
        }
    }
}
