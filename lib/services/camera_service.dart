// lib/services/camera_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service untuk fitur native kamera/galeri (foto profil pengguna).
/// Memanfaatkan package image_picker untuk akses kamera HP secara langsung,
/// lalu file disalin ke direktori aplikasi agar persisten antar sesi.
class CameraService {
  static final ImagePicker _picker = ImagePicker();

  /// Minta izin kamera ke OS (Android/iOS).
  /// Mengembalikan true jika user mengizinkan.
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Ambil foto langsung dari kamera perangkat
  static Future<File?> takePhotoFromCamera() async {
    final hasPermission = await requestCameraPermission();
    if (!hasPermission) {
      throw Exception(
          'Izin kamera ditolak. Aktifkan di pengaturan perangkat.');
    }

    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (picked == null) return null;
    return _saveToAppDirectory(picked);
  }

  /// Pilih foto dari galeri (alternatif jika tidak ingin pakai kamera langsung)
  static Future<File?> pickPhotoFromGallery() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (picked == null) return null;
    return _saveToAppDirectory(picked);
  }

  /// Salin file foto ke direktori dokumen aplikasi supaya tidak hilang
  /// walau file asli di cache OS dibersihkan.
  static Future<File> _saveToAppDirectory(XFile picked) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${appDir.path}/$fileName';
    final savedFile = await File(picked.path).copy(savedPath);
    return savedFile;
  }
}
