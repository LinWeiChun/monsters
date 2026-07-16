import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _checkedSession = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_restoreSession);
  }

  Future<void> _restoreSession() async {
    final restored =
        await ref.read(authControllerProvider.notifier).restoreSession();
    if (!mounted) {
      return;
    }

    if (restored) {
      context.goNamed(AppRoute.home);
      return;
    }

    setState(() {
      _checkedSession = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          final designSize =
              isDesktop ? const Size(1440, 900) : const Size(390, 844);

          return Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: designSize.width,
                height: designSize.height,
                child: _SplashArtwork(
                  isDesktop: isDesktop,
                  showActions: _checkedSession,
                  onLogin: () => context.goNamed(AppRoute.login),
                  onRegister: () => context.goNamed(AppRoute.register),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SplashArtwork extends StatelessWidget {
  const _SplashArtwork({
    required this.isDesktop,
    required this.showActions,
    required this.onLogin,
    required this.onRegister,
  });

  final bool isDesktop;
  final bool showActions;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final spec = isDesktop ? _SplashSpec.web() : _SplashSpec.mobile();

    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: AppColors.splashBackground),
        ),
        Positioned(
          left: spec.logoLeft,
          top: spec.logoTop,
          width: spec.logoWidth,
          height: spec.logoHeight,
          child: Image.asset(
            'assets/images/app_logo.png',
            key: const Key('splashLogo'),
            fit: BoxFit.contain,
            semanticLabel: 'monsters logo',
          ),
        ),
        if (isDesktop)
          Positioned(
            left: spec.haloLeft,
            top: spec.haloTop,
            width: spec.haloSize,
            height: spec.haloSize,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.splashHalo,
                shape: BoxShape.circle,
              ),
            ),
          ),
        Positioned(
          left: spec.monsterLeft,
          top: spec.monsterTop,
          width: spec.monsterSize,
          height: spec.monsterSize,
          child: Image.asset(
            'assets/images/icon.png',
            key: const Key('splashMonster'),
            fit: BoxFit.contain,
            semanticLabel: 'monsters mascot',
          ),
        ),
        Positioned(
          left: spec.quoteLeft,
          top: spec.quoteTop,
          width: spec.quoteWidth,
          height: spec.quoteHeight,
          child: Text(
            '把心裡的重量，先放在這裡。',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.splashAccentText,
              fontSize: spec.quoteFontSize,
              fontWeight: spec.quoteFontWeight,
              height: 1.2,
            ),
          ),
        ),
        Positioned(
          left: spec.statusLeft,
          top: spec.statusTop,
          width: spec.statusWidth,
          height: spec.statusHeight,
          child: const _SplashStatusCard(),
        ),
        if (showActions)
          Positioned(
            left: spec.actionLeft,
            top: spec.actionTop,
            width: spec.actionWidth,
            child: _SplashActions(onLogin: onLogin, onRegister: onRegister),
          ),
        if (!isDesktop)
          Positioned(
            left: spec.noteLeft,
            top: spec.noteTop,
            width: spec.noteWidth,
            height: spec.noteHeight,
            child: Text(
              '貘nsters · 陪你整理每一種心情',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.splashMuted,
                fontSize: spec.noteFontSize,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ),
      ],
    );
  }
}

class _SplashStatusCard extends StatelessWidget {
  const _SplashStatusCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('splashStatusCard'),
      decoration: BoxDecoration(
        color: AppColors.splashStatusBackground,
        border: Border.all(color: AppColors.splashStatusBorder),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.splashPrimary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '正在確認登入狀態…',
                  style: TextStyle(
                    color: AppColors.splashInk,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '最長保留 30 天登入狀態',
                  style: TextStyle(
                    color: AppColors.splashMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashActions extends StatelessWidget {
  const _SplashActions({required this.onLogin, required this.onRegister});

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 128,
          height: 44,
          child: FilledButton(
            key: const Key('splashLoginButton'),
            onPressed: onLogin,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.splashPrimary,
              foregroundColor: AppColors.splashOnPrimary,
            ),
            child: const Text('登入'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 128,
          height: 44,
          child: OutlinedButton(
            key: const Key('splashRegisterButton'),
            onPressed: onRegister,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.splashPrimary,
              side: const BorderSide(color: AppColors.splashPrimary),
            ),
            child: const Text('註冊'),
          ),
        ),
      ],
    );
  }
}

class _SplashSpec {
  const _SplashSpec({
    required this.logoLeft,
    required this.logoTop,
    required this.logoWidth,
    required this.logoHeight,
    required this.haloLeft,
    required this.haloTop,
    required this.haloSize,
    required this.monsterLeft,
    required this.monsterTop,
    required this.monsterSize,
    required this.quoteLeft,
    required this.quoteTop,
    required this.quoteWidth,
    required this.quoteHeight,
    required this.quoteFontSize,
    required this.quoteFontWeight,
    required this.statusLeft,
    required this.statusTop,
    required this.statusWidth,
    required this.statusHeight,
    required this.actionLeft,
    required this.actionTop,
    required this.actionWidth,
    required this.noteLeft,
    required this.noteTop,
    required this.noteWidth,
    required this.noteHeight,
    required this.noteFontSize,
  });

  factory _SplashSpec.web() {
    return const _SplashSpec(
      logoLeft: 570,
      logoTop: 120,
      logoWidth: 300,
      logoHeight: 92,
      haloLeft: 555,
      haloTop: 270,
      haloSize: 330,
      monsterLeft: 610,
      monsterTop: 318,
      monsterSize: 220,
      quoteLeft: 500,
      quoteTop: 642,
      quoteWidth: 390,
      quoteHeight: 36,
      quoteFontSize: 30,
      quoteFontWeight: FontWeight.w800,
      statusLeft: 550,
      statusTop: 724,
      statusWidth: 340,
      statusHeight: 74,
      actionLeft: 582,
      actionTop: 814,
      actionWidth: 276,
      noteLeft: 0,
      noteTop: 0,
      noteWidth: 0,
      noteHeight: 0,
      noteFontSize: 12,
    );
  }

  factory _SplashSpec.mobile() {
    return const _SplashSpec(
      logoLeft: 92,
      logoTop: 94,
      logoWidth: 206,
      logoHeight: 64,
      haloLeft: 0,
      haloTop: 0,
      haloSize: 0,
      monsterLeft: 78,
      monsterTop: 224,
      monsterSize: 234,
      quoteLeft: 68,
      quoteTop: 496,
      quoteWidth: 270,
      quoteHeight: 24,
      quoteFontSize: 18,
      quoteFontWeight: FontWeight.w700,
      statusLeft: 54,
      statusTop: 586,
      statusWidth: 282,
      statusHeight: 82,
      actionLeft: 57,
      actionTop: 698,
      actionWidth: 276,
      noteLeft: 79,
      noteTop: 774,
      noteWidth: 162,
      noteHeight: 15,
      noteFontSize: 12,
    );
  }

  final double logoLeft;
  final double logoTop;
  final double logoWidth;
  final double logoHeight;
  final double haloLeft;
  final double haloTop;
  final double haloSize;
  final double monsterLeft;
  final double monsterTop;
  final double monsterSize;
  final double quoteLeft;
  final double quoteTop;
  final double quoteWidth;
  final double quoteHeight;
  final double quoteFontSize;
  final FontWeight quoteFontWeight;
  final double statusLeft;
  final double statusTop;
  final double statusWidth;
  final double statusHeight;
  final double actionLeft;
  final double actionTop;
  final double actionWidth;
  final double noteLeft;
  final double noteTop;
  final double noteWidth;
  final double noteHeight;
  final double noteFontSize;
}
