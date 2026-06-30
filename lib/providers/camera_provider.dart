// lib/providers/camera_provider.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/camera_service.dart';

/// AsyncNotifier untuk menangani aksi ambil foto dari kamera/galeri.
/// State berupa AsyncValue<File?> -- null berarti belum ada foto dipilih.
class ProfilePhotoNotifier extends AsyncNotifier<File?> {
  @override
  Future<File?> build() async => null;

  Future<void> takeFromCamera() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => CameraService.takePhotoFromCamera());
  }

  Future<void> pickFromGallery() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => CameraService.pickPhotoFromGallery());
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final profilePhotoProvider =
    AsyncNotifierProvider<ProfilePhotoNotifier, File?>(() {
  return ProfilePhotoNotifier();
});
