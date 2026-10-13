import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/medical_record_controller.dart';

void main() {
  group('medicalRecordProvider', () {
    test('returns empty list until a records endpoint exists', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(medicalRecordProvider), isEmpty);
    });
  });
}
