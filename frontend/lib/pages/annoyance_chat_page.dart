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
import '../widgets/annoyance/annoyance_content_input.dart';
import '../widgets/annoyance/drawing_choice_card.dart';
import '../widgets/annoyance/drawing_preview_card.dart';
import '../widgets/annoyance/mood_drawing_canvas.dart';
import '../widgets/annoyance/record_method_selector.dart';

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
          tooltip: '返回首頁',
          onPressed: () => context.goNamed(AppRoute.home),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('怪獸聊天室'),
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
        message: '嗨，我在這裡陪你。想說的時候，我們就慢慢開始。',
        isUser: false,
      ),
      if (state.step != AnnoyanceChatStep.intro)
        const AnnoyanceChatBubble(message: '今天想記錄哪一類煩惱呢？', isUser: false),
      if (state.category case final category?) ...[
        AnnoyanceChatBubble(message: category.name, isUser: true),
        const AnnoyanceChatBubble(message: '謝謝你告訴我。想用什麼方式記錄？', isUser: false),
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
          message: '內容收到了。想畫一張心情圖，讓感受多一種表達嗎？',
          isUser: false,
        ),
      ],
      if (state.wantsDrawing case final wantsDrawing?)
        AnnoyanceChatBubble(message: wantsDrawing ? '想畫' : '先不用', isUser: true),
      if (state.drawing case final drawing?)
        DrawingPreviewCard(drawing: drawing),
      if (state.step == AnnoyanceChatStep.score)
        const AnnoyanceChatBubble(
          key: Key('annoyanceScorePrompt'),
          message: '謝謝你完成這一步。接下來記錄現在的煩惱分數。',
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
        label: const Text('開始聊聊'),
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
      AnnoyanceChatStep.score => const Card(
        key: Key('annoyanceScoreStepPlaceholder'),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Text('煩惱分數選擇會接續顯示在這裡。'),
        ),
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
            if (state.step != AnnoyanceChatStep.intro) ...[
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

  String _contentPrompt(AnnoyanceRecordMethod method) {
    return switch (method) {
      AnnoyanceRecordMethod.text => '慢慢來，接下來把想說的話寫下來就好。',
      AnnoyanceRecordMethod.image => '接下來可以選一張圖片，讓我陪你看看。',
      AnnoyanceRecordMethod.audio => '接下來可以錄下想說的話，不用急。',
      AnnoyanceRecordMethod.video => '接下來可以選一段影片來記錄這件事。',
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
