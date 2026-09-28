import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/network/cookie_manager_service.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';

void main() {
  group('Network Riverpod Providers Test', () {
    test('dioClientProvider resolves properly with in-memory default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cookieManager = container.read(cookieManagerServiceProvider);
      expect(cookieManager, isA<CookieManagerService>());

      final dioClient = container.read(dioClientProvider);
      expect(dioClient, isA<DioClient>());
      expect(dioClient.cookieManagerService, equals(cookieManager));
    });

    test('cookieManagerServiceProvider can be overridden', () {
      final customCookieManager = CookieManagerService.inMemory();
      final container = ProviderContainer(
        overrides: [
          cookieManagerServiceProvider.overrideWithValue(customCookieManager),
        ],
      );
      addTearDown(container.dispose);

      final resolved = container.read(cookieManagerServiceProvider);
      expect(resolved, equals(customCookieManager));

      final dioClient = container.read(dioClientProvider);
      expect(dioClient.cookieManagerService, equals(customCookieManager));
    });
  });
}
