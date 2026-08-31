class AppRoute {
  const AppRoute._();

  static const annoyanceChat = 'annoyanceChat';
  static const diaryChat = 'diaryChat';
  static const splash = 'splash';
  static const home = 'home';
  static const login = 'login';
  static const register = 'register';
  static const emailVerificationPending = 'emailVerificationPending';
  static const emailVerification = 'emailVerification';
  static const profile = 'profile';
  static const passwordLock = 'passwordLock';
  static const eligibility = 'eligibility';
  static const guardianConsent = 'guardianConsent';
  static const sessions = 'sessions';
  static const googleAccountLink = 'googleAccountLink';
  static const passwordResetRequest = 'passwordResetRequest';
  static const passwordReset = 'passwordReset';
}

class AppPath {
  const AppPath._();

  static const annoyanceChat = '/annoyances/new';
  static const diaryChat = '/diaries/new';
  static const splash = '/';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const emailVerificationPending = '/register/email-pending';
  static const emailVerification = '/verify-email';
  static const profile = '/profile';
  static const passwordLock = '/password-lock';
  static const eligibility = '/complete-eligibility';
  static const guardianConsent = '/guardian-consent';
  static const sessions = '/profile/sessions';
  static const googleAccountLink = '/link-google-account';
  static const passwordResetRequest = '/forgot-password';
  static const passwordReset = '/reset-password';
}
