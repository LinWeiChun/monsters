part of '../../pages/profile_page.dart';

class _ResponsiveProfileCanvas extends StatelessWidget {
  const _ResponsiveProfileCanvas({
    required this.profile,
    required this.userNameController,
    required this.birthdayController,
    required this.isSaving,
    required this.isLoggingOut,
    required this.errorMessage,
    required this.onSave,
    required this.onSelectBirthday,
    required this.onLogout,
    required this.onHome,
    required this.onAddAnnoyance,
    required this.onUnavailable,
    this.compact = false,
  });

  final UserProfile profile;
  final TextEditingController userNameController;
  final TextEditingController birthdayController;
  final bool isSaving;
  final bool isLoggingOut;
  final String? errorMessage;
  final VoidCallback onSave;
  final VoidCallback onSelectBirthday;
  final VoidCallback onLogout;
  final VoidCallback onHome;
  final VoidCallback onAddAnnoyance;
  final VoidCallback onUnavailable;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('profileResponsiveShell'),
      color: AppColors.profileBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (compact)
            _ResponsiveProfileHeader(
              compact: true,
              isSaving: isSaving,
              isLoggingOut: isLoggingOut,
              onSave: onSave,
              onLogout: onLogout,
              onBack: onHome,
              onUnavailable: onUnavailable,
            )
          else ...[
            AppTopNavigation(
              activeDestination: AppNavigationDestination.profile,
              profileInitial: profile.userName,
              onHome: onHome,
              onAddAnnoyance: onAddAnnoyance,
              onNotification: onUnavailable,
              onProfile: () {},
              onUnavailable: (_) => onUnavailable(),
            ),
            _ProfileActionBar(
              isSaving: isSaving,
              isLoggingOut: isLoggingOut,
              onSave: onSave,
              onLogout: onLogout,
            ),
          ],
          Expanded(
            child: SingleChildScrollView(
              child: ResponsiveContent(
                maxWidth: 1088,
                horizontalPadding: compact ? 32 : 48,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: compact ? 32 : 44),
                  child: _ResponsiveProfileCard(
                    profile: profile,
                    userNameController: userNameController,
                    birthdayController: birthdayController,
                    isSaving: isSaving,
                    errorMessage: errorMessage,
                    onSave: onSave,
                    onSelectBirthday: onSelectBirthday,
                    compact: compact,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveProfileHeader extends StatelessWidget {
  const _ResponsiveProfileHeader({
    required this.compact,
    required this.isSaving,
    required this.isLoggingOut,
    required this.onSave,
    required this.onLogout,
    required this.onBack,
    required this.onUnavailable,
  });

  final bool compact;
  final bool isSaving;
  final bool isLoggingOut;
  final VoidCallback onSave;
  final VoidCallback onLogout;
  final VoidCallback onBack;
  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.profileSurface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 32 : 42),
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                InkWell(
                  onTap: onBack,
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 118,
                    height: 36,
                    fit: BoxFit.fill,
                    semanticLabel: '返回陪伴首頁',
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(width: 52),
                  TextButton(onPressed: onBack, child: const Text('陪伴首頁')),
                  TextButton(
                    onPressed: onUnavailable,
                    child: const Text('心的軌跡'),
                  ),
                  TextButton(
                    onPressed: onUnavailable,
                    child: const Text('怪獸收藏'),
                  ),
                ],
                const Spacer(),
                Text(
                  '個人資料',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.profileInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                OutlinedButton.icon(
                  key: const Key('profileLogoutButton'),
                  onPressed: isLoggingOut ? null : onLogout,
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(isLoggingOut ? '登出中' : '登出'),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  height: 44,
                  child: FilledButton(
                    key: const Key('profileSaveButton'),
                    onPressed: isSaving ? null : onSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.profilePrimary,
                      foregroundColor: AppColors.profileOnPrimary,
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: Text(isSaving ? '儲存中' : '儲存變更'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileActionBar extends StatelessWidget {
  const _ProfileActionBar({
    required this.isSaving,
    required this.isLoggingOut,
    required this.onSave,
    required this.onLogout,
  });

  final bool isSaving;
  final bool isLoggingOut;
  final VoidCallback onSave;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('profileActionBar'),
      color: AppColors.profileActionBackground,
      child: ResponsiveContent(
        maxWidth: 1088,
        horizontalPadding: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              Text(
                '個人資料',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.profileInk,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                key: const Key('profileLogoutButton'),
                onPressed: isLoggingOut ? null : onLogout,
                icon: const Icon(Icons.logout, size: 18),
                label: Text(isLoggingOut ? '登出中' : '登出'),
              ),
              const SizedBox(width: AppSpacing.md),
              FilledButton(
                key: const Key('profileSaveButton'),
                onPressed: isSaving ? null : onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.profilePrimary,
                  foregroundColor: AppColors.profileOnPrimary,
                  shape: const RoundedRectangleBorder(),
                ),
                child: Text(isSaving ? '儲存中' : '儲存變更'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResponsiveProfileCard extends StatelessWidget {
  const _ResponsiveProfileCard({
    required this.profile,
    required this.userNameController,
    required this.birthdayController,
    required this.isSaving,
    required this.errorMessage,
    required this.onSave,
    required this.onSelectBirthday,
    required this.compact,
  });

  final UserProfile profile;
  final TextEditingController userNameController;
  final TextEditingController birthdayController;
  final bool isSaving;
  final String? errorMessage;
  final VoidCallback onSave;
  final VoidCallback onSelectBirthday;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.profileSurface,
        border: Border.all(color: AppColors.profileBorder),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? AppSpacing.xl : AppSpacing.xxl),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useColumns = constraints.maxWidth >= 760;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ResponsiveProfileIdentity(profile: profile, compact: compact),
                SizedBox(height: compact ? 36 : 48),
                Text(
                  '基本資料',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.profileInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _ResponsiveProfileFields(
                  useColumns: useColumns,
                  first: _FlowProfileEditableField(
                    fieldKey: const Key('profileUserNameField'),
                    label: '暱稱',
                    controller: userNameController,
                    validator: _ProfilePageState._validateUserName,
                    textInputAction: TextInputAction.next,
                  ),
                  second: _FlowProfileEditableField(
                    fieldKey: const Key('profileBirthdayField'),
                    label: '生日',
                    controller: birthdayController,
                    validator: _ProfilePageState._validateBirthday,
                    keyboardType: TextInputType.datetime,
                    textInputAction: TextInputAction.done,
                    readOnly: true,
                    onTap: onSelectBirthday,
                    suffixIcon: const Icon(Icons.calendar_month_outlined),
                    onSubmitted: (_) {
                      if (!isSaving) {
                        onSave();
                      }
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _ResponsiveProfileFields(
                  useColumns: useColumns,
                  first: _FlowProfileReadonlyField(
                    label: 'Email',
                    value: profile.email,
                  ),
                  second: _FlowProfileReadonlyField(
                    label: '帳號',
                    value: profile.account ?? '尚未設定',
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _FlowSaveStateMessage(errorMessage: errorMessage),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Email 與帳號目前不可在此修改。',
                  style: TextStyle(
                    color: AppColors.profileMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ResponsiveProfileIdentity extends StatelessWidget {
  const _ResponsiveProfileIdentity({
    required this.profile,
    required this.compact,
  });

  final UserProfile profile;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final account = _formatAccount(profile.account);
    final details = Column(
      crossAxisAlignment:
          compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          profile.userName,
          key: const Key('profileDisplayName'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.profileInk,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          account,
          style: const TextStyle(color: AppColors.profileMuted, fontSize: 13),
        ),
        const SizedBox(height: AppSpacing.md),
        const DecoratedBox(
          decoration: BoxDecoration(color: AppColors.profileSuccessBackground),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Text(
              '●  帳號正常',
              style: TextStyle(
                color: AppColors.profileSuccessText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
    if (compact) {
      return Column(
        children: [
          _FlowProfileAvatar(profile: profile),
          const SizedBox(height: AppSpacing.lg),
          details,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FlowProfileAvatar(profile: profile),
        const SizedBox(width: 36),
        Expanded(child: details),
      ],
    );
  }
}

class _FlowProfileAvatar extends StatelessWidget {
  const _FlowProfileAvatar({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final initial =
        profile.userName.isEmpty ? '?' : profile.userName.characters.first;
    return SizedBox.square(
      dimension: 148,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const DecoratedBox(
            key: Key('profileAvatar'),
            decoration: BoxDecoration(
              color: AppColors.profileAvatarHalo,
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(dimension: 148),
          ),
          ClipOval(
            child: SizedBox.square(
              dimension: 104,
              child:
                  profile.avatarUrl == null
                      ? ColoredBox(
                        color: AppColors.profileAvatarHalo,
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: AppColors.profileOnPrimary,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                      : Image.network(profile.avatarUrl!, fit: BoxFit.cover),
            ),
          ),
          const Align(
            alignment: Alignment.bottomRight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.profileSurface,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '✎',
                  style: TextStyle(
                    color: AppColors.profilePrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveProfileFields extends StatelessWidget {
  const _ResponsiveProfileFields({
    required this.useColumns,
    required this.first,
    required this.second,
  });

  final bool useColumns;
  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    if (!useColumns) {
      return Column(
        children: [first, const SizedBox(height: AppSpacing.lg), second],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 36),
        Expanded(child: second),
      ],
    );
  }
}

class _FlowProfileEditableField extends StatelessWidget {
  const _FlowProfileEditableField({
    required this.fieldKey,
    required this.label,
    required this.controller,
    required this.validator,
    required this.textInputAction,
    this.keyboardType,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final Key fieldKey;
  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FlowProfileLabel(label),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          key: fieldKey,
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          readOnly: readOnly,
          onTap: onTap,
          decoration: _flowProfileInputDecoration().copyWith(
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

class _FlowProfileReadonlyField extends StatelessWidget {
  const _FlowProfileReadonlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FlowProfileLabel(label),
        const SizedBox(height: AppSpacing.sm),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.profileReadonlyFill,
            border: Border.all(color: AppColors.profileBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.profileMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  '●',
                  style: TextStyle(color: AppColors.profileMuted, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FlowProfileLabel extends StatelessWidget {
  const _FlowProfileLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.profileMuted,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FlowSaveStateMessage extends StatelessWidget {
  const _FlowSaveStateMessage({required this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null;
    final color =
        hasError ? AppColors.profileError : AppColors.profileSuccessText;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.profileSuccessBackground,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Text(
              hasError ? '!' : '✓',
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                errorMessage ?? '資料已是最新狀態',
                key: hasError ? const Key('profileErrorMessage') : null,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _flowProfileInputDecoration() {
  return const InputDecoration(
    filled: true,
    fillColor: AppColors.profileFieldFill,
    contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: AppColors.profileBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: AppColors.profileBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: AppColors.profilePrimary),
    ),
  );
}

class _MobileProfileCanvas extends StatelessWidget {
  const _MobileProfileCanvas({
    required this.profile,
    required this.userNameController,
    required this.birthdayController,
    required this.isSaving,
    required this.isLoggingOut,
    required this.errorMessage,
    required this.onSave,
    required this.onSelectBirthday,
    required this.onLogout,
    required this.onHome,
    required this.onBack,
    required this.onUnavailable,
  });

  final UserProfile profile;
  final TextEditingController userNameController;
  final TextEditingController birthdayController;
  final bool isSaving;
  final bool isLoggingOut;
  final String? errorMessage;
  final VoidCallback onSave;
  final VoidCallback onSelectBirthday;
  final VoidCallback onLogout;
  final VoidCallback onHome;
  final VoidCallback onBack;
  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) {
    final account = _formatAccount(profile.account);
    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: AppColors.profileMobileBackground),
        ),
        const Positioned(
          left: 0,
          top: 0,
          width: 390,
          height: 70,
          child: ColoredBox(color: AppColors.profileSurface),
        ),
        Positioned(
          left: 18,
          top: 17,
          width: 26,
          height: 36,
          child: GestureDetector(
            key: const Key('profileBackButton'),
            onTap: onBack,
            child: const Text(
              '‹',
              style: TextStyle(
                color: AppColors.profilePrimary,
                fontSize: 30,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ),
        ),
        const _TextBlock(
          left: 54,
          top: 23,
          width: 90,
          height: 24,
          text: '個人資料',
          color: AppColors.profileInk,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        _SaveButton.mobile(isSaving: isSaving, onTap: onSave),
        Positioned(
          left: 230,
          top: 15,
          width: 72,
          height: 40,
          child: TextButton.icon(
            key: const Key('profileLogoutButton'),
            onPressed: isLoggingOut ? null : onLogout,
            icon: const Icon(Icons.logout, size: 15),
            label: Text(isLoggingOut ? '登出中' : '登出'),
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              foregroundColor: AppColors.profileError,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        _ProfileAvatar(
          profile: profile,
          left: 125,
          top: 96,
          halo: 140,
          image: 100,
        ),
        const _EditAvatarButton(left: 217, top: 190, size: 42),
        _TextBlock(
          key: const Key('profileDisplayName'),
          left: 110,
          top: 250,
          width: 170,
          height: 26,
          text: profile.userName,
          color: AppColors.profileInk,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          textAlign: TextAlign.center,
        ),
        _TextBlock(
          left: 110,
          top: 280,
          width: 170,
          height: 18,
          text: account,
          color: AppColors.profileMuted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          textAlign: TextAlign.center,
        ),
        _ProfileEditableField(
          fieldKey: const Key('profileUserNameField'),
          label: '暱稱',
          labelLeft: 36,
          labelTop: 330,
          left: 36,
          top: 352,
          width: 318,
          height: 54,
          controller: userNameController,
          validator: _ProfilePageState._validateUserName,
          textInputAction: TextInputAction.next,
        ),
        _ReadonlyField.mobile(
          label: 'Email',
          value: profile.email,
          left: 36,
          top: 444,
          labelLeft: 36,
          labelTop: 422,
          width: 318,
          height: 54,
          lockLeft: 326,
          lockTop: 462,
        ),
        _ReadonlyField.mobile(
          label: '帳號',
          value: profile.account ?? '尚未設定',
          left: 36,
          top: 536,
          labelLeft: 36,
          labelTop: 514,
          width: 318,
          height: 54,
          lockLeft: 326,
          lockTop: 554,
        ),
        _ProfileEditableField(
          fieldKey: const Key('profileBirthdayField'),
          label: '生日',
          labelLeft: 36,
          labelTop: 606,
          left: 36,
          top: 628,
          width: 318,
          height: 54,
          controller: birthdayController,
          validator: _ProfilePageState._validateBirthday,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.datetime,
          readOnly: true,
          onTap: onSelectBirthday,
          suffixIcon: const Icon(
            Icons.calendar_month_outlined,
            color: AppColors.profilePrimary,
            size: 20,
          ),
          onSubmitted: (_) {
            if (!isSaving) {
              onSave();
            }
          },
        ),
        _SaveStateMessage(
          left: 36,
          top: 710,
          width: 318,
          height: 54,
          errorMessage: errorMessage,
          mobile: true,
        ),
        const _TextBlock(
          left: 88,
          top: 790,
          width: 230,
          height: 16,
          text: '個人資料只用於帳號與陪伴體驗',
          color: AppColors.profileMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        MobileAppBottomNavigation(
          activeDestination: AppNavigationDestination.profile,
          onHome: onHome,
          onProfile: () {},
          onUnavailable: (_) => onUnavailable(),
        ),
      ],
    );
  }
}

class _ProfileEditableField extends StatelessWidget {
  const _ProfileEditableField({
    required this.fieldKey,
    required this.label,
    required this.labelLeft,
    required this.labelTop,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.controller,
    required this.validator,
    required this.textInputAction,
    this.keyboardType,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final Key fieldKey;
  final String label;
  final double labelLeft;
  final double labelTop;
  final double left;
  final double top;
  final double width;
  final double height;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _TextBlock(
          left: labelLeft,
          top: labelTop,
          width: 120,
          height: 18,
          text: label,
          color: AppColors.profileMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        Positioned(
          left: left,
          top: top,
          width: width,
          height: height,
          child: TextFormField(
            key: fieldKey,
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onFieldSubmitted: onSubmitted,
            readOnly: readOnly,
            onTap: onTap,
            style: const TextStyle(
              color: AppColors.profileInk,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.profileFieldFill,
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: AppColors.profileBorder),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: AppColors.profileBorder),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: AppColors.profilePrimary),
              ),
              errorStyle: const TextStyle(fontSize: 10, height: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({
    required this.label,
    required this.value,
    required this.left,
    required this.top,
    required this.labelLeft,
    required this.labelTop,
    required this.width,
    required this.height,
    required this.lockLeft,
    required this.lockTop,
  }) : fill = AppColors.profileReadonlyFill;

  const _ReadonlyField.mobile({
    required this.label,
    required this.value,
    required this.left,
    required this.top,
    required this.labelLeft,
    required this.labelTop,
    required this.width,
    required this.height,
    required this.lockLeft,
    required this.lockTop,
  }) : fill = AppColors.profileMobileReadonlyFill;

  final String label;
  final String value;
  final double left;
  final double top;
  final double labelLeft;
  final double labelTop;
  final double width;
  final double height;
  final double lockLeft;
  final double lockTop;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _TextBlock(
          left: labelLeft,
          top: labelTop,
          width: 120,
          height: 18,
          text: label,
          color: AppColors.profileMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        _RectBlock(
          left: left,
          top: top,
          width: width,
          height: height,
          color: fill,
          border: AppColors.profileBorder,
        ),
        _TextBlock(
          left: left + 18,
          top: top + 18,
          width: width - 58,
          height: 20,
          text: value,
          color: AppColors.profileMuted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        _TextBlock(
          left: lockLeft,
          top: lockTop,
          width: 16,
          height: 16,
          text: '●',
          color: AppColors.profileMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton.mobile({required this.isSaving, required this.onTap})
    : left = 318,
      top = 26,
      width = 44,
      height = 22,
      text = '儲存',
      fontSize = 13;

  final bool isSaving;
  final VoidCallback onTap;
  final double left;
  final double top;
  final double width;
  final double height;
  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        key: const Key('profileSaveButton'),
        onTap: isSaving ? null : onTap,
        child:
            width > 100
                ? DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.profilePrimary,
                  ),
                  child: Center(
                    child: Text(
                      isSaving ? '儲存中' : text,
                      style: TextStyle(
                        color: AppColors.profileOnPrimary,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                )
                : Text(
                  isSaving ? '儲存' : text,
                  style: TextStyle(
                    color: AppColors.profilePrimary,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.profile,
    required this.left,
    required this.top,
    required this.halo,
    required this.image,
  });

  final UserProfile profile;
  final double left;
  final double top;
  final double halo;
  final double image;

  @override
  Widget build(BuildContext context) {
    final initial =
        profile.userName.isEmpty ? '?' : profile.userName.characters.first;
    final imageOffset = (halo - image) / 2;
    return Stack(
      children: [
        _CircleBlock(
          key: const Key('profileAvatar'),
          left: left,
          top: top,
          size: halo,
          color: AppColors.profileAvatarHalo,
        ),
        Positioned(
          left: left + imageOffset,
          top: top + imageOffset,
          width: image,
          height: image,
          child: ClipOval(
            child:
                profile.avatarUrl == null
                    ? ColoredBox(
                      color: AppColors.profileAvatarHalo,
                      child: Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: AppColors.profileOnPrimary,
                            fontSize: image * 0.34,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ),
                    )
                    : Image.network(profile.avatarUrl!, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}

class _EditAvatarButton extends StatelessWidget {
  const _EditAvatarButton({
    required this.left,
    required this.top,
    required this.size,
  });

  final double left;
  final double top;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _CircleBlock(
          left: left,
          top: top,
          size: size,
          color: AppColors.profileSurface,
          border: AppColors.profileBorder,
        ),
        _TextBlock(
          left: left + size * 0.31,
          top: top + size * 0.27,
          width: size * 0.42,
          height: size * 0.46,
          text: '✎',
          color: AppColors.profilePrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }
}

class _SaveStateMessage extends StatelessWidget {
  const _SaveStateMessage({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.errorMessage,
    this.mobile = false,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final String? errorMessage;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null;
    final color =
        hasError ? AppColors.profileError : AppColors.profileSuccessText;
    return Stack(
      children: [
        _RectBlock(
          left: left,
          top: top,
          width: width,
          height: height,
          color: AppColors.profileSuccessBackground,
        ),
        _TextBlock(
          left: left + (mobile ? 18 : 24),
          top: top + (mobile ? 17 : 26),
          width: 22,
          height: 22,
          text: hasError ? '!' : '✓',
          color: color,
          fontSize: mobile ? 16 : 18,
          fontWeight: FontWeight.w800,
        ),
        _TextBlock(
          key: hasError ? const Key('profileErrorMessage') : null,
          left: left + (mobile ? 46 : 56),
          top: top + (mobile ? 15 : 22),
          width: width - (mobile ? 70 : 90),
          height: mobile ? 24 : 28,
          text: errorMessage ?? '資料已是最新狀態',
          color: color,
          fontSize: mobile ? 13 : 15,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }
}

class _RectBlock extends StatelessWidget {
  const _RectBlock({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.color,
    this.border,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final Color color;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: border == null ? null : Border.all(color: border!),
        ),
      ),
    );
  }
}

class _CircleBlock extends StatelessWidget {
  const _CircleBlock({
    required this.left,
    required this.top,
    required this.size,
    required this.color,
    this.border,
    super.key,
  });

  final double left;
  final double top;
  final double size;
  final Color color;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: border == null ? null : Border.all(color: border!),
        ),
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.text,
    required this.color,
    required this.fontSize,
    required this.fontWeight,
    this.textAlign = TextAlign.left,
    super.key,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Text(
        text,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: 1.2,
        ),
      ),
    );
  }
}

String _formatAccount(String? account) {
  final value = account?.trim();
  if (value == null || value.isEmpty) {
    return '@未設定';
  }
  return value.startsWith('@') ? value : '@$value';
}

void _showUnavailableMessage(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text('此功能即將開放')));
}
