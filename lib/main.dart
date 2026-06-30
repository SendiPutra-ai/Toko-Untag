// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/local_storage_service.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  // Wajib dipanggil sebelum operasi async lain (Firebase, Hive) saat startup
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase (Authentication)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi Hive (local storage / caching offline)
  await LocalStorageService.init();

  runApp(
    // ProviderScope WAJIB membungkus seluruh aplikasi agar semua widget
    // di dalamnya bisa mengakses Riverpod providers lewat ConsumerWidget/ref.
    const ProviderScope(
      child: TokoOnlineUntag(),
    ),
  );
}

class TokoOnlineUntag extends StatelessWidget {
  const TokoOnlineUntag({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Online UNTAG',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      // Routing disederhanakan: SplashScreen bertindak sebagai router utama,
      // mengamati authStateProvider untuk menentukan tujuan navigasi.
      // Layar lain (Login/Register/Detail/Edit) dinavigasi langsung via
      // Navigator.push agar membawa data (mis. objek Product/User) dengan aman.
      home: const SplashScreen(),
    );
  }
}
