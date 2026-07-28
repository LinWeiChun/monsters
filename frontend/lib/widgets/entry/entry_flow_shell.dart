import 'package:flutter/material.dart';

import '../../layout/responsive_layout.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../navigation/app_navigation.dart';

class EntryFlowShell extends StatelessWidget {
  const EntryFlowShell({
    required this.keyPrefix,
    required this.compactTitle,
    required this.activeDestination,
    required this.stepLabel,
    required this.progress,
    required this.flowTitle,
    required this.flowCaption,
    required this.panelTitle,
    required this.panelSubtitle,
    required this.messages,
    required this.operation,
    required this.onHome,
    required this.onPrimaryAction,
    required this.onBack,
    required this.onProfile,
    required this.onNotification,
    required this.onUnavailable,
    required this.onRestart,
    required this.canRestart,
    this.privacyMessage = '●  內容預設保持私人',
    super.key,
  });

  final String keyPrefix;
  final String compactTitle;
  final AppNavigationDestination activeDestination;
  final String stepLabel;
  final double progress;
  final String flowTitle;
  final String flowCaption;
  final String panelTitle;
  final String panelSubtitle;
  final List<Widget> messages;
  final Widget operation;
  final VoidCallback onHome;
  final VoidCallback onPrimaryAction;
  final VoidCallback onBack;
  final VoidCallback onProfile;
  final VoidCallback onNotification;
  final ValueChanged<String> onUnavailable;
  final VoidCallback onRestart;
  final bool canRestart;
  final String privacyMessage;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: Key('${keyPrefix}ResponsiveShell'),
      color: AppColors.entryBackground,
      child: ResponsiveLayout(
        mobile: (context, constraints) => _MobileEntryShell(data: this),
        tablet: (context, constraints) => _TabletEntryShell(data: this),
        desktop: (context, constraints) => _DesktopEntryShell(data: this),
      ),
    );
  }
}

class _DesktopEntryShell extends StatelessWidget {
  const _DesktopEntryShell({required this.data});

  final EntryFlowShell data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTopNavigation(
          activeDestination: data.activeDestination,
          onHome: data.onHome,
          onAddAnnoyance: data.onPrimaryAction,
          onNotification: data.onNotification,
          onProfile: data.onProfile,
          onUnavailable: data.onUnavailable,
        ),
        _EntryProgress(data: data, horizontalPadding: 48),
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

class _TabletEntryShell extends StatelessWidget {
  const _TabletEntryShell({required this.data});

  final EntryFlowShell data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EntryCompactHeader(data: data),
        _EntryProgress(data: data, horizontalPadding: 32),
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

class _MobileEntryShell extends StatelessWidget {
  const _MobileEntryShell({required this.data});

  final EntryFlowShell data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EntryCompactHeader(data: data),
        _EntryProgress(data: data, horizontalPadding: 16),
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

class _EntryCompactHeader extends StatelessWidget {
  const _EntryCompactHeader({required this.data});

  final EntryFlowShell data;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.entrySurface,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              IconButton(
                key: Key('${data.keyPrefix}ChatHomeButton'),
                tooltip: '回首頁',
                onPressed: data.onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              Text(
                data.compactTitle,
                style: const TextStyle(
                  color: AppColors.entryInk,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton(
                key: Key('${data.keyPrefix}ChatRestartButton'),
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

class _EntryProgress extends StatelessWidget {
  const _EntryProgress({required this.data, required this.horizontalPadding});

  final EntryFlowShell data;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.entryBrandBackground,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 12,
        ),
        child: Row(
          children: [
            if (horizontalPadding >= 48) ...[
              TextButton.icon(
                key: Key('${data.keyPrefix}ChatHomeButton'),
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
                  color: AppColors.entryMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  key: Key('${data.keyPrefix}Progress'),
                  value: data.progress,
                  minHeight: 7,
                  backgroundColor: AppColors.entryProgressTrack,
                  color: AppColors.entryPrimary,
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

  final EntryFlowShell data;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.entryBrandBackground,
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
                color: AppColors.entryInk,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.flowCaption,
              style: const TextStyle(color: AppColors.entryMuted, fontSize: 14),
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
            _MessageList(
              keyPrefix: data.keyPrefix,
              messages: data.messages,
              height: desktop ? 120 : 110,
            ),
            const SizedBox(height: 16),
            Text(
              data.privacyMessage,
              style: const TextStyle(
                color: AppColors.entrySuccess,
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

  final EntryFlowShell data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MessageList(
          keyPrefix: data.keyPrefix,
          messages: data.messages,
          height: 96,
        ),
        const SizedBox(height: 8),
        Text(
          data.privacyMessage,
          style: const TextStyle(
            color: AppColors.entrySuccess,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.keyPrefix,
    required this.messages,
    required this.height,
  });

  final String keyPrefix;
  final List<Widget> messages;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('${keyPrefix}ChatMessages'),
      height: height,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.entrySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.entryBorder),
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

  final EntryFlowShell data;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('${data.keyPrefix}OperationPanel'),
      constraints: BoxConstraints(minHeight: desktop ? 692 : 0),
      padding: EdgeInsets.all(desktop ? 44 : 20),
      decoration: BoxDecoration(
        color: AppColors.entrySurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.entryBorder),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.entryPrimary,
            surface: AppColors.entrySurface,
            outline: AppColors.entryBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              data.panelTitle,
              style: const TextStyle(
                color: AppColors.entryInk,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.panelSubtitle,
              style: const TextStyle(
                color: AppColors.entryMuted,
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
