import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

class HomeMobileNavigation extends StatelessWidget {
  const HomeMobileNavigation({required this.onUnavailableSelected, super.key});

  final VoidCallback onUnavailableSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        if (index != 0) {
          onUnavailableSelected();
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_rounded), label: '首頁'),
        NavigationDestination(icon: Icon(Icons.groups_outlined), label: '社群'),
        NavigationDestination(
          icon: Icon(Icons.auto_stories_outlined),
          label: '圖鑑',
        ),
        NavigationDestination(
          icon: Icon(Icons.extension_outlined),
          label: '互動',
        ),
      ],
    );
  }
}

class HomeDesktopNavigation extends StatelessWidget {
  const HomeDesktopNavigation({
    required this.onHomeSelected,
    required this.onProfileSelected,
    required this.onPasswordLockSelected,
    required this.onUnavailableSelected,
    required this.onLogout,
    super.key,
  });

  final VoidCallback onHomeSelected;
  final VoidCallback onProfileSelected;
  final VoidCallback onPasswordLockSelected;
  final VoidCallback onUnavailableSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 244,
      child: Material(
        color: colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/images/app_logo.png',
                height: 56,
                alignment: Alignment.centerLeft,
                semanticLabel: '貘nsters',
              ),
              const SizedBox(height: AppSpacing.xl),
              _NavigationItem(
                icon: Icons.home_rounded,
                label: '首頁',
                selected: true,
                onTap: onHomeSelected,
              ),
              _NavigationItem(
                icon: Icons.groups_outlined,
                label: '社群',
                onTap: onUnavailableSelected,
              ),
              _NavigationItem(
                icon: Icons.auto_stories_outlined,
                label: '怪獸圖鑑',
                onTap: onUnavailableSelected,
              ),
              _NavigationItem(
                icon: Icons.extension_outlined,
                label: '互動區',
                onTap: onUnavailableSelected,
              ),
              const Spacer(),
              const Divider(),
              _NavigationItem(
                icon: Icons.person_outline_rounded,
                label: '個人資料',
                onTap: onProfileSelected,
              ),
              _NavigationItem(
                icon: Icons.lock_outline_rounded,
                label: '密碼鎖',
                onTap: onPasswordLockSelected,
              ),
              _NavigationItem(
                icon: Icons.logout_rounded,
                label: '登出',
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        selected: selected,
        selectedTileColor: colorScheme.primaryContainer,
        leading: Icon(icon),
        title: Text(label),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        onTap: onTap,
      ),
    );
  }
}
