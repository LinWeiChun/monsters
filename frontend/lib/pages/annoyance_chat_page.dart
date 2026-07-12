import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/annoyance_draft.dart';
import '../providers/annoyance_chat_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_spacing.dart';
import '../widgets/annoyance/annoyance_category_selector.dart';
import '../widgets/annoyance/annoyance_chat_bubble.dart';
import '../widgets/annoyance/record_method_selector.dart';

class AnnoyanceChatPage extends ConsumerStatefulWidget {
  const AnnoyanceChatPage({super.key});

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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      key: const Key('annoyanceChatMessages'),
                      controller: _scrollController,
                      children: _buildMessages(state),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildInteractionPanel(state, controller),
                ],
              ),
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
    ];
  }

  Widget _buildInteractionPanel(
    AnnoyanceChatState state,
    AnnoyanceChatController controller,
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
      AnnoyanceChatStep.content => const Card(
        key: Key('annoyanceContentStep'),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Text('內容輸入與預覽會接續顯示在這裡。'),
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
