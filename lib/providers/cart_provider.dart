// lib/providers/cart_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/local_storage_service.dart';
import 'auth_provider.dart';

/// StateNotifier untuk mengelola state keranjang belanja.
/// Setiap perubahan (tambah/kurang/hapus) otomatis disimpan ke Hive
/// agar isi keranjang tidak hilang saat aplikasi ditutup paksa.
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier(this._uid)
      : super(_uid != null ? LocalStorageService.getCart(_uid) : []);

  final String? _uid;

  void _persist() {
    if (_uid != null) {
      LocalStorageService.saveCart(_uid!, state);
    }
  }

  void addProduct(Product product) {
    final index = state.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      final updated = [...state];
      updated[index].quantity++;
      state = updated;
    } else {
      state = [...state, CartItem(product: product)];
    }
    _persist();
  }

  void removeProduct(int productId) {
    state = state.where((i) => i.product.id != productId).toList();
    _persist();
  }

  void increaseQuantity(int productId) {
    state = [
      for (final item in state)
        if (item.product.id == productId)
          CartItem(product: item.product, quantity: item.quantity + 1)
        else
          item
    ];
    _persist();
  }

  void decreaseQuantity(int productId) {
    final List<CartItem> updated = [];
    for (final item in state) {
      if (item.product.id == productId) {
        if (item.quantity > 1) {
          updated.add(
              CartItem(product: item.product, quantity: item.quantity - 1));
        }
        // Jika quantity == 1, item dihapus (tidak ditambahkan ke `updated`)
      } else {
        updated.add(item);
      }
    }
    state = updated;
    _persist();
  }

  void clear() {
    state = [];
    _persist();
  }
}

/// Provider keranjang yang otomatis terikat ke UID user yang sedang login.
/// `.family` tidak dipakai di sini -- sebagai gantinya kita watch currentUserProvider
/// supaya keranjang reset/reload otomatis saat user berganti akun.
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  final user = ref.watch(currentUserProvider);
  return CartNotifier(user?.uid);
});

/// Provider turunan untuk total item (dipakai di badge BottomNavigationBar)
final cartTotalItemsProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});

/// Provider turunan untuk total harga (dipakai di halaman Keranjang)
final cartTotalPriceProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0.0, (sum, item) => sum + item.totalPrice);
});
