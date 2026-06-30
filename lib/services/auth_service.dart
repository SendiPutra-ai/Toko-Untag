// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'local_storage_service.dart';

/// Service yang membungkus Firebase Authentication.
/// Semua operasi login/register/logout terhubung ke server Firebase,
/// lalu data profil tambahan (nim, prodi, foto) disimpan di Hive lokal
/// karena Firebase Auth defaultnya hanya menyimpan email & displayName.
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream untuk memantau perubahan status login secara real-time.
  /// Dipakai oleh Riverpod StreamProvider agar UI otomatis bereaksi
  /// saat user login/logout di mana pun.
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static User? get currentFirebaseUser => _auth.currentUser;

  /// REGISTER — membuat akun baru di Firebase Authentication
  static Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set display name di profil Firebase
      await credential.user?.updateDisplayName(name);

      final user = UserModel(
        uid: credential.user!.uid,
        email: email,
        name: name,
      );

      // Simpan data tambahan (nim, prodi) di Hive lokal, terikat ke UID
      await LocalStorageService.saveUserProfile(user);

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    }
  }

  /// LOGIN — autentikasi ke server Firebase
  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Ambil data profil tambahan dari Hive (jika sudah pernah login)
      final cached = LocalStorageService.getUserProfile(uid);
      if (cached != null) return cached;

      // Jika belum ada cache lokal (login pertama di device ini)
      final user = UserModel(
        uid: uid,
        email: credential.user!.email ?? email,
        name: credential.user!.displayName ?? 'Pengguna',
      );
      await LocalStorageService.saveUserProfile(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    }
  }

  /// LOGOUT
  static Future<void> logout() async {
    await _auth.signOut();
  }

  /// Update profil (nama, NIM, prodi, foto) — disimpan ke Hive lokal
  static Future<UserModel> updateProfile(UserModel updatedUser) async {
    // Update display name di Firebase juga, biar konsisten
    await _auth.currentUser?.updateDisplayName(updatedUser.name);
    await LocalStorageService.saveUserProfile(updatedUser);
    return updatedUser;
  }

  /// Terjemahkan pesan error Firebase ke Bahasa Indonesia yang informatif
  static String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Gunakan email lain atau login.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'user-not-found':
        return 'Akun dengan email ini tidak ditemukan.';
      case 'wrong-password':
        return 'Password yang Anda masukkan salah.';
      case 'invalid-credential':
        return 'Email atau password salah. Silakan coba lagi.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi beberapa saat.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}
