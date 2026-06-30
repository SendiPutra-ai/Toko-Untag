// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/local_storage_service.dart';
import '../utils/app_theme.dart';
import 'onboarding/onboarding_screen.dart';
import 'auth/login_screen.dart';
import 'main_screen.dart';

/// Splash screen sekaligus berfungsi sebagai "router" utama aplikasi.
/// Menggunakan ConsumerWidget agar bisa watch authStateProvider (Firebase)
/// secara real-time -- begitu Firebase selesai mengecek sesi tersimpan,
/// widget ini otomatis mengarahkan ke screen yang sesuai.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _minDelayPassed = false;

  @override
  void initState() {
    super.initState();
    // Delay minimal supaya splash tidak "berkedip" terlalu cepat
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _minDelayPassed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (firebaseUser) {
        if (!_minDelayPassed) return const _SplashVisual();

        // Cek onboarding dulu (FutureBuilder kecil karena ini operasi async)
        return FutureBuilder<bool>(
          future: LocalStorageService.hasSeenOnboarding(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const _SplashVisual();

            final seenOnboarding = snapshot.data!;
            if (!seenOnboarding) return const OnboardingScreen();
            if (firebaseUser == null) return const LoginScreen();
            return const MainScreen();
          },
        );
      },
      loading: () => const _SplashVisual(),
      error: (err, _) => const LoginScreen(),
    );
  }
}

class _SplashVisual extends StatelessWidget {
  const _SplashVisual();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.store_rounded,
                color: AppColors.primary,
                size: 58,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'TOKO ONLINE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const Text(
              'UNTAG',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Universitas 17 Agustus 1945 Surabaya',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
                color: AppColors.accent, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
