import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../layout/responsive_layout.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

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
      body: ResponsiveLayout(
        desktop:
            (context, constraints) => _DesktopHomeCanvas(
              greetingName: greetingName,
              onAddAnnoyance: () => context.goNamed(AppRoute.annoyanceChat),
              onProfile: () => context.goNamed(AppRoute.profile),
              onUnavailable: () => _showUnavailableMessage(context),
            ),
        tablet:
            (context, constraints) => _TabletHomeCanvas(
              greetingName: greetingName,
              onAddAnnoyance: () => context.goNamed(AppRoute.annoyanceChat),
              onProfile: () => context.goNamed(AppRoute.profile),
              onUnavailable: () => _showUnavailableMessage(context),
            ),
        mobile:
            (context, constraints) => ClipRect(
              child: FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 390,
                  height: 844,
                  child: _MobileHomeCanvas(
                    greetingName: greetingName,
                    onAddAnnoyance:
                        () => context.goNamed(AppRoute.annoyanceChat),
                    onProfile: () => context.goNamed(AppRoute.profile),
                    onUnavailable: () => _showUnavailableMessage(context),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

class _DesktopHomeCanvas extends StatelessWidget {
  const _DesktopHomeCanvas({
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
    return ColoredBox(
      key: const Key('homeDesktopShell'),
      color: AppColors.homeBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DesktopNavBar(
            onAddAnnoyance: onAddAnnoyance,
            onProfile: onProfile,
            onUnavailable: onUnavailable,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = constraints.maxWidth.clamp(980.0, 1200.0);
                final horizontalPadding =
                    (constraints.maxWidth - contentWidth) / 2;
                final verticalPadding = (constraints.maxHeight * 0.08).clamp(
                  32.0,
                  56.0,
                );
                final columnGap = (contentWidth * 0.03).clamp(24.0, 40.0);

                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      verticalPadding,
                      horizontalPadding,
                      verticalPadding,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '陪你整理今天的心情',
                            style: TextStyle(
                              color: AppColors.homeInk,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: verticalPadding * 0.18),
                          const Text(
                            '選一件現在最想做的事，不需要一次處理所有情緒。',
                            style: TextStyle(
                              color: AppColors.homeMuted,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: verticalPadding * 0.65),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 19,
                                child: Column(
                                  children: [
                                    const _DesktopHeroPanel(
                                      key: Key('desktopCompanionHero'),
                                    ),
                                    SizedBox(height: verticalPadding * 0.45),
                                    _DesktopCollectionPanel(
                                      onUnavailable: onUnavailable,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: columnGap),
                              Expanded(
                                flex: 10,
                                child: _DesktopActionColumn(
                                  onAddAnnoyance: onAddAnnoyance,
                                  onUnavailable: onUnavailable,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabletHomeCanvas extends StatelessWidget {
  const _TabletHomeCanvas({
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
    return ColoredBox(
      key: const Key('homeTabletShell'),
      color: AppColors.homeBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TabletNavBar(onAddAnnoyance: onAddAnnoyance, onProfile: onProfile),
          Expanded(
            child: SingleChildScrollView(
              child: ResponsiveContent(
                maxWidth: 900,
                horizontalPadding: 32,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '陪你整理今天的心情',
                        style: TextStyle(
                          color: AppColors.homeInk,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '畫面會依瀏覽器寬度重新排列，先選一件現在最想做的事。',
                        style: TextStyle(
                          color: AppColors.homeMuted,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const _DesktopHeroPanel(key: Key('tabletCompanionHero')),
                      const SizedBox(height: 24),
                      _TabletCollectionPanel(onUnavailable: onUnavailable),
                      const SizedBox(height: 24),
                      _DesktopActionColumn(
                        onAddAnnoyance: onAddAnnoyance,
                        onUnavailable: onUnavailable,
                      ),
                    ],
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

class _TabletNavBar extends StatelessWidget {
  const _TabletNavBar({required this.onAddAnnoyance, required this.onProfile});

  final VoidCallback onAddAnnoyance;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.homeSurface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                const Image(
                  image: AssetImage('assets/images/app_logo.png'),
                  key: Key('homeTabletLogo'),
                  width: 124,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                SizedBox(
                  height: 40,
                  child: FilledButton(
                    key: const Key('homeTabletCtaButton'),
                    onPressed: onAddAnnoyance,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.homePrimary,
                      foregroundColor: AppColors.homeOnPrimary,
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: const Text('＋ 記下心情'),
                  ),
                ),
                const SizedBox(width: 16),
                _DesktopCircleButton(
                  key: const Key('homeAccountMenu'),
                  label: 'W',
                  filled: true,
                  onTap: onProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabletCollectionPanel extends StatelessWidget {
  const _TabletCollectionPanel({required this.onUnavailable});

  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) {
    const assets = [
      'assets/images/icon.png',
      'assets/images/app_icon.png',
      'assets/images/bonus.png',
      'assets/images/icon_main.png',
      'assets/images/icon.png',
      'assets/images/app_icon.png',
      'assets/images/icon_main.png',
    ];

    return InkWell(
      onTap: onUnavailable,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.homePanel,
          border: Border.all(color: AppColors.homeSoftBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    '我的怪獸',
                    style: TextStyle(
                      color: AppColors.homeInkAlt,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    '8 / 20',
                    style: TextStyle(
                      color: AppColors.homeAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '查看全部 ›',
                    style: TextStyle(
                      color: AppColors.homeAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (var index = 0; index < assets.length; index++)
                    _DesktopMonsterChip(
                      asset: assets[index],
                      selected: index == 0,
                    ),
                  const _DesktopMoreChip(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopNavBar extends StatelessWidget {
  const _DesktopNavBar({
    required this.onAddAnnoyance,
    required this.onProfile,
    required this.onUnavailable,
  });

  final VoidCallback onAddAnnoyance;
  final VoidCallback onProfile;
  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = (constraints.maxWidth * 0.03).clamp(
          32.0,
          56.0,
        );
        final itemGap = (constraints.maxWidth * 0.025).clamp(24.0, 36.0);

        return ColoredBox(
          color: AppColors.homeSurface,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: SizedBox(
              height: 72,
              child: Row(
                children: [
                  const Image(
                    image: AssetImage('assets/images/app_logo.png'),
                    key: Key('homeDesktopLogo'),
                    width: 130,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: itemGap),
                  const _DesktopNavText('陪伴首頁', active: true),
                  SizedBox(width: itemGap * 0.8),
                  const _DesktopNavText('心的軌跡'),
                  SizedBox(width: itemGap * 0.8),
                  const _DesktopNavText('怪獸收藏'),
                  SizedBox(width: itemGap * 0.8),
                  const _DesktopNavText('匿名社群'),
                  SizedBox(width: itemGap * 0.8),
                  const _DesktopNavText('互動區'),
                  const Spacer(),
                  SizedBox(
                    height: 40,
                    child: FilledButton(
                      key: const Key('homeDesktopCtaButton'),
                      onPressed: onAddAnnoyance,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.homePrimary,
                        foregroundColor: AppColors.homeOnPrimary,
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: const Text('＋ 記下現在的心情'),
                    ),
                  ),
                  SizedBox(width: itemGap * 0.55),
                  _DesktopCircleButton(label: '●', onTap: onUnavailable),
                  SizedBox(width: itemGap * 0.45),
                  _DesktopCircleButton(
                    key: const Key('homeAccountMenu'),
                    label: 'W',
                    filled: true,
                    onTap: onProfile,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DesktopNavText extends StatelessWidget {
  const _DesktopNavText(this.text, {this.active = false});

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: active ? AppColors.homeInk : AppColors.homeNavMuted,
        fontSize: 14,
        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        height: 1.2,
      ),
    );
  }
}

class _DesktopCircleButton extends StatelessWidget {
  const _DesktopCircleButton({
    required this.label,
    required this.onTap,
    this.filled = false,
    super.key,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: CircleAvatar(
        radius: 18,
        backgroundColor:
            filled ? AppColors.homePrimary : AppColors.homeAccountBackground,
        child: Text(
          label,
          style: TextStyle(
            color: filled ? AppColors.homeOnPrimary : AppColors.homePrimary,
            fontSize: filled ? 14 : 18,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

class _DesktopHeroPanel extends StatelessWidget {
  const _DesktopHeroPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.homeHero),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth * 0.45;
            return Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: const _AnimatedHomeMonster(),
                    ),
                  ),
                ),
                SizedBox(width: constraints.maxWidth * 0.05),
                SizedBox(
                  width: cardWidth,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(color: AppColors.homeSurface),
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '今日陪伴',
                            style: TextStyle(
                              color: AppColors.homeAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '嗨，我在這裡。',
                            style: TextStyle(
                              color: AppColors.homeInk,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            '不用急著整理好所有情緒，\n先選一件想做的事就好。',
                            style: TextStyle(
                              color: AppColors.homeMuted,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _DesktopActionColumn extends StatelessWidget {
  const _DesktopActionColumn({
    required this.onAddAnnoyance,
    required this.onUnavailable,
  });

  final VoidCallback onAddAnnoyance;
  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = (constraints.maxWidth * 0.04).clamp(16.0, 20.0);
        return Column(
          children: [
            _DesktopActionTile.primary(
              key: const Key('homeAnnoyanceChatButton'),
              icon: '◇',
              title: '記下現在的心情',
              caption: '用聊天方式慢慢說',
              onTap: onAddAnnoyance,
            ),
            SizedBox(height: gap),
            _DesktopActionTile(
              icon: '✦',
              title: '寫一篇日記',
              caption: '把今天的片段收藏起來',
              onTap: onUnavailable,
            ),
            SizedBox(height: gap),
            _DesktopActionTile(
              icon: '◷',
              title: '回顧心情記錄',
              caption: '看看最近的心情變化',
              onTap: onUnavailable,
            ),
            SizedBox(height: gap),
            _DesktopActionTile.interaction(
              icon: '✦',
              title: '互動區',
              caption: '解答、測驗、遊戲與紓壓',
              onTap: onUnavailable,
            ),
          ],
        );
      },
    );
  }
}

class _DesktopActionTile extends StatelessWidget {
  const _DesktopActionTile({
    required this.icon,
    required this.title,
    required this.caption,
    required this.onTap,
    this.primary = false,
    this.interaction = false,
    super.key,
  });

  const _DesktopActionTile.primary({
    required String icon,
    required String title,
    required String caption,
    required VoidCallback onTap,
    Key? key,
  }) : this(
         key: key,
         icon: icon,
         title: title,
         caption: caption,
         onTap: onTap,
         primary: true,
       );

  const _DesktopActionTile.interaction({
    required String icon,
    required String title,
    required String caption,
    required VoidCallback onTap,
    Key? key,
  }) : this(
         key: key,
         icon: icon,
         title: title,
         caption: caption,
         onTap: onTap,
         interaction: true,
       );

  final String icon;
  final String title;
  final String caption;
  final VoidCallback onTap;
  final bool primary;
  final bool interaction;

  @override
  Widget build(BuildContext context) {
    final background =
        primary
            ? AppColors.homePrimary
            : interaction
            ? AppColors.homeInteractionBackground
            : AppColors.homeSurface;
    final border =
        primary
            ? null
            : Border.all(
              color:
                  interaction
                      ? AppColors.homeInteractionBorder
                      : AppColors.homeBorder,
            );
    final titleColor = primary ? AppColors.homeOnPrimary : AppColors.homeInk;
    final captionColor =
        primary
            ? AppColors.homePrimaryCaption
            : interaction
            ? AppColors.homeNavMuted
            : AppColors.homeMutedAlt;
    final iconColor = primary ? AppColors.homeOnPrimary : AppColors.homeAccent;

    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(color: background, border: border),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Row(
            children: [
              Text(
                icon,
                style: TextStyle(
                  color: iconColor,
                  fontSize: primary ? 28 : 27,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: interaction ? AppColors.homeInkSoft : titleColor,
                        fontSize: primary ? 20 : 18,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      caption,
                      style: TextStyle(
                        color: captionColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                primary ? '→' : '›',
                style: TextStyle(
                  color:
                      primary ? AppColors.homeOnPrimary : AppColors.homeAccent,
                  fontSize: primary ? 26 : 28,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopCollectionPanel extends StatelessWidget {
  const _DesktopCollectionPanel({required this.onUnavailable});

  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) {
    const chips = [
      ('assets/images/icon.png', true),
      ('assets/images/app_icon.png', false),
      ('assets/images/bonus.png', false),
      ('assets/images/icon_main.png', false),
      ('assets/images/icon.png', false),
      ('assets/images/app_icon.png', false),
      ('assets/images/icon_main.png', false),
    ];

    return InkWell(
      onTap: onUnavailable,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.homePanel,
          border: Border.all(color: AppColors.homeSoftBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    '我的怪獸',
                    style: TextStyle(
                      color: AppColors.homeInkAlt,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(width: 28),
                  Text(
                    '8 / 20',
                    style: TextStyle(
                      color: AppColors.homeAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(width: 36),
                  Expanded(
                    child: Text(
                      '點選怪獸即可更換陪伴夥伴',
                      style: TextStyle(
                        color: AppColors.homeMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Text(
                    '查看全部 ›',
                    style: TextStyle(
                      color: AppColors.homeAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  for (final chip in chips) ...[
                    _DesktopMonsterChip(asset: chip.$1, selected: chip.$2),
                    const SizedBox(width: 16),
                  ],
                  const _DesktopMoreChip(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopMonsterChip extends StatelessWidget {
  const _DesktopMonsterChip({required this.asset, required this.selected});

  final String asset;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? AppColors.homeMonsterSelected : Colors.transparent,
        border: selected ? Border.all(color: AppColors.homeAccent) : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(selected ? 8 : 0),
        child: Image.asset(asset, width: 64, height: 64, fit: BoxFit.contain),
      ),
    );
  }
}

class _DesktopMoreChip extends StatelessWidget {
  const _DesktopMoreChip();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 32,
      backgroundColor: AppColors.homeMonsterMore,
      child: Text(
        '+1',
        style: TextStyle(
          color: AppColors.homeAccent,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
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
  const _CollectionPanel.mobile({required this.onUnavailable});

  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) {
    const left = 16.0;
    const top = 402.0;
    const width = 358.0;
    const height = 118.0;
    const item = 54.0;
    const image = 46.0;
    const firstLeft = 16.0;
    const imageTop = 52.0;
    const gap = 60.0;

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
            const _TextBlock(
              left: 18,
              top: 14,
              width: 70,
              height: 20,
              text: '我的怪獸',
              color: AppColors.homeInkAlt,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
            const _TextBlock(
              left: 90,
              top: 16,
              width: 38,
              height: 16,
              text: '8 / 20',
              color: AppColors.homeAccent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            const _TextBlock(
              left: 276,
              top: 16,
              width: 60,
              height: 16,
              text: '查看全部 ›',
              color: AppColors.homeAccent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            const _MonsterChip(
              left: firstLeft,
              top: imageTop,
              size: item,
              imageSize: image,
              selected: true,
              asset: 'assets/images/icon.png',
            ),
            const _MonsterChip(
              left: firstLeft + gap,
              top: imageTop,
              size: item,
              imageSize: image,
              asset: 'assets/images/app_icon.png',
            ),
            const _MonsterChip(
              left: firstLeft + gap * 2,
              top: imageTop,
              size: item,
              imageSize: image,
              asset: 'assets/images/bonus.png',
            ),
            const _MonsterChip(
              left: firstLeft + gap * 3,
              top: imageTop,
              size: item,
              imageSize: image,
              asset: 'assets/images/icon_main.png',
            ),
            const _MoreMonsterChip(
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
