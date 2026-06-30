// lib/screens/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_theme.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final totalItems = ref.watch(cartTotalItemsProvider);
    final totalPrice = ref.watch(cartTotalPriceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Keranjang ($totalItems item)'),
        automaticallyImplyLeading: false,
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Kosongkan Keranjang'),
                    content:
                        const Text('Yakin ingin menghapus semua produk dari keranjang?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).clear();
                          Navigator.pop(context);
                        },
                        child: const Text('Hapus Semua',
                            style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
              },
              child:
                  const Text('Hapus Semua', style: TextStyle(color: Colors.white70)),
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.textLight, width: 2),
                    ),
                    child: const Icon(Icons.shopping_cart_outlined,
                        size: 56, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Keranjang Kosong',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  const Text('Yuk, tambahkan produk favoritmu!',
                      style: TextStyle(color: AppColors.textMedium)),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: item.product.image,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.contain,
                                    placeholder: (_, __) => const SizedBox(
                                      width: 70,
                                      height: 70,
                                      child: Center(
                                          child:
                                              CircularProgressIndicator(strokeWidth: 2)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textDark),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${item.product.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          _QtyButton(
                                            icon: Icons.remove,
                                            onTap: () {
                                              ref
                                                  .read(cartProvider.notifier)
                                                  .decreaseQuantity(item.product.id);
                                            },
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.symmetric(horizontal: 12),
                                            child: Text('${item.quantity}',
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700)),
                                          ),
                                          _QtyButton(
                                            icon: Icons.add,
                                            onTap: () {
                                              ref
                                                  .read(cartProvider.notifier)
                                                  .increaseQuantity(item.product.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded,
                                          color: AppColors.error, size: 20),
                                      onPressed: () {
                                        ref
                                            .read(cartProvider.notifier)
                                            .removeProduct(item.product.id);
                                      },
                                    ),
                                    Text(
                                      '\$${item.totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textDark),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 16,
                              offset: Offset(0, -4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:',
                                  style: TextStyle(
                                      fontSize: 15, color: AppColors.textMedium)),
                              Text('\$${totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Pembayaran',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark),
                              ),
                              Text(
                                '\$${totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('🎉 Pesanan Berhasil!'),
                                    content: Text(
                                        'Pesanan senilai \$${totalPrice.toStringAsFixed(2)} sedang diproses.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          ref.read(cartProvider.notifier).clear();
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Checkout Sekarang',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.textLight),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}
