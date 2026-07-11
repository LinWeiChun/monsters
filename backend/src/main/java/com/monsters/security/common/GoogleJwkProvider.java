package com.monsters.security.common;

import java.util.Map;

public interface GoogleJwkProvider {

    Map<String, Object> getKey(String keyId);
}
