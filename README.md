# 🛍️ TOKO UNTAG
### Aplikasi E-Commerce Sederhana
**Universitas 17 Agustus 1945 Surabaya**

Menambahkan: **Riverpod, Firebase Authentication, Hive (offline caching), fitur Kamera, REST API CRUD lengkap (GET/POST/PUT/DELETE), dan desain responsif.**

---

## 📋 Pemenuhan Ketentuan Baru

| No | Ketentuan | Implementasi |
|----|-----------|--------------|
| 1 | **UI & UX Responsif** | `Responsive` helper class (kolom grid, max-width, padding dinamis) + `NavigationRail` untuk tablet/desktop, `BottomNavigationBar` untuk HP |
| 2 | **Autentikasi** | **Firebase Authentication** (email/password) via `firebase_auth` |
| 3 | **State Management** | **Riverpod** (`flutter_riverpod`) — `StreamProvider`, `AsyncNotifier`, `StateNotifier`, `Provider` turunan |
| 4 | **Networking & API** | REST API `fakestoreapi.com` — GET, POST, PUT, DELETE + penanganan loading/error/offline |
| 5 | **Penyimpanan Lokal** | **Hive** — cache produk offline, sesi profil user, persist keranjang belanja |
| 6 | **Fitur Native** | **Kamera** (`image_picker` + `permission_handler`) — ambil/pilih foto profil |

---

## 🗂️ Struktur Proyek

```
lib/
├── main.dart                          # Entry point: init Firebase + Hive + ProviderScope
├── firebase_options.dart
│
├── models/
│   ├── product_model.dart             # Product + Rating, dengan @HiveType (cache offline)
│   ├── product_model.g.dart           # Hive TypeAdapter (generated)
│   ├── cart_item_model.dart           # CartItem (serializable ke JSON untuk Hive)
│   └── user_model.dart                # UserModel terikat ke Firebase UID
│
├── services/                          # Layer komunikasi ke sumber data eksternal
│   ├── auth_service.dart              # Wrapper Firebase Authentication
│   ├── product_service.dart           # HTTP GET/POST/PUT/DELETE + fallback offline
│   ├── local_storage_service.dart     # Hive: cache produk, profil, keranjang
│   ├── connectivity_service.dart      # Deteksi online/offline (connectivity_plus)
│   └── camera_service.dart            # Native kamera/galeri (image_picker)
│
├── providers/                         # State management terstruktur (Riverpod)
│   ├── auth_provider.dart             # authStateProvider (Stream), currentUserProvider, authActionProvider
│   ├── product_provider.dart          # productListProvider (AsyncNotifier), filteredProductsProvider
│   ├── cart_provider.dart             # cartProvider (StateNotifier) + total item/harga
│   ├── camera_provider.dart           # profilePhotoProvider (AsyncNotifier<File?>)
│   └── connectivity_provider.dart     # Status online/offline real-time
│
├── widgets/
│   └── offline_banner.dart            # Banner "Mode Offline" reusable
│
├── utils/
│   └── app_theme.dart                 # Theme + class Responsive (helper UI adaptif)
│
└── screens/
    ├── splash_screen.dart             # Router utama: cek onboarding + authStateProvider
    ├── main_screen.dart               # BottomNavigationBar (HP) / NavigationRail (tablet+)
    ├── onboarding/onboarding_screen.dart
    ├── auth/
    │   ├── login_screen.dart          # Login via Firebase
    │   └── register_screen.dart       # Register via Firebase
    ├── home/home_screen.dart          # Grid responsif + shimmer loading
    ├── catalog/catalog_screen.dart    # Search + filter via Riverpod provider
    ├── detail/product_detail_screen.dart
    ├── cart/cart_screen.dart          # Keranjang ter-Hive-persist per akun
    └── profile/
        ├── profile_screen.dart
        └── edit_profile_screen.dart   # 📸 Fitur kamera ada di sini
```

---

## ⚙️ Setup & Instalasi

### 1. Install dependencies
```bash
cd toko_online_untag
flutter pub get
```

### 2. 🔥 Setup Firebase (WAJIB sebelum running)

Aplikasi ini **tidak akan bisa di-build** sebelum Firebase dikonfigurasi, karena `lib/firebase_options.dart` masih berisi placeholder.

**Langkah-langkah:**

```bash
# a. Install FlutterFire CLI (sekali saja di komputer Anda)
dart pub global activate flutterfire_cli

# b. Login ke akun Google/Firebase Anda
firebase login

# c. Jalankan dari root folder proyek ini
flutterfire configure
```

Saat `flutterfire configure` dijalankan:
1. Pilih **Create a new project** (atau pilih project Firebase yang sudah ada).
2. Pilih platform yang ingin didukung (minimal **Android**).
3. CLI akan **otomatis menimpa** `lib/firebase_options.dart` dengan kredensial asli.

### 2. Tambahkan Permission Android

Gabungkan isi `android/app/src/main/AndroidManifest_PERMISSIONS_TO_MERGE.xml` ke dalam `android/app/src/main/AndroidManifest.xml` yang dihasilkan oleh Flutter (tambahkan tag `<uses-permission>` sebelum `<application>`).

