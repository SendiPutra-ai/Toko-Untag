// lib/services/local_storage_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../models/cart_item_model.dart';

/// Service terpusat untuk semua penyimpanan data lokal.
///
/// Menggunakan 2 jenis local storage sesuai kebutuhan:
/// - Hive: untuk data terstruktur yang lebih besar (produk cache, profil user,
///   isi keranjang) karena lebih cepat dan mendukung object kompleks.
/// - SharedPreferences: untuk flag sederhana (mis. status onboarding).
class LocalStorageService {
  static const String _productBoxName = 'products_cache';
  static const String _userBoxName = 'user_profiles';
  static const String _cartBoxName = 'cart_items';
  static const String _metaBoxName = 'app_meta';

  /// Wajib dipanggil sekali di main() sebelum runApp()
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(RatingAdapter());
    Hive.registerAdapter(ProductAdapter());

    await Hive.openBox<Product>(_productBoxName);
    await Hive.openBox(_userBoxName);
    await Hive.openBox(_cartBoxName);
    await Hive.openBox(_metaBoxName);
  }

  // ---------------------------------------------------------------------
  // PRODUCT CACHE (untuk mode offline)
  // ---------------------------------------------------------------------

  static Box<Product> get _productBox =>
      Hive.box<Product>(_productBoxName);

  /// Simpan daftar produk hasil fetch API ke cache lokal
  static Future<void> cacheProducts(List<Product> products) async {
    final Map<String, Product> entries = {
      for (var p in products) p.id.toString(): p
    };
    await _productBox.putAll(entries);
    await _setLastSyncTime();
  }

  /// Ambil produk dari cache (dipakai saat offline)
  static List<Product> getCachedProducts() {
    return _productBox.values.toList();
  }

  static bool get hasCachedProducts => _productBox.isNotEmpty;

  static Future<void> _setLastSyncTime() async {
    final metaBox = Hive.box(_metaBoxName);
    await metaBox.put('last_sync', DateTime.now().toIso8601String());
  }

  static DateTime? get lastSyncTime {
    final metaBox = Hive.box(_metaBoxName);
    final iso = metaBox.get('last_sync');
    return iso != null ? DateTime.tryParse(iso) : null;
  }

  // ---------------------------------------------------------------------
  // USER PROFILE (data tambahan di luar Firebase: nim, prodi, foto)
  // ---------------------------------------------------------------------

  static Box get _userBox => Hive.box(_userBoxName);

  static Future<void> saveUserProfile(UserModel user) async {
    await _userBox.put(user.uid, user.toMap());
  }

  static UserModel? getUserProfile(String uid) {
    final data = _userBox.get(uid);
    if (data == null) return null;
    return UserModel.fromMap(Map<dynamic, dynamic>.from(data));
  }

  static Future<void> clearUserProfile(String uid) async {
    // Data profil TIDAK dihapus saat logout (agar tetap ada saat login lagi),
    // hanya sesi yang dihapus. Ini sesuai praktik umum: profil = cache lokal.
  }

  // ---------------------------------------------------------------------
  // CART PERSISTENCE (supaya keranjang tidak hilang saat app ditutup)
  // ---------------------------------------------------------------------

  static Box get _cartBox => Hive.box(_cartBoxName);

  static Future<void> saveCart(String uid, List<CartItem> items) async {
    final jsonList = items.map((e) => e.toJson()).toList();
    await _cartBox.put(uid, jsonList);
  }

  static List<CartItem> getCart(String uid) {
    final data = _cartBox.get(uid);
    if (data == null) return [];
    final list = List<Map>.from(data);
    return list
        .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ---------------------------------------------------------------------
  // ONBOARDING FLAG (SharedPreferences — cukup untuk flag sederhana)
  // ---------------------------------------------------------------------

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seen_onboarding') ?? false;
  }

  static Future<void> setSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
  }
}
