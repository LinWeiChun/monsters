package com.monsters.auth.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.monsters.common.security.JwtTokenPayload;
import com.monsters.common.security.JwtTokenService;
import com.monsters.user.entity.RevokedToken;
import com.monsters.user.repository.RevokedTokenRepository;
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
        verify(revokedTokenRepository).save(tokenCaptor.capture());
        assertThat(tokenCaptor.getValue().getTokenHash()).isEqualTo("token-hash");
        assertThat(tokenCaptor.getValue().getExpiresAt()).isNotNull();
    }
}
