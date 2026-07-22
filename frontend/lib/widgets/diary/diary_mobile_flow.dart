import 'package:flutter/material.dart';

import '../../layout/responsive_layout.dart';
import '../../models/diary_draft.dart';
import '../../providers/diary_chat_provider.dart';
import '../../services/entry_media_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../entry/entry_content_input.dart';
import '../entry/mood_drawing_canvas.dart';
import '../navigation/app_navigation.dart';
import 'diary_review_card.dart';

class DiaryMobileFlow extends StatelessWidget {
  const DiaryMobileFlow({
    required this.state,
    required this.controller,
    required this.mediaService,
    required this.stepLabel,
    required this.progress,
    required this.title,
    required this.subtitle,
    required this.onExit,
    required this.onHome,
    required this.onProfile,
    required this.onUnavailable,
    this.drawingExporter,
    super.key,
  });

  final DiaryChatState state;
  final DiaryChatController controller;
  final EntryMediaService mediaService;
  final String stepLabel;
  final double progress;
  final String title;
  final String subtitle;
  final VoidCallback onExit;
  final VoidCallback onHome;
  final VoidCallback onProfile;
  final ValueChanged<String> onUnavailable;
  final MoodDrawingExport? drawingExporter;

  @override
  Widget build(BuildContext context) {
    final completed = state.step == DiaryChatStep.completed;

    return ColoredBox(
      key: const Key('diaryResponsiveShell'),
      color: AppColors.entryBrandBackground,
      child: ResponsiveFixedCanvas(
        viewportKey: const Key('diaryMobileViewport'),
        canvasWidth: 390,
        canvasHeight: 844,
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.entryPrimary,
              surface: AppColors.entrySurface,
              outline: AppColors.entryBorder,
            ),
          ),
          child: ColoredBox(
            key: const Key('diaryMobileCanvas'),
            color: AppColors.entryBrandBackground,
            child: Stack(
              children: [
                _MobileHeader(
                  stepLabel: stepLabel,
                  progress: progress,
                  title: title,
                  subtitle: subtitle,
                ),
                if (state.step != DiaryChatStep.intro && !completed)
                  Positioned(
                    left: 100,
                    top: 6,
                    width: 40,
                    height: 40,
                    child: IconButton(
                      key: const Key('diaryMobileBackButton'),
                      tooltip: '上一步',
                      padding: EdgeInsets.zero,
                      onPressed: controller.goBack,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.entryPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                Positioned(
                  key: const Key('diaryMobileOperation'),
                  left: 24,
                  top: 164,
                  width: 342,
                  height: completed ? 590 : 640,
                  child: _buildOperation(context),
                ),
                if (completed)
                  MobileAppBottomNavigation(
                    activeDestination: AppNavigationDestination.diary,
                    onHome: onHome,
                    onProfile: onProfile,
                    onUnavailable: onUnavailable,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperation(BuildContext context) {
    return switch (state.step) {
      DiaryChatStep.intro => _MobileIntro(
        onStart: controller.begin,
        onSkip: onExit,
      ),
      DiaryChatStep.recordMethod => _MobileRecordMethod(
        selectedMethod: state.recordMethod,
        onSelected: controller.chooseRecordMethod,
        onContinue: controller.confirmRecordMethod,
      ),
      DiaryChatStep.content => EntryContentInput(
        key: ValueKey(state.recordMethod),
        method: state.recordMethod!,
        textContent: state.contentText,
        media: state.contentMedia,
        mediaService: mediaService,
        onTextChanged: controller.updateTextContent,
        onMediaSelected: controller.selectContentMedia,
        onClear: controller.clearContent,
        canContinue: state.isContentReady,
        onContinue: controller.confirmContent,
        keyPrefix: 'diary',
        textLabel: '日記內容',
        textHint: '今天早上走到公司時，突然發現風很舒服……',
        maxTextLength: 2000,
        continueLabel: '儲存並繼續',
        showTitle: false,
      ),
      DiaryChatStep.drawingDecision => _MobileDrawingDecision(
        onSelected: controller.selectDrawingChoice,
      ),
      DiaryChatStep.drawing => MoodDrawingCanvas(
        onCompleted: controller.saveDrawing,
        onCancel: controller.cancelDrawing,
        exportPng: drawingExporter,
      ),
      DiaryChatStep.score => _MobileMoodScore(
        selectedScore: state.score,
        onSelected: controller.chooseScore,
        onContinue: controller.confirmScore,
      ),
      DiaryChatStep.sharing => _MobileSharing(
        selectedValue: state.isShared,
        onSelected: controller.chooseSharing,
        onContinue: controller.confirmSharing,
      ),
      DiaryChatStep.review => DiaryReviewCard(
        state: state,
        onSubmit: controller.submit,
        showTitle: false,
      ),
      DiaryChatStep.submitting => const _MobileSubmitting(),
      DiaryChatStep.completed => _MobileCompleted(
        score: state.createdDiary!.score,
        isShared: state.createdDiary!.isShared,
        onHome: onHome,
        onCreateAnother: controller.restart,
      ),
    };
  }
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader({
    required this.stepLabel,
    required this.progress,
    required this.title,
    required this.subtitle,
  });

  final String stepLabel;
  final double progress;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          left: 24,
          top: 20,
          child: Text(
            '貘nsters',
            style: TextStyle(
              color: AppColors.entryInk,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Positioned(
          left: 302,
          top: 20,
          width: 52,
          child: Text(
            stepLabel,
            key: const Key('diaryMobileStepLabel'),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.entryMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Positioned(
          left: 24,
          top: 54,
          width: 342,
          height: 5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.entryProgressTrack,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        Positioned(
          left: 24,
          top: 54,
          width: 342 * progress,
          height: 5,
          child: DecoratedBox(
            key: const Key('diaryProgress'),
            decoration: BoxDecoration(
              color: AppColors.entryPrimary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        Positioned(
          left: 24,
          top: 82,
          width: 342,
          child: Text(
            title,
            key: const Key('diaryMobileTitle'),
            style: const TextStyle(
              color: AppColors.entryInk,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ),
        Positioned(
          left: 24,
          top: 120,
          width: 342,
          child: Text(
            subtitle,
            key: const Key('diaryMobileSubtitle'),
            style: const TextStyle(
              color: AppColors.entryMuted,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileIntro extends StatelessWidget {
  const _MobileIntro({required this.onStart, required this.onSkip});

  final VoidCallback onStart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/icon.png',
          width: 180,
          height: 180,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.entrySurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.entryBorder),
          ),
          child: const Text(
            '「今天有什麼想記住的嗎？\n開心、疲倦，或普通的一天都可以。」',
            key: Key('diaryMobileGreeting'),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.entryInk, height: 1.5),
          ),
        ),
        const SizedBox(height: 18),
        const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.entrySoft,
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Text(
              '約 2–4 分鐘',
              style: TextStyle(
                color: AppColors.entryMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const Spacer(),
        _PrimaryButton(
          key: const Key('diaryChatStartButton'),
          label: '開始記錄',
          onPressed: onStart,
        ),
        TextButton(
          key: const Key('diaryMobileSkipButton'),
          onPressed: onSkip,
          child: const Text('稍後再說'),
        ),
      ],
    );
  }
}

class _MobileRecordMethod extends StatelessWidget {
  const _MobileRecordMethod({
    required this.selectedMethod,
    required this.onSelected,
    required this.onContinue,
  });

  final DiaryRecordMethod? selectedMethod;
  final ValueChanged<DiaryRecordMethod> onSelected;
  final VoidCallback onContinue;

  static const _icons = <DiaryRecordMethod, IconData>{
    DiaryRecordMethod.text: Icons.notes_rounded,
    DiaryRecordMethod.image: Icons.image_outlined,
    DiaryRecordMethod.audio: Icons.mic_none_rounded,
    DiaryRecordMethod.video: Icons.videocam_outlined,
  };

  static const _descriptions = <DiaryRecordMethod, String>{
    DiaryRecordMethod.text: '慢慢寫下今天',
    DiaryRecordMethod.image: '放入一張回憶',
    DiaryRecordMethod.audio: '說出現在感受',
    DiaryRecordMethod.video: '留下完整片段',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < 2; row++) ...[
          Row(
            children: [
              for (var column = 0; column < 2; column++) ...[
                if (column > 0) const SizedBox(width: 14),
                Expanded(
                  child: _MethodCard(
                    method: DiaryRecordMethod.values[row * 2 + column],
                    icon: _icons[DiaryRecordMethod.values[row * 2 + column]]!,
                    description:
                        _descriptions[DiaryRecordMethod.values[row * 2 +
                            column]]!,
                    selected:
                        selectedMethod ==
                        DiaryRecordMethod.values[row * 2 + column],
                    onTap: onSelected,
                  ),
                ),
              ],
            ],
          ),
          if (row == 0) const SizedBox(height: 14),
        ],
        const Spacer(),
        _PrimaryButton(
          key: const Key('diaryMobileNextButton'),
          label: '下一步',
          onPressed: selectedMethod == null ? null : onContinue,
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.method,
    required this.icon,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final DiaryRecordMethod method;
  final IconData icon;
  final String description;
  final bool selected;
  final ValueChanged<DiaryRecordMethod> onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: method.label,
      child: Material(
        color: selected ? AppColors.entrySoft : AppColors.entrySurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: selected ? AppColors.entryPrimary : AppColors.entryBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          key: Key('diaryRecordMethod${method.apiValue}'),
          onTap: () => onTap(method),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: SizedBox(
            height: 126,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: AppColors.entryPrimary, size: 28),
                  const Spacer(),
                  Text(
                    method.label,
                    style: const TextStyle(
                      color: AppColors.entryInk,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.entryMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileDrawingDecision extends StatelessWidget {
  const _MobileDrawingDecision({required this.onSelected});

  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 42),
        Icon(
          Icons.brush_rounded,
          size: 142,
          color: AppColors.entryPrimary.withValues(alpha: 0.85),
        ),
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.entrySurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.entryBorder),
          ),
          child: const Text(
            '「不用會畫畫，隨手畫也很好。」',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.entryInk),
          ),
        ),
        const Spacer(),
        _PrimaryButton(
          key: const Key('diaryDrawingYesButton'),
          label: '打開畫布',
          onPressed: () => onSelected(true),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            key: const Key('diaryDrawingNoButton'),
            onPressed: () => onSelected(false),
            child: const Text('這次先跳過'),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _MobileMoodScore extends StatelessWidget {
  const _MobileMoodScore({
    required this.selectedScore,
    required this.onSelected,
    required this.onContinue,
  });

  final int? selectedScore;
  final ValueChanged<int> onSelected;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 54),
        Semantics(
          label: '今日心情分數，1 到 5 分',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final score in diaryScores)
                _MobileScoreOption(
                  score: score,
                  selected: selectedScore == score,
                  onTap: () => onSelected(score),
                ),
            ],
          ),
        ),
        const SizedBox(height: 46),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.entrySurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.entryBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedScore == null ? '尚未選擇' : '$selectedScore 分',
                key: const Key('diaryMobileSelectedScore'),
                style: const TextStyle(
                  color: AppColors.entryInk,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                selectedScore == null
                    ? '選擇最符合此刻感受的分數'
                    : _scoreNote(selectedScore!),
                style: const TextStyle(color: AppColors.entryMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          '圖片輔助呈現；無障礙名稱使用中性分數',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.entryMuted, fontSize: 11),
        ),
        const Spacer(),
        _PrimaryButton(
          key: const Key('diaryMobileNextButton'),
          label: '記下這個分數',
          onPressed: selectedScore == null ? null : onContinue,
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  String _scoreNote(int score) {
    return switch (score) {
      1 => '今天的感受比較低落',
      2 => '今天需要多照顧自己',
      3 => '今天的感受比較平穩',
      4 => '今天有不少舒服的時刻',
      5 => '今天的感受很有力量',
      _ => '',
    };
  }
}

class _MobileScoreOption extends StatelessWidget {
  const _MobileScoreOption({
    required this.score,
    required this.selected,
    required this.onTap,
  });

  final int score;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$score 分',
      child: InkWell(
        key: Key('diaryScore$score'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.entrySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected ? AppColors.entryPrimary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/moodPoint_$score.png',
                key: Key('diaryScoreImage$score'),
                width: 42,
                height: 42,
              ),
              const SizedBox(height: 6),
              Text(
                '$score分',
                style: const TextStyle(
                  color: AppColors.entryInk,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileSharing extends StatelessWidget {
  const _MobileSharing({
    required this.selectedValue,
    required this.onSelected,
    required this.onContinue,
  });

  final bool? selectedValue;
  final ValueChanged<bool> onSelected;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MobileShareOption(
          key: const Key('diarySharePrivateButton'),
          icon: Icons.lock_outline_rounded,
          title: '只給自己看',
          description: '內容保留在私人日記中',
          selected: selectedValue == false,
          onTap: () => onSelected(false),
        ),
        const SizedBox(height: 18),
        _MobileShareOption(
          key: const Key('diarySharePublicButton'),
          icon: Icons.north_east_rounded,
          title: '匿名分享',
          description: '隱藏身份後分享給社群',
          selected: selectedValue == true,
          onTap: () => onSelected(true),
        ),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.entrySurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.entryBorder),
          ),
          child: const Text(
            '分享前可再次確認；\n不會公開姓名與個人資料。',
            style: TextStyle(color: AppColors.entryMuted, height: 1.5),
          ),
        ),
        const Spacer(),
        _PrimaryButton(
          key: const Key('diaryMobileNextButton'),
          label: '下一步',
          onPressed: selectedValue == null ? null : onContinue,
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _MobileShareOption extends StatelessWidget {
  const _MobileShareOption({
    required super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: selected ? AppColors.entrySoft : AppColors.entrySurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: selected ? AppColors.entryPrimary : AppColors.entryBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: SizedBox(
            height: 128,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.entryPrimary, size: 28),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.entryInk,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            color: AppColors.entryMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color:
                        selected
                            ? AppColors.entryPrimary
                            : AppColors.entryBorder,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileSubmitting extends StatelessWidget {
  const _MobileSubmitting();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Card(
        key: Key('diarySubmittingCard'),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppSpacing.md),
              Text('正在把今天的日記收好。'),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileCompleted extends StatelessWidget {
  const _MobileCompleted({
    required this.score,
    required this.isShared,
    required this.onHome,
    required this.onCreateAnother,
  });

  final int score;
  final bool isShared;
  final VoidCallback onHome;
  final VoidCallback onCreateAnother;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('diaryCompletedCard'),
      children: [
        Container(
          width: double.infinity,
          height: 182,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.entrySurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.entryBorder),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/icon.png',
                width: 112,
                height: 112,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今日心情 · $score 分',
                      style: const TextStyle(
                        color: AppColors.entryInk,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isShared ? '已匿名分享\n並安全保存' : '私人日記\n已安全保存',
                      style: const TextStyle(
                        color: AppColors.entryMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.entrySurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.entryBorder),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.entrySuccess,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '這篇日記已安全保存',
                      style: TextStyle(
                        color: AppColors.entryInk,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isShared ? '已匿名分享，之後可再調整分享設定' : '只有你能看見，之後可再調整分享設定',
                      style: const TextStyle(
                        color: AppColors.entryMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            key: const Key('diaryCompletedHomeButton'),
            onPressed: onHome,
            child: const Text('回到陪伴首頁'),
          ),
        ),
        const SizedBox(height: 16),
        _PrimaryButton(
          key: const Key('diaryCreateAnotherButton'),
          label: '再寫一篇日記',
          onPressed: onCreateAnother,
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(onPressed: onPressed, child: Text(label)),
    );
  }
}
