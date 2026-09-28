import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Layar Autentikasi / Masuk Pasien
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(title: const Text('Masuk')),
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: AppColors.brandGoldenCaramel,
              ),
              SizedBox(height: 16),
              Text(
                'Layar Masuk Akun SIIJAPIN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
