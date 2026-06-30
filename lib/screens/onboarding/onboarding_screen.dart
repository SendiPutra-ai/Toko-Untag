// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../services/local_storage_service.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';

class OnboardingData {
  final String emoji;
  final String title;
  final String subtitle;
  final Color bgColor;

  const OnboardingData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bgColor,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = const [
    OnboardingData(
      emoji: '🛍️',
      title: 'Belanja Ribuan Produk',
      subtitle:
          'Temukan produk fashion, elektronik, perhiasan, dan banyak lagi dengan harga terbaik langsung dari genggamanmu.',
      bgColor: Color(0xFFEEF2FF),
    ),
    OnboardingData(
      emoji: '🔍',
      title: 'Cari & Filter Mudah',
      subtitle:
          'Cari produk favoritmu dengan cepat menggunakan fitur pencarian real-time dan filter kategori yang lengkap.',
      bgColor: Color(0xFFFFF7ED),
    ),
    OnboardingData(
      emoji: '🛒',
      title: 'Belanja Aman & Tersinkron',
      subtitle:
          'Akun kamu tersimpan aman dengan Firebase, dan keranjang belanja tetap ada meski koneksi terputus.',
      bgColor: Color(0xFFECFDF5),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() async {
    await LocalStorageService.setSeenOnboarding();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: _currentPage < 2
                  ? TextButton(
                      onPressed: _goToLogin,
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                          color: AppColors.textMedium,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : const SizedBox(height: 40),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _OnboardingPage(data: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.textLight,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_currentPage < 2)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Selanjutnya'),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _goToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                        ),
                        child: const Text(
                          'Mulai Belanja 🛍️',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: data.bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(data.emoji, style: const TextStyle(fontSize: 80)),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textMedium,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
