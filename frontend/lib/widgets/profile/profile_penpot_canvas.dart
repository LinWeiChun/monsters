part of '../../pages/profile_page.dart';

class _DesktopProfileCanvas extends StatelessWidget {
  const _DesktopProfileCanvas({
    required this.profile,
    required this.userNameController,
    required this.birthdayController,
    required this.isSaving,
    required this.errorMessage,
    required this.onSave,
    required this.onUnavailable,
  });

  final UserProfile profile;
  final TextEditingController userNameController;
  final TextEditingController birthdayController;
  final bool isSaving;
  final String? errorMessage;
  final VoidCallback onSave;
  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) {
    final account = _formatAccount(profile.account);
    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: AppColors.profileBackground),
        ),
        const _DesktopNavBar(),
        const _TextBlock(
          left: 182,
          top: 24,
          width: 120,
          height: 30,
          text: '個人資料',
          color: AppColors.profileInk,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        _SaveButton.desktop(isSaving: isSaving, onTap: onSave),
        const _RectBlock(
          left: 182,
          top: 116,
          width: 1088,
          height: 736,
          color: AppColors.profileSurface,
          border: AppColors.profileBorder,
        ),
        _ProfileAvatar(
          profile: profile,
          left: 230,
          top: 160,
          halo: 172,
          image: 108,
        ),
        const _EditAvatarButton(left: 350, top: 272, size: 44),
        _TextBlock(
          key: const Key('profileDisplayName'),
          left: 442,
          top: 184,
          width: 300,
          height: 34,
          text: profile.userName,
          color: AppColors.profileInk,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        _TextBlock(
          left: 442,
          top: 224,
          width: 240,
          height: 18,
          text: account,
          color: AppColors.profileMuted,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        const _StatusPill(left: 442, top: 262, width: 124, height: 30),
        const _TextBlock(
          left: 230,
          top: 370,
          width: 80,
          height: 20,
          text: '基本資料',
          color: AppColors.profileInk,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
        _ProfileEditableField(
          fieldKey: const Key('profileUserNameField'),
          label: '暱稱',
          labelLeft: 230,
          labelTop: 408,
          left: 230,
          top: 432,
          width: 460,
          height: 56,
          controller: userNameController,
          validator: _ProfilePageState._validateUserName,
          textInputAction: TextInputAction.next,
        ),
        _ProfileEditableField(
          fieldKey: const Key('profileBirthdayField'),
          label: '生日',
          labelLeft: 726,
          labelTop: 408,
          left: 726,
          top: 432,
          width: 460,
          height: 56,
          controller: birthdayController,
          validator: _ProfilePageState._validateBirthday,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.datetime,
          onSubmitted: (_) {
            if (!isSaving) {
              onSave();
            }
          },
        ),
        _ReadonlyField(
          label: 'Email',
          value: profile.email,
          left: 230,
          top: 540,
          labelLeft: 230,
          labelTop: 516,
          width: 460,
          height: 56,
          lockLeft: 662,
          lockTop: 560,
        ),
        _ReadonlyField(
          label: '帳號',
          value: profile.account ?? '尚未設定',
          left: 726,
          top: 540,
          labelLeft: 726,
          labelTop: 516,
          width: 460,
          height: 56,
          lockLeft: 1158,
          lockTop: 560,
        ),
        _SaveStateMessage(
          left: 230,
          top: 650,
          width: 956,
          height: 72,
          errorMessage: errorMessage,
        ),
        const _TextBlock(
          left: 230,
          top: 764,
          width: 260,
          height: 18,
          text: 'Email 與帳號目前不可在此修改。',
          color: AppColors.profileMuted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }
}

class _MobileProfileCanvas extends StatelessWidget {
  const _MobileProfileCanvas({
    required this.profile,
    required this.userNameController,
    required this.birthdayController,
    required this.isSaving,
    required this.errorMessage,
    required this.onSave,
    required this.onBack,
    required this.onUnavailable,
  });

  final UserProfile profile;
  final TextEditingController userNameController;
  final TextEditingController birthdayController;
  final bool isSaving;
  final String? errorMessage;
  final VoidCallback onSave;
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
        _ProfileBottomNav(onUnavailable: onUnavailable),
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
            style: const TextStyle(
              color: AppColors.profileInk,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            decoration: const InputDecoration(
              filled: true,
              fillColor: AppColors.profileFieldFill,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
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
              errorStyle: TextStyle(fontSize: 10, height: 0.8),
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
  const _SaveButton.desktop({required this.isSaving, required this.onTap})
    : left = 1056,
      top = 10,
      width = 216,
      height = 56,
      text = '儲存變更',
      fontSize = 15;

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

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
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
          left: left + 16,
          top: top + 9,
          width: width - 24,
          height: 14,
          text: '●  帳號正常',
          color: AppColors.profileSuccessText,
          fontSize: 11,
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

class _DesktopNavBar extends StatelessWidget {
  const _DesktopNavBar();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          width: 1440,
          height: 72,
          child: ColoredBox(color: AppColors.profileSurface),
        ),
        Positioned(
          left: 42,
          top: 18,
          width: 118,
          height: 36,
          child: Image(
            image: AssetImage('assets/images/app_logo.png'),
            fit: BoxFit.fill,
          ),
        ),
        _TextBlock(
          left: 212,
          top: 27,
          width: 70,
          height: 18,
          text: '陪伴首頁',
          color: AppColors.profileMuted,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        _TextBlock(
          left: 306,
          top: 27,
          width: 70,
          height: 18,
          text: '心的軌跡',
          color: AppColors.profileMuted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        _TextBlock(
          left: 400,
          top: 27,
          width: 70,
          height: 18,
          text: '怪獸收藏',
          color: AppColors.profileMuted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        _CircleBlock(
          left: 1360,
          top: 18,
          size: 36,
          color: AppColors.profileAvatarHalo,
        ),
      ],
    );
  }
}

class _ProfileBottomNav extends StatelessWidget {
  const _ProfileBottomNav({required this.onUnavailable});

  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) {
    const labels = [
      ('⌂', '首頁', AppColors.profileNavMuted, FontWeight.w400),
      ('◇', '社群', AppColors.profileNavMuted, FontWeight.w400),
      ('◆', '怪獸', AppColors.profileNavMuted, FontWeight.w400),
      ('○', '互動', AppColors.profileNavMuted, FontWeight.w400),
      ('●', '我的', AppColors.profilePrimary, FontWeight.w700),
    ];
    const lefts = [16.0, 90.0, 164.0, 238.0, 312.0];
    return Positioned(
      left: 0,
      top: 774,
      width: 390,
      height: 70,
      child: Stack(
        children: [
          const Positioned.fill(
            child: ColoredBox(color: AppColors.profileSurface),
          ),
          for (var i = 0; i < labels.length; i++)
            Positioned(
              left: lefts[i],
              top: 0,
              width: 62,
              height: 70,
              child: GestureDetector(
                onTap: i == 4 ? null : onUnavailable,
                child: Stack(
                  children: [
                    _TextBlock(
                      left: 0,
                      top: 13,
                      width: 62,
                      height: 22,
                      text: labels[i].$1,
                      color: labels[i].$3,
                      fontSize: 18,
                      fontWeight: labels[i].$4,
                      textAlign: TextAlign.center,
                    ),
                    _TextBlock(
                      left: 0,
                      top: 39,
                      width: 62,
                      height: 16,
                      text: labels[i].$2,
                      color: labels[i].$3,
                      fontSize: 10,
                      fontWeight: labels[i].$4,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
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
