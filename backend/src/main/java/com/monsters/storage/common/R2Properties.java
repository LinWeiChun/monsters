package com.monsters.storage.common;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.storage.r2")
public class R2Properties {

    private String accountId = "";
    private String accessKeyId = "";
    private String secretAccessKey = "";
    private String bucket = "";
    private String publicBaseUrl = "";
    private String avatarKeyPrefix = "users/avatars";
    private long maxAvatarSizeBytes = 5 * 1024 * 1024;
    private String entryMediaBucket = "";
    private String entryMediaKeyPrefix = "entries/media";
    private long maxEntryImageSizeBytes = 5 * 1024 * 1024;
    private long maxEntryAudioSizeBytes = 10 * 1024 * 1024;
    private long maxEntryVideoSizeBytes = 50 * 1024 * 1024;
    private long maxEntryDrawingSizeBytes = 5 * 1024 * 1024;
    private long maxEntryAudioDurationSeconds = 5 * 60;
    private long maxEntryVideoDurationSeconds = 60;
    private String ffprobePath = "ffprobe";
    private long ffprobeTimeoutSeconds = 10;

    public String accountId() {
        return accountId;
    }

    public void setAccountId(String accountId) {
        this.accountId = accountId;
    }

    public String accessKeyId() {
        return accessKeyId;
    }

    public void setAccessKeyId(String accessKeyId) {
        this.accessKeyId = accessKeyId;
    }

    public String secretAccessKey() {
        return secretAccessKey;
    }

    public void setSecretAccessKey(String secretAccessKey) {
        this.secretAccessKey = secretAccessKey;
    }

    public String bucket() {
        return bucket;
    }

    public void setBucket(String bucket) {
        this.bucket = bucket;
    }

    public String publicBaseUrl() {
        return publicBaseUrl;
    }

    public void setPublicBaseUrl(String publicBaseUrl) {
        this.publicBaseUrl = publicBaseUrl;
    }

    public String avatarKeyPrefix() {
        return avatarKeyPrefix;
    }

    public void setAvatarKeyPrefix(String avatarKeyPrefix) {
        this.avatarKeyPrefix = avatarKeyPrefix;
    }

    public long maxAvatarSizeBytes() {
        return maxAvatarSizeBytes;
    }

    public void setMaxAvatarSizeBytes(long maxAvatarSizeBytes) {
        this.maxAvatarSizeBytes = maxAvatarSizeBytes;
    }

    public String entryMediaKeyPrefix() {
        return entryMediaKeyPrefix;
    }

    public String entryMediaBucket() {
        return entryMediaBucket;
    }

    public void setEntryMediaBucket(String entryMediaBucket) {
        this.entryMediaBucket = entryMediaBucket;
    }

    public void setEntryMediaKeyPrefix(String entryMediaKeyPrefix) {
        this.entryMediaKeyPrefix = entryMediaKeyPrefix;
    }

    public long maxEntryImageSizeBytes() {
        return maxEntryImageSizeBytes;
    }

    public void setMaxEntryImageSizeBytes(long maxEntryImageSizeBytes) {
        this.maxEntryImageSizeBytes = maxEntryImageSizeBytes;
    }

    public long maxEntryAudioSizeBytes() {
        return maxEntryAudioSizeBytes;
    }

    public void setMaxEntryAudioSizeBytes(long maxEntryAudioSizeBytes) {
        this.maxEntryAudioSizeBytes = maxEntryAudioSizeBytes;
    }

    public long maxEntryVideoSizeBytes() {
        return maxEntryVideoSizeBytes;
    }

    public void setMaxEntryVideoSizeBytes(long maxEntryVideoSizeBytes) {
        this.maxEntryVideoSizeBytes = maxEntryVideoSizeBytes;
    }

    public long maxEntryDrawingSizeBytes() {
        return maxEntryDrawingSizeBytes;
    }

    public void setMaxEntryDrawingSizeBytes(long maxEntryDrawingSizeBytes) {
        this.maxEntryDrawingSizeBytes = maxEntryDrawingSizeBytes;
    }

    public long maxEntryAudioDurationSeconds() {
        return maxEntryAudioDurationSeconds;
    }

    public void setMaxEntryAudioDurationSeconds(long maxEntryAudioDurationSeconds) {
        this.maxEntryAudioDurationSeconds = maxEntryAudioDurationSeconds;
    }

    public long maxEntryVideoDurationSeconds() {
        return maxEntryVideoDurationSeconds;
    }

    public void setMaxEntryVideoDurationSeconds(long maxEntryVideoDurationSeconds) {
        this.maxEntryVideoDurationSeconds = maxEntryVideoDurationSeconds;
    }

    public String ffprobePath() {
        return ffprobePath;
    }

    public void setFfprobePath(String ffprobePath) {
        this.ffprobePath = ffprobePath;
    }

    public long ffprobeTimeoutSeconds() {
        return ffprobeTimeoutSeconds;
    }

    public void setFfprobeTimeoutSeconds(long ffprobeTimeoutSeconds) {
        this.ffprobeTimeoutSeconds = ffprobeTimeoutSeconds;
    }
}
