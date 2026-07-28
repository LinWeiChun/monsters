import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/annoyance_draft.dart';
import '../providers/annoyance_chat_provider.dart';
import '../providers/annoyance_media_provider.dart';
import '../routes/app_routes.dart';
import '../services/entry_media_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/annoyance/annoyance_category_selector.dart';
import '../widgets/annoyance/annoyance_chat_bubble.dart';
import '../widgets/annoyance/annoyance_completed_card.dart';
import '../widgets/annoyance/annoyance_review_card.dart';
import '../widgets/entry/drawing_choice_card.dart';
import '../widgets/entry/drawing_preview_card.dart';
import '../widgets/entry/entry_content_input.dart';
import '../widgets/entry/entry_flow_shell.dart';
import '../widgets/entry/mood_drawing_canvas.dart';
import '../widgets/entry/mood_score_selector.dart';
import '../widgets/entry/record_method_selector.dart';
import '../widgets/entry/share_choice_card.dart';
import '../widgets/navigation/app_navigation.dart';

class AnnoyanceChatPage extends ConsumerStatefulWidget {
  const AnnoyanceChatPage({this.drawingExporter, super.key});

  final MoodDrawingExport? drawingExporter;

  @override
  ConsumerState<AnnoyanceChatPage> createState() => _AnnoyanceChatPageState();
}

