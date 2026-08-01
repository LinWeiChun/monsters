package com.monsters.security.common;

import com.monsters.service.auth.ContinuationCredentialService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class ContinuationAuthenticationFilter extends OncePerRequestFilter {
    private static final String PREFIX = "Continuation ";
    public static final String ERROR_CODE_ATTRIBUTE = "continuation.error.code";
    private final ObjectProvider<ContinuationCredentialService> credentialsProvider;
    public ContinuationAuthenticationFilter(ObjectProvider<ContinuationCredentialService> credentialsProvider) {
        this.credentialsProvider = credentialsProvider;
    }
    @Override protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
            FilterChain chain) throws ServletException, IOException {
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith(PREFIX)
                && SecurityContextHolder.getContext().getAuthentication() == null) {
            try {
                ContinuationCredentialService credentials = credentialsProvider.getIfAvailable();
                if (credentials == null) { chain.doFilter(request, response); return; }
                var user = credentials.authenticateEligibility(header.substring(PREFIX.length()).trim());
                var auth = new UsernamePasswordAuthenticationToken(
                        new ContinuationAuthenticatedMember(user.getId()), null,
                        List.of(new SimpleGrantedAuthority("CONTINUATION_COMPLETE_ELIGIBILITY")));
                auth.setDetails(header.substring(PREFIX.length()).trim());
                SecurityContextHolder.getContext().setAuthentication(auth);
            } catch (RuntimeException ignored) {
                SecurityContextHolder.clearContext();
                request.setAttribute(ERROR_CODE_ATTRIBUTE, "ELIGIBILITY_CONTINUATION_INVALID");
            }
        }
        chain.doFilter(request, response);
    }
}
