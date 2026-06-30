// lib/services/connectivity_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service sederhana untuk mengecek status koneksi internet.
/// Dipakai supaya aplikasi tahu kapan harus fallback ke data cache (Hive)
/// alih-alih menunggu request API yang pasti gagal.
class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();

  static Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Stream untuk memantau perubahan koneksi secara real-time
  static Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (result) => !result.contains(ConnectivityResult.none),
    );
  }
}
