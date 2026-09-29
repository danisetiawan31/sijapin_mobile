import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_time.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_widgets.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _birthDate;
  String _gender = 'Laki-laki';
  bool _agreement = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final now = AppDateTime.now();
    final initialDate =
        _birthDate ?? AppDateTime.wibDateTime(now.year - 18, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: now,
      initialDate: initialDate,
      helpText: 'Pilih tanggal lahir',
    );
    if (selected == null) return;

    setState(() {
      _birthDate = selected;
      _birthDateController.text =
          '${selected.day.toString().padLeft(2, '0')}/${selected.month.toString().padLeft(2, '0')}/${selected.year}';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      _showMessage('Pilih tanggal lahir terlebih dahulu.');
      return;
    }
    if (!_agreement) {
      _showMessage(
        'Setujui ketentuan layanan dan kebijakan privasi untuk melanjutkan.',
      );
      return;
    }

    FocusScope.of(context).unfocus();
    await ref
        .read(authControllerProvider.notifier)
        .register(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          birthDate: _birthDate!,
          gender: _gender,
          password: _passwordController.text,
        );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (!mounted) return;
      if (next.status == AuthSubmissionStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran dummy berhasil. Silakan masuk.'),
          ),
        );
        context.go('/login');
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthSubmissionStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 36,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AuthBackButton(),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brandCreamLinen,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            '•  Pendaftaran Mandiri',
                            style: TextStyle(
                              color: AppColors.brandWarmBronze,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 4,
                          height: 34,
                          margin: const EdgeInsets.only(right: 10, top: 2),
                          decoration: BoxDecoration(
                            color: AppColors.brandGoldenCaramel,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Buat Akun Pasien',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Satu akun untuk seluruh kemudahan janji temu poliklinik dan pantau antrean RSUP Dr. Sitanala.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    AuthFormCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AuthTextField(
                              controller: _nameController,
                              label: 'Nama Lengkap Pasien *',
                              hint: 'Sesuai KTP',
                              icon: Icons.person_outline_rounded,
                              textInputAction: TextInputAction.next,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Masukkan nama lengkap.'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            AuthTextField(
                              controller: _phoneController,
                              label: 'Nomor WhatsApp / HP *',
                              hint: 'Masukkan nomor WhatsApp / HP',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Masukkan nomor WhatsApp / HP.'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            AuthTextField(
                              controller: _emailController,
                              label: 'Email Pasien',
                              hint: 'nama@email.com',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                if (!value.contains('@')) {
                                  return 'Format email belum benar.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            AuthTextField(
                              controller: _birthDateController,
                              label: 'Tanggal Lahir *',
                              hint: 'Pilih tanggal lahir (DD/MM/YYYY)',
                              icon: Icons.calendar_today_outlined,
                              readOnly: true,
                              onTap: _selectBirthDate,
                              suffixIcon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                              ),
                              validator: (_) => _birthDate == null
                                  ? 'Pilih tanggal lahir.'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Jenis Kelamin *',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 6),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment<String>(
                                  value: 'Laki-laki',
                                  icon: Icon(Icons.male_rounded),
                                  label: Text('Laki-laki'),
                                ),
                                ButtonSegment<String>(
                                  value: 'Perempuan',
                                  icon: Icon(Icons.female_rounded),
                                  label: Text('Perempuan'),
                                ),
                              ],
                              selected: {_gender},
                              onSelectionChanged: (selection) =>
                                  setState(() => _gender = selection.first),
                              showSelectedIcon: false,
                            ),
                            const SizedBox(height: 12),
                            AuthPasswordField(
                              controller: _passwordController,
                              label: 'Kata Sandi *',
                              hint: 'Masukkan kata sandi',
                              textInputAction: TextInputAction.next,
                              helperText: 'Kombinasi minimal 6 huruf dan angka',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan kata sandi.';
                                }
                                if (value.length < 6) {
                                  return 'Kata sandi minimal 6 karakter.';
                                }
                                if (!RegExp(r'(?=.*[A-Za-z])(?=.*\d)')
                                    .hasMatch(value)) {
                                  return 'Gunakan kombinasi huruf dan angka.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            AuthPasswordField(
                              controller: _confirmPasswordController,
                              label: 'Konfirmasi Kata Sandi *',
                              hint: 'Ulangi kata sandi',
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Konfirmasi kata sandi.';
                                }
                                if (value != _passwordController.text) {
                                  return 'Kata sandi belum sama.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Material(
                              color: AppColors.transparent,
                              child: CheckboxListTile(
                                value: _agreement,
                                onChanged: (value) =>
                                    setState(() => _agreement = value ?? false),
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                dense: true,
                                title: const Text(
                                  'Saya menyetujui Ketentuan Layanan & Kebijakan Privasi RSUP Dr. Sitanala',
                                ),
                              ),
                            ),

                            if (authState.status ==
                                    AuthSubmissionStatus.error &&
                                authState.message != null) ...[
                              const SizedBox(height: 4),
                              AuthStatusMessage(
                                message: authState.message!,
                                error: true,
                              ),
                              const SizedBox(height: 12),
                            ],
                            AuthPrimaryButton(
                              label: 'Daftar Akun Sekarang',
                              icon: Icons.arrow_forward_rounded,
                              loading: isLoading,
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text('Sudah punya akun? '),
                          TextButton(
                            onPressed: () => context.push('/login'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            child: const Text('Masuk di sini'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Center(
                      child: AuthSecurityBadge(
                        text: 'Data terlindungi sesuai UU PDP & Kemenkes RI',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
