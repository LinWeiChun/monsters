package com.monsters.security.session;

import java.util.Locale;

public record SessionDeviceContext(
        SessionDeviceType type,
        String summary
) {

    private static final String UNKNOWN_SUMMARY = "Unknown device";

    public static SessionDeviceContext unknown() {
        return new SessionDeviceContext(SessionDeviceType.UNKNOWN, UNKNOWN_SUMMARY);
    }

    public static SessionDeviceContext resolve(String clientPlatform, String userAgent) {
        if (clientPlatform == null) {
            return unknown();
        }
        return switch (clientPlatform.trim().toUpperCase(Locale.ROOT)) {
            case "ANDROID" -> new SessionDeviceContext(SessionDeviceType.ANDROID, "Android App");
            case "IOS" -> new SessionDeviceContext(SessionDeviceType.IOS, "iOS App");
            case "WEB" -> new SessionDeviceContext(SessionDeviceType.WEB, webSummary(userAgent));
            default -> unknown();
        };
    }

    private static String webSummary(String userAgent) {
        if (userAgent == null || userAgent.isBlank()) {
            return "Web Browser";
        }
        String browser = userAgent.contains("Edg/") ? "Edge"
                : userAgent.contains("Chrome/") ? "Chrome"
                : userAgent.contains("Firefox/") ? "Firefox"
                : userAgent.contains("Safari/") ? "Safari"
                : "Web Browser";
        String operatingSystem = userAgent.contains("Macintosh") ? "macOS"
                : userAgent.contains("Windows") ? "Windows"
                : userAgent.contains("Android") ? "Android"
                : userAgent.contains("iPhone") || userAgent.contains("iPad") ? "iOS"
                : "Unknown OS";
        return browser + " on " + operatingSystem;
    }
}
