import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_spacing.dart';
import '../widgets/state/error_view.dart';
import '../widgets/state/loading_view.dart';

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
      appBar: AppBar(title: const Text('個人資料')),
      body: SafeArea(child: _buildBody(context, state, profile)),
    );
  }

  Widget _buildBody(
    BuildContext context,
    UserProfileState state,
    UserProfile? profile,
  ) {
    if (state.isLoading && profile == null) {
      return const LoadingView(message: '正在載入個人資料');
    }

    if (profile == null) {
      return ErrorView(
        message: state.errorMessage ?? '無法取得個人資料',
        onRetry:
            () =>
                ref.read(userProfileControllerProvider.notifier).loadProfile(),
      );
    }

    return RefreshIndicator(
      onRefresh:
          () => ref.read(userProfileControllerProvider.notifier).loadProfile(),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileHeader(profile: profile),
                    const SizedBox(height: AppSpacing.lg),
                    _ProfileInfo(profile: profile),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '編輯資料',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      key: const Key('profileUserNameField'),
                      controller: _userNameController,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.nickname],
                      decoration: const InputDecoration(
                        labelText: '暱稱',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: _validateUserName,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      key: const Key('profileBirthdayField'),
                      controller: _birthdayController,
                      keyboardType: TextInputType.datetime,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: '生日',
                        hintText: 'yyyy-MM-dd',
                        prefixIcon: const Icon(Icons.cake_outlined),
                        suffixIcon: IconButton(
                          tooltip: '選擇生日',
                          onPressed: state.isSaving ? null : _pickBirthday,
                          icon: const Icon(Icons.calendar_month_outlined),
                        ),
                      ),
                      validator: _validateBirthday,
                      onFieldSubmitted:
                          state.isSaving ? null : (_) => _submit(),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        state.errorMessage!,
                        key: const Key('profileErrorMessage'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      key: const Key('profileSaveButton'),
                      onPressed: state.isSaving ? null : _submit,
                      icon:
                          state.isSaving
                              ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.save_outlined),
                      label: Text(state.isSaving ? '儲存中' : '儲存'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateUserName(String? value) {
    final userName = value?.trim() ?? '';
    if (userName.isEmpty) {
      return '請輸入暱稱';
    }
    if (userName.length > 80) {
      return '暱稱最多 80 個字';
    }
    return null;
  }

  String? _validateBirthday(String? value) {
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

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final initialDate =
        DateTime.tryParse(_birthdayController.text.trim()) ??
        DateTime(now.year - 18, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate == null) {
      return;
    }

    _birthdayController.text = _formatDate(pickedDate);
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

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        CircleAvatar(
          key: const Key('profileAvatar'),
          radius: 48,
          backgroundColor: colorScheme.primaryContainer,
          foregroundImage:
              profile.avatarUrl == null
                  ? null
                  : NetworkImage(profile.avatarUrl!),
          child:
              profile.avatarUrl == null
                  ? Text(
                    profile.userName.isEmpty
                        ? '?'
                        : profile.userName.characters.first,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                  : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          profile.userName,
          key: const Key('profileDisplayName'),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          profile.email,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _ProfileInfoRow(label: 'Email', value: profile.email),
            _ProfileInfoRow(label: '帳號', value: profile.account ?? '未設定'),
            _ProfileInfoRow(label: '生日', value: profile.birthday ?? '未設定'),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
