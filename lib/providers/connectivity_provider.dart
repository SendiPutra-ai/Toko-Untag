// lib/providers/connectivity_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';

/// StreamProvider yang memantau status koneksi internet secara real-time.
/// UI bisa watch provider ini untuk menampilkan banner "Mode Offline"
/// di mana pun diperlukan.
final connectivityProvider = StreamProvider<bool>((ref) {
  return ConnectivityService.onConnectivityChanged;
});