### 3. Jalankan aplikasi
```bash
flutter run
```

---

## 📦 Dependencies Utama

```yaml
flutter_riverpod: ^2.5.1        # State management
firebase_core / firebase_auth   # Autentikasi
http                              # REST API (GET/POST/PUT/DELETE)
connectivity_plus                 # Deteksi online/offline
hive / hive_flutter               # Local storage & caching offline
image_picker / permission_handler # Fitur kamera native
cached_network_image              # Load gambar dari API
shimmer                           # Skeleton loading
```

---

## 🧠 Konsep State Management (Riverpod)

| Provider | Tipe | Fungsi |
|---|---|---|
| `authStateProvider` | `StreamProvider<User?>` | Memantau status login Firebase real-time |
| `currentUserProvider` | `Provider<UserModel?>` | Gabungkan data Firebase + profil Hive lokal |
| `authActionProvider` | `StateNotifierProvider<AsyncValue>` | Aksi login/register/logout/update profil |
| `productListProvider` | `AsyncNotifierProvider<List<Product>>` | Fetch produk dari API (loading/error/data) |
| `filteredProductsProvider` | `Provider` (computed) | Gabungkan hasil search + filter kategori |
| `cartProvider` | `StateNotifierProvider<List<CartItem>>` | State keranjang, auto-persist ke Hive |
| `profilePhotoProvider` | `AsyncNotifierProvider<File?>` | Hasil ambil foto dari kamera/galeri |
| `connectivityProvider` | `StreamProvider<bool>` | Status online/offline real-time |

---

## 🌐 REST API — CRUD Lengkap

| Method | Endpoint | Fungsi di `ProductService` |
|---|---|---|
| GET | `/products` | `fetchAllProducts()` — fallback ke Hive cache jika offline |
| GET | `/products/categories` | `fetchCategories()` |
| GET | `/products/{id}` | `fetchProductById()` |
| POST | `/products` | `createProduct()` |
| PUT | `/products/{id}` | `updateProduct()` |
| DELETE | `/products/{id}` | `deleteProduct()` |

> ℹ️ fakestoreapi.com bersifat simulasi — request POST/PUT/DELETE akan dibalas seolah berhasil, namun tidak benar-benar mengubah data permanen di server mereka. Ini sudah sesuai sifat API publik untuk keperluan latihan.

---

## 📴 Mekanisme Offline (Hive)

1. Setiap kali `fetchAllProducts()` berhasil mengambil data online, hasilnya otomatis disimpan ke **Hive Box** (`cacheProducts()`).
2. Jika `ConnectivityService.isOnline()` mendeteksi tidak ada koneksi, `ProductService` langsung membaca dari cache Hive tanpa request ke server.
3. `OfflineBanner` widget menampilkan indikator visual di layar Beranda & Katalog saat mode offline aktif.
4. Isi keranjang juga disimpan ke Hive per UID user (`saveCart`/`getCart`), sehingga tidak hilang saat aplikasi ditutup paksa.

---

## 📸 Fitur Kamera

Lokasi: **Profil → Edit Profil → ketuk foto avatar**

Alur:
1. Muncul bottom sheet pilihan: **Ambil Foto** (kamera) atau **Pilih dari Galeri**.
2. `CameraService.requestCameraPermission()` meminta izin OS terlebih dahulu.
3. Foto hasil jepretan disalin ke direktori dokumen aplikasi (`path_provider`) agar persisten.
4. Path foto disimpan sebagai bagian dari `UserModel.photoPath`, ikut tersimpan di Hive.

---

## 📱 Desain Responsif

`Responsive` class di `utils/app_theme.dart` menyediakan:
- `gridColumns(context)` — 2 kolom (HP), 3-4 (tablet), 5 (desktop)
- `maxContentWidth(context)` — membatasi lebar konten di layar besar
- `isMobile/isTablet/isDesktop` — breakpoint deteksi ukuran layar
- `MainScreen` otomatis beralih dari `BottomNavigationBar` (HP) ke `NavigationRail` (tablet ke atas)

---

## 💡 Alur Navigasi & Autentikasi

```
SplashScreen (watch authStateProvider)
    ├── Belum lihat onboarding → OnboardingScreen → LoginScreen
    ├── firebaseUser == null   → LoginScreen
    └── firebaseUser != null   → MainScreen
                                    ├── Beranda
                                    ├── Katalog → DetailProduk (push)
                                    ├── Keranjang (persist per UID via Hive)
                                    └── Profil → EditProfil (push, fitur kamera)
                                                   └── Logout → authStateProvider berubah
                                                                → SplashScreen auto-redirect ke Login
```

Karena `authStateProvider` adalah `StreamProvider` yang memantau Firebase secara real-time, **tidak perlu** memanggil `Navigator.pushReplacement` manual saat logout — cukup panggil `AuthService.logout()`, dan `SplashScreen` (yang selalu listening) otomatis mengarahkan ulang ke `LoginScreen`.

---

## 👨‍💻 Dibuat untuk
**Mata Kuliah:** Pemrograman Aplikasi Berbasis Mobile  
**Universitas 17 Agustus 1945 (UNTAG) Surabaya**
