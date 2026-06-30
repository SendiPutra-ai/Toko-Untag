// lib/widgets/offline_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_provider.dart';
import '../utils/app_theme.dart';

/// Widget kecil yang menampilkan banner kuning saat aplikasi mendeteksi
/// tidak ada koneksi internet. Dipasang di bagian atas screen yang butuh
/// data dari API (Beranda, Katalog) supaya user paham kenapa data yang
/// tampil mungkin sudah tidak terbaru (data dari cache).
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);

    return connectivity.when(
      data: (isOnline) {
        if (isOnline) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          color: AppColors.accent.withOpacity(0.15),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 16, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                'Mode Offline — menampilkan data tersimpan',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.accent.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
