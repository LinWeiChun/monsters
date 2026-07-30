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
}
