import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/core/widgets/app_button.dart';
import 'package:sijapin_mobile/core/widgets/state_widgets.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.lightTheme,
  home: Scaffold(body: child),
);

void main() {
  group('AppErrorState Widget Tests', () {
    testWidgets('renders default title and message', (tester) async {
      await tester.pumpWidget(_wrap(const AppErrorState()));
      expect(find.text('Terjadi Kendala Koneksi'), findsOneWidget);
      expect(
        find.text(
          'Gagal memuat data. Periksa koneksi internet Anda dan coba lagi.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders custom title and message', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppErrorState(
            title: 'Server Sedang Pemeliharaan',
            message: 'Silakan coba beberapa saat lagi.',
          ),
        ),
      );
      expect(find.text('Server Sedang Pemeliharaan'), findsOneWidget);
      expect(find.text('Silakan coba beberapa saat lagi.'), findsOneWidget);
    });

    testWidgets('shows retry button and triggers onRetry callback', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      var retried = false;
      await tester.pumpWidget(
        _wrap(AppErrorState(onRetry: () => retried = true)),
      );
      expect(find.byType(AppPrimaryButton), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(retried, isTrue);
    });

    testWidgets('does not show retry button when onRetry is null', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppErrorState()));
      expect(find.byType(AppPrimaryButton), findsNothing);
    });

    testWidgets('renders custom icon', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppErrorState(icon: Icons.error_outline_rounded)),
      );
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });
  });

  group('AppEmptyState Widget Tests', () {
    testWidgets('renders default title and message', (tester) async {
      await tester.pumpWidget(_wrap(const AppEmptyState()));
      expect(find.text('Belum Ada Data'), findsOneWidget);
      expect(
        find.text('Data yang Anda cari belum tersedia saat ini.'),
        findsOneWidget,
      );
    });

    testWidgets('renders custom title and message', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppEmptyState(
            title: 'Belum Ada Jadwal',
            message: 'Tidak ada jadwal poliklinik untuk hari ini.',
          ),
        ),
      );
      expect(find.text('Belum Ada Jadwal'), findsOneWidget);
      expect(
        find.text('Tidak ada jadwal poliklinik untuk hari ini.'),
        findsOneWidget,
      );
    });

    testWidgets('renders action button when provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppEmptyState(
            actionButton: AppPrimaryButton(
              label: 'Daftar Sekarang',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );
      expect(find.text('Daftar Sekarang'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });

    testWidgets('does not render action button when null', (tester) async {
      await tester.pumpWidget(_wrap(const AppEmptyState()));
      expect(find.byType(AppPrimaryButton), findsNothing);
    });
  });
}
