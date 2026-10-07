# KampusConnect — Flutter (frontend)

Frontend Flutter untuk aplikasi jual-beli barang bekas antar mahasiswa
(**KampusConnect**). Backend: ElysiaJS di `../be` (prefix `/api/v1`), database Neon.

## Stack

- **State management:** flutter_riverpod
- **Routing:** go_router (StatefulShellRoute, bottom nav 5 tab)
- **HTTP:** dio (+ interceptor JWT Bearer & unwrap envelope `{success, data, requestId}`)
- **Storage:** flutter_secure_storage (token JWT) + shared_preferences (cache user)
- **UI:** Material 3 + google_fonts (Inter), design token terpusat di `lib/core/theme`

## Struktur

```
lib/
├── core/
│   ├── constants/      # API base URL, kunci storage
│   ├── network/        # Dio client + interceptor JWT/envelope + ApiException
│   ├── providers/      # wiring global provider (dio, session, repository)
│   ├── storage/        # SessionStore (token) + cache user
│   ├── theme/          # AppColors (design token) + AppTheme
│   └── utils/          # formatter Rupiah, tanggal, inisial
├── features/
│   ├── auth/           # data (datasource+repo) / domain (model+interface) / presentation (controller+page)
│   ├── home|explore|listing|chat|profile/   # placeholder tab (isi berurutan)
│   └── onboarding/     # splash + shell (bottom nav)
├── router/             # go_router config + auth redirect
├── shared/
│   └── widgets/        # KCButton, KCTextField, KCLogo, AuthScaffold
└── main.dart
```

## Menjalankan

Backend harus jalan dulu (dari `../be`):

```bash
# be/
bun run dev        # http://localhost:3000
```

Lalu jalankan Flutter:

```bash
cd fe
flutter pub get

# Android emulator (default URL sudah mengarah ke 10.0.2.2:3000)
flutter run

# Perangkat fisik / backend sudah di-deploy:
flutter run --dart-define=API_BASE_URL=https://kampusconnect-api.example.com

# Build APK dengan URL production:
flutter build apk --release --dart-define=API_BASE_URL=https://kampusconnect-api.example.com
```

Default `API_BASE_URL` = `http://10.0.2.2:3000` (localhost host dari Android
emulator). Lihat `lib/core/constants/app_constants.dart`.

> Catatan Android: pastikan `android:usesCleartextTraffic="true"` (atau
> network security config) bila memakai `http://` non-HTTPS untuk development.

## Akun demo (seed database)

Backend Neon sudah berisi data seed. Gunakan email kampus
(`@untidar.ac.id` / `@students.untidar.ac.id`) saat register agar domain
valid, atau login dengan akun seed yang sudah ada.

## Iterasi

- **I1 (fondasi + auth):** tema, Dio+JWT, Riverpod, router, splash, login, register ✅
- **I2 (inti jual-beli):** home feed, explore + filter, detail listing, create/search listing
- **I3 (transaksi + trust):** chat, transaksi, review, report, seller profile
