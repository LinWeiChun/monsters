import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const double _desktopBreakpoint = 900;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(
      authControllerProvider.select(
        (state) => state.loginResult?.user.userName.trim(),
      ),
    );
    final greetingName = userName == null || userName.isEmpty ? '你' : userName;

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= _desktopBreakpoint;
          final size = isDesktop ? const Size(1440, 900) : const Size(390, 844);
          return Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child:
                    isDesktop
                        ? _DesktopHomeCanvas(
                          greetingName: greetingName,
                          onAddAnnoyance:
                              () => context.goNamed(AppRoute.annoyanceChat),
                          onUnavailable: () => _showUnavailableMessage(context),
                        )
                        : _MobileHomeCanvas(
                          greetingName: greetingName,
                          onAddAnnoyance:
                              () => context.goNamed(AppRoute.annoyanceChat),
                          onProfile: () => context.goNamed(AppRoute.profile),
                          onUnavailable: () => _showUnavailableMessage(context),
                        ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DesktopHomeCanvas extends StatelessWidget {
  const _DesktopHomeCanvas({
    required this.greetingName,
    required this.onAddAnnoyance,
    required this.onUnavailable,
  });

  final String greetingName;
  final VoidCallback onAddAnnoyance;
  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: AppColors.homeBackground),
        ),
        const _TextBlock(
          left: 168,
          top: 52,
          width: 270,
          height: 36,
          text: '陪你整理今天的心情',
          color: AppColors.homeInk,
          fontSize: 30,
          fontWeight: FontWeight.w700,
        ),
        const _TextBlock(
          left: 168,
          top: 96,
          width: 760,
          height: 24,
          text: '選一件現在最想做的事，不需要一次處理所有情緒。',
          color: AppColors.homeMuted,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        _HeroPanel(
          key: const Key('desktopCompanionHero'),
          left: 168,
          top: 152,
          width: 630,
          height: 520,
          monsterLeft: 208,
          monsterTop: 208,
          monsterSize: 260,
          cardLeft: 494,
          cardTop: 218,
          cardWidth: 264,
          cardHeight: 150,
          titleLeft: 518,
          titleTop: 246,
          titleFontSize: 22,
          bodyLeft: 518,
          bodyTop: 288,
          bodyWidth: 214,
          bodyText: '今天有什麼想說的嗎？\n慢慢來就好。',
          greetingName: greetingName,
        ),
        _ActionCard(
          key: const Key('homeAnnoyanceChatButton'),
          left: 830,
          top: 152,
          width: 414,
          height: 154,
          background: AppColors.homePrimary,
          icon: '◇',
          iconLeft: 28,
          iconTop: 36,
          iconColor: AppColors.homeOnPrimary,
          title: '記下現在的心情',
          titleLeft: 76,
          titleTop: 28,
          titleColor: AppColors.homeOnPrimary,
          caption: '用聊天方式記錄煩惱',
          captionLeft: 76,
          captionTop: 66,
          captionColor: AppColors.homePrimaryCaption,
          arrowLeft: 378,
          arrowTop: 52,
          onTap: onAddAnnoyance,
        ),
        _ActionCard(
          left: 830,
          top: 322,
          width: 414,
          height: 154,
          background: AppColors.homeSurface,
          border: AppColors.homeBorder,
          icon: '✦',
          iconLeft: 28,
          iconTop: 36,
          iconColor: AppColors.homePrimary,
          title: '寫一篇日記',
          titleLeft: 76,
          titleTop: 28,
          titleColor: AppColors.homeInk,
          caption: 'Phase 4 即將開放',
          captionLeft: 76,
          captionTop: 66,
          captionColor: AppColors.homeMutedAlt,
          onTap: onUnavailable,
        ),
        _ActionCard(
          left: 830,
          top: 492,
          width: 414,
          height: 82,
          background: AppColors.homeSurface,
          border: AppColors.homeBorder,
          icon: '◷',
          iconLeft: 28,
          iconTop: 18,
          iconColor: AppColors.homePrimary,
          title: '回顧心情記錄',
          titleLeft: 76,
          titleTop: 12,
          titleColor: AppColors.homeInk,
          caption: '歷史記錄與心的軌跡即將開放',
          captionLeft: 76,
          captionTop: 44,
          captionColor: AppColors.homeMutedAlt,
          onTap: onUnavailable,
        ),
        _CollectionPanel.desktop(onUnavailable: onUnavailable),
      ],
    );
  }
}

