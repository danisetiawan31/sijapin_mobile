import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';

void main() {
  setUpAll(() {
    AppDateTime.initialize();
  });

  group('AppDateTime and Asia/Jakarta Timezone Tests', () {
    test('now() returns DateTime in Asia/Jakarta timezone', () {
      final nowWib = AppDateTime.now();
      expect(nowWib.timeZoneName, equals('WIB'));
      expect(nowWib.timeZoneOffset.inHours, equals(7));
    });

    test('toWib converts UTC DateTime correctly to UTC+7', () {
      final utcTime = DateTime.utc(2026, 9, 29, 3, 0); // 03:00 UTC
      final wibTime = AppDateTime.toWib(utcTime);

      expect(wibTime.hour, equals(10)); // 10:00 WIB
      expect(wibTime.day, equals(29));
      expect(wibTime.timeZoneOffset.inHours, equals(7));
    });

    test('DateFormatter.hariRelatif accurately uses WIB reference', () {
      final refWib = DateTime(2026, 9, 29, 10, 0);
      final today = DateTime(2026, 9, 29, 14, 0);
      final tomorrow = DateTime(2026, 9, 30, 8, 30);

      expect(DateFormatter.hariRelatif(today, reference: refWib), equals('Hari ini'));
      expect(DateFormatter.hariRelatif(tomorrow, reference: refWib), equals('Besok'));
    });
  });
}
