import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/biometrics/biometric_auth_service.dart';
import '../../../../core/biometrics/biometric_controller.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/passcode/passcode_controller.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

/// Layar inisial awal (Splash Screen) aplikasi SIIJAPIN Mobile.
///
/// Saat `Kunci Biometrik` aktif, setelah tampilan branding selesai aplikasi
/// memunculkan dialog biometrik sistem (Sidik Jari / Face ID) sebelum berpindah
/// ke beranda. Bila biometrik gagal/dibatalkan dan user sudah membuat
/// `Kode Kunci (PIN)`, user dapat membuka aplikasi dengan memasukkan PIN.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({
    super.key,
    this.delay = const Duration(milliseconds: 1200),
    this.autoRedirect = true,
  });

  /// Durasi tampilan branding sebelum transisi ke beranda
  final Duration delay;

  /// Flag pengaktifan auto-redirect (dapat dinonaktifkan untuk pengujian unit/widget)
  final bool autoRedirect;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _navigationTimer;
  bool _checkingBiometric = false;
  bool _authFailed = false;
  bool _pinEntry = false;
  bool _pinBusy = false;
  bool _hasPasscode = false;
  String? _pinError;

  @override
  void initState() {
    super.initState();

    if (widget.autoRedirect) {
      _navigationTimer = Timer(widget.delay, _finalizeStartup);
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  /// Menentukan alur setelah branding: lewati bila biometrik nonaktif, atau
  /// minta autentikasi biometrik sistem bila `Kunci Biometrik` aktif.
  Future<void> _finalizeStartup() async {
    if (!mounted) return;

    bool biometricEnabled = false;
    bool hasPasscode = false;
    try {
      biometricEnabled = await ref.read(biometricEnabledProvider.future);
    } catch (_) {
      biometricEnabled = false;
    }
    try {
      hasPasscode = await ref.read(passcodeEnabledProvider.future);
    } catch (_) {
      hasPasscode = false;
    }
    _hasPasscode = hasPasscode;

    if (!biometricEnabled) {
      if (mounted) context.go(AppRoutes.homePath);
      return;
    }

    setState(() {
      _checkingBiometric = true;
      _authFailed = false;
      _pinEntry = false;
      _pinError = null;
    });

    final bool ok = await ref
        .read(biometricAuthServiceProvider)
        .authenticate(reason: 'Buka Kunci Biometrik untuk masuk ke Aplikasi');

    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.homePath);
    } else {
      setState(() {
        _checkingBiometric = false;
        _pinEntry = _hasPasscode;
        _authFailed = !_hasPasscode;
      });
    }
  }

  /// Memverifikasi Kode Kunci (PIN) sebagai pengganti biometrik yang gagal.
  Future<void> _unlockWithPasscode(String pin) async {
    if (_pinBusy) return;
    setState(() {
      _pinBusy = true;
      _pinError = null;
    });

    final bool ok = await ref
        .read(passcodeControllerProvider.notifier)
        .verifyPasscode(pin);

    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.homePath);
      return;
    }
    setState(() {
      _pinBusy = false;
      _pinError = 'Kode Kunci salah. Silakan coba lagi.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_hospital_rounded,
                  size: 72,
                  color: AppColors.brandWarmBronze,
                ),
                const SizedBox(height: 16),
                Text(
                  AppConfig.appName,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text('RSUP Dr. Sitanala Tangerang'),
                const SizedBox(height: 24),
                if (_checkingBiometric) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  const Text('Memverifikasi biometrik...'),
                ] else if (_pinEntry) ...[
                  _PasscodeEntry(
                    busy: _pinBusy,
                    error: _pinError,
                    onSubmit: _unlockWithPasscode,
                    onRetryBiometric: _finalizeStartup,
                  ),
                ] else if (_authFailed) ...[
                  const Icon(
                    Icons.fingerprint_rounded,
                    size: 56,
                    color: AppColors.brandGoldenCaramel,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Autentikasi biometrik gagal atau dibatalkan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandDarkEspresso,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gunakan Sidik Jari / Face ID perangkat Anda untuk membuka aplikasi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _finalizeStartup,
                    icon: const Icon(Icons.lock_open_rounded, size: 18),
                    label: const Text('Coba Lagi'),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => context.go(AppRoutes.homePath),
                    icon: const Icon(Icons.home_outlined, size: 18),
                    label: const Text(
                      'Lanjut ke Beranda (Akses Tiket Offline)',
                    ),
                  ),
                ] else ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  const Text('Memuat aplikasi...'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Form masukan Kode Kunci (PIN) via keypad angka saat biometrik gagal.
class _PasscodeEntry extends StatefulWidget {
  const _PasscodeEntry({
    required this.busy,
    required this.error,
    required this.onSubmit,
    required this.onRetryBiometric,
  });

  final bool busy;
  final String? error;
  final Future<void> Function(String pin) onSubmit;
  final VoidCallback onRetryBiometric;

  @override
  State<_PasscodeEntry> createState() => _PasscodeEntryState();
}

class _PasscodeEntryState extends State<_PasscodeEntry> {
  String _digits = '';

  bool get _canSubmit =>
      _digits.length >= PasscodeController.minLength &&
      _digits.length <= PasscodeController.maxLength;

  void _addDigit(String digit) {
    if (widget.busy || _digits.length >= PasscodeController.maxLength) return;
    setState(() => _digits += digit);
    if (_digits.length == PasscodeController.maxLength) {
      _submit();
    }
  }

  void _backspace() {
    if (widget.busy || _digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  Future<void> _submit() async {
    if (widget.busy || !_canSubmit) return;
    await widget.onSubmit(_digits);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Masukkan Kode Kunci',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.brandDarkEspresso,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Biometrik ditolak. Masukkan Kode Kunci (PIN) '
          'yang dibuat di menu Profil.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        _buildDots(context),
        if (widget.error != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.dangerCrimson,
            ),
          ),
        ],
        const SizedBox(height: 20),
        _buildKeypad(context),
        const SizedBox(height: 16),
        TextButton(
          key: const ValueKey('splash-passcode-retry-biometric'),
          onPressed: widget.busy ? null : widget.onRetryBiometric,
          child: const Text('Gunakan biometrik'),
        ),
        TextButton.icon(
          key: const ValueKey('splash-passcode-escape-home'),
          onPressed: widget.busy ? null : () => context.go(AppRoutes.homePath),
          icon: const Icon(Icons.home_outlined, size: 16),
          label: const Text('Lupa PIN? Buka Beranda / Tiket'),
        ),
      ],
    );
  }

  Widget _buildDots(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(PasscodeController.maxLength, (int index) {
        final bool filled = index < _digits.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 14,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? AppColors.brandDarkEspresso
                : AppColors.borderSubtle,
            border: filled ? null : Border.all(color: AppColors.brandSoftSand),
          ),
        );
      }),
    );
  }

  Widget _buildKeypad(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildKeyRow(const ['1', '2', '3']),
        _buildKeyRow(const ['4', '5', '6']),
        _buildKeyRow(const ['7', '8', '9']),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _KeypadButton(
              key: const ValueKey('splash-pad-backspace'),
              icon: Icons.backspace_outlined,
              type: _KeypadButtonType.utility,
              onTap: _backspace,
            ),
            _KeypadButton(
              key: const ValueKey('splash-pad-0'),
              label: '0',
              onTap: () => _addDigit('0'),
            ),
            _KeypadButton(
              key: const ValueKey('splash-pad-ok'),
              label: 'Buka',
              icon: Icons.lock_open_rounded,
              type: _KeypadButtonType.submit,
              enabled: _canSubmit && !widget.busy,
              onTap: _submit,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys
          .map(
            (String digit) => _KeypadButton(
              key: ValueKey('splash-pad-$digit'),
              label: digit,
              onTap: () => _addDigit(digit),
            ),
          )
          .toList(),
    );
  }
}

enum _KeypadButtonType { number, utility, submit }

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    super.key,
    this.label,
    this.icon,
    this.enabled = true,
    this.type = _KeypadButtonType.number,
    required this.onTap,
  });

  final String? label;
  final IconData? icon;
  final bool enabled;
  final _KeypadButtonType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = switch (type) {
      _KeypadButtonType.submit => AppColors.white,
      _KeypadButtonType.utility => AppColors.brandWarmBronze,
      _KeypadButtonType.number => AppColors.brandDarkEspresso,
    };
    final Color background = switch (type) {
      _KeypadButtonType.submit => AppColors.brandGoldenCaramel,
      _ => AppColors.surfaceCard,
    };

    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        width: 68,
        height: 58,
        child: Material(
          color: enabled ? background : background.withValues(alpha: 0.5),
          shape: const StadiumBorder(),
          elevation: type == _KeypadButtonType.submit ? 0 : 1,
          shadowColor: AppColors.shadowWarm,
          child: InkWell(
            onTap: enabled ? onTap : null,
            customBorder: const StadiumBorder(),
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 22, color: foreground)
                  : Text(
                      label ?? '',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: foreground,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
