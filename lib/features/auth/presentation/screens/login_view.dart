import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_widgets.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref
        .read(authControllerProvider.notifier)
        .login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
          rememberMe: _rememberMe,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (!mounted) return;
      if (next.status == AuthSubmissionStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.message ?? 'Berhasil masuk ke layanan SIIJAPIN.',
            ),
          ),
        );
        context.go('/profile');
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
                    const AuthBackButton(),
                    const SizedBox(height: 16),
                    Text(
                      'Selamat Datang',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Masuk untuk mendaftar poliklinik, memantau antrean live, dan mengelola rekam medis keluarga.',
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
                              controller: _identifierController,
                              label: 'Nomor Telepon / Email',
                              hint: 'Contoh: 081234567890 atau email@domain.com',
                              icon: Icons.person_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                final trimmed = value?.trim() ?? '';
                                if (trimmed.isEmpty) {
                                  return 'Masukkan nomor telepon atau email terdaftar.';
                                }
                                if (trimmed.contains('@')) {
                                  if (!trimmed.contains('.') ||
                                      trimmed.length < 5) {
                                    return 'Format email belum benar.';
                                  }
                                  return null;
                                }
                                final digitsOnly = trimmed.replaceAll(
                                  RegExp(r'\D'),
                                  '',
                                );
                                if (digitsOnly.length < 10 ||
                                    digitsOnly.length > 15) {
                                  return 'Nomor telepon harus 10–15 digit angka.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            AuthPasswordField(
                              controller: _passwordController,
                              label: 'Kata Sandi',
                              hint: 'Masukkan kata sandi',
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan kata sandi.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Material(
                                    color: AppColors.transparent,
                                    child: CheckboxListTile(
                                      value: _rememberMe,
                                      onChanged: (value) => setState(
                                        () => _rememberMe = value ?? false,
                                      ),
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      title: const Text('Ingat Saya'),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('Lupa Kata Sandi?'),
                                ),
                              ],
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
                              label: 'Masuk ke Akun',
                              icon: Icons.arrow_forward_rounded,
                              loading: isLoading,
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text('Belum memiliki akun? '),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            child: const Text('Daftar di sini'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Center(
                      child: AuthSecurityBadge(
                        text: 'Data terenkripsi standar keamanan Kemenkes RI',
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
