import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../layout/responsive_layout.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
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

    final restoreError = ref.read(authControllerProvider).errorMessage;
    if (restoreError != null) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(restoreError),
          action: SnackBarAction(
            label: '重試',
            onPressed: () => unawaited(_restoreSession()),
          ),
        ),
      );
      return;
    }

    context.goNamed(AppRoute.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: ResponsiveLayout(
        mobile:
            (context, constraints) => const Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 390,
                  height: 844,
                  child: _SplashArtwork(isDesktop: false),
                ),
              ),
            ),
        tablet:
            (context, constraints) =>
                const _ResponsiveSplashArtwork(compact: true),
        desktop: (context, constraints) => const _ResponsiveSplashArtwork(),
      ),
    );
  }
}

class _SplashArtwork extends StatelessWidget {
  const _SplashArtwork({required this.isDesktop});

  final bool isDesktop;

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
            fit: BoxFit.fill,
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
            textAlign: TextAlign.left,
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
          child: _SplashStatusCard(spec: spec),
        ),
        if (!isDesktop)
          Positioned(
            left: spec.noteLeft,
            top: spec.noteTop,
            width: spec.noteWidth,
            height: spec.noteHeight,
            child: Text(
              '貘nsters · 陪你整理每一種心情',
              textAlign: TextAlign.left,
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

class _ResponsiveSplashArtwork extends StatelessWidget {
  const _ResponsiveSplashArtwork({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final logoWidth = compact ? 240.0 : 300.0;
    final logoHeight = compact ? 74.0 : 92.0;
    final haloSize = compact ? 280.0 : 330.0;
    final monsterSize = compact ? 190.0 : 220.0;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 32 : 48,
                  vertical: 48,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/app_logo.png',
                        key: const Key('splashLogo'),
                        width: logoWidth,
                        height: logoHeight,
                        fit: BoxFit.fill,
                        semanticLabel: 'monsters logo',
                      ),
                      SizedBox(height: compact ? 36 : 58),
                      SizedBox.square(
                        dimension: haloSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.splashHalo,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/images/icon.png',
                              key: const Key('splashMonster'),
                              width: monsterSize,
                              height: monsterSize,
                              fit: BoxFit.contain,
                              semanticLabel: 'monsters mascot',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: compact ? 32 : 42),
                      SizedBox(
                        width: compact ? 340 : 390,
                        child: Text(
                          '把心裡的重量，先放在這裡。',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.splashAccentText,
                            fontSize: compact ? 22 : 28,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 32 : 46),
                      SizedBox(
                        width: 340,
                        child: _ResponsiveSplashStatusCard(compact: compact),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResponsiveSplashStatusCard extends StatelessWidget {
  const _ResponsiveSplashStatusCard({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('splashStatusCard'),
      decoration: BoxDecoration(
        color: AppColors.splashStatusBackground,
        border: Border.all(color: AppColors.splashStatusBorder),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 22 : 25,
          vertical: compact ? 18 : 17,
        ),
        child: const Row(
          children: [
            const SizedBox.square(
              dimension: 16,
              child: DecoratedBox(
                key: Key('splashStatusDot'),
                decoration: BoxDecoration(
                  color: AppColors.splashPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 18),
            const Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '正在確認登入狀態…',
                    key: Key('splashStatusText'),
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
                    key: Key('splashStatusHint'),
                    style: TextStyle(
                      color: AppColors.splashMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashStatusCard extends StatelessWidget {
  const _SplashStatusCard({required this.spec});

  final _SplashSpec spec;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('splashStatusCard'),
      decoration: BoxDecoration(
        color: AppColors.splashStatusBackground,
        border: Border.all(color: AppColors.splashStatusBorder),
      ),
      child: Stack(
        children: [
          Positioned(
            left: spec.statusDotLeft,
            top: spec.statusDotTop,
            width: 16,
            height: 16,
            child: const DecoratedBox(
              key: Key('splashStatusDot'),
              decoration: BoxDecoration(
                color: AppColors.splashPrimary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: spec.statusTextLeft,
            top: spec.statusTextTop,
            width: 123,
            height: 17,
            child: const Text(
              '正在確認登入狀態…',
              key: Key('splashStatusText'),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.splashInk,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          Positioned(
            left: spec.statusHintLeft,
            top: spec.statusHintTop,
            width: 118,
            height: 14,
            child: const Text(
              '最長保留 30 天登入狀態',
              key: Key('splashStatusHint'),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.splashMuted,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
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
    required this.statusDotLeft,
    required this.statusDotTop,
    required this.statusTextLeft,
    required this.statusTextTop,
    required this.statusHintLeft,
    required this.statusHintTop,
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
      statusDotLeft: 26,
      statusDotTop: 29,
      statusTextLeft: 60,
      statusTextTop: 22,
      statusHintLeft: 60,
      statusHintTop: 46,
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
      statusDotLeft: 22,
      statusDotTop: 28,
      statusTextLeft: 54,
      statusTextTop: 22,
      statusHintLeft: 54,
      statusHintTop: 48,
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
  final double statusDotLeft;
  final double statusDotTop;
  final double statusTextLeft;
  final double statusTextTop;
  final double statusHintLeft;
  final double statusHintTop;
  final double noteLeft;
  final double noteTop;
  final double noteWidth;
  final double noteHeight;
  final double noteFontSize;
}