class _MobileHomeCanvas extends StatelessWidget {
  const _MobileHomeCanvas({
    required this.greetingName,
    required this.onAddAnnoyance,
    required this.onProfile,
    required this.onUnavailable,
  });

  final String greetingName;
  final VoidCallback onAddAnnoyance;
  final VoidCallback onProfile;
  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: AppColors.homeBackground),
        ),
        const Positioned(
          left: 0,
          top: 0,
          width: 390,
          height: 72,
          child: ColoredBox(color: AppColors.homeSurface),
        ),
        const Positioned(
          left: 20,
          top: 12,
          width: 96,
          height: 48,
          child: Image(
            image: AssetImage('assets/images/app_logo.png'),
            key: Key('homeMobileLogo'),
            fit: BoxFit.fill,
          ),
        ),
        _AccountButton(onTap: onProfile),
        _HeroPanel(
          key: const Key('mobileCompanionHero'),
          left: 16,
          top: 92,
          width: 358,
          height: 294,
          monsterLeft: 119,
          monsterTop: 102,
          monsterSize: 152,
          cardLeft: 40,
          cardTop: 250,
          cardWidth: 310,
          cardHeight: 118,
          titleLeft: 64,
          titleTop: 268,
          titleFontSize: 20,
          bodyLeft: 64,
          bodyTop: 306,
          bodyWidth: 262,
          bodyText: '今天有什麼想說的嗎？慢慢來就好。',
          greetingName: greetingName,
        ),
        _CollectionPanel.mobile(onUnavailable: onUnavailable),
        _MobilePrimaryAction(onTap: onAddAnnoyance),
        _MobileQuickAction(
          left: 16,
          icon: '✦',
          title: '寫日記',
          caption: '即將開放',
          background: AppColors.homeSurface,
          border: AppColors.homeBorder,
          iconColor: AppColors.homePrimary,
          onTap: onUnavailable,
        ),
        _MobileQuickAction(
          left: 138,
          icon: '◷',
          title: '回顧記錄',
          caption: '即將開放',
          background: AppColors.homeSurface,
          border: AppColors.homeBorder,
          iconColor: AppColors.homePrimary,
          onTap: onUnavailable,
        ),
        _MobileQuickAction(
          left: 260,
          icon: '✦',
          title: '互動區',
          caption: '放鬆一下',
          background: AppColors.homeInteractionBackground,
          border: AppColors.homeInteractionBorder,
          iconColor: AppColors.homeAccent,
          titleColor: AppColors.homeInkSoft,
          captionColor: AppColors.homeNavMuted,
          onTap: onUnavailable,
        ),
        _BottomNavigation(onUnavailable: onUnavailable),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.monsterLeft,
    required this.monsterTop,
    required this.monsterSize,
    required this.cardLeft,
    required this.cardTop,
    required this.cardWidth,
    required this.cardHeight,
    required this.titleLeft,
    required this.titleTop,
    required this.titleFontSize,
    required this.bodyLeft,
    required this.bodyTop,
    required this.bodyWidth,
    required this.bodyText,
    required this.greetingName,
    super.key,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final double monsterLeft;
  final double monsterTop;
  final double monsterSize;
  final double cardLeft;
  final double cardTop;
  final double cardWidth;
  final double cardHeight;
  final double titleLeft;
  final double titleTop;
  final double titleFontSize;
  final double bodyLeft;
  final double bodyTop;
  final double bodyWidth;
  final String bodyText;
  final String greetingName;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          width: width,
          height: height,
          child: const ColoredBox(color: AppColors.homeHero),
        ),
        Positioned(
          left: monsterLeft,
          top: monsterTop,
          width: monsterSize,
          height: monsterSize,
          child: const _AnimatedHomeMonster(),
        ),
        Positioned(
          left: cardLeft,
          top: cardTop,
          width: cardWidth,
          height: cardHeight,
          child: const ColoredBox(color: AppColors.homeSurface),
        ),
        _TextBlock(
          left: titleLeft,
          top: titleTop,
          width: 180,
          height: titleFontSize + 6,
          text: '$greetingName，我在這裡。',
          color: AppColors.homeInk,
          fontSize: titleFontSize,
          fontWeight: FontWeight.w600,
        ),
        _TextBlock(
          left: bodyLeft,
          top: bodyTop,
          width: bodyWidth,
          height: 48,
          text: bodyText,
          color: AppColors.homeMuted,
          fontSize: titleFontSize == 22 ? 16 : 14,
          fontWeight: FontWeight.w400,
        ),
      ],
    );
  }
}

