import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../config/app_config.dart';
import '../theme/app_colors.dart';

/// Router aplikasi terpusat agar feature screen tidak saling bergantung.
class AppRouter {
  const AppRouter._();

  static GoRouter create() {
    return GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
        GoRoute(path: '/home', builder: (_, _) => const HomePlaceholderScreen()),
        GoRoute(path: '/profile', builder: (_, _) => const ProfilePlaceholderScreen()),
        GoRoute(path: '/login', builder: (_, _) => const LoginView()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterView()),
      ],
      errorBuilder: (_, _) => const RouteNotFoundScreen(),
      observers: [SentryNavigatorObserver()],
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_hospital_rounded,
                  size: 72,
                  color: AppColors.brandWarmBronze,
                ),
                const SizedBox(height: 16),
                Text(
                  AppConfig.appName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('RSUP Dr. Sitanala Tangerang'),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Lanjut ke Aplikasi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _IntegrationPlaceholder(
      title: 'Home',
      message: 'Placeholder integrasi — implementasi Home dikerjakan oleh tim terkait.',
      actions: [
        FilledButton(
          onPressed: () => context.go('/profile'),
          child: const Text('Buka Profile'),
        ),
        OutlinedButton(
          onPressed: () => context.push('/login'),
          child: const Text('Uji Login'),
        ),
      ],
    );
  }
}

class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _IntegrationPlaceholder(
      title: 'Profile',
      message: 'Placeholder integrasi — implementasi Profile dikerjakan oleh tim terkait.',
      actions: [
        FilledButton(
          onPressed: () => context.go('/login'),
          child: const Text('Masuk ke Akun'),
        ),
        OutlinedButton(
          onPressed: () => context.go('/register'),
          child: const Text('Daftar Akun'),
        ),
      ],
    );
  }
}

class _IntegrationPlaceholder extends StatelessWidget {
  final String title;
  final String message;
  final List<Widget> actions;

  const _IntegrationPlaceholder({
    required this.title,
    required this.message,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_outlined, size: 48),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ...actions.map(
                (action) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(width: double.infinity, child: action),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RouteNotFoundScreen extends StatelessWidget {
  const RouteNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Halaman tidak ditemukan.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('Kembali ke Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
