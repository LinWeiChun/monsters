package com.monsters.service.auth;

import com.monsters.security.common.JwtTokenPayload;
import com.monsters.security.common.JwtTokenService;
import com.monsters.entity.user.RevokedToken;
import com.monsters.exception.common.UnauthorizedException;
import com.monsters.repository.user.RevokedTokenRepository;
import java.time.LocalDateTime;
import java.time.ZoneId;
import org.springframework.dao.DataIntegrityViolationException;
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
        storeRevocation(token, payload);
    }

    @Transactional
    public JwtTokenPayload consumeRefreshToken(String token) {
        JwtTokenPayload payload = jwtTokenService.verifyRefreshToken(token);
        storeRevocation(token, payload);
        return payload;
    }

    @Transactional
    public void revokeRefreshToken(String token) {
        consumeRefreshToken(token);
    }

    private void storeRevocation(String token, JwtTokenPayload payload) {
        String tokenHash = jwtTokenService.hashToken(token);
        revokedTokenRepository.deleteByExpiresAtBefore(LocalDateTime.now());
        if (revokedTokenRepository.existsByTokenHash(tokenHash)) {
            throw new UnauthorizedException("Invalid JWT token");
        }
        try {
            revokedTokenRepository.saveAndFlush(new RevokedToken(
                    tokenHash,
                    LocalDateTime.ofInstant(payload.expiresAt(), ZoneId.systemDefault())
            ));
        } catch (DataIntegrityViolationException exception) {
            throw new UnauthorizedException("Invalid JWT token");
        }
    }
}
