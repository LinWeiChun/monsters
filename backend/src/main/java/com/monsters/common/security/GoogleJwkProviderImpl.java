package com.monsters.common.security;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Clock;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class GoogleJwkProviderImpl implements GoogleJwkProvider {

    private static final URI GOOGLE_JWKS_URI = URI.create("https://www.googleapis.com/oauth2/v3/certs");
    private static final long CACHE_SECONDS = 3600;

    private final HttpClient httpClient;
    private final ObjectMapper objectMapper;
    private final Clock clock;
    private final Map<String, Object> keyCache = new ConcurrentHashMap<>();
    private Instant cacheExpiresAt = Instant.EPOCH;

    @Autowired
    public GoogleJwkProviderImpl(ObjectMapper objectMapper) {
        this(HttpClient.newHttpClient(), objectMapper, Clock.systemUTC());
    }

    GoogleJwkProviderImpl(HttpClient httpClient, ObjectMapper objectMapper, Clock clock) {
        this.httpClient = httpClient;
        this.objectMapper = objectMapper;
        this.clock = clock;
    }

    @Override
    public Map<String, Object> getKey(String keyId) {
        refreshCacheIfNeeded();
        Object key = keyCache.get(keyId);
        if (!(key instanceof Map<?, ?> keyMap)) {
            throw new IllegalStateException("Google signing key not found");
        }
        return castToStringObjectMap(keyMap);
    }

    private synchronized void refreshCacheIfNeeded() {
        if (Instant.now(clock).isBefore(cacheExpiresAt) && !keyCache.isEmpty()) {
            return;
        }
        try {
            HttpRequest request = HttpRequest.newBuilder(GOOGLE_JWKS_URI).GET().build();
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                throw new IllegalStateException("Google signing keys request failed");
            }
            Map<String, Object> body = objectMapper.readValue(
                    response.body(),
                    new TypeReference<Map<String, Object>>() {
                    }
            );
            Object keys = body.get("keys");
            if (!(keys instanceof List<?> keyList)) {
                throw new IllegalStateException("Google signing keys response is invalid");
            }
            keyCache.clear();
            for (Object key : keyList) {
                if (key instanceof Map<?, ?> keyMap && keyMap.get("kid") instanceof String keyId) {
                    keyCache.put(keyId, castToStringObjectMap(keyMap));
                }
            }
            cacheExpiresAt = Instant.now(clock).plusSeconds(CACHE_SECONDS);
        } catch (Exception exception) {
            throw new IllegalStateException("Google signing keys request failed", exception);
        }
    }

    private Map<String, Object> castToStringObjectMap(Map<?, ?> source) {
        return source.entrySet().stream()
                .filter(entry -> entry.getKey() instanceof String)
                .collect(Collectors.toMap(entry -> (String) entry.getKey(), Map.Entry::getValue));
    }
}
