package com.monsters.common.security;

import java.util.Map;

public interface GoogleJwkProvider {

    Map<String, Object> getKey(String keyId);
}
