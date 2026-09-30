import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/core/widgets/app_loading_state.dart';
import 'package:sijapin_mobile/features/public_services/domain/entities/bed_availability.dart';
import 'package:sijapin_mobile/features/public_services/domain/repositories/bed_availability_repository.dart';
import 'package:sijapin_mobile/features/public_services/presentation/controllers/bed_availability_controller.dart';
import 'package:sijapin_mobile/features/public_services/presentation/screens/bed_availability_screen.dart';

/// Membangun aplikasi uji. Hindari `pumpAndSettle`: pil Live SIMRS memakai
/// `PulseDot` beranimasi terus-menerus sehingga settle tidak pernah selesai.
Widget _buildApp(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: const BedAvailabilityScreen(),
    ),
  );
}

/// Memuat data awal (delay sampel 400ms) lalu merender ulang hasil fetch.
Future<void> _settleLoad(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}

void main() {
  group('BedAvailabilityScreen (Ketersediaan Kamar)', () {
    testWidgets('renders header with title and Live SIMRS badge', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await _settleLoad(tester);

      expect(find.text('Ketersediaan Kamar'), findsOneWidget);
      expect(find.text('Live SIMRS'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('renders hero summary with bed counts and BOR', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await _settleLoad(tester);

      expect(find.text('KAPASITAS RAWAT INAP RS'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('Bed Siap Huni'), findsOneWidget);
      expect(find.textContaining('142'), findsOneWidget);
      expect(find.textContaining('87,3%'), findsAtLeastNWidgets(1));
      expect(find.text('18 Tersedia'), findsOneWidget);
      expect(find.textContaining('124 Terisi'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('renders 6 filter chips with Semua Kelas active by default', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await _settleLoad(tester);

      for (final label in <String>[
        'Semua Kelas',
        'Kelas 3',
        'Kelas 2',
        'Kelas 1',
        'VIP / VVIP',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      // Chip ICU berada di luar viewport strip horizontal — cari tanpa
      // memedulikan offstage.
      expect(find.text('ICU', skipOffstage: false), findsOneWidget);

      // Chip aktif berlatar karamel
      final activeChip = find.ancestor(
        of: find.text('Semua Kelas'),
        matching: find.byType(AnimatedContainer),
      );
      final decoration =
          tester.widget<AnimatedContainer>(activeChip).decoration
              as BoxDecoration;
      expect(decoration.color, AppColors.brandGoldenCaramel);

      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('tapping Kelas 3 makes it active and filters wards', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await _settleLoad(tester);

      await tester.tap(find.text('Kelas 3'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // Chip Kelas 3 aktif, Semua Kelas nonaktif
      final activeDecoration =
          tester
                  .widget<AnimatedContainer>(
                    find.ancestor(
                      of: find.text('Kelas 3'),
                      matching: find.byType(AnimatedContainer),
                    ),
                  )
                  .decoration
              as BoxDecoration;
      expect(activeDecoration.color, AppColors.brandGoldenCaramel);
      final inactiveDecoration =
          tester
                  .widget<AnimatedContainer>(
                    find.ancestor(
                      of: find.text('Semua Kelas'),
                      matching: find.byType(AnimatedContainer),
                    ),
                  )
                  .decoration
              as BoxDecoration;
      expect(inactiveDecoration.color, AppColors.surfaceCard);

      // Melati & Dahlia punya Kelas 3; ICU tidak
      expect(find.text('Ruang Melati (Dewasa)'), findsOneWidget);
      expect(find.text('Ruang Dahlia (Anak)'), findsOneWidget);
      expect(find.text('ICU Sentral'), findsNothing);

      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('ward cards render identity, schedule and actions', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await _settleLoad(tester);

      expect(find.text('Ketersediaan Ruangan'), findsOneWidget);
      expect(find.text('3 Unit Dipantau'), findsOneWidget);

      expect(find.text('Ruang Melati (Dewasa)'), findsOneWidget);
      expect(find.text('Penyakit Dalam • Lantai 3 Gedung B'), findsOneWidget);
      expect(find.text('6 Bed Kosong'), findsOneWidget);
      expect(find.text('Ruang Dahlia (Anak)'), findsOneWidget);
      expect(find.text('5 Bed Kosong'), findsOneWidget);
      expect(find.textContaining('mnt lalu'), findsAtLeastNWidgets(1));
      expect(find.text('Detail Ruangan'), findsAtLeastNWidgets(1));

      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('ICU card shows full state with alert and protocol action', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await _settleLoad(tester);

      expect(find.text('ICU Sentral'), findsOneWidget);
      expect(find.text('Penuh (0 Bed)'), findsOneWidget);
      expect(
        find.text('Hubungi IGD untuk rujukan darurat antar-RS'),
        findsOneWidget,
      );
      expect(find.text('Update: Real-time'), findsOneWidget);
      expect(find.text('Protokol IGD'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('filter with no matching ward shows empty state', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await _settleLoad(tester);

      await tester.tap(find.text('VIP / VVIP'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.text('Tidak Ada Ruangan Tersedia'), findsOneWidget);
      expect(find.text('Ruang Melati (Dewasa)'), findsNothing);

      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('filter change does not show shimmer skeleton', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await _settleLoad(tester);

      // Daftar awal tampil, bukan shimmer
      expect(find.byType(AppLoadingState), findsNothing);
      expect(find.text('Ruang Melati (Dewasa)'), findsOneWidget);

      await tester.tap(find.text('Kelas 2'));
      await tester.pump();

      // Selama fetch: tidak ada shimmer, daftar lama tetap tampil
      expect(find.byType(AppLoadingState), findsNothing);
      expect(find.text('Ruang Melati (Dewasa)'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // Hasil filter tampil
      expect(find.text('Ruang Melati (Dewasa)'), findsOneWidget);
      expect(find.text('Ruang Dahlia (Anak)'), findsOneWidget);
      expect(find.text('ICU Sentral'), findsNothing);

      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('admission banner renders contact and call action', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await _settleLoad(tester);

      expect(find.text('Admisi: (021) 552-3059'), findsOneWidget);
      expect(find.text('Panggil'), findsOneWidget);
      expect(
        find.text('SIIJAPIN • Layanan Rawat Inap RSUP Dr. Sitanala'),
        findsOneWidget,
      );

      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('retry button appears on repository error', (tester) async {
      final container = ProviderContainer(
        overrides: [
          bedAvailabilityRepositoryProvider.overrideWithValue(
            _FailingBedRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.text('Gagal Memuat Data Kamar'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}

/// Repository yang selalu gagal — untuk menguji state error + retry.
class _FailingBedRepository implements BedAvailabilityRepository {
  @override
  Future<BedAvailabilitySummary> getBedAvailability({
    String? classFilter,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    throw Exception('SIMRS tidak terjangkau');
  }

  @override
  Future<WardAvailability?> getWardById(String id) async => null;
}
