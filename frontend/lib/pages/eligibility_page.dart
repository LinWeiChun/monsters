import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/network/api_exception.dart';
import '../models/eligibility_policy.dart';
import '../providers/eligibility_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

enum EligibilityAgeBand { underage, minor, adult }

EligibilityAgeBand eligibilityAgeBand(DateTime birthday, DateTime serviceDate) {
  var age = serviceDate.year - birthday.year;
  if (serviceDate.month < birthday.month ||
      (serviceDate.month == birthday.month && serviceDate.day < birthday.day))
    age--;
  if (age < 13) return EligibilityAgeBand.underage;
  if (age < 18) return EligibilityAgeBand.minor;
  return EligibilityAgeBand.adult;
}

class EligibilityPage extends ConsumerStatefulWidget {
  const EligibilityPage({super.key, required this.continuationCredential});
  final String continuationCredential;
  @override
  ConsumerState<EligibilityPage> createState() => _EligibilityPageState();
}

class _EligibilityPageState extends ConsumerState<EligibilityPage> {
  final _formKey = GlobalKey<FormState>();
  final _nickname = TextEditingController();
  final _guardianEmail = TextEditingController();
  EligibilityPolicy? _policy;
  DateTime? _birthday;
  String _region = 'TW';
  bool _minorAccepted = false;
  bool _disclosureConfirmed = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _nickname.dispose();
    _guardianEmail.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.continuationCredential.isEmpty) {
      setState(() {
        _loading = false;
        _error = '資格連結無效，請重新登入';
      });
      return;
    }
    try {
      final value = await ref.read(eligibilityRepositoryProvider).policy();
      if (mounted)
        setState(() {
          _policy = value;
          _region = value.serviceRegion;
          _loading = false;
        });
    } on Object {
      if (mounted)
        setState(() {
          _loading = false;
          _error = '目前無法載入資格資料';
        });
    }
  }

  EligibilityAgeBand? get _band =>
      _birthday == null ? null : eligibilityAgeBand(_birthday!, DateTime.now());
  bool get _restricted =>
      _region != (_policy?.serviceRegion ?? 'TW') ||
      _band == EligibilityAgeBand.underage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.registerFormBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: constraints.maxWidth > 760 ? 620 : 358,
                    height: 720,
                    child:
                        _loading
                            ? const Center(child: CircularProgressIndicator())
                            : _content(context),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    if (_error != null && _policy == null)
      return _messageCard(Icons.link_off, '無法繼續', _error!, '返回登入');
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Icon(
            Icons.verified_user_outlined,
            size: 54,
            color: AppColors.registerPrimary,
          ),
          const SizedBox(height: 12),
          Text(
            '完成會員資格',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text('資料只用於確認服務資格；生日與監護人資料不會公開。', textAlign: TextAlign.center),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            key: const Key('eligibilityRegionField'),
            // Flutter 3.29.2 compatibility; use initialValue after the CI baseline advances.
            // ignore: deprecated_member_use
            value: _region,
            decoration: const InputDecoration(labelText: '服務地區'),
            items: const [
              DropdownMenuItem(value: 'TW', child: Text('台灣')),
              DropdownMenuItem(value: 'ZZ', child: Text('其他地區')),
            ],
            onChanged: (value) => setState(() => _region = value ?? 'TW'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: const Key('eligibilityBirthdayField'),
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: _pickBirthday,
            label: Text(
              _birthday == null
                  ? '選擇生日'
                  : '${_birthday!.year}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}',
            ),
          ),
          if (_birthday != null && !_restricted) ...[
            const SizedBox(height: 10),
            TextFormField(
              key: const Key('eligibilityNicknameField'),
              controller: _nickname,
              decoration: const InputDecoration(labelText: '公開暱稱（2–30 字）'),
              validator:
                  (value) =>
                      (value ?? '').trim().runes.length < 2
                          ? '請輸入至少 2 個字'
                          : null,
            ),
          ],
          if (_band == EligibilityAgeBand.minor && !_restricted) ...[
            const SizedBox(height: 10),
            TextFormField(
              key: const Key('guardianEmailField'),
              controller: _guardianEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: '監護人 Email'),
              validator:
                  (value) =>
                      !(value ?? '').contains('@') ? '請輸入有效的監護人 Email' : null,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: _minorAccepted,
              onChanged:
                  (value) => setState(() => _minorAccepted = value ?? false),
              title: TextButton(
                onPressed: () => _showDocument('未成年人與監護人說明'),
                child: const Text('我已閱讀未成年人說明'),
              ),
            ),
          ],
          if (_band == EligibilityAgeBand.adult && !_restricted)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: _disclosureConfirmed,
              onChanged:
                  (value) =>
                      setState(() => _disclosureConfirmed = value ?? false),
              title: TextButton(
                onPressed: () => _showDocument('公開暱稱揭露說明'),
                child: const Text('預覽並確認公開暱稱'),
              ),
            ),
          if (_restricted)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                _region != (_policy?.serviceRegion ?? 'TW')
                    ? '目前第一版服務地區僅限台灣。'
                    : '未滿 13 歲無法取得一般功能，仍可使用必要的申訴、匯出與刪除入口。',
                key: const Key('eligibilityRestrictionMessage'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.registerError,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.registerError),
              ),
            ),
          const SizedBox(height: 14),
          FilledButton(
            key: const Key('eligibilitySubmitButton'),
            onPressed: _submit,
            child: Text(
              _restricted
                  ? '確認資格結果'
                  : _band == EligibilityAgeBand.minor
                  ? '寄送監護人同意信'
                  : '完成資格資料',
            ),
          ),
          TextButton(
            onPressed: () => context.goNamed(AppRoute.login),
            child: const Text('稍後再填'),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _messageCard(
    IconData icon,
    String title,
    String body,
    String action,
  ) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, size: 64),
      const SizedBox(height: 12),
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      Text(body),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: () => context.goNamed(AppRoute.login),
        child: Text(action),
      ),
    ],
  );

  Future<void> _pickBirthday() async {
    final value = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (value != null) setState(() => _birthday = value);
  }

  Future<void> _showDocument(String title) => showDialog<void>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(title),
          content: const SizedBox(
            width: 480,
            height: 320,
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Text(
                  '本服務是非醫療的情緒記錄與自我照顧工具。監護人同意僅用於確認未成年人使用資格，不授予查看私人日記、煩惱、媒體或自我探索內容的權限。公開暱稱會在社群開放後顯示；未完成明確確認前不得發布或留言。\n\n如需撤回監護人同意，請使用寄送至監護人 Email 的短效單次連結。撤回後一般功能會立即停止，之後可重新取得同意。',
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('關閉'),
            ),
          ],
        ),
  );

  Future<void> _submit() async {
    if (_birthday == null) {
      setState(() => _error = '請先選擇生日');
      return;
    }
    if (!_restricted && !_formKey.currentState!.validate()) return;
    if (_band == EligibilityAgeBand.minor && !_minorAccepted) {
      setState(() => _error = '請先閱讀並同意未成年人說明');
      return;
    }
    setState(() => _error = null);
    try {
      final outcome = await ref
          .read(eligibilityRepositoryProvider)
          .complete(
            credential: widget.continuationCredential,
            region: _region,
            birthday: _birthday!,
            nickname: _restricted ? null : _nickname.text.trim(),
            guardianEmail:
                _band == EligibilityAgeBand.minor && !_restricted
                    ? _guardianEmail.text.trim()
                    : null,
            policy: _policy!,
            confirmDisclosure:
                _band == EligibilityAgeBand.adult && _disclosureConfirmed,
          );
      if (!mounted) return;
      if (outcome.nextAction == 'SIGN_IN')
        context.goNamed(AppRoute.login);
      else
        setState(
          () =>
              _error =
                  outcome.nextAction == 'AWAIT_GUARDIAN_CONSENT'
                      ? '已寄出監護人同意信；完成同意後請重新登入。'
                      : '此資格目前無法使用一般功能。',
        );
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = '目前無法儲存資格資料');
    }
  }
}
