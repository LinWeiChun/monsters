import 'package:flutter/material.dart';

import '../../layout/responsive_layout.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'password_reset_brand_panel.dart';

class PasswordResetShell extends StatelessWidget {
  const PasswordResetShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.registerFieldBorder),
    );
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: AppColors.registerPrimary,
          onPrimary: AppColors.registerOnPrimary,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(120, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.registerFieldFill,
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: const BorderSide(
              color: AppColors.registerPrimary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.all(AppSpacing.md),
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.registerFormBackground,
        body: SafeArea(
          child: ResponsiveLayout(
            mobile:
                (context, constraints) => _FormViewport(
                  maxWidth: 430,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: AppSpacing.md,
                  ),
                  child: child,
                ),
            tablet:
                (context, constraints) => _FormViewport(
                  maxWidth: 560,
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: child,
                ),
            desktop:
                (context, constraints) => Row(
                  children: [
                    const Expanded(flex: 5, child: PasswordResetBrandPanel()),
                    Expanded(
                      flex: 7,
                      child: _FormViewport(
                        maxWidth: 520,
                        padding: const EdgeInsets.all(64),
                        child: child,
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

class PasswordResetStatus extends StatelessWidget {
  const PasswordResetStatus({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('passwordResetStatus'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Image.asset(
            'assets/images/title.png',
            width: 150,
            semanticLabel: '貘nsters',
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Icon(icon, size: 68, color: AppColors.registerPrimary),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.registerInk,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.registerMuted),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
        if (secondaryLabel != null) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
        ],
      ],
    );
  }
}

class _FormViewport extends StatelessWidget {
  const _FormViewport({
    required this.maxWidth,
    required this.padding,
    required this.child,
  });

  final double maxWidth;
  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:
          (context, viewport) => Padding(
            padding:
                viewport.maxHeight < 500
                    ? EdgeInsets.symmetric(
                      horizontal: padding.left,
                      vertical: 12,
                    )
                    : padding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth.clamp(0.0, maxWidth);
                return Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(width: width, child: child),
                  ),
                );
              },
            ),
          ),
    );
  }
}
