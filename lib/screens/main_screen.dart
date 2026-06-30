// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;
import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';
import 'home/home_screen.dart';
import 'catalog/catalog_screen.dart';
import 'cart/cart_screen.dart';
import 'profile/profile_screen.dart';

/// MainScreen menampung 4 tab utama. Untuk MEMENUHI ketentuan "desain
/// responsif", layout beralih otomatis:
/// - Layar sempit (HP): BottomNavigationBar di bawah (pola mobile umum)
/// - Layar lebar (tablet/desktop): NavigationRail di samping kiri,
///   memanfaatkan ruang horizontal yang lebih luas.
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    CatalogScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final totalItems = ref.watch(cartTotalItemsProvider);
    final isWide = Responsive.isTablet(context) || Responsive.isDesktop(context);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.white,
              leading: const SizedBox(height: 16),
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Beranda'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view_rounded),
                  label: Text('Katalog'),
                ),
                NavigationRailDestination(
                  icon: badges.Badge(
                    showBadge: totalItems > 0,
                    badgeContent: Text('$totalItems',
                        style: const TextStyle(color: Colors.white, fontSize: 10)),
                    badgeStyle: const badges.BadgeStyle(badgeColor: AppColors.accent),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  selectedIcon: const Icon(Icons.shopping_cart_rounded),
                  label: const Text('Keranjang'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Profil'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: IndexedStack(index: _currentIndex, children: _screens),
            ),
          ],
        ),
      );
    }

    // Layout mobile (default)
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Katalog',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              showBadge: totalItems > 0,
              badgeContent: Text('$totalItems',
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
              badgeStyle: const badges.BadgeStyle(badgeColor: AppColors.accent),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: badges.Badge(
              showBadge: totalItems > 0,
              badgeContent: Text('$totalItems',
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
              badgeStyle: const badges.BadgeStyle(badgeColor: AppColors.accent),
              child: const Icon(Icons.shopping_cart_rounded),
            ),
            label: 'Keranjang',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
