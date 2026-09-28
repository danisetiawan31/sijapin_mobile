import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Tab 2: Janji Temu (Tiket Aktif & Riwayat Kunjungan)
class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(title: const Text('Janji Temu'), centerTitle: false),
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.confirmation_number_rounded,
                size: 64,
                color: AppColors.brandGoldenCaramel,
              ),
              SizedBox(height: 16),
              Text(
                'Tiket & Janji Temu Pasien',
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
