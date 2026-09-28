import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';

void main() {
  group('AppTheme & WCAG AA Compliance Tests (US-CORE-04)', () {
    final theme = AppTheme.lightTheme;

    test('should use Material 3 and official Sitanala colors', () {
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, equals(AppColors.surfaceBg));
      expect(theme.colorScheme.primary, equals(AppColors.brandWarmBronze));
      expect(theme.colorScheme.secondary, equals(AppColors.brandGoldenCaramel));
      expect(theme.colorScheme.error, equals(AppColors.dangerCrimson));
    });

    test('inputDecorationTheme should have radius 14 and surfaceCard fill', () {
      final inputTheme = theme.inputDecorationTheme;
      expect(inputTheme.filled, isTrue);
      expect(inputTheme.fillColor, equals(AppColors.surfaceCard));

      final border = inputTheme.border as OutlineInputBorder?;
      expect(border?.borderRadius, equals(BorderRadius.circular(14)));
    });

    test('elevatedButtonTheme complies with WCAG AA minHeight 48dp', () {
      final buttonStyle = theme.elevatedButtonTheme.style;
      expect(buttonStyle, isNotNull);

      final minSize = buttonStyle?.minimumSize?.resolve({});
      expect(minSize, isNotNull);
      expect(minSize!.height, greaterThanOrEqualTo(48.0));
      expect(buttonStyle?.shape?.resolve({}), isA<StadiumBorder>());
    });

    test('outlinedButtonTheme complies with WCAG AA minHeight 48dp', () {
      final buttonStyle = theme.outlinedButtonTheme.style;
      expect(buttonStyle, isNotNull);

      final minSize = buttonStyle?.minimumSize?.resolve({});
      expect(minSize, isNotNull);
      expect(minSize!.height, greaterThanOrEqualTo(48.0));
      expect(buttonStyle?.shape?.resolve({}), isA<StadiumBorder>());
    });

    test('textButtonTheme complies with WCAG AA min touch target 48x48dp', () {
      final buttonStyle = theme.textButtonTheme.style;
      expect(buttonStyle, isNotNull);

      final minSize = buttonStyle?.minimumSize?.resolve({});
      expect(minSize, isNotNull);
      expect(minSize!.height, greaterThanOrEqualTo(48.0));
      expect(minSize.width, greaterThanOrEqualTo(48.0));
    });

    test('typography textTheme matches Sitanala hierarchy', () {
      expect(theme.textTheme.displayLarge?.fontSize, equals(26.0));
      expect(theme.textTheme.headlineMedium?.fontSize, equals(20.0));
      expect(theme.textTheme.titleMedium?.fontSize, equals(16.0));
      expect(theme.textTheme.bodyMedium?.fontSize, equals(14.0));
      expect(theme.textTheme.labelMedium?.fontSize, equals(12.0));
    });
  });
}
