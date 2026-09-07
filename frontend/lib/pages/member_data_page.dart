import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../layout/responsive_layout.dart';
import '../models/member_profile.dart';
import '../theme/app_colors.dart';
import '../widgets/navigation/app_navigation.dart';
import '../widgets/member/member_sensitive_dialog.dart';
import '../providers/auth_provider.dart';
import '../providers/member_data_provider.dart';
import '../routes/app_routes.dart';
import '../widgets/state/error_view.dart';
import '../widgets/state/loading_view.dart';

class MemberDataPage extends ConsumerStatefulWidget {
  const MemberDataPage({super.key});

  @override
  ConsumerState<MemberDataPage> createState() => _MemberDataPageState();
}

class _MemberDataPageState extends ConsumerState<MemberDataPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(memberDataControllerProvider.notifier).loadProfile(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memberDataControllerProvider);
    if (state.isLoading && state.profile == null) {
      return const Scaffold(body: LoadingView(message: '正在讀取會員資料'));
    }
    final profile = state.profile;
    if (profile == null) {
      return Scaffold(
        body: ErrorView(
          message: state.errorMessage ?? '無法取得會員資料',
          onRetry:
              () =>
                  ref.read(memberDataControllerProvider.notifier).loadProfile(),
        ),
      );
    }

    Widget canvas({required bool mobile, bool desktop = false}) =>
        _MemberDataCanvas(
          profile: profile,
          mobile: mobile,
          desktop: desktop,
          isSaving: state.isSaving,
          errorMessage: state.errorMessage,
          onReload:
              () =>
                  ref.read(memberDataControllerProvider.notifier).loadProfile(),
          onNickname: _editNickname,
          onEmail: _changeEmail,
          onBirthday: _correctBirthday,
          onSessions: () => context.pushNamed(AppRoute.sessions),
          onDeactivate: _deactivate,
          onLogout: _logout,
          onHome: () => context.goNamed(AppRoute.home),
        );

    return Scaffold(
      backgroundColor: _MemberColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          mobile:
              (context, constraints) => Center(
                child: FittedBox(
                  key: const Key('memberDataViewport'),
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: 390,
                    height: 844,
                    child: canvas(mobile: true),
                  ),
                ),
              ),
          tablet: (context, constraints) => canvas(mobile: false),
          desktop:
              (context, constraints) => canvas(mobile: false, desktop: true),
        ),
      ),
    );
  }

  Future<void> _editNickname() async {
    final profile = ref.read(memberDataControllerProvider).profile!;
    var nickname = profile.publicNickname;
    var confirmed = false;
    final submitted = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('編輯公開暱稱'),
                  content: SizedBox(
                    width: 480,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          key: const Key('memberNicknameField'),
                          initialValue: nickname,
                          onChanged:
                              (value) => setDialogState(() => nickname = value),
                          maxLength: 120,
                          decoration: const InputDecoration(labelText: '新暱稱'),
                        ),
                        const Text('送出後，既有社群內容會立即顯示新暱稱。'),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: confirmed,
                          title: const Text('我了解既有社群內容也會更新'),
                          onChanged:
                              (value) => setDialogState(
                                () => confirmed = value ?? false,
                              ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('取消'),
                    ),
                    FilledButton(
                      key: const Key('memberNicknameSubmit'),
                      onPressed:
                          confirmed && nickname.trim().isNotEmpty
                              ? () => Navigator.pop(dialogContext, true)
                              : null,
                      child: const Text('儲存暱稱'),
                    ),
                  ],
                ),
          ),
    );
    if (submitted != true || !mounted) return;
    final success = await ref
        .read(memberDataControllerProvider.notifier)
        .updatePublicNickname(publicNickname: nickname);
    if (!mounted) return;
    _showResult(success ? '公開暱稱已更新' : null);
  }

  Future<void> _changeEmail() async {
    final input = await _showSensitiveDialog(
      title: '變更 Email',
      fieldLabel: '新 Email',
      fieldHint: 'new.member@example.com',
    );
    if (input == null || !mounted) return;
    final success = await ref
        .read(memberDataControllerProvider.notifier)
        .requestEmailChange(
          newEmail: input.value,
          password: input.password,
          useGoogle: input.useGoogle,
          reauthentication: input.reauthentication,
        );
    if (!mounted) return;
    _showResult(success ? '申請已送出，請至新 Email 收取驗證信；目前 Email 尚未變更' : null);
  }

  Future<void> _correctBirthday() async {
    final input = await _showSensitiveDialog(
      title: '申請生日更正',
      fieldLabel: '新生日',
      fieldHint: 'yyyy-MM-dd',
      showReason: true,
    );
    if (input == null || !mounted) return;
    final result = await ref
        .read(memberDataControllerProvider.notifier)
        .requestBirthdayCorrection(
          birthday: input.value,
          reason: input.reason,
          password: input.password,
          useGoogle: input.useGoogle,
          reauthentication: input.reauthentication,
        );
    if (!mounted || result == null) {
      if (mounted) _showResult(null);
      return;
    }
    if (!result.restricted) {
      _showResult(result.status == 'AUTO_APPROVED' ? '生日已完成更正' : '生日更正已送出');
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('生日更正待審'),
            content: const Text('申請跨越資格區間，已立即套用保守限制並登出所有裝置。這不代表更正已核准。'),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('回到登入'),
              ),
            ],
          ),
    );
    await ref.read(authControllerProvider.notifier).completeRemoteLogout();
    if (mounted) context.goNamed(AppRoute.login);
  }

  Future<MemberSensitiveInput?> _showSensitiveDialog({
    required String title,
    required String fieldLabel,
    required String fieldHint,
    bool showReason = false,
  }) => showDialog<MemberSensitiveInput>(
    context: context,
    builder:
        (context) => MemberSensitiveDialog(
          title: title,
          fieldLabel: fieldLabel,
          fieldHint: fieldHint,
          showReason: showReason,
        ),
  );

  Future<void> _deactivate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('確定要停用帳號嗎？'),
            content: const Text('所有裝置會立即登出，公開內容會取消分享；恢復帳號後不會自動重新分享。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              FilledButton(
                key: const Key('memberDeactivateConfirm'),
                style: FilledButton.styleFrom(
                  backgroundColor: _MemberColors.danger,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('停用帳號'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;
    final success =
        await ref.read(memberDataControllerProvider.notifier).deactivate();
    if (!mounted) return;
    if (!success) {
      _showResult(null);
      return;
    }
    await ref.read(authControllerProvider.notifier).completeRemoteLogout();
    if (mounted) context.goNamed(AppRoute.memberDeactivated);
  }

  void _showResult(String? successMessage) {
    final state = ref.read(memberDataControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successMessage ?? state.errorMessage ?? '操作失敗')),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('登出此裝置？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('確認登出'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) context.goNamed(AppRoute.login);
  }
}

class _MemberDataCanvas extends StatelessWidget {
  const _MemberDataCanvas({
    required this.profile,
    required this.mobile,
    this.desktop = false,
    required this.isSaving,
    required this.errorMessage,
    required this.onReload,
    required this.onNickname,
    required this.onEmail,
    required this.onBirthday,
    required this.onSessions,
    required this.onDeactivate,
    required this.onLogout,
    required this.onHome,
  });

  final MemberProfile profile;
  final bool mobile;
  final bool desktop;
  final bool isSaving;
  final String? errorMessage;
  final VoidCallback onReload;
  final VoidCallback onNickname;
  final VoidCallback onEmail;
  final VoidCallback onBirthday;
  final VoidCallback onSessions;
  final VoidCallback onDeactivate;
  final VoidCallback onLogout;
  final VoidCallback onHome;

  void _unavailable(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label即將開放')));
  }

  Widget _compactHeader() => SizedBox(
    height: 56,
    child: Row(
      children: [
        IconButton(
          tooltip: '返回首頁',
          onPressed: onHome,
          icon: const Icon(Icons.arrow_back),
        ),
        const Text(
          '貘nsters',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (mobile) {
      return ColoredBox(
        color: _MemberColors.mobileBackground,
        child: Stack(
          children: [
            Positioned(
              left: 20,
              right: 20,
              top: 0,
              bottom: 82,
              child: Column(
                children: [
                  _compactHeader(),
                  Expanded(child: _content(context)),
                ],
              ),
            ),
            MobileAppBottomNavigation(
              activeDestination: AppNavigationDestination.profile,
              onHome: onHome,
              onProfile: () {},
              onUnavailable: (label) => _unavailable(context, label),
            ),
          ],
        ),
      );
    }
    return Column(
      key: const Key('memberDataViewport'),
      children: [
        if (desktop)
          AppTopNavigation(
            activeDestination: AppNavigationDestination.profile,
            onHome: onHome,
            onAddAnnoyance: () => context.pushNamed(AppRoute.annoyanceChat),
            onNotification: () => _unavailable(context, '通知'),
            onProfile: () {},
            onUnavailable: (label) => _unavailable(context, label),
            profileInitial: profile.publicNickname,
          )
        else
          _compactHeader(),
        Expanded(
          child: SingleChildScrollView(
            key: const Key('memberDataFlowScroll'),
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: ResponsiveContent(
              maxWidth: 1200,
              horizontalPadding: desktop ? 36 : 24,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (desktop) ...[
                    _SettingsSidebar(
                      onNickname: isSaving ? null : onNickname,
                      onEmail: isSaving ? null : onEmail,
                      onBirthday: isSaving ? null : onBirthday,
                      onDeactivate: isSaving ? null : onDeactivate,
                    ),
                    const SizedBox(width: 28),
                  ],
                  Expanded(child: _content(context)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      mainAxisSize: mobile ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '會員資料',
          key: const Key('memberDataTitle'),
          style: TextStyle(
            fontSize: mobile ? 25 : 30,
            fontWeight: FontWeight.w700,
            color: _MemberColors.text,
          ),
        ),
        const SizedBox(height: 4),
        const Text('一般資料只讀；敏感欄位各自進入獨立流程。'),
        const SizedBox(height: 14),
        Flexible(
          fit: mobile ? FlexFit.tight : FlexFit.loose,
          flex: mobile ? 1 : 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _MemberColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _MemberColors.border),
            ),
            child: Padding(
              padding: EdgeInsets.all(mobile ? 18 : 26),
              child: Column(
                mainAxisSize: mobile ? MainAxisSize.max : MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DataRow(label: '公開暱稱', value: profile.publicNickname),
                  _DataRow(label: '目前 Email', value: profile.email),
                  _DataRow(label: '生日（唯讀）', value: profile.birthday ?? '尚未設定'),
                  Text(
                    '資格：${switch (profile.eligibilityStatus) {
                      'ELIGIBLE_ADULT' => '成年會員',
                      'ELIGIBLE_PRIVATE_ONLY' => '僅限私人功能',
                      'GUARDIAN_CONSENT_PENDING' => '等待監護人同意',
                      _ => '待確認或受限',
                    }}',
                  ),
                  if (!mobile) ...[
                    _DataRow(label: '會員識別碼', value: profile.publicId),
                    _DataRow(
                      label: '服務地區',
                      value: profile.serviceRegion == 'TW' ? '台灣' : '尚未設定',
                    ),
                    _DataRow(
                      label: '帳號狀態',
                      value: profile.memberState == 'ACTIVE' ? '使用中' : '受限',
                    ),
                  ] else
                    Text(
                      '服務地區：${profile.serviceRegion == 'TW' ? '台灣' : '尚未設定'} · 帳號：${profile.memberState == 'ACTIVE' ? '使用中' : '受限'}',
                    ),
                  if (profile.pendingEmailChange != null)
                    _PendingCard(
                      text:
                          '待驗證 Email：${profile.pendingEmailChange!.target ?? '驗證信已寄出'}',
                    ),
                  if (profile.pendingBirthdayCorrection != null)
                    _PendingCard(
                      text:
                          '生日更正待審：${profile.pendingBirthdayCorrection!.target ?? '處理中'}',
                      danger: true,
                    ),
                  if (errorMessage != null)
                    _PendingCard(text: errorMessage!, danger: true),
                  if (mobile) const Spacer() else const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _ActionButton(
                        key: const Key('memberNicknameAction'),
                        label: '編輯公開暱稱',
                        onPressed: isSaving ? null : onNickname,
                      ),
                      _ActionButton(
                        key: const Key('memberEmailAction'),
                        label: '變更 Email',
                        onPressed: isSaving ? null : onEmail,
                      ),
                      _ActionButton(
                        key: const Key('memberBirthdayAction'),
                        label: '申請生日更正',
                        onPressed: isSaving ? null : onBirthday,
                      ),
                      _ActionButton(label: '登入裝置', onPressed: onSessions),
                      _ActionButton(
                        label: '登出',
                        onPressed: isSaving ? null : onLogout,
                      ),
                      _ActionButton(
                        key: const Key('memberDeactivateAction'),
                        label: '停用帳號',
                        danger: true,
                        onPressed: isSaving ? null : onDeactivate,
                      ),
                      if (errorMessage != null)
                        _ActionButton(label: '重新載入', onPressed: onReload),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsSidebar extends StatelessWidget {
  const _SettingsSidebar({
    required this.onNickname,
    required this.onEmail,
    required this.onBirthday,
    required this.onDeactivate,
  });
  final VoidCallback? onNickname;
  final VoidCallback? onEmail;
  final VoidCallback? onBirthday;
  final VoidCallback? onDeactivate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _MemberColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _MemberColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('一般資料', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextButton(onPressed: onNickname, child: const Text('公開暱稱')),
          TextButton(onPressed: onEmail, child: const Text('Email')),
          TextButton(onPressed: onBirthday, child: const Text('生日')),
          TextButton(onPressed: onDeactivate, child: const Text('帳號狀態')),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _MemberColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: _MemberColors.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.text, this.danger = false});

  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: danger ? _MemberColors.dangerSoft : _MemberColors.warningSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: danger ? _MemberColors.danger : _MemberColors.warning,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: danger ? _MemberColors.danger : _MemberColors.primary,
        side: BorderSide(
          color: danger ? _MemberColors.danger : _MemberColors.border,
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class _MemberColors {
  const _MemberColors._();

  static const background = AppColors.profileBackground;
  static const mobileBackground = AppColors.profileMobileBackground;
  static const surface = AppColors.profileSurface;
  static const text = Color(0xFF3B302B);
  static const muted = Color(0xFF7B6D66);
  static const primary = AppColors.profilePrimary;
  static const border = Color(0xFFE9DDD4);
  static const warning = Color(0xFFA66A2C);
  static const warningSoft = Color(0xFFFFF0D8);
  static const danger = Color(0xFFB4493F);
  static const dangerSoft = Color(0xFFFBE9E7);
}
