// lib/screens/profile/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final actionState = ref.watch(authActionProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    void logout() {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // Logout via Firebase -- authStateProvider otomatis mendeteksi
                // perubahan ini dan SplashScreen/router akan redirect ke Login.
                await ref.read(authActionProvider.notifier).logout();
              },
              child: const Text('Logout',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text('Profil Saya'), automaticallyImplyLeading: false),
      body: Center(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image: user.photoPath != null
                              ? DecorationImage(
                                  image: FileImage(File(user.photoPath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: user.photoPath == null
                            ? Center(
                                child: Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                            fontSize: 14, color: Colors.white.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Pribadi',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark),
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                          icon: Icons.person_outline_rounded,
                          label: 'Nama Lengkap',
                          value: user.name),
                      const Divider(height: 20),
                      _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: user.email),
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'NIM',
                        value:
                            user.nim.isNotEmpty ? user.nim : '— (belum diisi)',
                        valueColor: user.nim.isNotEmpty
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.school_outlined,
                        label: 'Program Studi',
                        value: user.prodi.isNotEmpty
                            ? user.prodi
                            : '— (belum diisi)',
                        valueColor: user.prodi.isNotEmpty
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      EditProfileScreen(user: user)),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Profil'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: actionState.isLoading ? null : logout,
                          icon: const Icon(Icons.logout_rounded,
                              color: AppColors.error),
                          label: const Text('Logout',
                              style: TextStyle(color: AppColors.error)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text('TOKO ONLINE UNTAG v2.0.0',
                    style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                const SizedBox(height: 4),
                const Text('Universitas 17 Agustus 1945 Surabaya',
                    style: TextStyle(color: AppColors.textLight, fontSize: 11)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMedium)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? AppColors.textDark)),
            ],
          ),
        ),
      ],
    );
  }
}
