import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/core/widgets/app_button.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';

/// Modal bottom sheet formulir pendaftaran anggota keluarga baru.
class AddFamilyMemberSheet extends StatefulWidget {
  const AddFamilyMemberSheet({super.key, required this.onSave});

  final ValueChanged<FamilyMember> onSave;

  /// Menampilkan lembar formulir tambah anggota keluarga.
  static Future<void> show(
    BuildContext context, {
    required ValueChanged<FamilyMember> onSave,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.brandDarkEspresso.withValues(alpha: 0.45),
      builder: (BuildContext sheetContext) {
        return AddFamilyMemberSheet(onSave: onSave);
      },
    );
  }

  @override
  State<AddFamilyMemberSheet> createState() => _AddFamilyMemberSheetState();
}

class _AddFamilyMemberSheetState extends State<AddFamilyMemberSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bpjsController = TextEditingController();
  final TextEditingController _rmController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();

  FamilyRelation _relation = FamilyRelation.child;
  String _gender = 'L';
  String _religion = '1';
  FamilyInsurance _insurance = FamilyInsurance.bpjs;
  DateTime? _birthDate;

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _phoneController.dispose();
    _bpjsController.dispose();
    _rmController.dispose();
    _birthPlaceController.dispose();
    _motherNameController.dispose();
    _addressController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final DateTime now = DateTime.now();
    final DateTime initial = _birthDate ?? DateTime(2000, 1, 1);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'PILIH TANGGAL LAHIR',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final FamilyMember newMember = FamilyMember(
      id: 'keluarga-${DateTime.now().millisecondsSinceEpoch}',
      fullName: _nameController.text.trim(),
      relation: _relation,
      gender: _gender,
      nik: _nikController.text.trim(),
      medicalRecordNumber: _rmController.text.trim().isNotEmpty
          ? _rmController.text.trim()
          : null,
      birthPlace: _birthPlaceController.text.trim(),
      motherName: _motherNameController.text.trim(),
      address: _addressController.text.trim(),
      religion: _religion,
      occupation: _occupationController.text.trim(),
      insurance: _insurance,
      insuranceNumber:
          _insurance == FamilyInsurance.bpjs &&
              _bpjsController.text.trim().isNotEmpty
          ? _bpjsController.text.trim()
          : null,
      phone: _phoneController.text.trim(),
      birthDate: _birthDate,
    );

    widget.onSave(newMember);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tambah Anggota Keluarga',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandDarkEspresso,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Masukkan data sesuai KTP atau Kartu Keluarga resmi.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap *',
                    hintText: 'Contoh: Ahmad Fauzi',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama lengkap wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nikController,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  decoration: const InputDecoration(
                    labelText: 'NIK (16 Digit) *',
                    hintText: '367104xxxxxxxxxx',
                    counterText: '',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'NIK wajib diisi';
                    }
                    if (value.trim().length != 16) {
                      return 'NIK harus 16 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickBirthDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Lahir',
                      hintText: 'Pilih tanggal lahir',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      suffixIcon: Icon(Icons.calendar_month_outlined),
                    ),
                    child: Text(
                      _birthDate != null
                          ? DateFormatter.tanggalPanjang(_birthDate!)
                          : 'Pilih tanggal lahir',
                      style: TextStyle(
                        fontSize: 14,
                        color: _birthDate != null
                            ? AppColors.brandDarkEspresso
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _birthPlaceController,
                  decoration: const InputDecoration(
                    labelText: 'Tempat Lahir',
                    hintText: 'Contoh: Tangerang',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<FamilyRelation>(
                        initialValue: _relation,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Hubungan',
                        ),
                        items: FamilyRelation.values
                            .map(
                              (FamilyRelation r) =>
                                  DropdownMenuItem<FamilyRelation>(
                                    value: r,
                                    child: Text(r.label),
                                  ),
                            )
                            .toList(),
                        onChanged: (FamilyRelation? value) {
                          if (value != null) setState(() => _relation = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _gender,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Kelamin',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'L',
                            child: Text('Laki-laki'),
                          ),
                          DropdownMenuItem(
                            value: 'P',
                            child: Text('Perempuan'),
                          ),
                        ],
                        onChanged: (String? value) {
                          if (value != null) setState(() => _gender = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _religion,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Agama'),
                        items: const [
                          DropdownMenuItem(value: '1', child: Text('Islam')),
                          DropdownMenuItem(value: '2', child: Text('Kristen')),
                          DropdownMenuItem(value: '3', child: Text('Katolik')),
                          DropdownMenuItem(value: '4', child: Text('Hindu')),
                          DropdownMenuItem(value: '5', child: Text('Buddha')),
                          DropdownMenuItem(value: '6', child: Text('Konghucu')),
                        ],
                        onChanged: (String? value) {
                          if (value != null) setState(() => _religion = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _occupationController,
                        decoration: const InputDecoration(
                          labelText: 'Pekerjaan',
                          hintText: 'Contoh: Karyawan',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<FamilyInsurance>(
                        initialValue: _insurance,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Jaminan'),
                        items: FamilyInsurance.values
                            .map(
                              (FamilyInsurance ins) =>
                                  DropdownMenuItem<FamilyInsurance>(
                                    value: ins,
                                    child: Text(ins.label),
                                  ),
                            )
                            .toList(),
                        onChanged: (FamilyInsurance? value) {
                          if (value != null) setState(() => _insurance = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _rmController,
                        decoration: const InputDecoration(
                          labelText: 'No. RM (Opsional)',
                          hintText: 'Pasien lama',
                        ),
                      ),
                    ),
                  ],
                ),
                if (_insurance == FamilyInsurance.bpjs) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bpjsController,
                    keyboardType: TextInputType.number,
                    maxLength: 13,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Kartu BPJS (13 Digit)',
                      hintText: '0001xxxxxxxx',
                      counterText: '',
                      prefixIcon: Icon(Icons.credit_card_outlined),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _motherNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Ibu Kandung',
                    hintText: 'Contoh: Siti Maryam',
                    helperText:
                        'Wajib diisi jika pasien baru (belum ada No. RM)',
                    prefixIcon: Icon(Icons.family_restroom_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Domisili',
                    hintText: 'Alamat lengkap sesuai KTP/KK',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor WhatsApp / HP',
                    hintText: '0812xxxxxxxx',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                AppPrimaryButton(
                  label: 'Simpan Anggota',
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
