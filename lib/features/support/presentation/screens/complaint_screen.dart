import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Layar Form Aspirasi & Pengaduan Pasien — Epic 08 (`US-SUP-02`)
/// Rute: `/support/complaint`
///
/// Kebijakan Teknis Backend:
/// - Murni pemrosesan teks ke tabel `t_saran_pengaduan` (TIDAK ADA fitur upload gambar/foto).
/// - Menyediakan tombol kontak langsung nasional: **Halo Kemenkes 1500-567**.
class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // TODO(rekan): Hubungkan ke controller CI3 POST /Saran_Pengaduan/input_saran_pengaduan
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aspirasi/Pengaduan Anda telah berhasil dicatat. Terima kasih atas masukan Anda.',
          ),
          backgroundColor: AppColors.successEmerald,
        ),
      );
      _subjectController.clear();
      _descriptionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        title: const Text('Form Pengaduan Layanan'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Kartu Informasi Bantuan Kemenkes (US-SUP-02 Scenario 2)
              const AppCard.filled(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.headset_mic_rounded,
                      color: AppColors.brandDarkEspresso,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kanal Bantuan Resmi Kemenkes RI',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandDarkEspresso,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pengaduan layanan kesehatan nasional dapat disampaikan melalui Halo Kemenkes 1500-567 atau email kontak@kemkes.go.id.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Data Pengirim Pengaduan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
              const SizedBox(height: 12),

              // TODO(rekan): Nilai-nilai field ini dapat di-auto-populate dari profil akun pasien login
              AppTextField(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama pengirim',
                controller: _nameController,
                isRequired: true,
                prefixIcon: Icons.person_outline_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama pengirim wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'Nomor WhatsApp / HP',
                hint: 'Contoh: 081234567890',
                controller: _phoneController,
                isRequired: true,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nomor HP wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'Alamat Email',
                hint: 'Contoh: pasien@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'Alamat Tinggal',
                hint: 'Masukkan alamat domisili pengirim',
                controller: _addressController,
                prefixIcon: Icons.home_outlined,
              ),
              const SizedBox(height: 20),

              const Text(
                'Rincian Pengaduan / Masukan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'Perihal Pengaduan',
                hint: 'Contoh: Keluhan Waktu Tunggu Farmasi',
                controller: _subjectController,
                isRequired: true,
                prefixIcon: Icons.title_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Perihal pengaduan wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'Deskripsi Keluhan / Saran',
                hint: 'Jelaskan rincian kronologi, lokasi unit, atau masukan Anda secara jelas...',
                controller: _descriptionController,
                isRequired: true,
                maxLines: 5,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Deskripsi pengaduan wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              AppPrimaryButton(
                label: 'Kirim Pengaduan',
                isLoading: _isSubmitting,
                icon: Icons.send_rounded,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
