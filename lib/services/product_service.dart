// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import 'local_storage_service.dart';
import 'connectivity_service.dart';

/// Service untuk komunikasi REST API ke fakestoreapi.com.
/// Mendukung 4 method HTTP utama: GET, POST, PUT, DELETE.
/// Setiap GET otomatis fallback ke cache lokal (Hive) saat offline.
class ProductService {
  static const String _baseUrl = 'https://fakestoreapi.com';
  static const Duration _timeout = Duration(seconds: 10);

  // ---------------------------------------------------------------------
  // GET — Ambil semua produk (dengan fallback offline)
  // ---------------------------------------------------------------------
  static Future<List<Product>> fetchAllProducts() async {
    final online = await ConnectivityService.isOnline();

    if (!online) {
      // Mode OFFLINE: ambil dari cache Hive
      if (LocalStorageService.hasCachedProducts) {
        return LocalStorageService.getCachedProducts();
      }
      throw Exception(
          'Tidak ada koneksi internet dan belum ada data tersimpan.');
    }

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/products'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final products =
            jsonList.map((json) => Product.fromJson(json)).toList();

        // Simpan ke cache untuk dipakai saat offline nanti
        await LocalStorageService.cacheProducts(products);
        return products;
      } else {
        throw Exception('Gagal memuat produk. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Network error tapi status "online" (mis. server down) -> fallback cache
      if (LocalStorageService.hasCachedProducts) {
        return LocalStorageService.getCachedProducts();
      }
      throw Exception('Gagal memuat produk: $e');
    }
  }

  // ---------------------------------------------------------------------
  // GET — Kategori produk
  // ---------------------------------------------------------------------
  static Future<List<String>> fetchCategories() async {
    final online = await ConnectivityService.isOnline();
    if (!online) {
      // Derive kategori dari cache lokal jika offline
      final cached = LocalStorageService.getCachedProducts();
      return cached.map((p) => p.category).toSet().toList();
    }

    final response = await http
        .get(Uri.parse('$_baseUrl/products/categories'))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => e.toString()).toList();
    } else {
      throw Exception('Gagal memuat kategori.');
    }
  }

  // ---------------------------------------------------------------------
  // GET — Detail satu produk by ID
  // ---------------------------------------------------------------------
  static Future<Product> fetchProductById(int id) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/products/$id'))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Produk tidak ditemukan.');
    }
  }

  // ---------------------------------------------------------------------
  // POST — Tambah produk baru
  // (fakestoreapi bersifat simulasi: server membalas seolah produk
  // tersimpan dengan id baru, namun tidak benar-benar persisten)
  // ---------------------------------------------------------------------
  static Future<Product> createProduct(Product product) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/products'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(product.toCreateJson()),
        )
        .timeout(_timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal menambahkan produk. Status: ${response.statusCode}');
    }
  }

  // ---------------------------------------------------------------------
  // PUT — Update produk yang ada
  // ---------------------------------------------------------------------
  static Future<Product> updateProduct(Product product) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl/products/${product.id}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(product.toCreateJson()),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal memperbarui produk. Status: ${response.statusCode}');
    }
  }

  // ---------------------------------------------------------------------
  // DELETE — Hapus produk
  // ---------------------------------------------------------------------
  static Future<bool> deleteProduct(int id) async {
    final response = await http
        .delete(Uri.parse('$_baseUrl/products/$id'))
        .timeout(_timeout);

    return response.statusCode == 200;
  }
}
