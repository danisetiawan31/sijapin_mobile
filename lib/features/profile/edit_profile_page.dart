import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_date_picker.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/states.dart';
import '../../data/models/app_user.dart';
import '../../state/auth_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _nik;
  late final TextEditingController _address;

  String? _gender;
  String _blood = 'O';
  DateTime? _birthDate;
  bool _saving = false;

  static const List<String> _bloodTypes = <String>['A', 'B', 'AB', 'O'];

  @override
  void initState() {
    super.initState();
    final AppUser? u = context.read<AuthProvider>().user;
    _name = TextEditingController(text: u?.fullName ?? '');
    _phone = TextEditingController(text: V.formatPhone(u?.phone));
    _nik = TextEditingController(text: u?.nik ?? '');
    _address = TextEditingController(text: u?.address ?? '');
    _gender = u?.gender;
    _blood = (u?.bloodType != null && u!.bloodType!.isNotEmpty)
        ? u.bloodType!
        : 'O';
    _birthDate = u?.birthDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _nik.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await AppDatePicker.pickBirthDate(
      context,
      initialDate: _birthDate,
    );
    if (picked != null && mounted) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final AuthProvider auth = context.read<AuthProvider>();
    final bool ok = await auth.updateProfile(
      auth.user!.copyWith(
        fullName: _name.text.trim(),
        phone: V.digitsOnly(_phone.text),
        nik: V.digitsOnly(_nik.text),
        birthDate: _birthDate,
        gender: _gender,
        bloodType: _blood,
        address: _address.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.of(context).pop();
      AppSnack.show(context, 'Profil berhasil diperbarui', success: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    final AppUser? user = context.watch<AuthProvider>().user;
    if (user == null) return const Scaffold(body: LoadingView());

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxxl,
          ),
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  UserAvatar(name: user.fullName, size: 84),
                  const SizedBox(height: AppSpacing.md),
                  Text(user.fullName, style: t.titleMedium),
                  Text(user.email, style: t.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nama lengkap',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: V.name,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(15),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Nomor HP',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (String? v) =>
                        v == null || v.isEmpty ? null : V.phone(v),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _nik,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'NIK',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (String? v) =>
                        v == null || v.isEmpty ? null : V.nik(v),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal lahir',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              _birthDate == null
                                  ? 'Belum diisi'
                                  : Fmt.dateSlash(_birthDate!),
                              style: _birthDate == null
                                  ? t.bodyMedium
                                  : t.titleSmall,
                            ),
                          ),
                          if (user.birthDate != null)
                            Text(
                              '${user.age} tahun',
                              style: t.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _GenderButton(
                          label: 'Laki-laki',
                          selected: _gender == 'L',
                          icon: Icons.male_rounded,
                          onTap: () => setState(() => _gender = 'L'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _GenderButton(
                          label: 'Perempuan',
                          selected: _gender == 'P',
                          icon: Icons.female_rounded,
                          onTap: () => setState(() => _gender = 'P'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Golongan darah', style: t.bodySmall),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: _bloodTypes
                        .map(
                          (String b) => SoftChip(
                            label: b,
                            selected: _blood == b,
                            color: AppColors.danger,
                            onTap: () => setState(() => _blood = b),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _address,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Alamat',
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 56),
                        child: Icon(Icons.location_on_outlined),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  const _GenderButton({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryContainer : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 18,
                color: selected ? AppColors.primary : AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: selected ? w700 : w500,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
