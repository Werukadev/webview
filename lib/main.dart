import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'services/connectivity_service.dart';
import 'services/deeplink_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── System UI ────────────────────────────────────────────────────────────
  if (AppConfig.fullScreen) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  if (AppConfig.hideStatusBar) {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
  }

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // Android: Brightness.light = ikon putih, Brightness.dark = ikon hitam
      statusBarIconBrightness: AppConfig.statusBarIconBrightness,
      // iOS: konvensi terbalik — light background = dark icons, dark background = light icons
      statusBarBrightness: AppConfig.statusBarIconBrightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // ── InAppWebView platform setup ──────────────────────────────────────────
  // File upload on Android is handled natively by the plugin.
  // DevTools debugging is enabled here for Android debug builds.
  if (Platform.isAndroid) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(
      AppConfig.enableInspector,
    );
  }

  // ── Services ─────────────────────────────────────────────────────────────
  await ConnectivityService.instance.init();
  final initialDeepLinkUri = await DeepLinkService.instance.init();
  final initialDeepLinkUrl = initialDeepLinkUri != null
      ? DeepLinkService.instance.resolveUrl(initialDeepLinkUri)
      : null;

  runApp(App(initialDeepLinkUrl: initialDeepLinkUrl));
}
