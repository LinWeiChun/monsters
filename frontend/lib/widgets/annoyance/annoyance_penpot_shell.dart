import 'package:flutter/material.dart';

import '../../layout/responsive_layout.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../navigation/app_navigation.dart';

class AnnoyancePenpotShell extends StatelessWidget {
  const AnnoyancePenpotShell({
    required this.stepLabel,
    required this.progress,
    required this.flowTitle,
    required this.flowCaption,
    required this.panelTitle,
    required this.panelSubtitle,
    required this.messages,
    required this.operation,
    required this.onHome,
    required this.onBack,
    required this.onProfile,
    required this.onNotification,
    required this.onUnavailable,
    required this.onRestart,
    required this.canRestart,
    super.key,
  });

  final String stepLabel;
  final double progress;
  final String flowTitle;
  final String flowCaption;
  final String panelTitle;
  final String panelSubtitle;
  final List<Widget> messages;
  final Widget operation;
  final VoidCallback onHome;
  final VoidCallback onBack;
  final VoidCallback onProfile;
  final VoidCallback onNotification;
  final ValueChanged<String> onUnavailable;
  final VoidCallback onRestart;
  final bool canRestart;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('annoyanceResponsiveShell'),
      color: AppColors.annoyanceBackground,
      child: ResponsiveLayout(
        mobile: (context, constraints) => _MobileAnnoyanceShell(data: this),
        tablet: (context, constraints) => _TabletAnnoyanceShell(data: this),
        desktop: (context, constraints) => _DesktopAnnoyanceShell(data: this),
      ),
    );
  }
}

class _DesktopAnnoyanceShell extends StatelessWidget {
  const _DesktopAnnoyanceShell({required this.data});

  final AnnoyancePenpotShell data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTopNavigation(
          activeDestination: AppNavigationDestination.annoyance,
          onHome: data.onHome,
          onAddAnnoyance: data.onRestart,
          onNotification: data.onNotification,
          onProfile: data.onProfile,
          onUnavailable: data.onUnavailable,
        ),
        _AnnoyanceProgress(data: data, horizontalPadding: 48),
        Expanded(
          child: SingleChildScrollView(
            child: ResponsiveContent(
              maxWidth: 1344,
              horizontalPadding: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 26),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 10,
                      child: _CompanionPanel(data: data, desktop: true),
                    ),
                    const SizedBox(width: 48),
                    Expanded(
                      flex: 10,
                      child: _OperationPanel(data: data, desktop: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TabletAnnoyanceShell extends StatelessWidget {
  const _TabletAnnoyanceShell({required this.data});

  final AnnoyancePenpotShell data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AnnoyanceCompactHeader(data: data),
        _AnnoyanceProgress(data: data, horizontalPadding: 32),
        Expanded(
          child: SingleChildScrollView(
            child: ResponsiveContent(
              maxWidth: 900,
              horizontalPadding: 32,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Column(
                  children: [
                    _CompanionPanel(data: data),
                    const SizedBox(height: 24),
                    _OperationPanel(data: data),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileAnnoyanceShell extends StatelessWidget {
  const _MobileAnnoyanceShell({required this.data});

  final AnnoyancePenpotShell data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AnnoyanceCompactHeader(data: data),
        _AnnoyanceProgress(data: data, horizontalPadding: 16),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                _MobileMessagePanel(data: data),
                const SizedBox(height: 24),
                _OperationPanel(data: data),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnnoyanceCompactHeader extends StatelessWidget {
  const _AnnoyanceCompactHeader({required this.data});

  final AnnoyancePenpotShell data;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.annoyanceSurface,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              IconButton(
                key: const Key('annoyanceChatHomeButton'),
                tooltip: '回首頁',
                onPressed: data.onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              const Text(
                '新增煩惱',
                style: TextStyle(
                  color: AppColors.annoyanceInk,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton(
                key: const Key('annoyanceChatRestartButton'),
                tooltip: '重新開始',
                onPressed: data.canRestart ? data.onRestart : null,
                icon: const Icon(Icons.refresh),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnoyanceProgress extends StatelessWidget {
  const _AnnoyanceProgress({
    required this.data,
    required this.horizontalPadding,
  });

  final AnnoyancePenpotShell data;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.annoyanceBrandBackground,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 12,
        ),
        child: Row(
          children: [
            if (horizontalPadding >= 48) ...[
              TextButton.icon(
                key: const Key('annoyanceChatHomeButton'),
                onPressed: data.onBack,
                icon: const Icon(Icons.chevron_left, size: 18),
                label: const Text('返回'),
              ),
              const SizedBox(width: 18),
            ],
            SizedBox(
              width: horizontalPadding >= 48 ? 104 : 132,
              child: Text(
                data.stepLabel,
                style: const TextStyle(
                  color: AppColors.annoyanceMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  key: const Key('annoyanceProgress'),
                  value: data.progress,
                  minHeight: 7,
                  backgroundColor: AppColors.annoyanceProgressTrack,
                  color: AppColors.annoyancePrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanionPanel extends StatelessWidget {
  const _CompanionPanel({required this.data, this.desktop = false});

  final AnnoyancePenpotShell data;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.annoyanceBrandBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: EdgeInsets.all(desktop ? 32 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              data.flowTitle,
              style: const TextStyle(
                color: AppColors.annoyanceInk,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.flowCaption,
              style: const TextStyle(
                color: AppColors.annoyanceMuted,
                fontSize: 14,
              ),
            ),
            SizedBox(height: desktop ? 28 : 20),
            Center(
              child: Image.asset(
                'assets/images/icon.png',
                width: desktop ? 270 : 150,
                height: desktop ? 270 : 150,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: desktop ? 24 : 16),
            _MessageList(messages: data.messages, height: desktop ? 120 : 110),
            const SizedBox(height: 16),
            const Text(
              '●  內容預設保持私人',
              style: TextStyle(
                color: AppColors.annoyanceSuccess,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileMessagePanel extends StatelessWidget {
  const _MobileMessagePanel({required this.data});

  final AnnoyancePenpotShell data;

  @override
  Widget build(BuildContext context) {
    return _MessageList(messages: data.messages, height: 96);
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.messages, required this.height});

  final List<Widget> messages;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('annoyanceChatMessages'),
      height: height,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.annoyanceSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.annoyanceBorder),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: messages,
        ),
      ),
    );
  }
}

class _OperationPanel extends StatelessWidget {
  const _OperationPanel({required this.data, this.desktop = false});

  final AnnoyancePenpotShell data;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('annoyanceOperationPanel'),
      constraints: BoxConstraints(minHeight: desktop ? 692 : 0),
      padding: EdgeInsets.all(desktop ? 44 : 20),
      decoration: BoxDecoration(
        color: AppColors.annoyanceSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.annoyanceBorder),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.annoyancePrimary,
            surface: AppColors.annoyanceSurface,
            outline: AppColors.annoyanceBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              data.panelTitle,
              style: const TextStyle(
                color: AppColors.annoyanceInk,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.panelSubtitle,
              style: const TextStyle(
                color: AppColors.annoyanceMuted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            data.operation,
          ],
        ),
      ),
    );
  }
}
