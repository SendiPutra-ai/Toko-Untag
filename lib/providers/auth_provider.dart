// lib/providers/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';

/// StreamProvider yang memantau status login Firebase secara real-time.
/// Ini provider "sumber kebenaran" (source of truth) untuk status autentikasi:
/// setiap kali user login/logout di mana pun dalam app, listener ini otomatis
/// memicu rebuild widget yang meng-watch-nya (mis. di splash/router).
final authStateProvider = StreamProvider<fb.User?>((ref) {
  return AuthService.authStateChanges;
});

/// Provider turunan yang mengubah Firebase User menjadi UserModel lengkap
/// (termasuk data tambahan nim/prodi/foto dari Hive lokal).
final currentUserProvider = Provider<UserModel?>((ref) {
  final firebaseUser = ref.watch(authStateProvider).value;
  if (firebaseUser == null) return null;

  final cached = LocalStorageService.getUserProfile(firebaseUser.uid);
  if (cached != null) return cached;

  // Fallback jika belum ada cache (kasus jarang)
  return UserModel(
    uid: firebaseUser.uid,
    email: firebaseUser.email ?? '',
    name: firebaseUser.displayName ?? 'Pengguna',
  );
});

/// AsyncNotifier untuk menangani aksi login/register/logout/update profil.
/// Dipisah dari authStateProvider agar UI bisa menampilkan loading/error
/// state spesifik untuk form (tanpa mengganggu listener auth global).
class AuthActionNotifier extends StateNotifier<AsyncValue<void>> {
  AuthActionNotifier() : super(const AsyncValue.data(null));

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await AuthService.login(email: email, password: password);
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await AuthService.register(name: name, email: email, password: password);
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await AuthService.logout();
    });
  }

  Future<void> updateProfile(UserModel user) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await AuthService.updateProfile(user);
    });
  }
}

final authActionProvider =
    StateNotifierProvider<AuthActionNotifier, AsyncValue<void>>((ref) {
  return AuthActionNotifier();
});
