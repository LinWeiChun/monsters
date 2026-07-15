package com.monsters.service.auth;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.Locale;
import java.util.Optional;
import java.util.regex.Pattern;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.monsters.dto.auth.AuthUserResponse;
import com.monsters.dto.auth.ForgotPasswordRequest;
import com.monsters.dto.auth.ForgotPasswordResponse;
import com.monsters.dto.auth.GoogleLoginRequest;
import com.monsters.dto.auth.LoginRequest;
import com.monsters.dto.auth.LoginResponse;
import com.monsters.dto.auth.RegisterRequest;
import com.monsters.dto.auth.RegisterResponse;
import com.monsters.dto.auth.ResetPasswordRequest;
import com.monsters.entity.user.PasswordResetToken;
import com.monsters.entity.user.User;
import com.monsters.entity.user.UserCredential;
import com.monsters.entity.user.UserOAuthAccount;
import com.monsters.exception.common.ConflictException;
import com.monsters.exception.common.UnauthorizedException;
import com.monsters.repository.user.PasswordResetTokenRepository;
import com.monsters.repository.user.UserCredentialRepository;
import com.monsters.repository.user.UserOAuthAccountRepository;
import com.monsters.repository.user.UserRepository;
import com.monsters.security.common.GoogleIdTokenVerifier;
import com.monsters.security.common.GoogleUserInfo;
import com.monsters.security.common.JwtProperties;
import com.monsters.security.common.JwtTokenService;
import com.monsters.security.common.PasswordResetTokenService;

@Service
public class AuthService {

	private static final long PASSWORD_RESET_TOKEN_EXPIRATION_SECONDS = 900;
	private static final int ACCOUNT_MAX_LENGTH = 50;
	private static final Pattern INVALID_ACCOUNT_CHARACTER_PATTERN = Pattern.compile("[^a-z0-9_]");

	private final UserRepository userRepository;
	private final UserCredentialRepository userCredentialRepository;
	private final UserOAuthAccountRepository userOAuthAccountRepository;
	private final PasswordResetTokenRepository passwordResetTokenRepository;
	private final PasswordEncoder passwordEncoder;
	private final JwtTokenService jwtTokenService;
	private final JwtProperties jwtProperties;
	private final GoogleIdTokenVerifier googleIdTokenVerifier;
	private final PasswordResetTokenService passwordResetTokenService;
	private final Clock clock;

	@Autowired
	public AuthService(UserRepository userRepository, UserCredentialRepository userCredentialRepository,
			UserOAuthAccountRepository userOAuthAccountRepository,
			PasswordResetTokenRepository passwordResetTokenRepository, PasswordEncoder passwordEncoder,
			JwtTokenService jwtTokenService, JwtProperties jwtProperties, GoogleIdTokenVerifier googleIdTokenVerifier,
			PasswordResetTokenService passwordResetTokenService) {
		this(userRepository, userCredentialRepository, userOAuthAccountRepository, passwordResetTokenRepository,
				passwordEncoder, jwtTokenService, jwtProperties, googleIdTokenVerifier, passwordResetTokenService,
				Clock.systemDefaultZone());
	}

	AuthService(UserRepository userRepository, UserCredentialRepository userCredentialRepository,
			UserOAuthAccountRepository userOAuthAccountRepository,
			PasswordResetTokenRepository passwordResetTokenRepository, PasswordEncoder passwordEncoder,
			JwtTokenService jwtTokenService, JwtProperties jwtProperties, GoogleIdTokenVerifier googleIdTokenVerifier,
			PasswordResetTokenService passwordResetTokenService, Clock clock) {
		this.userRepository = userRepository;
		this.userCredentialRepository = userCredentialRepository;
		this.userOAuthAccountRepository = userOAuthAccountRepository;
		this.passwordResetTokenRepository = passwordResetTokenRepository;
		this.passwordEncoder = passwordEncoder;
		this.jwtTokenService = jwtTokenService;
		this.jwtProperties = jwtProperties;
		this.googleIdTokenVerifier = googleIdTokenVerifier;
		this.passwordResetTokenService = passwordResetTokenService;
		this.clock = clock;
	}

	@Transactional
	public RegisterResponse register(RegisterRequest request) {
		String account = normalizeAccount(request.account());
		if (userRepository.existsByAccount(account)) {
			throw new ConflictException("Account already registered");
		}

		String email = normalizeEmail(request.email());
		if (userRepository.existsByEmail(email)) {
			throw new ConflictException("Email already registered");
		}

		User user = new User(account, email, request.userName().trim());
		User savedUser = userRepository.save(user);

		String passwordHash = passwordEncoder.encode(request.password());
		userCredentialRepository.save(new UserCredential(savedUser, passwordHash));

		return new RegisterResponse(savedUser.getId(), savedUser.getAccount(), savedUser.getEmail(),
				savedUser.getUserName());
	}

	@Transactional(readOnly = true)
	public LoginResponse login(LoginRequest request) {
		String email = normalizeEmail(request.email());

		User user = userRepository.findByEmailOrAccountAndDeletedFalse(email)
				.orElseThrow(() -> new UnauthorizedException("Invalid email or password"));

		UserCredential credential = userCredentialRepository.findByUser(user)
				.orElseThrow(() -> new UnauthorizedException("Invalid email or password"));

		if (!passwordEncoder.matches(request.password(), credential.getPasswordHash())) {
			throw new UnauthorizedException("Invalid email or password");
		}

		return createLoginResponse(user);
	}

