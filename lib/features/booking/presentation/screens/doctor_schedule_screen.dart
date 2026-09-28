import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Tab 3: Jadwal Dokter Spesialis & Poliklinik
class DoctorScheduleScreen extends StatelessWidget {
  const DoctorScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(title: const Text('Jadwal Dokter'), centerTitle: false),
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 64,
                color: AppColors.brandGoldenCaramel,
              ),
              SizedBox(height: 16),
              Text(
                'Jadwal Praktik Poliklinik',
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
