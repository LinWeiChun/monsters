import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/member_data_result.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_data_provider.dart';
import '../auth/google_sign_in_web_button.dart';

class MemberSensitiveInput {
  const MemberSensitiveInput({
    required this.value,
    required this.reason,
    required this.password,
    required this.useGoogle,
    this.reauthentication,
  });

  final String value;
  final String reason;
  final String password;
  final bool useGoogle;
  final MemberReauthentication? reauthentication;
}

class MemberSensitiveDialog extends ConsumerStatefulWidget {
  const MemberSensitiveDialog({
    super.key,
    required this.title,
    required this.fieldLabel,
    required this.fieldHint,
    this.showReason = false,
    this.useWebGoogle = kIsWeb,
  });

  final String title;
  final String fieldLabel;
  final String fieldHint;
  final bool showReason;
  final bool useWebGoogle;

  @override
  ConsumerState<MemberSensitiveDialog> createState() =>
      _MemberSensitiveDialogState();
}

class _MemberSensitiveDialogState extends ConsumerState<MemberSensitiveDialog> {
  final _value = TextEditingController();
  final _password = TextEditingController();
  StreamSubscription<String>? _googleSubscription;
  String _reason = 'DATA_ENTRY_ERROR';
  bool _googleReady = false;
  bool _verifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.useWebGoogle) _initializeGoogle();
  }

  Future<void> _initializeGoogle() async {
    try {
      final service = ref.read(googleSignInServiceProvider);
      await service.initialize();
      if (!mounted) return;
      _googleSubscription = service.idTokenEvents.listen(
        _verifyGoogle,
        onError: (_) {
          if (mounted) setState(() => _error = 'Google 驗證失敗，請重新嘗試');
        },
      );
      setState(() => _googleReady = true);
    } on Object {
      if (mounted) setState(() => _error = 'Google 驗證目前無法使用');
    }
  }

  Future<void> _verifyGoogle(String idToken) async {
    if (!mounted || _verifying || _value.text.trim().isEmpty) return;
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      // The ID token goes directly to the backend, never into widget/provider
      // state. Only the purpose-bound proof leaves this dialog.
      final proof = await ref
          .read(memberDataRepositoryProvider)
          .reauthenticateWithGoogle(
            idToken: idToken,
            purpose: widget.showReason ? 'BIRTHDAY_CORRECTION' : 'EMAIL_CHANGE',
          );
      if (!mounted) return;
      _submit(useGoogle: true, proof: proof);
    } on Object {
      if (mounted) {
        setState(() {
          _verifying = false;
          _error = 'Google 重新驗證失敗，沒有變更資料';
        });
      }
    }
  }

  Future<void> _selectBirthday() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_value.text) ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900, 1, 1),
      lastDate: today,
      helpText: '選擇更正後生日',
      cancelText: '取消',
      confirmText: '確定',
    );
    if (selected == null || !mounted) return;
    setState(
      () =>
          _value.text =
              '${selected.year.toString().padLeft(4, '0')}-'
              '${selected.month.toString().padLeft(2, '0')}-'
              '${selected.day.toString().padLeft(2, '0')}',
    );
  }

  void _submit({required bool useGoogle, MemberReauthentication? proof}) {
    Navigator.pop(
      context,
      MemberSensitiveInput(
        value: _value.text.trim(),
        reason: _reason,
        password: useGoogle ? '' : _password.text,
        useGoogle: useGoogle,
        reauthentication: proof,
      ),
    );
  }

  @override
  void dispose() {
    _googleSubscription?.cancel();
    _value.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = _value.text.trim().isNotEmpty;
    return AlertDialog(
      title: Text(widget.title),
      scrollable: true,
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('memberSensitiveValueField'),
              controller: _value,
              enabled: !_verifying,
              readOnly: widget.showReason,
              onTap: widget.showReason ? _selectBirthday : null,
              keyboardType:
                  widget.showReason ? null : TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: widget.fieldLabel,
                hintText: widget.fieldHint,
                suffixIcon:
                    widget.showReason ? const Icon(Icons.calendar_month) : null,
              ),
            ),
            if (widget.showReason) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                // Flutter 3.29.2 compatibility; migrate after CI is upgraded.
                // ignore: deprecated_member_use
                value: _reason,
                decoration: const InputDecoration(labelText: '更正原因'),
                items: const [
                  DropdownMenuItem(
                    value: 'DATA_ENTRY_ERROR',
                    child: Text('資料輸入錯誤'),
                  ),
                  DropdownMenuItem(
                    value: 'LEGAL_RECORD_CORRECTION',
                    child: Text('法定資料更正'),
                  ),
                  DropdownMenuItem(value: 'OTHER', child: Text('其他')),
                ],
                onChanged:
                    _verifying
                        ? null
                        : (value) => setState(() => _reason = value ?? _reason),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              key: const Key('memberSensitivePasswordField'),
              controller: _password,
              enabled: !_verifying,
              onChanged: (_) => setState(() {}),
              obscureText: true,
              decoration: const InputDecoration(labelText: '目前密碼（5 分鐘重新驗證）'),
            ),
            if (widget.useWebGoogle && hasValue && _googleReady)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: IgnorePointer(
                  ignoring: _verifying,
                  child: const GoogleSignInWebButton(),
                ),
              ),
            if (_verifying) const LinearProgressIndicator(),
            if (_error != null) Text(_error!),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        if (!widget.useWebGoogle)
          OutlinedButton(
            key: const Key('memberSensitiveGoogleSubmit'),
            onPressed: hasValue ? () => _submit(useGoogle: true) : null,
            child: const Text('使用 Google 驗證'),
          ),
        FilledButton(
          key: const Key('memberSensitivePasswordSubmit'),
          onPressed:
              hasValue && _password.text.isNotEmpty && !_verifying
                  ? () => _submit(useGoogle: false)
                  : null,
          child: const Text('繼續'),
        ),
      ],
    );
  }
}
