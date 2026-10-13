import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/network/server_status_controller.dart';
import 'package:sijapin_mobile/core/widgets/offline_banner.dart';

class _FakeStatusController extends ServerStatusController {
  _FakeStatusController(this.initial);

  final ServerStatus initial;
  int refreshCalls = 0;

  @override
  ServerStatus build() => initial;

  @override
  Future<void> refresh() async {
    refreshCalls++;
  }
}

Future<void> _pumpBanner(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(body: Column(children: [OfflineBanner()])),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('OfflineBanner', () {
    testWidgets('hidden when server online', (tester) async {
      final ProviderContainer container = ProviderContainer(
        overrides: [
          serverStatusProvider.overrideWith(
            () => _FakeStatusController(ServerStatus.online),
          ),
        ],
      );
      addTearDown(container.dispose);
      await _pumpBanner(tester, container);

      expect(find.textContaining('Tidak dapat menjangkau'), findsNothing);
    });

    testWidgets('shows message and working retry when offline', (tester) async {
      final _FakeStatusController fake = _FakeStatusController(
        ServerStatus.offline,
      );
      final ProviderContainer container = ProviderContainer(
        overrides: [serverStatusProvider.overrideWith(() => fake)],
      );
      addTearDown(container.dispose);
      await _pumpBanner(tester, container);

      expect(find.textContaining('Tidak dapat menjangkau'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);

      await tester.tap(find.text('Coba lagi'));
      await tester.pump();

      expect(fake.refreshCalls, 1);
    });
  });
}
