package com.monsters.service.auth;

import com.monsters.security.common.JwtTokenPayload;
import com.monsters.security.common.JwtTokenService;
import com.monsters.entity.user.RevokedToken;
import com.monsters.repository.user.RevokedTokenRepository;
import java.time.LocalDateTime;
import java.time.ZoneId;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class TokenRevocationService {

    private final JwtTokenService jwtTokenService;
    private final RevokedTokenRepository revokedTokenRepository;

    public TokenRevocationService(
            JwtTokenService jwtTokenService,
            RevokedTokenRepository revokedTokenRepository
    ) {
        this.jwtTokenService = jwtTokenService;
        this.revokedTokenRepository = revokedTokenRepository;
    }

    @Transactional
    public void revokeAccessToken(String token) {
        JwtTokenPayload payload = jwtTokenService.verifyAccessToken(token);
        String tokenHash = jwtTokenService.hashToken(token);
        revokedTokenRepository.deleteByExpiresAtBefore(LocalDateTime.now());
        if (!revokedTokenRepository.existsByTokenHash(tokenHash)) {
            revokedTokenRepository.save(new RevokedToken(
                    tokenHash,
                    LocalDateTime.ofInstant(payload.expiresAt(), ZoneId.systemDefault())
            ));
        }
    }
}
