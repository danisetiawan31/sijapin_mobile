import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kontrak layanan pengatur kecerahan layar untuk scanner 2D APM (PRD FR-05.2 & FR-05.3)
abstract class IScreenBrightnessService {
  Future<void> setMaxBrightness();
  Future<void> resetBrightness();
}

/// Implementasi pengaturan kecerahan layar dengan platform channel Android/iOS.
/// Beroperasi secara aman (resilient) tanpa melempar unhandled exception pada
/// desktop, web, atau lingkungan pengujian widget/unit.
class ScreenBrightnessService implements IScreenBrightnessService {
  static const MethodChannel _channel = MethodChannel(
    'id.go.kemkes.sitanala.sijapin/brightness',
  );

  @override
  Future<void> setMaxBrightness() async {
    try {
      await _channel.invokeMethod<void>('setMaxBrightness');
    } on MissingPluginException {
      // Platform channel belum tersedia pada host lingkungan saat ini
    } catch (_) {
      // Cegah crash pada kegagalan non-kritis perangkat keras
    }
  }

  @override
  Future<void> resetBrightness() async {
    try {
      await _channel.invokeMethod<void>('resetBrightness');
    } on MissingPluginException {
      // Platform channel belum tersedia pada host lingkungan saat ini
    } catch (_) {
      // Cegah crash pada kegagalan non-kritis perangkat keras
    }
  }
}

/// Provider Riverpod untuk IScreenBrightnessService
final screenBrightnessServiceProvider = Provider<IScreenBrightnessService>((
  ref,
) {
  return ScreenBrightnessService();
});
