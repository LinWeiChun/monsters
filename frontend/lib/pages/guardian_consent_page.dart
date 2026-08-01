import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/eligibility_policy.dart';
import '../providers/eligibility_provider.dart';
import '../theme/app_colors.dart';

class GuardianConsentPage extends ConsumerStatefulWidget {
  const GuardianConsentPage({super.key, required this.token});
  final String token;
  @override
  ConsumerState<GuardianConsentPage> createState() =>
      _GuardianConsentPageState();
}

class _GuardianConsentPageState extends ConsumerState<GuardianConsentPage> {
  final _reference = TextEditingController();
  final _email = TextEditingController();
  GuardianConsentAction? _action;
  bool _loading = false;
  String? _message;
  @override
  void initState() {
    super.initState();
    if (widget.token.isNotEmpty) Future.microtask(_inspect);
  }

  @override
  void dispose() {
    _reference.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _inspect() async {
    setState(() => _loading = true);
    try {
      final action = await ref
          .read(eligibilityRepositoryProvider)
          .guardianAction(widget.token, submit: false);
      if (mounted)
        setState(() {
          _action = action;
          _loading = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _loading = false;
          _message = '此連結無效、已使用或已過期';
        });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.registerFormBackground,
    body: SafeArea(
      child: LayoutBuilder(
        builder:
            (context, constraints) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: constraints.maxWidth > 700 ? 520 : 350,
                    height: 620,
                    child: _content(context),
                  ),
                ),
              ),
            ),
      ),
    ),
  );
  Widget _content(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Icon(
        Icons.family_restroom,
        size: 64,
        color: AppColors.registerPrimary,
      ),
      const SizedBox(height: 14),
      Text(
        '監護人同意',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 12),
      if (_loading)
        const Center(child: CircularProgressIndicator())
      else if (widget.token.isNotEmpty)
        _tokenAction()
      else
        _withdrawalRequest(),
      if (_message != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            _message!,
            key: const Key('guardianConsentMessage'),
            textAlign: TextAlign.center,
          ),
        ),
    ],
  );
  Widget _tokenAction() {
    if (_action == null) return const SizedBox.shrink();
    final withdraw = _action!.purpose == 'WITHDRAW';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          withdraw ? '確認撤回後，會員會立即停止使用一般功能。' : '同意僅用於使用資格，不會讓您查看任何私人內容。',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('guardianConsentActionButton'),
          onPressed: _submitAction,
          child: Text(withdraw ? '確認撤回同意' : '閱讀並同意'),
        ),
      ],
    );
  }

  Widget _withdrawalRequest() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        '輸入同意信中的同意編號與監護人 Email，我們會寄出 15 分鐘單次撤回連結。',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 14),
      TextField(
        key: const Key('guardianConsentReferenceField'),
        controller: _reference,
        decoration: const InputDecoration(labelText: '同意編號'),
      ),
      const SizedBox(height: 10),
      TextField(
        key: const Key('guardianConsentEmailField'),
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: '監護人 Email'),
      ),
      const SizedBox(height: 16),
      FilledButton(
        key: const Key('guardianWithdrawalRequestButton'),
        onPressed: _requestWithdrawal,
        child: const Text('寄送撤回連結'),
      ),
    ],
  );
  Future<void> _submitAction() async {
    setState(() => _loading = true);
    try {
      final result =
          _action!.purpose == 'WITHDRAW'
              ? await ref
                  .read(eligibilityRepositoryProvider)
                  .withdraw(widget.token)
              : await ref
                  .read(eligibilityRepositoryProvider)
                  .guardianAction(widget.token, submit: true);
      if (mounted)
        setState(() {
          _loading = false;
          _action = result;
          _message =
              result.status == 'GRANTED'
                  ? '同意已完成。請保留同意編號：${result.consentReference}'
                  : '同意已撤回。';
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _loading = false;
          _message = '此連結無效、已使用或已過期';
        });
    }
  }

  Future<void> _requestWithdrawal() async {
    if (_reference.text.trim().isEmpty || !_email.text.contains('@')) {
      setState(() => _message = '請輸入同意編號與有效 Email');
      return;
    }
    await ref
        .read(eligibilityRepositoryProvider)
        .requestWithdrawal(
          reference: _reference.text.trim(),
          email: _email.text.trim(),
        );
    if (mounted) setState(() => _message = '若資料相符，撤回連結將寄至監護人 Email。');
  }
}
