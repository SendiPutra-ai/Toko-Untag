// lib/providers/product_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

/// AsyncNotifier untuk mengelola daftar produk dari REST API.
/// AsyncNotifier otomatis menyediakan 3 state (loading/error/data) lewat
/// AsyncValue, menggantikan peran FutureBuilder secara lebih terstruktur
/// dan reusable di banyak screen sekaligus.
class ProductListNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    return ProductService.fetchAllProducts();
  }

  /// Refresh manual (pull-to-refresh / tombol retry)
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ProductService.fetchAllProducts());
  }
}

final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, List<Product>>(() {
  return ProductListNotifier();
});

/// FutureProvider terpisah untuk kategori (lebih ringan, jarang berubah)
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  return ProductService.fetchCategories();
});

// ---------------------------------------------------------------------
// SEARCH & FILTER STATE
// ---------------------------------------------------------------------

/// State sederhana untuk query pencarian — pakai StateProvider karena
/// hanya menyimpan satu nilai primitif (String) yang sering berubah.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// State untuk kategori yang dipilih di filter Chip
final selectedCategoryProvider = StateProvider<String>((ref) => 'Semua');

/// Provider turunan (computed) yang menggabungkan data produk + search + filter.
/// Setiap kali searchQuery atau selectedCategory berubah, provider ini
/// otomatis menghitung ulang daftar produk yang terfilter -- UI tinggal
/// watch provider ini tanpa perlu logic filter manual di widget.
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productListProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final category = ref.watch(selectedCategoryProvider);

  return productsAsync.whenData((products) {
    return products.where((p) {
      final matchSearch = p.title.toLowerCase().contains(query);
      final matchCategory = category == 'Semua' || p.category == category;
      return matchSearch && matchCategory;
    }).toList();
  });
});
