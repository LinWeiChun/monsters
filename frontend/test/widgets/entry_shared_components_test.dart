import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/models/entry_record.dart';
import 'package:monsters/widgets/entry/entry_flow_shell.dart';
import 'package:monsters/widgets/entry/record_method_selector.dart';
import 'package:monsters/widgets/navigation/app_navigation.dart';

void main() {
  testWidgets('record method selector uses a flow-specific key prefix', (
    tester,
  ) async {
    EntryRecordMethod? selectedMethod;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordMethodSelector(
            keyPrefix: 'diary',
            onSelected: (method) => selectedMethod = method,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('diaryRecordMethodTEXT')));

    expect(selectedMethod, EntryRecordMethod.text);
  });

  for (final size in <Size>[
    const Size(390, 844),
    const Size(900, 900),
    const Size(1440, 900),
  ]) {
    testWidgets('entry flow shell supports ${size.width.toInt()}px layout', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EntryFlowShell(
              keyPrefix: 'diary',
              compactTitle: '新增日記',
              activeDestination: AppNavigationDestination.home,
              stepLabel: '1 / 8　記錄方式',
              progress: 0.125,
              flowTitle: '把今天記下來',
              flowCaption: '慢慢整理此刻的感受。',
              panelTitle: '選擇記錄方式',
              panelSubtitle: '先選擇一種主要內容。',
              messages: const [Text('我會陪你把今天記下來。')],
              operation: const Text('Diary operation'),
              onHome: _noop,
              onPrimaryAction: _noop,
              onBack: _noop,
              onProfile: _noop,
              onNotification: _noop,
              onUnavailable: (_) {},
              onRestart: _noop,
              canRestart: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('diaryResponsiveShell')), findsOneWidget);
      expect(find.byKey(const Key('diaryProgress')), findsOneWidget);
      expect(find.byKey(const Key('diaryOperationPanel')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

void _noop() {}
