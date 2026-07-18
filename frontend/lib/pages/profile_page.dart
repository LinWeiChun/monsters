import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../layout/responsive_layout.dart';
import '../models/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/state/error_view.dart';
import '../widgets/state/loading_view.dart';

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
    final profile = state.profile;

    return Scaffold(
      backgroundColor: AppColors.profileMobileBackground,
      body: _buildBody(context, state, profile),
    );
  }

  Widget _buildBody(
    BuildContext context,
    UserProfileState state,
    UserProfile? profile,
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
              errorMessage: state.errorMessage,
              onSave: _submit,
              onBack: () => context.goNamed(AppRoute.home),
              onUnavailable: () => _showUnavailableMessage(context),
            ),
        tablet:
            (context, constraints) => _ResponsiveProfileCanvas(
              profile: profile,
              userNameController: _userNameController,
              birthdayController: _birthdayController,
              isSaving: state.isSaving,
              errorMessage: state.errorMessage,
              onSave: _submit,
              onBack: () => context.goNamed(AppRoute.home),
              onUnavailable: () => _showUnavailableMessage(context),
              compact: true,
            ),
        mobile:
            (context, constraints) => ClipRect(
              child: FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 390,
                  height: 844,
                  child: _MobileProfileCanvas(
                    profile: profile,
                    userNameController: _userNameController,
                    birthdayController: _birthdayController,
                    isSaving: state.isSaving,
                    errorMessage: state.errorMessage,
                    onSave: _submit,
                    onBack: () => context.goNamed(AppRoute.home),
                    onUnavailable: () => _showUnavailableMessage(context),
                  ),
                ),
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

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
