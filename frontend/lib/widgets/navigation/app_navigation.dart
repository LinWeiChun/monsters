import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

enum AppNavigationDestination {
  home,
  history,
  monsters,
  community,
  interaction,
  annoyance,
  diary,
  profile,
}

class AppTopNavigation extends StatelessWidget {
  const AppTopNavigation({
    required this.activeDestination,
    required this.onHome,
    required this.onAddAnnoyance,
    required this.onNotification,
    required this.onProfile,
    required this.onUnavailable,
    this.profileInitial = 'W',
    super.key,
  });

  final AppNavigationDestination activeDestination;
  final VoidCallback onHome;
  final VoidCallback onAddAnnoyance;
  final VoidCallback onNotification;
  final VoidCallback onProfile;
  final ValueChanged<String> onUnavailable;
  final String profileInitial;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('appTopNavigation'),
      color: AppColors.homeSurface,
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = (constraints.maxWidth * 0.03).clamp(
              32.0,
              56.0,
            );
            final gap = (constraints.maxWidth * 0.014).clamp(14.0, 22.0);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: SizedBox(
                height: 72,
                child: Row(
                  children: [
                    InkWell(
                      key: const Key('appTopNavLogo'),
                      onTap: onHome,
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: 124,
                        fit: BoxFit.contain,
                        semanticLabel: '返回陪伴首頁',
                      ),
                    ),
                    SizedBox(width: gap),
                    _TopNavigationItem(
                      key: const Key('appTopNavHome'),
                      label: '陪伴首頁',
                      selected:
                          activeDestination == AppNavigationDestination.home,
                      onTap: onHome,
                    ),
                    SizedBox(width: gap),
                    _TopNavigationItem(
                      label: '心的軌跡',
                      selected:
                          activeDestination == AppNavigationDestination.history,
                      onTap: () => onUnavailable('心的軌跡'),
                    ),
                    SizedBox(width: gap),
                    _TopNavigationItem(
                      label: '怪獸收藏',
                      selected:
                          activeDestination ==
                          AppNavigationDestination.monsters,
                      onTap: () => onUnavailable('怪獸收藏'),
                    ),
                    SizedBox(width: gap),
                    _TopNavigationItem(
                      label: '匿名社群',
                      selected:
                          activeDestination ==
                          AppNavigationDestination.community,
                      onTap: () => onUnavailable('匿名社群'),
                    ),
                    SizedBox(width: gap),
                    _TopNavigationItem(
                      label: '互動區',
                      selected:
                          activeDestination ==
                          AppNavigationDestination.interaction,
                      onTap: () => onUnavailable('互動區'),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 40,
                      child: FilledButton(
                        key: const Key('appTopNavAddAnnoyance'),
                        onPressed: onAddAnnoyance,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.homePrimary,
                          foregroundColor: AppColors.homeOnPrimary,
                          shape: const RoundedRectangleBorder(),
                        ),
                        child: const Text('＋ 記下現在的心情'),
                      ),
                    ),
                    SizedBox(width: gap),
                    IconButton.filledTonal(
                      key: const Key('appTopNavNotification'),
                      tooltip: '通知',
                      onPressed: onNotification,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.homeAccountBackground,
                        foregroundColor: AppColors.homePrimary,
                      ),
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                    SizedBox(width: gap * 0.7),
                    Semantics(
                      button: true,
                      label: '個人資料',
                      child: InkWell(
                        key: const Key('appTopNavProfile'),
                        onTap: onProfile,
                        customBorder: const CircleBorder(),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              activeDestination ==
                                      AppNavigationDestination.profile
                                  ? AppColors.homePrimary
                                  : AppColors.homeAccountBackground,
                          foregroundColor:
                              activeDestination ==
                                      AppNavigationDestination.profile
                                  ? AppColors.homeOnPrimary
                                  : AppColors.homePrimary,
                          child: Text(
                            profileInitial.trim().isEmpty
                                ? 'W'
                                : profileInitial.trim().characters.first,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MobileAppBottomNavigation extends StatelessWidget {
  const MobileAppBottomNavigation({
    required this.activeDestination,
    required this.onHome,
    required this.onProfile,
    required this.onUnavailable,
    super.key,
  });

  final AppNavigationDestination activeDestination;
  final VoidCallback onHome;
  final VoidCallback onProfile;
  final ValueChanged<String> onUnavailable;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, Icons.home_rounded, '首頁'),
      (Icons.favorite_border_rounded, Icons.favorite_rounded, '社群'),
      (Icons.diamond_outlined, Icons.diamond_rounded, '怪獸'),
      (Icons.auto_awesome_outlined, Icons.auto_awesome_rounded, '互動'),
      (Icons.person_outline_rounded, Icons.person_rounded, '我的'),
    ];
    final selectedIndex =
        activeDestination == AppNavigationDestination.profile ? 4 : 0;
    final keys = const [
      Key('mobileNavHome'),
      Key('mobileNavCommunity'),
      Key('mobileNavMonsters'),
      Key('mobileNavInteraction'),
      Key('mobileNavProfile'),
    ];

    return Positioned(
      key: const Key('mobileAppBottomNavigation'),
      left: 0,
      top: 774,
      width: 390,
      height: 70,
      child: Material(
        color: AppColors.homeSurface,
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++)
              Expanded(
                child: InkWell(
                  key: keys[index],
                  onTap: () {
                    if (index == selectedIndex) {
                      return;
                    }
                    switch (index) {
                      case 0:
                        onHome();
                        return;
                      case 4:
                        onProfile();
                        return;
                      default:
                        onUnavailable(items[index].$3);
                        return;
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        index == selectedIndex
                            ? items[index].$2
                            : items[index].$1,
                        size: 21,
                        color:
                            index == selectedIndex
                                ? AppColors.homeAccent
                                : AppColors.homeNavMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index].$3,
                        style: TextStyle(
                          color:
                              index == selectedIndex
                                  ? AppColors.homeAccent
                                  : AppColors.homeNavMuted,
                          fontSize: 10,
                          fontWeight:
                              index == selectedIndex
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopNavigationItem extends StatelessWidget {
  const _TopNavigationItem({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: selected ? AppColors.homeInk : AppColors.homeNavMuted,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 18),
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      child: Text(label),
    );
  }
}