class _AnimatedHomeMonster extends StatefulWidget {
  const _AnimatedHomeMonster();

  @override
  State<_AnimatedHomeMonster> createState() => _AnimatedHomeMonsterState();
}

class _AnimatedHomeMonsterState extends State<_AnimatedHomeMonster>
    with TickerProviderStateMixin {
  late final AnimationController _reactionController;
  late final Animation<double> _scale;
  late final Animation<double> _offset;
  bool _isReacting = false;

  @override
  void initState() {
    super.initState();
    _reactionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 0.94), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.08), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1), weight: 45),
    ]).animate(
      CurvedAnimation(parent: _reactionController, curve: Curves.easeOut),
    );
    _offset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 8), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 8, end: -12), weight: 35),
      TweenSequenceItem(tween: Tween(begin: -12, end: 0), weight: 45),
    ]).animate(
      CurvedAnimation(parent: _reactionController, curve: Curves.easeOut),
    );
    _reactionController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _isReacting = false);
      }
    });
  }

  @override
  void dispose() {
    _reactionController.dispose();
    super.dispose();
  }

  void _react() {
    if (MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    setState(() => _isReacting = true);
    _reactionController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('homeAnimatedMonster'),
      onTap: _react,
      child: AnimatedBuilder(
        key: Key(
          _isReacting
              ? 'homeAnimatedMonsterReacting'
              : 'homeAnimatedMonsterIdle',
        ),
        animation: _reactionController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              MediaQuery.disableAnimationsOf(context) ? 0 : _offset.value,
            ),
            child: Transform.scale(
              scale: MediaQuery.disableAnimationsOf(context) ? 1 : _scale.value,
              child: child,
            ),
          );
        },
        child: Image.asset('assets/images/app_icon.png', fit: BoxFit.contain),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.background,
    required this.icon,
    required this.iconLeft,
    required this.iconTop,
    required this.iconColor,
    required this.title,
    required this.titleLeft,
    required this.titleTop,
    required this.titleColor,
    required this.caption,
    required this.captionLeft,
    required this.captionTop,
    required this.captionColor,
    required this.onTap,
    this.border,
    this.arrowLeft,
    this.arrowTop,
    super.key,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final Color background;
  final Color? border;
  final String icon;
  final double iconLeft;
  final double iconTop;
  final Color iconColor;
  final String title;
  final double titleLeft;
  final double titleTop;
  final Color titleColor;
  final String caption;
  final double captionLeft;
  final double captionTop;
  final Color captionColor;
  final double? arrowLeft;
  final double? arrowTop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: background,
                  border: border == null ? null : Border.all(color: border!),
                ),
              ),
            ),
            _TextBlock(
              left: iconLeft,
              top: iconTop,
              width: 34,
              height: 34,
              text: icon,
              color: iconColor,
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
            _TextBlock(
              left: titleLeft,
              top: titleTop,
              width: 180,
              height: 28,
              text: title,
              color: titleColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            _TextBlock(
              left: captionLeft,
              top: captionTop,
              width: 300,
              height: 24,
              text: caption,
              color: captionColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            if (arrowLeft != null && arrowTop != null)
              _TextBlock(
                left: arrowLeft!,
                top: arrowTop!,
                width: 24,
                height: 30,
                text: '→',
                color: AppColors.homeOnPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
          ],
        ),
      ),
    );
  }
}

