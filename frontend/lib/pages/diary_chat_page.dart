import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/diary_draft.dart';
import '../layout/responsive_layout.dart';
import '../providers/diary_chat_provider.dart';
import '../providers/diary_media_provider.dart';
import '../routes/app_routes.dart';
import '../services/entry_media_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/diary/diary_completed_card.dart';
import '../widgets/diary/diary_mobile_flow.dart';
import '../widgets/diary/diary_review_card.dart';
import '../widgets/entry/drawing_choice_card.dart';
import '../widgets/entry/drawing_preview_card.dart';
import '../widgets/entry/entry_chat_bubble.dart';
import '../widgets/entry/entry_content_input.dart';
import '../widgets/entry/entry_flow_shell.dart';
import '../widgets/entry/mood_drawing_canvas.dart';
import '../widgets/entry/mood_score_selector.dart';
import '../widgets/entry/record_method_selector.dart';
import '../widgets/entry/share_choice_card.dart';
import '../widgets/navigation/app_navigation.dart';

class DiaryChatPage extends ConsumerStatefulWidget {
  const DiaryChatPage({this.drawingExporter, super.key});

  final MoodDrawingExport? drawingExporter;

  @override
  ConsumerState<DiaryChatPage> createState() => _DiaryChatPageState();
}

class _DiaryChatPageState extends ConsumerState<DiaryChatPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diaryChatControllerProvider);
    final mediaService = ref.watch(diaryMediaServiceProvider);
    final controller = ref.read(diaryChatControllerProvider.notifier);
    final presentation = _presentationFor(state.step);

    final wideFlow =
        state.step == DiaryChatStep.drawing
            ? SafeArea(
              child: MoodDrawingCanvas(
                onCompleted: controller.saveDrawing,
                onCancel: controller.cancelDrawing,
                exportPng: widget.drawingExporter,
              ),
            )
            : EntryFlowShell(
              keyPrefix: 'diary',
              compactTitle: '寫一篇日記',
              activeDestination: AppNavigationDestination.diary,
              stepLabel: presentation.stepLabel,
              progress: presentation.progress,
              flowTitle: presentation.flowTitle,
              flowCaption: '不用整理好情緒，貘會陪你慢慢記。',
              panelTitle: presentation.panelTitle,
              panelSubtitle: presentation.panelSubtitle,
              messages: _buildMessages(state),
              operation: _buildInteractionPanel(
                state,
                controller,
                mediaService,
              ),
              onHome: () => context.goNamed(AppRoute.home),
              onPrimaryAction: () => context.pushNamed(AppRoute.annoyanceChat),
              onBack: () => _returnToHome(context),
              onProfile: () => context.pushNamed(AppRoute.profile),
              onNotification: () => _showUnavailable(context, '通知'),
              onUnavailable: (feature) => _showUnavailable(context, feature),
              onRestart: controller.restart,
              canRestart: state.step != DiaryChatStep.intro,
              privacyMessage: '●  可隨時儲存，預設只有自己看得見',
            );

    return Scaffold(
      backgroundColor: AppColors.entryBackground,
      body: ResponsiveLayout(
        mobile:
            (context, constraints) => DiaryMobileFlow(
              state: state,
              controller: controller,
              mediaService: mediaService,
              stepLabel: presentation.mobileStepLabel,
              progress: presentation.progress,
              title: presentation.panelTitle,
              subtitle: presentation.mobileSubtitle,
              onExit: () => _returnToHome(context),
              onHome: () => context.goNamed(AppRoute.home),
              onProfile: () => context.pushNamed(AppRoute.profile),
              onUnavailable: (feature) => _showUnavailable(context, feature),
              drawingExporter: widget.drawingExporter,
            ),
        tablet: (context, constraints) => wideFlow,
        desktop: (context, constraints) => wideFlow,
      ),
    );
  }

  void _returnToHome(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.goNamed(AppRoute.home);
  }

  void _showUnavailable(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature即將開放')));
  }

  List<Widget> _buildMessages(DiaryChatState state) {
    return [
      const EntryChatBubble(
        key: Key('diaryChatGreeting'),
        message: '今天有什麼想記住的嗎？開心、疲倦，或只是普通的一天都可以。',
        isUser: false,
      ),
      if (state.step != DiaryChatStep.intro)
        const EntryChatBubble(message: '先選擇你想記錄的方式。', isUser: false),
      if (state.recordMethod case final recordMethod?) ...[
        EntryChatBubble(message: recordMethod.label, isUser: true),
        EntryChatBubble(
          key: const Key('diaryContentPrompt'),
          message: _contentPrompt(recordMethod),
          isUser: false,
        ),
      ],
      if (state.step.index > DiaryChatStep.content.index) ...[
        EntryChatBubble(message: _contentSummary(state), isUser: true),
        const EntryChatBubble(
          key: Key('diaryDrawingPrompt'),
          message: '內容已記下來。要不要也畫下現在的心情？',
          isUser: false,
        ),
      ],
      if (state.wantsDrawing case final wantsDrawing?)
        EntryChatBubble(message: wantsDrawing ? '打開畫布' : '這次先跳過', isUser: true),
      if (state.drawing case final drawing?)
        DrawingPreviewCard(drawing: drawing, keyPrefix: 'diary'),
      if (state.step.index >= DiaryChatStep.score.index)
        const EntryChatBubble(
          key: Key('diaryScorePrompt'),
          message: '分數沒有好壞，只代表此刻的感受。',
          isUser: false,
        ),
      if (state.score case final score?)
        EntryChatBubble(message: score.scoreLabel, isUser: true),
      if (state.step.index >= DiaryChatStep.sharing.index)
        const EntryChatBubble(
          key: Key('diarySharingPrompt'),
          message: '最後決定這篇日記要保持私人，或匿名分享。',
          isUser: false,
        ),
      if (state.isShared case final isShared?)
        EntryChatBubble(message: isShared ? '匿名分享' : '只給自己看', isUser: true),
      if (state.step == DiaryChatStep.review)
        const EntryChatBubble(
          key: Key('diaryReviewPrompt'),
          message: '最後看一次，儲存後仍可編輯。',
          isUser: false,
        ),
      if (state.step == DiaryChatStep.submitting)
        const EntryChatBubble(
          key: Key('diarySubmittingPrompt'),
          message: '正在把今天的日記收好。',
          isUser: false,
        ),
      if (state.step == DiaryChatStep.completed)
        const EntryChatBubble(
          key: Key('diaryCompletedPrompt'),
          message: '這篇日記已安全保存。',
          isUser: false,
        ),
    ];
  }

  Widget _buildInteractionPanel(
    DiaryChatState state,
    DiaryChatController controller,
    EntryMediaService mediaService,
  ) {
    final selector = switch (state.step) {
      DiaryChatStep.intro => FilledButton.icon(
        key: const Key('diaryChatStartButton'),
        onPressed: controller.begin,
        icon: const Icon(Icons.edit_note),
        label: const Text('開始記錄'),
      ),
      DiaryChatStep.recordMethod => RecordMethodSelector(
        onSelected: controller.selectRecordMethod,
        keyPrefix: 'diary',
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
      ),
      DiaryChatStep.drawingDecision => DrawingChoiceCard(
        onSelected: controller.selectDrawingChoice,
        keyPrefix: 'diary',
        title: '要畫下現在的心情嗎？',
        acceptLabel: '打開畫布',
        skipLabel: '這次先跳過',
      ),
      DiaryChatStep.score => MoodScoreSelector(
        selectedScore: state.score,
        onSelected: controller.selectScore,
        keyPrefix: 'diary',
        title: '現在的心情是幾分？',
        semanticLabel: '今日心情分數，1 到 5 分',
      ),
      DiaryChatStep.sharing => ShareChoiceCard(
        selectedValue: state.isShared,
        onSelected: controller.selectSharing,
        keyPrefix: 'diary',
        title: '要把日記分享出去嗎？',
      ),
      DiaryChatStep.review => DiaryReviewCard(
        state: state,
        onSubmit: controller.submit,
      ),
      DiaryChatStep.submitting => const Card(
        key: Key('diarySubmittingCard'),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppSpacing.sm),
              Text('儲存中，請稍候。'),
            ],
          ),
        ),
      ),
      DiaryChatStep.completed =>
        state.createdDiary == null
            ? const SizedBox.shrink()
            : DiaryCompletedCard(
              diary: state.createdDiary!,
              onCreateAnother: controller.restart,
              onGoHome: () => _returnToHome(context),
            ),
      _ => const SizedBox.shrink(),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: KeyedSubtree(key: ValueKey(state.step), child: selector),
        ),
        if (_canGoBack(state.step)) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            key: const Key('diaryChatBackButton'),
            onPressed: controller.goBack,
            icon: const Icon(Icons.undo),
            label: const Text('上一步'),
          ),
        ],
      ],
    );
  }

  bool _canGoBack(DiaryChatStep step) {
    return step != DiaryChatStep.intro &&
        step != DiaryChatStep.submitting &&
        step != DiaryChatStep.completed;
  }

  String _contentPrompt(DiaryRecordMethod method) {
    return switch (method) {
      DiaryRecordMethod.text => '把今天寫下來，不用完整，也不必寫得漂亮。',
      DiaryRecordMethod.image => '選一張圖片，留下今天的回憶。',
      DiaryRecordMethod.audio => '錄一段聲音，說出現在的感受。',
      DiaryRecordMethod.video => '選一段影片，留下今天的片段。',
    };
  }

  String _contentSummary(DiaryChatState state) {
    if (state.recordMethod == DiaryRecordMethod.text) {
      return state.contentText.trim();
    }
    return '已選擇${state.recordMethod?.label ?? '媒體'}內容';
  }

  _DiaryStepPresentation _presentationFor(DiaryChatStep step) {
    return switch (step) {
      DiaryChatStep.intro => const _DiaryStepPresentation(
        stepLabel: '1 / 8　引導',
        progress: 0.125,
        flowTitle: '今天想留下什麼？',
        panelTitle: '今天想留下什麼？',
        panelSubtitle: '約需 2–4 分鐘，過程中可以返回修改。',
        mobileSubtitle: '不用整理好情緒，貘會陪你慢慢記。',
      ),
      DiaryChatStep.recordMethod => const _DiaryStepPresentation(
        stepLabel: '2 / 8　記錄方式',
        progress: 0.25,
        flowTitle: '想用哪種方式記錄？',
        panelTitle: '想用哪種方式記錄？',
        panelSubtitle: '目前先選擇一種主要記錄方式，之後仍可編輯。',
        mobileSubtitle: '目前先選擇一種主要記錄方式，之後仍可編輯。',
      ),
      DiaryChatStep.content => const _DiaryStepPresentation(
        stepLabel: '3 / 8　輸入內容',
        progress: 0.375,
        flowTitle: '把今天寫下來',
        panelTitle: '把今天寫下來',
        panelSubtitle: '不用完整，也不必寫得漂亮。',
        mobileSubtitle: '不用完整，也不必寫得漂亮。',
      ),
      DiaryChatStep.drawingDecision => const _DiaryStepPresentation(
        stepLabel: '4 / 8　畫心情',
        progress: 0.5,
        flowTitle: '要畫下現在的心情嗎？',
        panelTitle: '要畫下現在的心情嗎？',
        panelSubtitle: '用顏色補充文字說不出的感受。',
        mobileSubtitle: '用顏色補充文字說不出的感受。',
      ),
      DiaryChatStep.drawing => const _DiaryStepPresentation(
        stepLabel: '5 / 8　畫布',
        progress: 0.625,
        flowTitle: '畫下此刻的心情',
        panelTitle: '畫下此刻的心情',
        panelSubtitle: '選擇顏色，用滑鼠或觸控筆自由畫。',
        mobileSubtitle: '選擇顏色，用手指自由畫。',
      ),
      DiaryChatStep.score => const _DiaryStepPresentation(
        stepLabel: '6 / 8　心情分數',
        progress: 0.75,
        flowTitle: '現在的心情是幾分？',
        panelTitle: '現在的心情是幾分？',
        panelSubtitle: '分數沒有好壞，只代表此刻感受。',
        mobileSubtitle: '分數沒有好壞，只代表此刻感受。',
      ),
      DiaryChatStep.sharing => const _DiaryStepPresentation(
        stepLabel: '7 / 8　分享設定',
        progress: 0.875,
        flowTitle: '要把日記分享出去嗎？',
        panelTitle: '要把日記分享出去嗎？',
        panelSubtitle: '分享設定之後可以隨時更改。',
        mobileSubtitle: '分享設定之後可以隨時更改。',
      ),
      DiaryChatStep.review ||
      DiaryChatStep.submitting => const _DiaryStepPresentation(
        stepLabel: '8 / 8　確認',
        progress: 1,
        flowTitle: '確認今天的日記',
        panelTitle: '確認今天的日記',
        panelSubtitle: '最後看一次，儲存後仍可編輯。',
        mobileSubtitle: '最後看一次，送出後仍可編輯。',
      ),
      DiaryChatStep.completed => const _DiaryStepPresentation(
        stepLabel: '完成',
        progress: 1,
        flowTitle: '日記已好好收進來了',
        panelTitle: '日記已好好收進來了',
        panelSubtitle: '謝謝你願意照顧今天的感受。',
        mobileSubtitle: '謝謝你願意照顧今天的感受。',
      ),
    };
  }
}

class _DiaryStepPresentation {
  const _DiaryStepPresentation({
    required this.stepLabel,
    required this.progress,
    required this.flowTitle,
    required this.panelTitle,
    required this.panelSubtitle,
    required this.mobileSubtitle,
  });

  final String stepLabel;
  final double progress;
  final String flowTitle;
  final String panelTitle;
  final String panelSubtitle;
  final String mobileSubtitle;

  String get mobileStepLabel {
    return stepLabel.split('　').first.replaceAll(' ', '');
  }
}
