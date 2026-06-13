// ============================================================
//  APP CONFIG — Edit file ini saja untuk mengonfigurasi app!
//  Programmer cukup ubah nilai di sini, tidak perlu menyentuh
//  file lain.
// ============================================================

import 'package:flutter/material.dart';

abstract final class AppConfig {
  // ── URL & SUMBER KONTEN ────────────────────────────────────────────────────

  /// URL utama yang ditampilkan di WebView.
  static const String webUrl = 'https://webview.weruka.dev';

  /// Nama aplikasi (judul di AppBar, halaman offline, dll).
  static const String appName = 'My WebView App';

  // ── MODE OFFLINE ──────────────────────────────────────────────────────────

  /// Aktifkan dukungan offline.
  static const bool enableOfflineMode = true;

  /// Sumber konten saat perangkat offline:
  ///   OfflineSource.cache     → tampilkan cache dari [webUrl]
  ///   OfflineSource.localHtml → tampilkan file HTML lokal
  static const OfflineSource offlineSource = OfflineSource.localHtml;

  /// Offline-first: true = cache dulu (lebih cepat, hemat kuota),
  ///               false = network dulu, cache sebagai fallback.
  static const bool offlineFirst = true;

  /// Path aset HTML lokal (aktif hanya jika offlineSource = localHtml).
  static const String offlineHtmlAsset = 'assets/offline/index.html';

  // ── FITUR WEBVIEW ─────────────────────────────────────────────────────────

  /// Aktifkan JavaScript.
  static const bool enableJavaScript = true;

  /// Aktifkan Pull-to-Refresh.
  static const bool enablePullToRefresh = true;

  /// Aktifkan upload file (file chooser & kamera).
  static const bool enableFileUpload = true;

  /// Aktifkan download file otomatis ke folder Downloads.
  static const bool enableFileDownload = true;

  /// Aktifkan WebRTC (akses kamera & mikrofon dari halaman web).
  static const bool enableWebRTC = true;

  /// Aktifkan akses geolokasi/GPS dari halaman web.
  static const bool enableGeolocation = true;

  /// Aktifkan pinch-to-zoom.
  static const bool enableZoom = false;

  /// Tampilkan scrollbar di WebView.
  static const bool enableScrollBar = false;

  /// Aktifkan DOM Storage (localStorage, sessionStorage).
  static const bool enableDOMStorage = true;

  /// Aktifkan cookies.
  static const bool enableCookies = true;

  /// Aktifkan konten mixed (http di dalam https) — Android only.
  /// Sebaiknya false untuk keamanan.
  static const bool enableMixedContent = false;

  /// Aktifkan Chrome DevTools inspector (debug build saja).
  static const bool enableInspector = true;

  // ── DEEP LINK ─────────────────────────────────────────────────────────────

  /// Aktifkan deep link.
  static const bool enableDeepLink = true;

  /// Scheme deep link kustom, contoh: myapp://open/halaman
  static const String deepLinkScheme = 'myapp';

  /// Host deep link kustom.
  static const String deepLinkHost = 'open';

  /// Domain untuk App Links (Android) / Universal Links (iOS).
  /// Kosongkan jika tidak memakai HTTPS deep link.
  static const String universalLinkDomain = '';

  // ── TAMPILAN ──────────────────────────────────────────────────────────────

  /// Tampilan edge-to-edge (layar penuh, status bar & nav bar transparan).
  static const bool fullScreen = true;

  /// Sembunyikan status bar sepenuhnya.
  static const bool hideStatusBar = false;

  /// Tambahkan padding di bawah status bar agar konten WebView tidak
  /// tertutup ikon jam, baterai, sinyal, dll.
  ///   true  → konten dimulai di bawah status bar (AMAN, direkomendasikan)
  ///   false → konten mulai dari paling atas layar (cocok untuk app fullscreen
  ///           yang desain webnya sudah menyertakan safe area sendiri)
  static const bool safeAreaTop = true;

  /// Warna ikon & teks di status bar perangkat (jam, baterai, sinyal, dll).
  ///   Brightness.light → ikon PUTIH  (untuk background gelap, seperti screenshot)
  ///   Brightness.dark  → ikon HITAM  (untuk background terang)
  static const Brightness statusBarIconBrightness = Brightness.light;

  /// Warna latar belakang saat halaman dimuat.
  static const Color backgroundColor = Color.fromARGB(255, 2, 0, 26);

  /// Warna loading bar di bagian atas.
  static const Color progressBarColor = Color.fromARGB(255, 3, 1, 20);

  /// Tampilkan loading progress bar.
  static const bool showProgressBar = true;

  /// Tampilkan banner "Offline" saat tidak ada koneksi internet.
  static const bool showOfflineBanner = true;

  /// Warna banner offline.
  static const Color offlineBannerColor = Color(0xFFF44336);

  // ── USER AGENT ────────────────────────────────────────────────────────────

  /// User agent kustom. Kosongkan ('') untuk memakai default.
  static const String customUserAgent = '';

  // ── NAVIGASI ──────────────────────────────────────────────────────────────

  /// Tombol Back perangkat menavigasi history WebView
  /// sebelum keluar dari aplikasi.
  static const bool backButtonNavigatesHistory = true;

  // ── URL ROUTING ───────────────────────────────────────────────────────────
  //
  //  Prioritas penentuan URL dibuka di mana:
  //
  //    1. externalSchemes  → selalu buka di app eksternal (tel:, mailto:, …)
  //    2. externalDomains  → selalu buka di browser eksternal
  //    3. allowedDomains   → jika TIDAK KOSONG, hanya domain ini yang dibuka
  //                          di WebView; semua lainnya ke browser eksternal
  //    4. (semua lainnya)  → dibuka di WebView
  //
  //  Tips penulisan domain:
  //    'weruka.dev'        → cocok dengan weruka.dev DAN *.weruka.dev
  //    'api.weruka.dev'    → cocok hanya dengan api.weruka.dev
  //    'weruka.dev/path'   → cocok dengan URL yang dimulai dengan path itu

  /// [ALLOWLIST] Domain yang BOLEH dibuka di dalam WebView.
  ///
  /// - Kosongkan ([]) → semua URL boleh dibuka di WebView (tidak ada filter).
  /// - Isi dengan domain → hanya domain ini yang dibuka di WebView;
  ///   URL lain otomatis dibuka di browser eksternal.
  ///
  /// Contoh:
  ///   ['weruka.dev', 'api.weruka.dev', 'cdn.weruka.dev']
  static const List<String> allowedDomains = [
    'weruka.dev',
    // 'api.weruka.dev',
  ];

  /// [BLOCKLIST] Domain yang SELALU dibuka di browser eksternal,
  /// meskipun ada di [allowedDomains].
  ///
  /// Contoh: link sosial media, payment gateway, atau situs pihak ketiga
  /// yang tidak boleh tertahan di dalam WebView.
  ///
  ///   ['facebook.com', 'instagram.com', 'tokopedia.com']
  static const List<String> externalDomains = [
    // 'facebook.com',
    // 'instagram.com',
  ];

  /// Scheme yang SELALU dibuka di app eksternal (bukan browser).
  /// Contoh: tel: → dialer, mailto: → email, whatsapp: → WhatsApp.
  static const List<String> externalSchemes = [
    'tel:',
    'mailto:',
    'whatsapp:',
    'market:',
    'intent:',
    'maps:',
  ];
}

/// Sumber konten saat perangkat offline.
enum OfflineSource {
  /// Pakai cache browser dari [AppConfig.webUrl].
  cache,

  /// Pakai file HTML lokal dari [AppConfig.offlineHtmlAsset].
  localHtml,
}
