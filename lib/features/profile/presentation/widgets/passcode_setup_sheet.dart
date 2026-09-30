import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/passcode/passcode_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Membuka bottom sheet pengaturan Kode Kunci (PIN) fallback biometrik.
///
/// Mengembalikan `true` bila ada perubahan (dibuat/diubah/dihapus).
Future<bool> showPasscodeSetupSheet(
  BuildContext context, {
  required PasscodeController controller,
  required bool hasPasscode,
}) async {
  final bool? changed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _PasscodeSetupSheet(
          controller: controller,
          hasPasscode: hasPasscode,
        ),
      );
    },
  );
  return changed == true;
}

class _PasscodeSetupSheet extends StatefulWidget {
  const _PasscodeSetupSheet({
    required this.controller,
    required this.hasPasscode,
  });

  final PasscodeController controller;
  final bool hasPasscode;

  @override
  State<_PasscodeSetupSheet> createState() => _PasscodeSetupSheetState();
}

enum _PasscodeMode { create, manage, change }

class _PasscodeSetupSheetState extends State<_PasscodeSetupSheet> {
  late _PasscodeMode _mode;
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mode = widget.hasPasscode ? _PasscodeMode.manage : _PasscodeMode.create;
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String pin = _pinController.text;
    final String confirm = _confirmController.text;

    if (pin.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Kode Kunci wajib diisi.');
      return;
    }
    if (pin.length < PasscodeController.minLength ||
        pin.length > PasscodeController.maxLength) {
      setState(
        () => _error =
            'Kode Kunci harus berupa ${PasscodeController.minLength}-'
            '${PasscodeController.maxLength} digit angka.',
      );
      return;
    }
    if (pin != confirm) {
      setState(() => _error = 'Kode Kunci tidak sama dengan ulangan.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    final bool ok = await widget.controller.setPasscode(pin);
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _busy = false;
        _error = 'Gagal menyimpan Kode Kunci. Coba lagi.';
      });
    }
  }

  Future<void> _remove() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Hapus Kode Kunci?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.brandDarkEspresso,
            ),
          ),
          content: const Text(
            'Kode Kunci tidak lagi diminta saat biometrik gagal. '
            'Jika biometrik juga dinonaktifkan, aplikasi langsung terbuka.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.dangerCrimson,
                minimumSize: const Size(110, 48),
                shape: const StadiumBorder(),
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    await widget.controller.disablePasscode();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            if (_mode == _PasscodeMode.manage) ...[
              _buildManageActions(),
            ] else ...[
              _buildPinFields(),
              if (_error != null) _buildError(_error!),
              const SizedBox(height: 16),
              AppPrimaryButton(
                key: const ValueKey('passcode-save-button'),
                label: _mode == _PasscodeMode.change
                    ? 'Simpan Perubahan'
                    : 'Simpan Kode Kunci',
                icon: Icons.lock_outline_rounded,
                isLoading: _busy,
                onPressed: _busy ? null : _save,
              ),
              if (_mode == _PasscodeMode.change) ...[
                const SizedBox(height: 8),
                TextButton(
                  key: const ValueKey('passcode-cancel-change-button'),
                  onPressed: () {
                    setState(() {
                      _mode = _PasscodeMode.manage;
                      _error = null;
                      _pinController.clear();
                      _confirmController.clear();
                    });
                  },
                  child: const Text('Batal'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Icon(Icons.pin_rounded, size: 40, color: AppColors.brandGoldenCaramel),
        SizedBox(height: 8),
        Text(
          'Kode Kunci (PIN)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.brandDarkEspresso,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Diperlukan saat biometrik gagal atau dibatalkan. '
          'Gunakan 4-6 digit angka.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildManageActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSecondaryButton(
          key: const ValueKey('passcode-change-button'),
          label: 'Ubah Kode Kunci',
          icon: Icons.edit_rounded,
          onPressed: () => setState(() {
            _mode = _PasscodeMode.change;
            _error = null;
          }),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            key: const ValueKey('passcode-remove-button'),
            onPressed: _busy ? null : _remove,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.dangerCrimson,
              side: const BorderSide(color: AppColors.dangerCrimson),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Hapus Kode Kunci'),
          ),
        ),
      ],
    );
  }

  Widget _buildPinFields() {
    final List<TextInputFormatter> digitsOnly = [
      FilteringTextInputFormatter.digitsOnly,
    ];
    return Column(
      children: [
        AppTextField(
          key: const ValueKey('passcode-pin-field'),
          controller: _pinController,
          label: _mode == _PasscodeMode.change
              ? 'Kode Kunci Baru'
              : 'Kode Kunci',
          hint: '4-6 digit angka',
          isRequired: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: digitsOnly,
          maxLength: PasscodeController.maxLength,
        ),
        const SizedBox(height: 8),
        AppTextField(
          key: const ValueKey('passcode-confirm-field'),
          controller: _confirmController,
          label: 'Ulangi Kode Kunci',
          hint: 'Ketik ulang kode kunci',
          isRequired: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: digitsOnly,
          maxLength: PasscodeController.maxLength,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message,
        style: const TextStyle(fontSize: 12, color: AppColors.dangerCrimson),
      ),
    );
  }
}