class _MobilePrimaryAction extends StatelessWidget {
  const _MobilePrimaryAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      top: 536,
      width: 358,
      height: 54,
      child: GestureDetector(
        key: const Key('homeAnnoyanceChatButton'),
        onTap: onTap,
        child: const Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: AppColors.homePrimary)),
            _TextBlock(
              left: 95,
              top: 16,
              width: 112,
              height: 20,
              text: '記下現在的心情',
              color: AppColors.homeOnPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            _TextBlock(
              left: 322,
              top: 14,
              width: 24,
              height: 28,
              text: '→',
              color: AppColors.homeOnPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileQuickAction extends StatelessWidget {
  const _MobileQuickAction({
    required this.left,
    required this.icon,
    required this.title,
    required this.caption,
    required this.background,
    required this.border,
    required this.iconColor,
    required this.onTap,
    this.titleColor,
    this.captionColor,
  });

  final double left;
  final String icon;
  final String title;
  final String caption;
  final Color background;
  final Color border;
  final Color iconColor;
  final Color? titleColor;
  final Color? captionColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final resolvedTitleColor = titleColor ?? AppColors.homeInk;
    return Positioned(
      left: left,
      top: 606,
      width: 114,
      height: 104,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: background,
                  border: Border.all(color: border),
                ),
              ),
            ),
            _TextBlock(
              left: 14,
              top: 12,
              width: 30,
              height: 30,
              text: icon,
              color: iconColor,
              fontSize: 25,
              fontWeight: FontWeight.w500,
            ),
            _TextBlock(
              left: 14,
              top: 44,
              width: 82,
              height: 20,
              text: title,
              color: resolvedTitleColor,
              fontSize: title == '互動區' ? 14 : 16,
              fontWeight: FontWeight.w700,
            ),
            _TextBlock(
              left: 14,
              top: 70,
              width: 82,
              height: 16,
              text: caption,
              color: captionColor ?? AppColors.homeMutedAlt,
              fontSize: title == '互動區' ? 10 : 12,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionPanel extends StatelessWidget {
  const _CollectionPanel._({
    required this.isDesktop,
    required this.onUnavailable,
  });

  factory _CollectionPanel.desktop({required VoidCallback onUnavailable}) {
    return _CollectionPanel._(isDesktop: true, onUnavailable: onUnavailable);
  }

  factory _CollectionPanel.mobile({required VoidCallback onUnavailable}) {
    return _CollectionPanel._(isDesktop: false, onUnavailable: onUnavailable);
  }

  final bool isDesktop;
  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) {
    final left = isDesktop ? 192.0 : 16.0;
    final top = isDesktop ? 500.0 : 402.0;
    final width = isDesktop ? 582.0 : 358.0;
    final height = isDesktop ? 144.0 : 118.0;
    final item = isDesktop ? 62.0 : 54.0;
    final image = isDesktop ? 54.0 : 46.0;
    final firstLeft = isDesktop ? 16.0 : 16.0;
    final imageTop = isDesktop ? 52.0 : 52.0;
    final gap = isDesktop ? 70.0 : 60.0;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onUnavailable,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.homePanel,
                  border: Border.all(color: AppColors.homeSoftBorder),
                ),
              ),
            ),
            _TextBlock(
              left: isDesktop ? 24 : 18,
              top: isDesktop ? 18 : 14,
              width: 70,
              height: 20,
              text: '我的怪獸',
              color: AppColors.homeInkAlt,
              fontSize: isDesktop ? 16 : 14,
              fontWeight: FontWeight.w800,
            ),
            _TextBlock(
              left: isDesktop ? 108 : 90,
              top: isDesktop ? 21 : 16,
              width: 38,
              height: 16,
              text: '8 / 20',
              color: AppColors.homeAccent,
              fontSize: isDesktop ? 12 : 11,
              fontWeight: FontWeight.w700,
            ),
            if (isDesktop)
              const _TextBlock(
                left: 182,
                top: 21,
                width: 128,
                height: 16,
                text: '點擊即可切換陪伴怪獸',
                color: AppColors.homeMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            _TextBlock(
              left: isDesktop ? 498 : 276,
              top: isDesktop ? 21 : 16,
              width: 60,
              height: 16,
              text: '查看全部 ›',
              color: AppColors.homeAccent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            _MonsterChip(
              left: firstLeft,
              top: imageTop,
              size: item,
              imageSize: image,
              selected: true,
              asset: 'assets/images/icon.png',
            ),
            _MonsterChip(
              left: firstLeft + gap,
              top: imageTop,
              size: item,
              imageSize: image,
              asset: 'assets/images/app_icon.png',
            ),
            _MonsterChip(
              left: firstLeft + gap * 2,
              top: imageTop,
              size: item,
              imageSize: image,
              asset: 'assets/images/bonus.png',
            ),
            _MonsterChip(
              left: firstLeft + gap * 3,
              top: imageTop,
              size: item,
              imageSize: image,
              asset: 'assets/images/icon_main.png',
            ),
            _MoreMonsterChip(
              left: firstLeft + gap * 4,
              top: imageTop,
              size: image,
            ),
          ],
        ),
      ),
    );
  }
}

