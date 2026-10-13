import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_response.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/datasources/feedback_remote_data_source.dart';

/// Layar Form Aspirasi & Pengaduan Pasien — Epic 08 (`US-SUP-02`)
/// Rute: `/support/complaint`
///
/// Kebijakan Teknis Backend:
/// - Murni pemrosesan teks ke tabel `t_saran_pengaduan` (TIDAK ADA fitur upload gambar/foto).
/// - Menyediakan tombol kontak langsung nasional: **Halo Kemenkes 1500-567**.
/// - REST authority (PANDUAN §7): prefill `GET /Saran_Pengaduan`, submit
///   `POST /Saran_Pengaduan/input_saran_pengaduan` + `Accept: application/json`.
class ComplaintScreen extends ConsumerStatefulWidget {
  const ComplaintScreen({super.key});

  @override
  ConsumerState<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends ConsumerState<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isSubmitting = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _loadPrefill();
  }

  Future<void> _loadPrefill() async {
    try {
      final prefill = await ref
          .read(feedbackRemoteDataSourceProvider)
          .fetchPrefill();
      if (!mounted || _prefilled) return;
      _prefilled = true;
      final String name = (prefill['nama'] ?? '').toString();
      final String phone =
          (prefill['no_contact'] ?? prefill['nomor_telepon'] ?? '').toString();
      final String email = (prefill['email'] ?? '').toString();
      if (name.isNotEmpty) _nameController.text = name;
      if (phone.isNotEmpty) _phoneController.text = phone;
      if (email.isNotEmpty) _emailController.text = email;
      setState(() {});
    } catch (_) {
      // Prefill opsional: biarkan pengguna mengisi manual saat offline.
    }
  }

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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final result = await ref
          .read(feedbackRemoteDataSourceProvider)
          .submitFeedback(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            address: _addressController.text.trim(),
            subject: _subjectController.text.trim(),
            description: _descriptionController.text.trim(),
          );
      if (!mounted) return;
      final bool ok = result['ret']?.toString() == 'success';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? (result['msg']?.toString().isNotEmpty ?? false
                      ? result['msg'].toString()
                      : 'Aspirasi/Pengaduan Anda telah berhasil dicatat. Terima kasih atas masukan Anda.')
                : (result['msg']?.toString() ?? 'Gagal mengirim pengaduan.'),
          ),
          backgroundColor: ok
              ? AppColors.successEmerald
              : AppColors.dangerCrimson,
        ),
      );
      if (ok) {
        _subjectController.clear();
        _descriptionController.clear();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.dangerCrimson,
        ),
      );
    } on DioException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak terhubung ke server. Periksa koneksi internet Anda.',
          ),
          backgroundColor: AppColors.dangerCrimson,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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

              // Identitas terisi otomatis dari `GET /Saran_Pengaduan` saat online.
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