	@Transactional
	public LoginResponse googleLogin(GoogleLoginRequest request) {
		GoogleUserInfo googleUser = googleIdTokenVerifier.verify(request.idToken());
		Optional<UserOAuthAccount> oauthAccount = userOAuthAccountRepository
				.findByProviderAndProviderUserId(UserOAuthAccount.PROVIDER_GOOGLE, googleUser.providerUserId());
		if (oauthAccount.isPresent() && oauthAccount.get().getUser().isDeleted()) {
			throw new UnauthorizedException("Invalid Google ID token");
		}

		User user = oauthAccount.map(UserOAuthAccount::getUser).orElseGet(() -> findOrCreateGoogleUser(googleUser));

		return createLoginResponse(user);
	}

	@Transactional
	public ForgotPasswordResponse forgotPassword(ForgotPasswordRequest request) {
		String email = normalizeEmail(request.email());
		Optional<User> user = userRepository.findByEmailAndDeletedFalse(email);
		if (user.isEmpty()) {
			return new ForgotPasswordResponse(null, PASSWORD_RESET_TOKEN_EXPIRATION_SECONDS);
		}

		passwordResetTokenRepository.deleteByUserAndUsedAtIsNull(user.get());
		String resetToken = passwordResetTokenService.createToken();
		String tokenHash = passwordResetTokenService.hashToken(resetToken);
		LocalDateTime expiresAt = now().plusSeconds(PASSWORD_RESET_TOKEN_EXPIRATION_SECONDS);
		passwordResetTokenRepository.save(new PasswordResetToken(user.get(), tokenHash, expiresAt));

		return new ForgotPasswordResponse(resetToken, PASSWORD_RESET_TOKEN_EXPIRATION_SECONDS);
	}

	@Transactional
	public void resetPassword(ResetPasswordRequest request) {
		String tokenHash = passwordResetTokenService.hashToken(request.resetToken());
		PasswordResetToken resetToken = passwordResetTokenRepository.findByTokenHashAndUsedAtIsNull(tokenHash)
				.orElseThrow(() -> new UnauthorizedException("Invalid password reset token"));
		LocalDateTime now = now();
		if (resetToken.isExpired(now) || resetToken.getUser().isDeleted()) {
			throw new UnauthorizedException("Invalid password reset token");
		}

		String passwordHash = passwordEncoder.encode(request.newPassword());
		User user = resetToken.getUser();
		userCredentialRepository.findByUser(user).ifPresentOrElse(
				credential -> credential.updatePasswordHash(passwordHash),
				() -> userCredentialRepository.save(new UserCredential(user, passwordHash)));
		resetToken.markUsed(now);
	}

	private User findOrCreateGoogleUser(GoogleUserInfo googleUser) {
		String email = normalizeEmail(googleUser.email());
		User user = userRepository.findByEmailAndDeletedFalse(email).orElseGet(
				() -> userRepository.save(new User(uniqueGoogleAccount(email), email, displayName(googleUser))));

		userOAuthAccountRepository
				.save(new UserOAuthAccount(user, UserOAuthAccount.PROVIDER_GOOGLE, googleUser.providerUserId()));

		return user;
	}

	private LoginResponse createLoginResponse(User user) {
		AuthUserResponse authUser = new AuthUserResponse(user.getId(), user.getAccount(), user.getEmail(),
				user.getUserName(), user.getAvatarUrl());
		return new LoginResponse(jwtTokenService.createAccessToken(user), jwtTokenService.createRefreshToken(user),
				"Bearer", jwtProperties.accessTokenExpirationSeconds(), authUser);
	}

	private String displayName(GoogleUserInfo googleUser) {
		if (googleUser.name() != null && !googleUser.name().isBlank()) {
			return googleUser.name().trim();
		}
		return googleUser.email().split("@")[0];
	}

	private String normalizeEmail(String email) {
		return email.trim().toLowerCase(Locale.ROOT);
	}

	private String normalizeAccount(String account) {
		return account.trim().toLowerCase(Locale.ROOT);
	}

	private String uniqueGoogleAccount(String email) {
		String baseAccount = googleAccountBase(email);
		String account = baseAccount;
		int suffix = 1;
		while (userRepository.existsByAccount(account)) {
			String suffixText = "_" + suffix;
			int baseMaxLength = ACCOUNT_MAX_LENGTH - suffixText.length();
			account = baseAccount.substring(0, Math.min(baseAccount.length(), baseMaxLength)) + suffixText;
			suffix++;
		}
		return account;
	}

	private String googleAccountBase(String email) {
		String localPart = email.split("@")[0].toLowerCase(Locale.ROOT);
		String sanitized = INVALID_ACCOUNT_CHARACTER_PATTERN.matcher(localPart).replaceAll("_");
		sanitized = sanitized.replaceAll("_+", "_").replaceAll("^_+", "").replaceAll("_+$", "");
		if (sanitized.isBlank() || !Character.isLetter(sanitized.charAt(0))) {
			sanitized = "user_" + sanitized;
		}
		if (sanitized.length() < 4) {
			sanitized = (sanitized + "_user").substring(0, 4);
		}
		if (sanitized.length() > ACCOUNT_MAX_LENGTH) {
			sanitized = sanitized.substring(0, ACCOUNT_MAX_LENGTH);
		}
		return sanitized;
	}

	private LocalDateTime now() {
		return LocalDateTime.now(clock);
	}
}