class _MonsterChip extends StatelessWidget {
  const _MonsterChip({
    required this.left,
    required this.top,
    required this.size,
    required this.imageSize,
    required this.asset,
    this.selected = false,
  });

  final double left;
  final double top;
  final double size;
  final double imageSize;
  final String asset;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: Stack(
        children: [
          if (selected)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.homeMonsterSelected,
                  border: Border.all(color: AppColors.homeAccent),
                ),
              ),
            ),
          Center(
            child: Image.asset(
              asset,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreMonsterChip extends StatelessWidget {
  const _MoreMonsterChip({
    required this.left,
    required this.top,
    required this.size,
  });

  final double left;
  final double top;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: const Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.homeMonsterMore,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Text(
              '+4',
              style: TextStyle(
                color: AppColors.homeAccent,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountButton extends StatelessWidget {
  const _AccountButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 338,
      top: 18,
      width: 38,
      height: 38,
      child: GestureDetector(
        key: const Key('homeAccountMenu'),
        onTap: onTap,
        child: const Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.homeAccountBackground,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            _TextBlock(
              left: 12,
              top: 4,
              width: 16,
              height: 24,
              text: '●',
              color: AppColors.homePrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({required this.onUnavailable});

  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) {
    const labels = [
      ('⌂', '首頁', AppColors.homeAccent, FontWeight.w400),
      ('♡', '社群', AppColors.homeNavMuted, FontWeight.w400),
      ('◇', '怪獸', AppColors.homeNavMuted, FontWeight.w400),
      ('✦', '互動', AppColors.homeNavMuted, FontWeight.w700),
      ('○', '我的', AppColors.homeNavMuted, FontWeight.w400),
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
            child: ColoredBox(color: AppColors.homeSurface),
          ),
          for (var i = 0; i < labels.length; i++)
            Positioned(
              left: lefts[i],
              top: 0,
              width: 62,
              height: 70,
              child: GestureDetector(
                onTap: i == 0 ? null : onUnavailable,
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

void _showUnavailableMessage(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text('此功能即將開放')));
}