class _AnnoyanceChatPageState extends ConsumerState<AnnoyanceChatPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(annoyanceChatControllerProvider);
    final mediaService = ref.watch(annoyanceMediaServiceProvider);
    final controller = ref.read(annoyanceChatControllerProvider.notifier);
    final presentation = _presentationFor(state.step);

    return Scaffold(
      backgroundColor: AppColors.annoyanceBackground,
      body:
          state.step == AnnoyanceChatStep.drawing
              ? SafeArea(
                child: MoodDrawingCanvas(
                  onCompleted: controller.saveDrawing,
                  onCancel: controller.cancelDrawing,
                  exportPng: widget.drawingExporter,
                ),
              )
              : EntryFlowShell(
                keyPrefix: 'annoyance',
                compactTitle: '新增煩惱',
                activeDestination: AppNavigationDestination.annoyance,
                stepLabel: presentation.stepLabel,
                progress: presentation.progress,
                flowTitle: presentation.flowTitle,
                flowCaption: '把複雜的感受，一步一步整理下來。',
                panelTitle: presentation.panelTitle,
                panelSubtitle: presentation.panelSubtitle,
                messages: _buildMessages(state),
                operation: _buildInteractionPanel(
                  state,
                  controller,
                  mediaService,
                ),
                onHome: () => context.goNamed(AppRoute.home),
                onPrimaryAction: () => _confirmRestart(context, controller),
                onBack: () => _returnToHome(context),
                onProfile: () => context.pushNamed(AppRoute.profile),
                onNotification: () => _showUnavailable(context, '通知'),
                onUnavailable: (feature) => _showUnavailable(context, feature),
                onRestart: () => _confirmRestart(context, controller),
                canRestart: state.step != AnnoyanceChatStep.intro,
                privacyMessage: state.draftStatusMessage,
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

  Future<void> _confirmRestart(
    BuildContext context,
    AnnoyanceChatController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('捨棄目前草稿？'),
            content: const Text('重新開始會刪除文字與已暫存的媒體，且無法復原。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('繼續編輯'),
              ),
              FilledButton(
                key: const Key('annoyanceConfirmRestartButton'),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('捨棄並重新開始'),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      await controller.restart();
    }
  }

  List<Widget> _buildMessages(AnnoyanceChatState state) {
    return [
      const AnnoyanceChatBubble(
        key: Key('annoyanceChatGreeting'),
        message: '我會陪你把這件煩惱記下來。準備好後就開始。',
        isUser: false,
      ),
      if (state.step != AnnoyanceChatStep.intro)
        const AnnoyanceChatBubble(message: '先選一個煩惱類型。', isUser: false),
      if (state.category case final category?) ...[
        AnnoyanceChatBubble(message: category.name, isUser: true),
        const AnnoyanceChatBubble(message: '接著選擇你想記錄的方式。', isUser: false),
      ],
      if (state.recordMethod case final recordMethod?) ...[
        AnnoyanceChatBubble(message: recordMethod.label, isUser: true),
        AnnoyanceChatBubble(
          key: const Key('annoyanceContentPrompt'),
          message: _contentPrompt(recordMethod),
          isUser: false,
        ),
      ],
      if (state.step.index > AnnoyanceChatStep.content.index) ...[
        AnnoyanceChatBubble(message: _contentSummary(state), isUser: true),
        const AnnoyanceChatBubble(
          key: Key('annoyanceDrawingPrompt'),
          message: '主要內容記好了。要不要畫一張心情圖一起保存？',
          isUser: false,
        ),
      ],
      if (state.wantsDrawing case final wantsDrawing?)
        AnnoyanceChatBubble(message: wantsDrawing ? '想畫' : '先不用', isUser: true),
      if (state.drawing case final drawing?)
        DrawingPreviewCard(drawing: drawing, keyPrefix: 'annoyance'),
      if (state.step.index >= AnnoyanceChatStep.score.index)
        const AnnoyanceChatBubble(
          key: Key('annoyanceScorePrompt'),
          message: '接著用 1 到 5 分記下這件事的煩惱程度。',
          isUser: false,
        ),
      if (state.score case final score?)
        AnnoyanceChatBubble(message: score.scoreLabel, isUser: true),
      if (state.step.index >= AnnoyanceChatStep.sharing.index)
        const AnnoyanceChatBubble(
          key: Key('annoyanceSharingPrompt'),
          message: '分數記下來了。接下來決定是否分享這筆煩惱。',
          isUser: false,
        ),
      if (state.isShared case final isShared?)
        AnnoyanceChatBubble(message: isShared ? '分享到社群' : '保持私人', isUser: true),
      if (state.step == AnnoyanceChatStep.review)
        const AnnoyanceChatBubble(
          key: Key('annoyanceReviewPrompt'),
          message: '分享狀態已記下來。確認摘要後就可以送出。',
          isUser: false,
        ),
      if (state.step == AnnoyanceChatStep.submitting)
        const AnnoyanceChatBubble(
          key: Key('annoyanceSubmittingPrompt'),
          message: '正在送出這筆煩惱。',
          isUser: false,
        ),
      if (state.step == AnnoyanceChatStep.completed)
        const AnnoyanceChatBubble(
          key: Key('annoyanceCompletedPrompt'),
          message: '煩惱已經記錄完成。',
          isUser: false,
        ),
    ];
  }

  Widget _buildInteractionPanel(
    AnnoyanceChatState state,
    AnnoyanceChatController controller,
    EntryMediaService mediaService,
  ) {
    final selector = switch (state.step) {
      AnnoyanceChatStep.intro => FilledButton.icon(
        key: const Key('annoyanceChatStartButton'),
        onPressed: controller.begin,
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('開始記錄'),
      ),
      AnnoyanceChatStep.category => AnnoyanceCategorySelector(
        onSelected: controller.selectCategory,
      ),
      AnnoyanceChatStep.recordMethod => RecordMethodSelector(
        onSelected: controller.selectRecordMethod,
        keyPrefix: 'annoyance',
      ),
      AnnoyanceChatStep.content => EntryContentInput(
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
        keyPrefix: 'annoyance',
        textLabel: '煩惱內容',
        continueLabel: '暫存並繼續',
      ),
      AnnoyanceChatStep.drawingDecision => DrawingChoiceCard(
        onSelected: controller.selectDrawingChoice,
        keyPrefix: 'annoyance',
      ),
      AnnoyanceChatStep.score => MoodScoreSelector(
        selectedScore: state.score,
        onSelected: controller.selectScore,
        keyPrefix: 'annoyance',
        title: '選擇現在的煩惱分數',
        semanticLabel: '煩惱分數，1 到 5 分',
      ),
      AnnoyanceChatStep.sharing => ShareChoiceCard(
        selectedValue: state.isShared,
        onSelected: controller.selectSharing,
        keyPrefix: 'annoyance',
        title: '是否分享這筆煩惱？',
      ),
      AnnoyanceChatStep.review => AnnoyanceReviewCard(
        state: state,
        onSubmit: controller.submit,
      ),
      AnnoyanceChatStep.submitting => const Card(
        key: Key('annoyanceSubmittingCard'),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppSpacing.sm),
              Text('送出中，請稍候。'),
            ],
          ),
        ),
      ),
      AnnoyanceChatStep.completed =>
        state.createdAnnoyance == null
            ? const SizedBox.shrink()
            : AnnoyanceCompletedCard(
              annoyance: state.createdAnnoyance!,
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
            key: const Key('annoyanceChatBackButton'),
            onPressed: controller.goBack,
            icon: const Icon(Icons.undo),
            label: const Text('上一步'),
          ),
        ],
      ],
    );
  }

  bool _canGoBack(AnnoyanceChatStep step) {
    return step != AnnoyanceChatStep.intro &&
        step != AnnoyanceChatStep.submitting &&
        step != AnnoyanceChatStep.completed;
  }

  String _contentPrompt(AnnoyanceRecordMethod method) {
    return switch (method) {
      AnnoyanceRecordMethod.text => '請輸入想記錄的內容。',
      AnnoyanceRecordMethod.image => '請選擇一張圖片來記錄這件事。',
      AnnoyanceRecordMethod.audio => '請錄下一段聲音來記錄這件事。',
      AnnoyanceRecordMethod.video => '請選擇一段影片來記錄這件事。',
    };
  }

  String _contentSummary(AnnoyanceChatState state) {
    if (state.recordMethod == AnnoyanceRecordMethod.text) {
      return state.contentText.trim();
    }
    return '已選擇${state.recordMethod?.label ?? '媒體'}內容';
  }

  _AnnoyanceStepPresentation _presentationFor(AnnoyanceChatStep step) {
    return switch (step) {
      AnnoyanceChatStep.intro => const _AnnoyanceStepPresentation(
        stepLabel: '準備開始',
        progress: 0.06,
        flowTitle: '新增一筆煩惱',
        panelTitle: '準備好了嗎？',
        panelSubtitle: '整個流程約需 2–4 分鐘，你可以隨時返回修改。',
      ),
      AnnoyanceChatStep.category => const _AnnoyanceStepPresentation(
        stepLabel: '1 / 8　選擇類別',
        progress: 0.13,
        flowTitle: '這件事比較接近哪一類？',
        panelTitle: '選擇煩惱類別',
        panelSubtitle: '類別只用來協助你整理與回顧。',
      ),
      AnnoyanceChatStep.recordMethod => const _AnnoyanceStepPresentation(
        stepLabel: '2 / 8　記錄方式',
        progress: 0.25,
        flowTitle: '你想怎麼把它記下來？',
        panelTitle: '選擇記錄方式',
        panelSubtitle: '目前先以一種方式作為主要內容。',
      ),
      AnnoyanceChatStep.content => const _AnnoyanceStepPresentation(
        stepLabel: '3 / 8　記錄內容',
        progress: 0.38,
        flowTitle: '想說的話，都可以放在這裡。',
        panelTitle: '記錄煩惱內容',
        panelSubtitle: '不用急著整理，先把此刻最想說的留下來。',
      ),
      AnnoyanceChatStep.drawingDecision => const _AnnoyanceStepPresentation(
        stepLabel: '4 / 8　心情繪圖',
        progress: 0.5,
        flowTitle: '要不要也畫下現在的感受？',
        panelTitle: '加入心情繪圖',
        panelSubtitle: '可以用顏色和線條補充文字說不出的感受。',
      ),
      AnnoyanceChatStep.drawing => const _AnnoyanceStepPresentation(
        stepLabel: '5 / 8　心情繪圖',
        progress: 0.63,
        flowTitle: '把感受畫下來',
        panelTitle: '心情畫布',
        panelSubtitle: '完成後會把圖畫和這筆煩惱一起保存。',
      ),
      AnnoyanceChatStep.score => const _AnnoyanceStepPresentation(
        stepLabel: '6 / 8　感受分數',
        progress: 0.75,
        flowTitle: '這件事現在有多困擾你？',
        panelTitle: '記錄感受分數',
        panelSubtitle: '選擇 1 到 5 分，作為日後回顧心情變化的參考。',
      ),
      AnnoyanceChatStep.sharing => const _AnnoyanceStepPresentation(
        stepLabel: '7 / 8　分享設定',
        progress: 0.88,
        flowTitle: '這份心情要留給誰看？',
        panelTitle: '選擇分享方式',
        panelSubtitle: '你之後仍可在紀錄中更改。',
      ),
      AnnoyanceChatStep.review ||
      AnnoyanceChatStep.submitting => const _AnnoyanceStepPresentation(
        stepLabel: '8 / 8　確認紀錄',
        progress: 1,
        flowTitle: '最後確認一次，就幫你收好。',
        panelTitle: '確認這份煩惱',
        panelSubtitle: '送出後仍可在「我的紀錄」中編輯。',
      ),
      AnnoyanceChatStep.completed => const _AnnoyanceStepPresentation(
        stepLabel: '完成',
        progress: 1,
        flowTitle: '煩惱已記錄完成',
        panelTitle: '謝謝你願意把它說出來。',
        panelSubtitle: '先讓這件事暫時留在這裡吧。',
      ),
    };
  }
}

class _AnnoyanceStepPresentation {
  const _AnnoyanceStepPresentation({
    required this.stepLabel,
    required this.progress,
    required this.flowTitle,
    required this.panelTitle,
    required this.panelSubtitle,
  });

  final String stepLabel;
  final double progress;
  final String flowTitle;
  final String panelTitle;
  final String panelSubtitle;
}
