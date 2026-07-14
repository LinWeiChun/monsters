import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/annoyance_draft.dart';
import '../providers/annoyance_chat_provider.dart';
import '../providers/annoyance_media_provider.dart';
import '../routes/app_routes.dart';
import '../services/annoyance_media_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/annoyance/annoyance_category_selector.dart';
import '../widgets/annoyance/annoyance_chat_bubble.dart';
import '../widgets/annoyance/annoyance_completed_card.dart';
import '../widgets/annoyance/annoyance_content_input.dart';
import '../widgets/annoyance/annoyance_review_card.dart';
import '../widgets/annoyance/drawing_choice_card.dart';
import '../widgets/annoyance/drawing_preview_card.dart';
import '../widgets/annoyance/mood_drawing_canvas.dart';
import '../widgets/annoyance/mood_score_selector.dart';
import '../widgets/annoyance/record_method_selector.dart';
import '../widgets/annoyance/share_choice_card.dart';

class AnnoyanceChatPage extends ConsumerStatefulWidget {
  const AnnoyanceChatPage({this.drawingExporter, super.key});

  final MoodDrawingExport? drawingExporter;

  @override
  ConsumerState<AnnoyanceChatPage> createState() => _AnnoyanceChatPageState();
}

class _AnnoyanceChatPageState extends ConsumerState<AnnoyanceChatPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(annoyanceChatControllerProvider);
    final mediaService = ref.watch(annoyanceMediaServiceProvider);
    final controller = ref.read(annoyanceChatControllerProvider.notifier);
    ref.listen(annoyanceChatControllerProvider, (previous, next) {
      if (previous?.step != next.step) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('annoyanceChatHomeButton'),
          tooltip: '回首頁',
          onPressed: () => context.goNamed(AppRoute.home),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('新增煩惱'),
        actions: [
          IconButton(
            key: const Key('annoyanceChatRestartButton'),
            tooltip: '重新開始',
            onPressed:
                state.step == AnnoyanceChatStep.intro
                    ? null
                    : controller.restart,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body:
          state.step == AnnoyanceChatStep.drawing
              ? SafeArea(
                child: MoodDrawingCanvas(
                  onCompleted: controller.saveDrawing,
                  onCancel: controller.cancelDrawing,
                  exportPng: widget.drawingExporter,
                ),
              )
              : _buildChatBody(state, controller, mediaService),
    );
  }

  Widget _buildChatBody(
    AnnoyanceChatState state,
    AnnoyanceChatController controller,
    AnnoyanceMediaService mediaService,
  ) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: ListView(
                    key: const Key('annoyanceChatMessages'),
                    controller: _scrollController,
                    children: _buildMessages(state),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Flexible(
                  flex: 3,
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    child: _buildInteractionPanel(
                      state,
                      controller,
                      mediaService,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        DrawingPreviewCard(drawing: drawing),
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
    AnnoyanceMediaService mediaService,
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
      ),
      AnnoyanceChatStep.content => AnnoyanceContentInput(
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
      ),
      AnnoyanceChatStep.drawingDecision => DrawingChoiceCard(
        onSelected: controller.selectDrawingChoice,
      ),
      AnnoyanceChatStep.score => MoodScoreSelector(
        selectedScore: state.score,
        onSelected: controller.selectScore,
      ),
      AnnoyanceChatStep.sharing => ShareChoiceCard(
        selectedValue: state.isShared,
        onSelected: controller.selectSharing,
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
              onGoHome: () => context.goNamed(AppRoute.home),
            ),
      _ => const SizedBox.shrink(),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
        ),
      ),
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

  void _scrollToBottom() {
    if (!mounted || !_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }
}
