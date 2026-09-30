import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';

void main() {
  setUpAll(() {
    AppDateTime.initialize();
  });

  group('AppDateTime and Asia/Jakarta Timezone Tests', () {
    test('now() returns DateTime in Asia/Jakarta timezone', () {
      final nowWib = AppDateTime.now();
      expect(nowWib.timeZoneName, equals('WIB'));
      expect(nowWib.timeZoneOffset.inHours, equals(7));
      expect(AppDateTime.timeZoneName, equals('Asia/Jakarta'));
      expect(AppDateTime.timeZoneAbbr, equals('WIB'));
    });

    test('toWib converts UTC DateTime correctly to UTC+7', () {
      final utcTime = DateTime.utc(2026, 9, 29, 3, 0); // 03:00 UTC
      final wibTime = AppDateTime.toWib(utcTime);

      expect(wibTime.hour, equals(10)); // 10:00 WIB
      expect(wibTime.day, equals(29));
      expect(wibTime.timeZoneOffset.inHours, equals(7));
    });

    test('wibDateTime creates DateTime in Asia/Jakarta timezone', () {
      final customWib = AppDateTime.wibDateTime(2026, 10, 1, 8, 30);
      expect(customWib.year, equals(2026));
      expect(customWib.month, equals(10));
      expect(customWib.day, equals(1));
      expect(customWib.hour, equals(8));
      expect(customWib.minute, equals(30));
      expect(customWib.timeZoneOffset.inHours, equals(7));
    });

    test('DateFormatter normalizes UTC inputs to WIB correctly', () {
      // 23:30 UTC on 29 Sept is 06:30 WIB on 30 Sept
      final utcNight = DateTime.utc(2026, 9, 29, 23, 30);
      expect(DateFormatter.jamMenit(utcNight), equals('06:30'));
      expect(DateFormatter.jamMenitWib(utcNight), equals('06:30 WIB'));
      expect(
        DateFormatter.tanggalPanjang(utcNight),
        equals('30 September 2026'),
      );
      expect(
        DateFormatter.hariTanggalPanjang(utcNight),
        equals('Rabu, 30 September 2026'),
      );
    });

    test('DateFormatter.hariRelatif accurately uses WIB reference', () {
      final refWib = AppDateTime.wibDateTime(2026, 9, 29, 10, 0);
      final today = AppDateTime.wibDateTime(2026, 9, 29, 14, 0);
      final tomorrow = AppDateTime.wibDateTime(2026, 9, 30, 8, 30);

      expect(
        DateFormatter.hariRelatif(today, reference: refWib),
        equals('Hari ini'),
      );
      expect(
        DateFormatter.hariRelatif(tomorrow, reference: refWib),
        equals('Besok'),
      );
    });

    test('Appointment.cancelDeadline correctly sets H-1 at 23:59 WIB', () {
      final appointment = Appointment(
        bookingCode: '260930014221',
        queueNumber: 'MAT-014',
        patientName: 'Rhesa',
        doctorName: 'dr. Hendra',
        specialty: 'Mata',
        clinic: 'Poli Mata',
        scheduledDate: AppDateTime.wibDateTime(2026, 9, 30, 9, 30),
        scheduledTime: '09.30 WIB',
        estimatedMinutes: 15,
        nowServingNumber: 'MAT-011',
        remainingQueue: 3,
      );

      final deadline = appointment.cancelDeadline;
      expect(deadline.year, equals(2026));
      expect(deadline.month, equals(9));
      expect(deadline.day, equals(29));
      expect(deadline.hour, equals(AppConfig.cancellationDeadlineHour));
      expect(deadline.minute, equals(AppConfig.cancellationDeadlineMinute));
      expect(deadline.timeZoneOffset.inHours, equals(7));
    });

    test('Appointment.cancelDeadline handles month boundary correctly (e.g. Oct 1 -> Sep 30)', () {
      final appointment = Appointment(
        bookingCode: '261001014221',
        queueNumber: 'MAT-014',
        patientName: 'Rhesa',
        doctorName: 'dr. Hendra',
        specialty: 'Mata',
        clinic: 'Poli Mata',
        scheduledDate: AppDateTime.wibDateTime(2026, 10, 1, 9, 30),
        scheduledTime: '09.30 WIB',
        estimatedMinutes: 15,
        nowServingNumber: 'MAT-011',
        remainingQueue: 3,
      );

      final deadline = appointment.cancelDeadline;
      expect(deadline.year, equals(2026));
      expect(deadline.month, equals(9));
      expect(deadline.day, equals(30));
      expect(deadline.hour, equals(23));
      expect(deadline.minute, equals(59));
    });
  });
}
