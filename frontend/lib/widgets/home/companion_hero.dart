import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

class CompanionHero extends StatelessWidget {
  const CompanionHero({
    required this.greetingName,
    this.compact = false,
    super.key,
  });

  final String greetingName;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      label: '陪伴怪獸向$greetingName問候',
      child: Container(
        padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child:
            compact
                ? Column(
                  children: [
                    const _MonsterImage(size: 176),
                    const SizedBox(height: AppSpacing.md),
                    _Greeting(greetingName: greetingName),
                  ],
                )
                : Row(
                  children: [
                    const Expanded(child: _MonsterImage(size: 260)),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(child: _Greeting(greetingName: greetingName)),
                  ],
                ),
      ),
    );
  }
}

class _MonsterImage extends StatefulWidget {
  const _MonsterImage({required this.size});

  final double size;

  @override
  State<_MonsterImage> createState() => _MonsterImageState();
}

class _MonsterImageState extends State<_MonsterImage>
    with TickerProviderStateMixin {
  late final AnimationController _idleController;
  late final AnimationController _reactionController;
  late final Animation<double> _idleScale;
  late final Animation<double> _idleOffset;
  late final Animation<double> _reactionScale;
  late final Animation<double> _reactionOffset;
  late final Animation<double> _reactionRotation;
  bool _idleStarted = false;
  bool _isReacting = false;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _reactionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _idleScale = Tween<double>(begin: 0.985, end: 1.015).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );
    _idleOffset = Tween<double>(begin: 3, end: -3).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );
    _reactionScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 0.94), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.08), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1), weight: 45),
    ]).animate(
      CurvedAnimation(parent: _reactionController, curve: Curves.easeOut),
    );
    _reactionOffset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 8), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 8, end: -12), weight: 35),
      TweenSequenceItem(tween: Tween(begin: -12, end: 0), weight: 45),
    ]).animate(
      CurvedAnimation(parent: _reactionController, curve: Curves.easeOut),
    );
    _reactionRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -0.035), weight: 35),
      TweenSequenceItem(tween: Tween(begin: -0.035, end: 0.025), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.025, end: 0), weight: 35),
    ]).animate(
      CurvedAnimation(parent: _reactionController, curve: Curves.easeOut),
    );
    _reactionController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _isReacting = false);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _idleStarted = false;
      _idleController.stop();
      _idleController.value = 0;
      _reactionController.stop();
      _reactionController.value = 0;
      _isReacting = false;
      return;
    }
    if (!_idleStarted) {
      _idleStarted = true;
      _idleController.repeat(reverse: true, count: 2);
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _reactionController.dispose();
    super.dispose();
  }

  void _react() {
    if (MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    setState(() => _isReacting = true);
    _reactionController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '和陪伴怪獸互動',
      value: _isReacting ? '怪獸正在回應' : '怪獸等待互動',
      child: Tooltip(
        message: '點一下和怪獸互動',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('homeAnimatedMonster'),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: _react,
            child: AnimatedBuilder(
              key: Key(
                _isReacting
                    ? 'homeAnimatedMonsterReacting'
                    : 'homeAnimatedMonsterIdle',
              ),
              animation: Listenable.merge([
                _idleController,
                _reactionController,
              ]),
              builder: (context, child) {
                final scale = _idleScale.value * _reactionScale.value;
                final offset = _idleOffset.value + _reactionOffset.value;
                return Transform.translate(
                  key: const Key('homeAnimatedMonsterTransform'),
                  offset: Offset(0, offset),
                  child: Transform.rotate(
                    angle: _reactionRotation.value,
                    child: Transform.scale(
                      key: const Key('homeAnimatedMonsterScale'),
                      scale: scale,
                      child: child,
                    ),
                  ),
                );
              },
              child: ExcludeSemantics(
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.greetingName});

  final String greetingName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greetingName，我在這裡。',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '今天有什麼想說的嗎？慢慢來就好。',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
