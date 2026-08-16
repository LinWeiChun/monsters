import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../layout/responsive_layout.dart';
import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/state/error_view.dart';
import '../widgets/state/loading_view.dart';
import '../widgets/navigation/app_navigation.dart';

part '../widgets/profile/profile_penpot_canvas.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _birthdayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(userProfileControllerProvider.notifier).loadProfile(),
    );
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserProfileState>(userProfileControllerProvider, (
      previous,
      next,
    ) {
      final profile = next.profile;
      if (profile != null && previous?.profile != profile) {
        _userNameController.text = profile.userName;
        _birthdayController.text = profile.birthday ?? '';
      }

      if (next.updateSucceeded && previous?.updateSucceeded != true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('個人資料已更新')));
      }
    });

    final state = ref.watch(userProfileControllerProvider);
    final isLoggingOut = ref.watch(
      authControllerProvider.select((state) => state.isLoading),
    );
    final profile = state.profile;

    return Scaffold(
      backgroundColor: AppColors.profileMobileBackground,
      body: _buildBody(context, state, profile, isLoggingOut),
    );
  }

  Widget _buildBody(
    BuildContext context,
    UserProfileState state,
    UserProfile? profile,
    bool isLoggingOut,
  ) {
    if (state.isLoading && profile == null) {
      return const LoadingView(message: '正在讀取個人資料');
    }

    if (profile == null) {
      return ErrorView(
        message: state.errorMessage ?? '無法取得個人資料',
        onRetry:
            () =>
                ref.read(userProfileControllerProvider.notifier).loadProfile(),
      );
    }

    return Form(
      key: _formKey,
      child: ResponsiveLayout(
        desktop:
            (context, constraints) => _ResponsiveProfileCanvas(
              profile: profile,
              userNameController: _userNameController,
              birthdayController: _birthdayController,
              isSaving: state.isSaving,
              isLoggingOut: isLoggingOut,
              errorMessage: state.errorMessage,
              onSave: _submit,
              onSelectBirthday: _selectBirthday,
              onLogout: () => _confirmLogout(context),
              onHome: () => context.goNamed(AppRoute.home),
              onAddAnnoyance: () => context.pushNamed(AppRoute.annoyanceChat),
              onSessions: () => context.pushNamed(AppRoute.sessions),
              onUnavailable: () => _showUnavailableMessage(context),
            ),
        tablet:
            (context, constraints) => _ResponsiveProfileCanvas(
              profile: profile,
              userNameController: _userNameController,
              birthdayController: _birthdayController,
              isSaving: state.isSaving,
              isLoggingOut: isLoggingOut,
              errorMessage: state.errorMessage,
              onSave: _submit,
              onSelectBirthday: _selectBirthday,
              onLogout: () => _confirmLogout(context),
              onHome: () => context.goNamed(AppRoute.home),
              onAddAnnoyance: () => context.pushNamed(AppRoute.annoyanceChat),
              onSessions: () => context.pushNamed(AppRoute.sessions),
              onUnavailable: () => _showUnavailableMessage(context),
              compact: true,
            ),
        mobile:
            (context, constraints) => ResponsiveFixedCanvas(
              viewportKey: const Key('profileMobileViewport'),
              canvasWidth: 390,
              canvasHeight: 844,
              child: _MobileProfileCanvas(
                profile: profile,
                userNameController: _userNameController,
                birthdayController: _birthdayController,
                isSaving: state.isSaving,
                isLoggingOut: isLoggingOut,
                errorMessage: state.errorMessage,
                onSave: _submit,
                onSelectBirthday: _selectBirthday,
                onLogout: () => _confirmLogout(context),
                onHome: () => context.goNamed(AppRoute.home),
                onBack: () => _returnToHome(context),
                onSessions: () => context.pushNamed(AppRoute.sessions),
                onUnavailable: () => _showUnavailableMessage(context),
              ),
            ),
      ),
    );
  }

  static String? _validateUserName(String? value) {
    final userName = value?.trim() ?? '';
    if (userName.isEmpty) {
      return '請輸入暱稱';
    }
    if (userName.length > 80) {
      return '暱稱最多 80 字';
    }
    return null;
  }

  static String? _validateBirthday(String? value) {
    final birthday = value?.trim() ?? '';
    if (birthday.isEmpty) {
      return null;
    }

    final pattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!pattern.hasMatch(birthday)) {
      return '生日格式需為 yyyy-MM-dd';
    }

    final parsed = DateTime.tryParse(birthday);
    if (parsed == null || birthday != _formatDate(parsed)) {
      return '請輸入有效日期';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(userProfileControllerProvider.notifier)
        .updateProfile(
          userName: _userNameController.text,
          birthday: _birthdayController.text,
        );
  }

  Future<void> _selectBirthday() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final current = DateTime.tryParse(_birthdayController.text);
    final initialDate =
        current == null || current.isAfter(today)
            ? DateTime(2000, 1, 1)
            : current;
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900, 1, 1),
      lastDate: today,
      helpText: '選擇生日',
      cancelText: '取消',
      confirmText: '確定',
      fieldLabelText: '生日',
      fieldHintText: 'yyyy-MM-dd',
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() => _birthdayController.text = _formatDate(selected));
    _formKey.currentState?.validate();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('確認登出'),
            content: const Text('登出後需要重新登入才能查看個人資料。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('取消'),
              ),
              FilledButton(
                key: const Key('profileConfirmLogoutButton'),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('登出'),
              ),
            ],
          ),
    );
    if (shouldLogout != true || !mounted) {
      return;
    }
    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) {
      context.goNamed(AppRoute.login);
    }
  }

  void _returnToHome(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.goNamed(AppRoute.home);
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
