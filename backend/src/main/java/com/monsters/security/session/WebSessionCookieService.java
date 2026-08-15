package com.monsters.security.session;

import com.monsters.exception.common.BusinessException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import java.time.Duration;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseCookie;
import org.springframework.stereotype.Component;
import org.springframework.util.PatternMatchUtils;
import org.springframework.util.StringUtils;

@Component
public class WebSessionCookieService {

    public static final String TRANSPORT_HEADER = "X-Session-Transport";
    public static final String TRANSPORT_COOKIE = "COOKIE";
    public static final String CSRF_HEADER = "X-CSRF-Protection";
    public static final String CSRF_VALUE = "1";
    public static final String COOKIE_NAME = "__Host-monsters-refresh";

    private final WebSessionProperties properties;

    public WebSessionCookieService(WebSessionProperties properties) {
        this.properties = properties;
    }

    public boolean usesCookieTransport(HttpServletRequest request) {
        String transport = request.getHeader(TRANSPORT_HEADER);
        return transport != null && TRANSPORT_COOKIE.equalsIgnoreCase(transport);
    }

    public void requireTrustedRequest(HttpServletRequest request) {
        String origin = request.getHeader("Origin");
        boolean trustedOrigin = origin != null
                && properties.trustedOriginPatterns().stream()
                        .anyMatch(pattern -> PatternMatchUtils.simpleMatch(pattern, origin));
        boolean validCsrfHeader = CSRF_VALUE.equals(request.getHeader(CSRF_HEADER));
        if (!trustedOrigin || !validCsrfHeader) {
            throw new BusinessException(
                    HttpStatus.FORBIDDEN,
                    "WEB_SESSION_REQUEST_REJECTED",
                    "Web session request origin or CSRF proof is invalid"
            );
        }
    }

    public ResponseCookie issue(String refreshCredential) {
        return ResponseCookie.from(COOKIE_NAME, refreshCredential)
                .httpOnly(true)
                .secure(true)
                .sameSite("None")
                .path("/")
                .maxAge(Duration.ofSeconds(properties.cookieMaxAgeSeconds()))
                .build();
    }

    public ResponseCookie expire() {
        return ResponseCookie.from(COOKIE_NAME, "")
                .httpOnly(true)
                .secure(true)
                .sameSite("None")
                .path("/")
                .maxAge(Duration.ZERO)
                .build();
    }

    public String refreshCredential(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (COOKIE_NAME.equals(cookie.getName()) && StringUtils.hasText(cookie.getValue())) {
                    return cookie.getValue();
                }
            }
        }
        throw new BusinessException(
                HttpStatus.UNAUTHORIZED,
                "AUTH_SESSION_INVALID",
                "Authentication session is invalid"
        );
    }
}
