package com.monsters.common.storage;

import java.net.URI;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;

@Configuration
@EnableConfigurationProperties(R2Properties.class)
public class R2StorageConfig {

    @Bean
    public S3Client r2S3Client(R2Properties properties) {
        return S3Client.builder()
                .endpointOverride(URI.create("https://" + valueOrDefault(
                        properties.accountId(),
                        "local"
                ) + ".r2.cloudflarestorage.com"))
                .credentialsProvider(StaticCredentialsProvider.create(
                        AwsBasicCredentials.create(
                                valueOrDefault(properties.accessKeyId(), "unused"),
                                valueOrDefault(properties.secretAccessKey(), "unused")
                        )
                ))
                .region(Region.US_EAST_1)
                .build();
    }

    private String valueOrDefault(String value, String defaultValue) {
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        return value;
    }
}
