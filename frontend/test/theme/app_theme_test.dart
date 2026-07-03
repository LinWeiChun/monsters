import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/theme/app_colors.dart';
import 'package:monsters/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('builds light theme from project seed color', () {
      final theme = AppTheme.light();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppColors.lightBackground);
      expect(theme.filledButtonTheme.style, isNotNull);
    });

    test('builds dark theme from project seed color', () {
      final theme = AppTheme.dark();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.darkBackground);
      expect(theme.inputDecorationTheme.filled, isTrue);
    });
  });
}
