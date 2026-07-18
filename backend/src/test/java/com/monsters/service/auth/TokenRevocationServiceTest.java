package com.monsters.service.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.security.common.JwtTokenPayload;
import com.monsters.security.common.JwtTokenService;
import com.monsters.entity.user.RevokedToken;
import com.monsters.repository.user.RevokedTokenRepository;
import java.time.Instant;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class TokenRevocationServiceTest {

    @Mock
    private JwtTokenService jwtTokenService;

    @Mock
    private RevokedTokenRepository revokedTokenRepository;

    @Test
    void revokeAccessTokenShouldStoreTokenHashAndExpiration() {
        TokenRevocationService service = new TokenRevocationService(jwtTokenService, revokedTokenRepository);
        JwtTokenPayload payload = new JwtTokenPayload(
                1L,
                "user@example.com",
                "access",
                Instant.now(),
                Instant.now().plusSeconds(3600)
        );
        when(jwtTokenService.verifyAccessToken("access-token")).thenReturn(payload);
        when(jwtTokenService.hashToken("access-token")).thenReturn("token-hash");
        when(revokedTokenRepository.existsByTokenHash("token-hash")).thenReturn(false);

        service.revokeAccessToken("access-token");

        ArgumentCaptor<RevokedToken> tokenCaptor = ArgumentCaptor.forClass(RevokedToken.class);
        verify(revokedTokenRepository).saveAndFlush(tokenCaptor.capture());
        assertThat(tokenCaptor.getValue().getTokenHash()).isEqualTo("token-hash");
        assertThat(tokenCaptor.getValue().getExpiresAt()).isNotNull();
    }

    @Test
    void consumeRefreshTokenShouldStoreRotationAndReturnPayload() {
        TokenRevocationService service = new TokenRevocationService(jwtTokenService, revokedTokenRepository);
        JwtTokenPayload payload = new JwtTokenPayload(
                1L,
                "user@example.com",
                "refresh",
                Instant.now(),
                Instant.now().plusSeconds(2592000)
        );
        when(jwtTokenService.verifyRefreshToken("refresh-token")).thenReturn(payload);
        when(jwtTokenService.hashToken("refresh-token")).thenReturn("refresh-hash");
        when(revokedTokenRepository.existsByTokenHash("refresh-hash")).thenReturn(false);

        JwtTokenPayload consumed = service.consumeRefreshToken("refresh-token");

        assertThat(consumed).isEqualTo(payload);
        ArgumentCaptor<RevokedToken> tokenCaptor = ArgumentCaptor.forClass(RevokedToken.class);
        verify(revokedTokenRepository).saveAndFlush(tokenCaptor.capture());
        assertThat(tokenCaptor.getValue().getTokenHash()).isEqualTo("refresh-hash");
    }

    @Test
    void consumeRefreshTokenShouldRejectPreviouslyRotatedToken() {
        TokenRevocationService service = new TokenRevocationService(jwtTokenService, revokedTokenRepository);
        JwtTokenPayload payload = new JwtTokenPayload(
                1L,
                "user@example.com",
                "refresh",
                Instant.now(),
                Instant.now().plusSeconds(2592000)
        );
        when(jwtTokenService.verifyRefreshToken("refresh-token")).thenReturn(payload);
        when(jwtTokenService.hashToken("refresh-token")).thenReturn("refresh-hash");
        when(revokedTokenRepository.existsByTokenHash("refresh-hash")).thenReturn(true);

        assertThatThrownBy(() -> service.consumeRefreshToken("refresh-token"))
                .isInstanceOf(com.monsters.exception.common.UnauthorizedException.class);
    }
}
