import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/core/widgets/app_button.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.lightTheme,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('AppPrimaryButton Widget Tests', () {
    testWidgets('renders label text correctly', (tester) async {
      await tester.pumpWidget(
        _wrap(AppPrimaryButton(label: 'Daftar Sekarang', onPressed: () {})),
      );
      expect(find.text('Daftar Sekarang'), findsOneWidget);
    });

    testWidgets('renders icon when icon is provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppPrimaryButton(
            label: 'Submit',
            onPressed: () {},
            icon: Icons.send_rounded,
          ),
        ),
      );
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('shows loading spinner when isLoading is true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppPrimaryButton(
            label: 'Menyimpan...',
            onPressed: null,
            isLoading: true,
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Menyimpan...'), findsNothing);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppPrimaryButton(label: 'Nonaktif', onPressed: null)),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('triggers onPressed callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppPrimaryButton(label: 'Tap Me', onPressed: () => tapped = true),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });
  });

  group('AppSecondaryButton Widget Tests', () {
    testWidgets('renders label text correctly', (tester) async {
      await tester.pumpWidget(
        _wrap(AppSecondaryButton(label: 'Batal', onPressed: () {})),
      );
      expect(find.text('Batal'), findsOneWidget);
    });

    testWidgets('shows loading spinner when isLoading is true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppSecondaryButton(
            label: 'Memuat...',
            onPressed: null,
            isLoading: true,
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('triggers onPressed callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppSecondaryButton(label: 'Klik', onPressed: () => tapped = true),
        ),
      );
      await tester.tap(find.byType(OutlinedButton));
      expect(tapped, isTrue);
    });
  });
}
