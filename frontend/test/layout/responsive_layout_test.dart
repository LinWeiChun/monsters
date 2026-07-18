import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/layout/responsive_layout.dart';

void main() {
  testWidgets('switches window classes while the viewport is resized', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _resize(tester, const Size(599, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: ResponsiveLayout(
          mobile: (context, constraints) => const Text('mobile'),
          tablet: (context, constraints) => const Text('tablet'),
          desktop: (context, constraints) => const Text('desktop'),
        ),
      ),
    );
    expect(find.text('mobile'), findsOneWidget);

    await _resize(tester, const Size(600, 800));
    expect(find.text('tablet'), findsOneWidget);

    await _resize(tester, const Size(1199, 800));
    expect(find.text('tablet'), findsOneWidget);

    await _resize(tester, const Size(1200, 800));
    expect(find.text('desktop'), findsOneWidget);

    await _resize(tester, const Size(390, 844));
    expect(find.text('mobile'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _resize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  await tester.pump();
}
