// lib/screens/profile/edit_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/camera_provider.dart';
import '../../utils/app_theme.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _nimCtrl;
  late TextEditingController _prodiCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _nimCtrl = TextEditingController(text: widget.user.nim);
    _prodiCtrl = TextEditingController(text: widget.user.prodi);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nimCtrl.dispose();
    _prodiCtrl.dispose();
    super.dispose();
  }

  /// Menampilkan bottom sheet pilihan: Kamera atau Galeri.
  /// Ini implementasi konkret "Fitur Native Device: Kamera" sesuai ketentuan.
  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pilih Sumber Foto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: AppColors.primary),
                  ),
                  title: const Text('Ambil Foto'),
                  subtitle: const Text('Gunakan kamera perangkat'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await ref
                        .read(profilePhotoProvider.notifier)
                        .takeFromCamera();
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library_outlined,
                        color: AppColors.accent),
                  ),
                  title: const Text('Pilih dari Galeri'),
                  subtitle: const Text('Gunakan foto yang sudah ada'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await ref
                        .read(profilePhotoProvider.notifier)
                        .pickFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final photoFile = ref.read(profilePhotoProvider).value;

    final updatedUser = widget.user.copyWith(
      name: _nameCtrl.text.trim(),
      nim: _nimCtrl.text.trim(),
      prodi: _prodiCtrl.text.trim(),
      photoPath: photoFile?.path,
    );

    await ref.read(authActionProvider.notifier).updateProfile(updatedUser);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profil berhasil diperbarui!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoState = ref.watch(profilePhotoProvider);
    final actionState = ref.watch(authActionProvider);
    final isLoading = actionState.isLoading || photoState.isLoading;

    ref.listen<AsyncValue<File?>>(profilePhotoProvider, (previous, next) {
      next.whenOrNull(
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

    // Tentukan gambar mana yang dipakai: foto baru (jika dipilih) atau foto lama
    final newPhoto = photoState.value;
    final existingPhotoPath = widget.user.photoPath;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.horizontalPadding(context),
                vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar + tombol ubah foto (FITUR KAMERA)
                  Center(
                    child: GestureDetector(
                      onTap: _showPhotoSourceSheet,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              image: newPhoto != null
                                  ? DecorationImage(
                                      image: FileImage(newPhoto),
                                      fit: BoxFit.cover)
                                  : (existingPhotoPath != null
                                      ? DecorationImage(
                                          image: FileImage(
                                              File(existingPhotoPath)),
                                          fit: BoxFit.cover)
                                      : null),
                            ),
                            child: (newPhoto == null &&
                                    existingPhotoPath == null)
                                ? Center(
                                    child: Text(
                                      widget.user.name.isNotEmpty
                                          ? widget.user.name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          fontSize: 42,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white),
                                    ),
                                  )
                                : (photoState.isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                            color: Colors.white))
                                    : null),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Ketuk foto untuk mengubah',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textMedium),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Data Pribadi',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: widget.user.email,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      fillColor: Color(0xFFF3F4F6),
                      helperText:
                          'Email terhubung ke Firebase, tidak dapat diubah',
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Data Akademik',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nimCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'NIM',
                      hintText: 'Contoh: 1462300183',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _prodiCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Program Studi',
                      hintText: 'Contoh: Teknik Informatika',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _saveProfile,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Simpan Perubahan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
