package com.monsters.security.common;

import com.monsters.repository.user.RevokedTokenRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.entity.user.MemberState;
import com.monsters.exception.common.UnauthorizedException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final String AUTHORIZATION_HEADER = "Authorization";
    private static final String BEARER_PREFIX = "Bearer ";

    private final JwtTokenService jwtTokenService;
    private final RevokedTokenRepository revokedTokenRepository;
    private final ObjectProvider<UserRepository> userRepositoryProvider;

    public JwtAuthenticationFilter(
            JwtTokenService jwtTokenService,
            RevokedTokenRepository revokedTokenRepository,
            ObjectProvider<UserRepository> userRepositoryProvider
    ) {
        this.jwtTokenService = jwtTokenService;
        this.revokedTokenRepository = revokedTokenRepository;
        this.userRepositoryProvider = userRepositoryProvider;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        String token = bearerToken(request);
        if (token != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            try {
                String tokenHash = jwtTokenService.hashToken(token);
                if (!revokedTokenRepository.existsByTokenHash(tokenHash)) {
                    JwtTokenPayload payload = jwtTokenService.verifyAccessToken(token);
                    UserRepository userRepository = userRepositoryProvider.getIfAvailable();
                    boolean active = userRepository == null || userRepository.findByIdAndDeletedFalse(payload.userId())
                            .map(user -> user.getMemberState() == MemberState.ACTIVE).orElse(false);
                    if (!active) {
                        SecurityContextHolder.clearContext();
                        filterChain.doFilter(request, response);
                        return;
                    }
                    AuthenticatedUser principal = new AuthenticatedUser(payload.userId(), payload.email());
                    UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                            principal,
                            null,
                            List.of(new SimpleGrantedAuthority("ROLE_USER"))
                    );
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                }
            } catch (UnauthorizedException exception) {
                SecurityContextHolder.clearContext();
            }
        }
        filterChain.doFilter(request, response);
    }

    private String bearerToken(HttpServletRequest request) {
        String header = request.getHeader(AUTHORIZATION_HEADER);
        if (header == null || !header.startsWith(BEARER_PREFIX)) {
            return null;
        }
        String token = header.substring(BEARER_PREFIX.length()).trim();
        if (token.isBlank()) {
            return null;
        }
        return token;
    }
}
