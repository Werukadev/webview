# Flutter WebView App

Template Flutter WebView yang siap pakai dan kaya fitur. Semua konfigurasi terpusat di **satu file** — programmer cukup mengubah nilai di `lib/config/app_config.dart` tanpa menyentuh file lain.

---

## Daftar Isi

- [Fitur](#fitur)
- [Persyaratan](#persyaratan)
- [Struktur Project](#struktur-project)
- [Setup & Instalasi](#setup--instalasi)
- [Konfigurasi (app_config.dart)](#konfigurasi-app_configdart)
  - [URL & Sumber Konten](#url--sumber-konten)
  - [Mode Offline](#mode-offline)
  - [Fitur WebView](#fitur-webview)
  - [Deep Link](#deep-link)
  - [Tampilan](#tampilan)
  - [Navigasi & URL Routing](#navigasi--url-routing)
- [URL Routing](#url-routing)
- [Deep Link](#deep-link-1)
  - [Custom Scheme (Android & iOS)](#custom-scheme-android--ios)
  - [App Links / Universal Links (HTTPS)](#app-links--universal-links-https)
- [Mode Offline](#mode-offline-1)
  - [Offline Cache](#offline-cache)
  - [Offline HTML Lokal](#offline-html-lokal)
- [Download File](#download-file)
- [Upload File](#upload-file)
- [WebRTC (Kamera & Mikrofon)](#webrtc-kamera--mikrofon)
- [Geolokasi](#geolokasi)
- [Tampilan Full Screen](#tampilan-full-screen)
- [Kustomisasi Halaman Offline](#kustomisasi-halaman-offline)
- [Izin (Permissions)](#izin-permissions)
  - [Android](#android)
  - [iOS](#ios)
- [Nama &amp; Ikon Aplikasi](#nama--ikon-aplikasi)
- [Build & Release](#build--release)
- [FAQ](#faq)

---

## Fitur

| Fitur | Deskripsi |
|---|---|
| ✅ **Single Config File** | Semua setting di `app_config.dart` — toggle `true`/`false` |
| ✅ **Pull to Refresh** | Gestur tarik ke bawah untuk reload halaman |
| ✅ **Download File** | Auto-download ke folder Downloads, notifikasi progress |
| ✅ **Upload File** | File chooser & akses galeri dari `<input type="file">` |
| ✅ **WebRTC** | Akses kamera & mikrofon untuk video/audio call di web |
| ✅ **Geolokasi** | Izinkan halaman web membaca posisi GPS perangkat |
| ✅ **Deep Link** | Custom scheme (`myapp://`) dan HTTPS (App Links / Universal Links) |
| ✅ **Offline Mode** | Tampilkan cache browser saat tidak ada koneksi |
| ✅ **Offline HTML Lokal** | Fallback ke halaman HTML statis dari assets |
| ✅ **Offline First** | Optionally sajikan dari cache dulu, network sebagai fallback |
| ✅ **Full Screen / Edge-to-Edge** | Konten mengisi layar penuh, aman di semua device |
| ✅ **JavaScript** | ES6+, `window.flutter_inappwebview`, console log |
| ✅ **Cookie & Storage** | localStorage, sessionStorage, DOM Storage, cookie |
| ✅ **Back Navigation** | Tombol Back menavigasi history WebView sebelum keluar app |
| ✅ **URL Routing** | Allowlist & blocklist domain — kontrol URL mana yang dibuka di WebView vs browser |
| ✅ **Status Bar Color** | Atur warna ikon status bar (putih/hitam) sesuai background app |
| ✅ **External Scheme** | `tel:`, `mailto:`, `whatsapp:`, dll. → dibuka di app eksternal |
| ✅ **Progress Bar** | Loading bar tipis di bagian atas layar |
| ✅ **Offline Banner** | Banner merah saat perangkat offline |
| ✅ **Chrome DevTools** | Inspect WebView dari Chrome DevTools (debug build) |
| ✅ **Custom User Agent** | Ganti UA string sesuai kebutuhan |
| ✅ **Dark Mode Aware** | Halaman offline mendukung dark mode otomatis |

---

## Persyaratan

| Komponen | Versi Minimum |
|---|---|
| Flutter | 3.10.0+ |
| Dart | 3.0.0+ |
| Android | API 21 (Android 5.0 Lollipop) |
| iOS | 12.0+ |

---

## Struktur Project

```
webview/
├── lib/
│   ├── config/
│   │   └── app_config.dart        ← ⭐ SATU FILE KONFIGURASI
│   ├── main.dart                  ← Entry point & inisialisasi
│   ├── app.dart                   ← Root MaterialApp
│   ├── screens/
│   │   └── webview_screen.dart    ← Layar utama WebView
│   ├── services/
│   │   ├── connectivity_service.dart   ← Monitor koneksi internet
│   │   ├── deeplink_service.dart       ← Handler deep link
│   │   └── download_service.dart       ← Download & simpan file
│   └── widgets/
│       ├── offline_banner.dart         ← Banner "Tidak ada koneksi"
│       └── web_progress_bar.dart       ← Progress bar loading
│
├── assets/
│   └── offline/
│       ├── index.html             ← Halaman fallback offline
│       ├── style.css              ← Style halaman offline (dark mode ready)
│       └── script.js             ← Auto-reload saat koneksi pulih
│
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml    ← Permissions & deep link intent-filter
│       └── res/xml/file_paths.xml ← FileProvider untuk download
│
└── ios/
    └── Runner/
        └── Info.plist             ← Permissions & URL scheme
```

---

## Setup & Instalasi

### 1. Clone / Download Project

```bash
git clone https://github.com/Werukadev/webview.git
cd webview
```

### 2. Install Dependensi

```bash
flutter pub get
```

### 3. Set URL Aplikasi

Buka `lib/config/app_config.dart` dan ganti URL:

```dart
static const String webUrl = 'https://domain-anda.com';
```

### 4. Jalankan Aplikasi

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Spesifik device
flutter devices          # lihat daftar device
flutter run -d <device-id>
```

### 5. Build Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (untuk Google Play)
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## Konfigurasi (app_config.dart)

> **Semua konfigurasi ada di satu file: `lib/config/app_config.dart`**
> Programmer tidak perlu menyentuh file lain untuk mengubah fitur.

### URL & Sumber Konten

```dart
// URL utama yang ditampilkan di WebView
static const String webUrl = 'https://domain-anda.com';

// Nama aplikasi (judul, halaman offline, dll.)
static const String appName = 'My WebView App';
```

### Mode Offline

```dart
// Aktifkan dukungan offline
static const bool enableOfflineMode = true;

// Pilih sumber konten saat offline:
//   OfflineSource.cache     → tampilkan cache browser dari webUrl
//   OfflineSource.localHtml → tampilkan file HTML dari assets/offline/
static const OfflineSource offlineSource = OfflineSource.cache;

// true  = sajikan dari cache dulu (hemat kuota, lebih cepat)
// false = network dulu, cache sebagai fallback
static const bool offlineFirst = false;

// Path file HTML lokal (hanya dipakai jika offlineSource = localHtml)
static const String offlineHtmlAsset = 'assets/offline/index.html';
```

### Fitur WebView

```dart
static const bool enableJavaScript       = true;   // JavaScript on/off
static const bool enablePullToRefresh    = true;   // Tarik ke bawah untuk refresh
static const bool enableFileUpload       = true;   // <input type="file">
static const bool enableFileDownload     = true;   // Auto-download file
static const bool enableWebRTC           = true;   // Kamera + mikrofon WebRTC
static const bool enableGeolocation      = true;   // GPS dari web
static const bool enableZoom             = false;  // Pinch-to-zoom
static const bool enableScrollBar        = false;  // Tampilkan scrollbar
static const bool enableDOMStorage       = true;   // localStorage, sessionStorage
static const bool enableCookies          = true;   // Cookie
static const bool enableMixedContent     = false;  // HTTP di dalam HTTPS (Android)
static const bool enableInspector        = true;   // Chrome DevTools (debug only)
```

### Deep Link

```dart
static const bool   enableDeepLink       = true;
static const String deepLinkScheme       = 'myapp';   // myapp://open/path
static const String deepLinkHost         = 'open';

// Domain untuk App Links (Android) / Universal Links (iOS)
// Kosongkan jika tidak pakai HTTPS deep link
static const String universalLinkDomain = '';         // 'domain-anda.com'
```

### Tampilan

```dart
static const bool   fullScreen           = true;           // Edge-to-edge
static const bool   hideStatusBar        = false;          // Sembunyikan status bar
static const bool   safeAreaTop          = true;           // Padding bawah status bar

// Warna ikon & teks status bar perangkat (jam, baterai, sinyal, dll.)
//   Brightness.light → ikon PUTIH  (untuk app background gelap)
//   Brightness.dark  → ikon HITAM  (untuk app background terang)
static const Brightness statusBarIconBrightness = Brightness.light;

static const Color  backgroundColor      = Colors.white;      // Background saat loading
static const Color  progressBarColor     = Color(0xFF2196F3); // Warna loading bar
static const bool   showProgressBar      = true;              // Tampilkan progress bar
static const bool   showOfflineBanner    = true;              // Banner offline
static const Color  offlineBannerColor   = Color(0xFFF44336); // Warna banner
static const String customUserAgent      = '';                // Kosong = default UA
```

### Navigasi & URL Routing

```dart
// Tombol Back → navigasi history WebView sebelum keluar app
static const bool backButtonNavigatesHistory = true;

// [ALLOWLIST] Hanya domain ini yang dibuka di WebView.
// Kosong ([]) = semua URL boleh masuk WebView (tidak ada filter).
static const List<String> allowedDomains = [
  'domain-anda.com',
  // 'api.domain-anda.com',
];

// [BLOCKLIST] Domain yang SELALU dibuka di browser eksternal.
static const List<String> externalDomains = [
  // 'facebook.com',
  // 'instagram.com',
];

// Scheme yang dibuka di app eksternal (bukan di WebView maupun browser)
static const List<String> externalSchemes = [
  'tel:',
  'mailto:',
  'whatsapp:',
  'market:',
  'intent:',
  'maps:',
];
```

**Prioritas routing URL:**

| Urutan | Kondisi | Tindakan |
|--------|---------|----------|
| 1 | URL dimulai dengan `externalSchemes` | Buka di app eksternal (dialer, email, …) |
| 2 | Domain cocok dengan `externalDomains` | Buka di browser eksternal |
| 3 | `allowedDomains` tidak kosong & domain tidak ada di list | Buka di browser eksternal |
| 4 | Semua lainnya | Buka di WebView |

---

## Deep Link

### Custom Scheme (Android & iOS)

Deep link dengan custom scheme sudah dikonfigurasi otomatis. Defaultnya adalah `myapp://open/path`.

**Mengubah scheme:**

1. Edit `app_config.dart`:
   ```dart
   static const String deepLinkScheme = 'myapp';   // ganti sesuai kebutuhan
   static const String deepLinkHost   = 'open';
   ```

2. Update `AndroidManifest.xml`:
   ```xml
   <data android:scheme="myapp" android:host="open" />
   ```

3. Update `ios/Runner/Info.plist`:
   ```xml
   <string>myapp</string>
   ```

**Cara memanggil deep link:**
```
myapp://open/halaman?param=nilai
```

URL yang dihasilkan di WebView (URL base + path dari deep link):
```
https://domain-anda.com/halaman?param=nilai
```

### App Links / Universal Links (HTTPS)

Untuk deep link via `https://domain-anda.com/path`:

**Android — App Links:**

1. Uncomment di `AndroidManifest.xml`:
   ```xml
   <intent-filter android:autoVerify="true">
       <action android:name="android.intent.action.VIEW" />
       <category android:name="android.intent.category.DEFAULT" />
       <category android:name="android.intent.category.BROWSABLE" />
       <data android:scheme="https" android:host="domain-anda.com" />
   </intent-filter>
   ```

2. Upload file verifikasi di server:
   ```
   https://domain-anda.com/.well-known/assetlinks.json
   ```

**iOS — Universal Links:**

1. Uncomment di `Info.plist`:
   ```xml
   <key>com.apple.developer.associated-domains</key>
   <array>
       <string>applinks:domain-anda.com</string>
   </array>
   ```

2. Upload file verifikasi di server:
   ```
   https://domain-anda.com/.well-known/apple-app-site-association
   ```

3. Aktifkan capability **Associated Domains** di Xcode.

---

## Mode Offline

### Offline Cache

WebView menyimpan konten yang sudah dikunjungi di cache browser secara otomatis. Saat perangkat offline, halaman ditampilkan dari cache tersebut.

```dart
static const OfflineSource offlineSource = OfflineSource.cache;
static const bool offlineFirst = false;  // ubah ke true untuk offline-first
```

**Perilaku:**
- `offlineFirst = false`: Selalu coba network dulu, cache sebagai fallback
- `offlineFirst = true`: Cache dulu (lebih cepat, hemat kuota), network untuk update

**Limitasi cache:** Konten di cache bergantung pada header HTTP dari server (`Cache-Control`, `Expires`). Pastikan server mengizinkan caching untuk halaman yang perlu tersedia offline.

### Offline HTML Lokal

Tampilkan halaman HTML statis dari assets jika tidak ada koneksi dan tidak ada cache:

```dart
static const OfflineSource offlineSource = OfflineSource.localHtml;
static const String offlineHtmlAsset = 'assets/offline/index.html';
```

**Kustomisasi halaman offline:** Edit file di `assets/offline/` sesuai kebutuhan branding (lihat [Kustomisasi Halaman Offline](#kustomisasi-halaman-offline)).

---

## Download File

File yang di-download dari WebView otomatis disimpan ke folder **Downloads** perangkat.

- Android: `/storage/emulated/0/Download/`
- iOS: Documents folder (dapat diakses via Files app)

Setelah download selesai, muncul notifikasi SnackBar dengan tombol **BUKA** untuk langsung membuka file.

**Mengaktifkan/menonaktifkan:**
```dart
static const bool enableFileDownload = true;
```

**Izin yang diperlukan:** Sudah dikonfigurasi otomatis di `AndroidManifest.xml` dan `Info.plist`.

---

## Upload File

Saat pengguna menekan `<input type="file">` di halaman web, sistem file picker native perangkat akan terbuka secara otomatis.

- Mendukung pilih foto, video, dokumen, dan file lainnya
- Mendukung pilih multiple file (jika HTML menggunakan `multiple`)
- Didukung oleh `flutter_inappwebview` secara native — tidak perlu konfigurasi tambahan

**Mengaktifkan:**
```dart
static const bool enableFileUpload = true;
```

**Izin yang diperlukan (Android):**
- `READ_EXTERNAL_STORAGE` (Android ≤ 12)
- `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO` (Android 13+)

---

## WebRTC (Kamera & Mikrofon)

Halaman web dapat mengakses kamera dan mikrofon perangkat untuk fitur seperti:
- Video call
- Audio call
- Perekaman video/audio langsung dari browser

**Mengaktifkan:**
```dart
static const bool enableWebRTC = true;
```

Saat halaman web meminta akses kamera/mikrofon melalui `getUserMedia()`, aplikasi otomatis meminta izin dari pengguna dan memberikan akses jika diizinkan.

**Izin yang diperlukan:**
- Android: `CAMERA`, `RECORD_AUDIO`, `MODIFY_AUDIO_SETTINGS`
- iOS: `NSCameraUsageDescription`, `NSMicrophoneUsageDescription` (sudah ada di `Info.plist`)

---

## Geolokasi

Halaman web dapat membaca posisi GPS perangkat melalui `navigator.geolocation`.

**Mengaktifkan:**
```dart
static const bool enableGeolocation = true;
```

Saat halaman web memanggil `getCurrentPosition()` atau `watchPosition()`, aplikasi otomatis meminta izin lokasi dari pengguna.

**Izin yang diperlukan:**
- Android: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`
- iOS: `NSLocationWhenInUseUsageDescription` (sudah ada di `Info.plist`)

---

## URL Routing

Kontrol penuh URL mana yang dibuka **di dalam WebView** dan mana yang diteruskan ke **browser eksternal** atau **app lain** — tanpa menyentuh kode.

### Allowlist — hanya domain tertentu di WebView

```dart
static const List<String> allowedDomains = [
  'domain-anda.com',       // cocok: domain-anda.com & *.domain-anda.com
  'api.domain-anda.com',   // cocok: hanya api.domain-anda.com
];
```

Jika `allowedDomains` **diisi**, semua URL di luar list secara otomatis dibuka di browser eksternal. Kosongkan (`[]`) untuk mengizinkan semua URL masuk ke WebView.

### Blocklist — paksa domain ke browser eksternal

```dart
static const List<String> externalDomains = [
  'facebook.com',    // cocok: facebook.com & *.facebook.com
  'instagram.com',
  'tokopedia.com',   // contoh: payment gateway pihak ketiga
];
```

Domain di `externalDomains` **selalu** dibuka di browser eksternal, bahkan jika ada di `allowedDomains`.

### Scheme — buka di app eksternal

```dart
static const List<String> externalSchemes = [
  'tel:',        // → app dialer
  'mailto:',     // → app email
  'whatsapp:',   // → WhatsApp
  'market:',     // → Play Store
  'intent:',     // → intent Android
  'maps:',       // → Google Maps
];
```

URL dengan scheme ini dibuka langsung di aplikasi yang menanganinya, bukan di browser.

### Contoh skenario umum

| Kebutuhan | Konfigurasi |
|-----------|-------------|
| Hanya website sendiri di WebView | `allowedDomains = ['domain-anda.com']` |
| Semua URL boleh di WebView | `allowedDomains = []` (kosong) |
| Blokir link sosmed ke browser | `externalDomains = ['facebook.com', 'twitter.com']` |
| Nomor telepon buka dialer | `externalSchemes` sudah berisi `'tel:'` (default) |

---

## Tampilan Full Screen

Dengan `fullScreen = true`, konten WebView ditampilkan edge-to-edge — mengisi seluruh layar termasuk area status bar dan navigation bar.

```dart
static const bool fullScreen      = true;   // edge-to-edge
static const bool hideStatusBar   = false;  // true = sembunyikan status bar sepenuhnya
static const bool safeAreaTop     = true;   // padding bawah status bar (direkomendasikan)
```

Status bar dan navigation bar transparan, sehingga tampilan terasa native dan immersive. Dikonfigurasi otomatis di:
- Android: `styles.xml` (`windowTranslucentStatus`, `windowTranslucentNavigation`)
- Flutter: `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)`

### Warna Ikon Status Bar

Atur apakah ikon dan teks di status bar perangkat (jam, baterai, sinyal, indikator jaringan) berwarna **putih** atau **hitam** agar tetap terbaca di atas background app.

```dart
// Brightness.light → ikon PUTIH (untuk background gelap)
// Brightness.dark  → ikon HITAM (untuk background terang)
static const Brightness statusBarIconBrightness = Brightness.light;
```

| Nilai | Tampilan ikon | Kapan dipakai |
|-------|---------------|---------------|
| `Brightness.light` | Putih / terang | Background app gelap (dark theme) |
| `Brightness.dark` | Hitam / gelap | Background app terang (light theme) |

> Pengaturan ini berlaku di Android dan iOS secara otomatis — konvensi iOS dibalik di belakang layar tanpa perlu konfigurasi tambahan.

---

## Kustomisasi Halaman Offline

Halaman offline ada di `assets/offline/`. Terdiri dari tiga file yang dapat diedit bebas:

### `assets/offline/index.html`
Struktur HTML halaman. Sudah berisi:
- Ikon Wi-Fi animasi dengan tanda silang merah
- Judul dan pesan offline
- Tombol "Coba Lagi"
- Hint teks

### `assets/offline/style.css`
Style halaman. Fitur bawaan:
- **Dark mode otomatis** via `prefers-color-scheme`
- Responsif untuk semua ukuran layar
- Animasi pulse pada ikon Wi-Fi
- Font system native (iOS/Android)

### `assets/offline/script.js`
Logika halaman:
- Fungsi `retry()` untuk reload
- **Auto-reload otomatis** saat koneksi pulih (via `window.addEventListener('online', ...)`)
- Integrasi dengan `window.flutter_inappwebview` untuk trigger reload dari sisi Flutter

**Contoh kustomisasi branding:**

```html
<!-- index.html — tambahkan logo perusahaan -->
<div class="container">
  <img src="logo.png" alt="Logo" width="120" />
  <h1 class="title">Tidak ada koneksi</h1>
  ...
</div>
```

```css
/* style.css — ubah warna tombol */
.retry-btn {
  background: #FF5722;  /* warna brand Anda */
}
```

> **Catatan:** Jika menggunakan gambar/aset tambahan di halaman offline, tambahkan folder-nya ke `pubspec.yaml`:
> ```yaml
> flutter:
>   assets:
>     - assets/offline/
>     - assets/images/   # tambahkan di sini
> ```

---

## Izin (Permissions)

### Android

Semua izin sudah dikonfigurasi di `android/app/src/main/AndroidManifest.xml`. Izin bersifat **opsional** — jika fitur dinonaktifkan di `app_config.dart`, izin tidak akan diminta saat runtime.

| Izin | Untuk Fitur |
|---|---|
| `INTERNET` | Semua (wajib) |
| `ACCESS_NETWORK_STATE` | Deteksi online/offline |
| `CAMERA` | WebRTC, upload foto |
| `RECORD_AUDIO` | WebRTC audio |
| `MODIFY_AUDIO_SETTINGS` | WebRTC |
| `READ_EXTERNAL_STORAGE` | Upload & download (Android ≤ 12) |
| `WRITE_EXTERNAL_STORAGE` | Download (Android ≤ 9) |
| `READ_MEDIA_IMAGES` | Upload gambar (Android 13+) |
| `READ_MEDIA_VIDEO` | Upload video (Android 13+) |
| `DOWNLOAD_WITHOUT_NOTIFICATION` | Download tanpa notifikasi sistem |
| `ACCESS_FINE_LOCATION` | Geolokasi presisi tinggi |
| `ACCESS_COARSE_LOCATION` | Geolokasi kasar |

### iOS

Semua deskripsi izin sudah ada di `ios/Runner/Info.plist`.

| Key | Untuk Fitur |
|---|---|
| `NSCameraUsageDescription` | WebRTC, upload foto |
| `NSMicrophoneUsageDescription` | WebRTC audio |
| `NSPhotoLibraryUsageDescription` | Upload dari galeri |
| `NSPhotoLibraryAddUsageDescription` | Simpan file download |
| `NSLocationWhenInUseUsageDescription` | Geolokasi |
| `NSDocumentsFolderUsageDescription` | Simpan & buka file |

**Mengubah teks deskripsi izin (iOS):**
Edit nilai string di `ios/Runner/Info.plist` sesuai bahasa aplikasi Anda.

---

## Nama & Ikon Aplikasi

### Nama Aplikasi

> **Penting:** `AppConfig.appName` hanya dipakai di dalam kode Flutter (judul MaterialApp, halaman offline, dll.). Nama yang tampil di **launcher / homescreen perangkat** diambil dari file native — bukan dari `AppConfig.appName`.

Untuk mengubah nama yang tampil di perangkat, ubah di **tiga lokasi** berikut:

**1. Android** — `android/app/src/main/AndroidManifest.xml`
```xml
<application
    android:label="Nama App Anda"   <!-- ← ganti di sini -->
    ...>
```

**2. iOS — Display Name** — `ios/Runner/Info.plist`
```xml
<key>CFBundleDisplayName</key>
<string>Nama App Anda</string>      <!-- tampil di homescreen -->
```

**3. iOS — Bundle Name** — `ios/Runner/Info.plist`
```xml
<key>CFBundleName</key>
<string>Nama App Anda</string>      <!-- nama internal bundle -->
```

Setelah mengubah ketiga lokasi, jalankan ulang app (`flutter run`) atau build ulang.

---

### Ikon Aplikasi

Ikon dikelola dengan package `flutter_launcher_icons` yang sudah terkonfigurasi di `pubspec.yaml`.

**Langkah mengganti ikon:**

1. Siapkan file PNG berukuran minimal **1024×1024 px** dengan padding yang cukup (ikon tidak terpotong)
2. Simpan di `assets/offline/webview.png` (atau path lain, sesuaikan di `pubspec.yaml`)
3. Jalankan perintah generate:

```bash
dart run flutter_launcher_icons
```

Icon otomatis di-generate untuk semua resolusi:
- **Android:** `mipmap-mdpi` hingga `mipmap-xxxhdpi` + adaptive icon (Android 8.0+)
- **iOS:** semua ukuran di `Assets.xcassets/AppIcon.appiconset/`

**Konfigurasi di `pubspec.yaml`:**

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/offline/webview.png"   # path ke file PNG Anda
  adaptive_icon_background: "#FFFFFF"         # warna background adaptive icon Android
  adaptive_icon_foreground: "assets/offline/webview.png"
  min_sdk_android: 21
  remove_alpha_ios: true                      # wajib untuk upload ke App Store
```

> **Catatan App Store iOS:** Apple tidak mengizinkan ikon dengan transparansi (alpha channel). Pastikan `remove_alpha_ios: true` aktif sebelum upload ke App Store.

---

## Build & Release

### Android

```bash
# APK langsung install
flutter build apk --release

# App Bundle untuk Google Play Store
flutter build appbundle --release
```

Output APK: `build/app/outputs/flutter-apk/app-release.apk`
Output AAB: `build/app/outputs/bundle/release/app-release.aab`

**Signing (wajib untuk upload ke Play Store):**
1. Buat keystore: `keytool -genkey -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000`
2. Buat file `android/key.properties`
3. Update `android/app/build.gradle.kts` untuk signing config

Lihat panduan resmi: https://docs.flutter.dev/deployment/android

### iOS

```bash
flutter build ios --release
```

Buka `ios/Runner.xcworkspace` di Xcode untuk archive dan upload ke App Store Connect.

Lihat panduan resmi: https://docs.flutter.dev/deployment/ios

---

## FAQ

**Q: Konten web tidak tampil saat offline, padahal sudah pernah dibuka?**

A: Cache bergantung pada header HTTP server (`Cache-Control`). Pastikan server mengirim header yang mengizinkan caching, misalnya:
```
Cache-Control: public, max-age=86400
```
Atau gunakan `offlineSource = OfflineSource.localHtml` sebagai fallback yang lebih andal.

---

**Q: Mengapa nama di `AppConfig.appName` tidak berpengaruh ke nama app di homescreen?**

A: `AppConfig.appName` hanya dipakai di dalam kode Flutter (judul MaterialApp, dll.). Nama yang tampil di launcher perangkat diambil dari file native:
- **Android:** `android:label` di `AndroidManifest.xml`
- **iOS:** `CFBundleDisplayName` dan `CFBundleName` di `Info.plist`

Lihat section [Nama & Ikon Aplikasi](#nama--ikon-aplikasi) untuk panduan lengkapnya.

---

**Q: Bagaimana cara mengganti ikon aplikasi?**

A: Ganti file `assets/offline/webview.png` dengan PNG baru (min 1024×1024 px), lalu jalankan:
```bash
dart run flutter_launcher_icons
```
Lihat section [Ikon Aplikasi](#ikon-aplikasi) untuk konfigurasi lengkapnya.

---

**Q: Bagaimana cara membuka halaman berbeda dari notifikasi push?**

A: Kirim URL sebagai payload notifikasi, lalu panggil:
```dart
// Di handler notifikasi Anda
webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
```
Atau lewatkan URL sebagai `initialUrl` ke `WebViewScreen`.

---

**Q: Bagaimana cara mengirim data dari Flutter ke JavaScript?**

A: Gunakan `evaluateJavascript`:
```dart
await webViewController?.evaluateJavascript(
  source: "window.flutterData = { token: '$token' };",
);
```

---

**Q: Bagaimana cara menerima data dari JavaScript ke Flutter?**

A: Tambahkan JavaScript handler:
```dart
// Di onWebViewCreated
controller.addJavaScriptHandler(
  handlerName: 'onDataReceived',
  callback: (args) {
    final data = args[0];
    // proses data dari JS
  },
);
```

Di JavaScript:
```javascript
window.flutter_inappwebview.callHandler('onDataReceived', { key: 'value' });
```

---

**Q: WebRTC tidak bekerja di iOS?**

A: Pastikan:
1. `enableWebRTC = true` di `app_config.dart`
2. Key di `Info.plist` sudah ada (`NSCameraUsageDescription`, `NSMicrophoneUsageDescription`)
3. Halaman web menggunakan HTTPS (WebRTC memerlukan secure context)

---

**Q: Download file tidak berfungsi di Android 13+?**

A: Izin `READ_EXTERNAL_STORAGE` dihapus di Android 13. Pastikan:
1. `compileSdkVersion` di `build.gradle.kts` adalah 33+
2. Izin `READ_MEDIA_IMAGES` dan `READ_MEDIA_VIDEO` sudah ada di manifest (sudah dikonfigurasi)

---

**Q: Bagaimana cara mengaktifkan HTTPS deep link (App Links / Universal Links)?**

A: Lihat bagian [App Links / Universal Links (HTTPS)](#app-links--universal-links-https) di atas. Intinya, Anda perlu:
1. File verifikasi di server (`.well-known/assetlinks.json` untuk Android, `.well-known/apple-app-site-association` untuk iOS)
2. Uncomment intent-filter di `AndroidManifest.xml` / Associated Domains di Xcode
3. Set `universalLinkDomain` di `app_config.dart`

---

## Dependensi Utama

| Package | Versi | Fungsi |
|---|---|---|
| `flutter_inappwebview` | ^6.1.5 | WebView engine utama |
| `connectivity_plus` | ^6.1.1 | Deteksi status koneksi internet |
| `permission_handler` | ^11.3.1 | Izin runtime (kamera, mikrofon, lokasi, storage) |
| `path_provider` | ^2.1.4 | Path direktori sistem (Downloads, Documents) |
| `app_links` | ^6.3.2 | Deep link handler (custom scheme + App/Universal Links) |
| `url_launcher` | ^6.3.1 | Buka URL di browser / app eksternal |
| `dio` | ^5.7.0 | HTTP client untuk download file |
| `open_filex` | ^4.4.1 | Buka file hasil download |
| `file_picker` | ^8.1.2 | File picker untuk upload (Android) |

---

## Lisensi

MIT License — bebas digunakan untuk project komersial maupun open source.

---

## Repository

**GitHub:** [https://github.com/Werukadev/webview](https://github.com/Werukadev/webview)

**Demo / Landing Page:** [https://webview.weruka.dev](https://webview.weruka.dev)

---

## Kontak

Pertanyaan, laporan bug, atau kontribusi:

- **Email:** info@weruka.dev
- **Website:** [weruka.dev](https://weruka.dev)
- **GitHub Issues:** [github.com/Werukadev/webview/issues](https://github.com/Werukadev/webview/issues)
