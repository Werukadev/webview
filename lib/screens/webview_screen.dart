import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../services/connectivity_service.dart';
import '../services/deeplink_service.dart';
import '../services/download_service.dart';
import '../widgets/offline_banner.dart';
import '../widgets/web_dialog.dart';
import '../widgets/web_progress_bar.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key, this.initialUrl});

  final String? initialUrl;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _controller;
  PullToRefreshController? _pullToRefreshController;

  double _progress = 0;
  bool _isOffline = false;
  bool _canGoBack = false;
  bool _loadedLocalFallback = false;

  StreamSubscription<bool>? _connectivitySub;
  StreamSubscription<Uri>? _deepLinkSub;

  // ── SETTINGS ──────────────────────────────────────────────────────────────

  InAppWebViewSettings get _settings => InAppWebViewSettings(
        javaScriptEnabled: AppConfig.enableJavaScript,

        // Media & WebRTC — media must NOT require gesture so WebRTC works
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        allowsAirPlayForMediaPlayback: true,

        // Cache / offline
        cacheEnabled: true,
        cacheMode: _cacheMode,

        // DOM
        domStorageEnabled: AppConfig.enableDOMStorage,
        databaseEnabled: AppConfig.enableDOMStorage,

        // Scroll
        verticalScrollBarEnabled: AppConfig.enableScrollBar,
        horizontalScrollBarEnabled: AppConfig.enableScrollBar,
        disableVerticalScroll: false,
        disableHorizontalScroll: false,

        // Zoom
        builtInZoomControls: AppConfig.enableZoom,
        displayZoomControls: false,
        supportZoom: AppConfig.enableZoom,

        // File access
        allowFileAccess: AppConfig.enableFileUpload,
        allowContentAccess: AppConfig.enableFileUpload,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,

        // Download
        useOnDownloadStart: AppConfig.enableFileDownload,

        // Navigation overrides
        useShouldOverrideUrlLoading: true,

        // Mixed content (Android only)
        mixedContentMode: AppConfig.enableMixedContent
            ? MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW
            : MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,

        // User agent
        userAgent: AppConfig.customUserAgent.isNotEmpty
            ? AppConfig.customUserAgent
            : null,

        // Safe browsing (Android)
        safeBrowsingEnabled: true,

        // Inspector / Chrome DevTools (debug builds only)
        isInspectable: kDebugMode && AppConfig.enableInspector,

        // Geolocation
        geolocationEnabled: AppConfig.enableGeolocation,
      );

  CacheMode get _cacheMode {
    if (_isOffline) {
      return AppConfig.offlineSource == OfflineSource.cache
          ? CacheMode.LOAD_CACHE_ELSE_NETWORK
          : CacheMode.LOAD_CACHE_ONLY;
    }
    return AppConfig.offlineFirst
        ? CacheMode.LOAD_CACHE_ELSE_NETWORK
        : CacheMode.LOAD_DEFAULT;
  }

  // ── LIFECYCLE ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initPullToRefresh();
    _initConnectivity();
    _initDeepLinks();
  }

  void _initPullToRefresh() {
    if (!AppConfig.enablePullToRefresh) return;
    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(color: AppConfig.progressBarColor),
      onRefresh: _reload,
    );
  }

  void _initConnectivity() {
    _isOffline = !ConnectivityService.instance.isOnline;
    _connectivitySub =
        ConnectivityService.instance.onConnectivityChanged.listen((online) {
      if (!mounted) return;
      final wasOffline = _isOffline;
      setState(() => _isOffline = !online);
      if (wasOffline && online) _reload();
    });
  }

  void _initDeepLinks() {
    if (!AppConfig.enableDeepLink) return;
    _deepLinkSub = DeepLinkService.instance.onDeepLink.listen((uri) {
      final url = DeepLinkService.instance.resolveUrl(uri);
      _loadUrl(url);
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _deepLinkSub?.cancel();
    super.dispose();
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  String get _startUrl => widget.initialUrl ?? AppConfig.webUrl;

  Future<void> _reload() async {
    if (_isOffline && AppConfig.offlineSource == OfflineSource.localHtml) {
      await _loadOfflineHtml();
      return;
    }
    if (Platform.isAndroid) {
      await _controller?.reload();
    } else {
      final url = await _controller?.getUrl();
      if (url != null) {
        await _controller?.loadUrl(urlRequest: URLRequest(url: url));
      }
    }
  }

  Future<void> _loadUrl(String url) async {
    await _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
  }

  Future<void> _loadOfflineHtml() async {
    if (!mounted) return;
    setState(() => _loadedLocalFallback = true);
    final html = await rootBundle.loadString(AppConfig.offlineHtmlAsset);
    await _controller?.loadData(
      data: html,
      mimeType: 'text/html',
      encoding: 'utf-8',
      baseUrl: WebUri('file:///android_asset/flutter_assets/'),
    );
  }

  /// Returns true if [host] matches any entry in [domains].
  /// 'example.com' matches 'example.com' and any subdomain of 'example.com'.
  bool _matchesDomain(String host, List<String> domains) {
    for (final domain in domains) {
      if (host == domain || host.endsWith('.$domain')) return true;
    }
    return false;
  }

  Future<void> _requestWebRTCPermissions() async {
    if (!AppConfig.enableWebRTC) return;
    await [Permission.camera, Permission.microphone].request();
  }

  Future<void> _requestGeolocationPermission() async {
    if (!AppConfig.enableGeolocation) return;
    await Permission.locationWhenInUse.request();
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

  SystemUiOverlayStyle get _overlayStyle => SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: AppConfig.statusBarIconBrightness,
        statusBarBrightness:
            AppConfig.statusBarIconBrightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlayStyle,
      child: PopScope(
      canPop: !AppConfig.backButtonNavigatesHistory || !_canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _canGoBack) _controller?.goBack();
      },
      child: Scaffold(
        backgroundColor: AppConfig.backgroundColor,
        body: SafeArea(
          top: AppConfig.safeAreaTop,
          bottom: false,
          child: Column(
            children: [
              if (AppConfig.showOfflineBanner && _isOffline) const OfflineBanner(),
              WebProgressBar(progress: _progress),
              Expanded(child: _buildWebView()),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildWebView() {
    final useLocalHtml =
        _isOffline && AppConfig.offlineSource == OfflineSource.localHtml;

    return InAppWebView(
      initialUrlRequest:
          useLocalHtml ? null : URLRequest(url: WebUri(_startUrl)),
      initialSettings: _settings,
      pullToRefreshController: _pullToRefreshController,

      // ── Created ───────────────────────────────────────────────────────────
      onWebViewCreated: (controller) async {
        _controller = controller;
        if (useLocalHtml) await _loadOfflineHtml();
      },

      // ── Progress ──────────────────────────────────────────────────────────
      onProgressChanged: (_, progress) {
        setState(() => _progress = progress / 100.0);
        if (progress == 100) _pullToRefreshController?.endRefreshing();
      },

      // ── Load events ───────────────────────────────────────────────────────
      onLoadStart: (_, url) => setState(() => _loadedLocalFallback = false),
      onLoadStop: (controller, _) async {
        _pullToRefreshController?.endRefreshing();
        _canGoBack = await controller.canGoBack();
        if (mounted) setState(() {});
      },

      // ── Errors ────────────────────────────────────────────────────────────
      onReceivedError: (_, request, error) async {
        if (request.isForMainFrame == true) {
          _pullToRefreshController?.endRefreshing();
          if (!_loadedLocalFallback &&
              AppConfig.enableOfflineMode &&
              AppConfig.offlineSource == OfflineSource.localHtml) {
            await _loadOfflineHtml();
          }
        }
      },

      // ── Navigation override ───────────────────────────────────────────────
      shouldOverrideUrlLoading: (_, action) async {
        final uri = action.request.url;
        final url = uri?.toString() ?? '';
        final host = uri?.host ?? '';

        // 1. externalSchemes → open in matching external app (dialer, email, …)
        for (final scheme in AppConfig.externalSchemes) {
          if (url.startsWith(scheme)) {
            final parsedUri = Uri.tryParse(url);
            if (parsedUri != null && await canLaunchUrl(parsedUri)) {
              await launchUrl(parsedUri, mode: LaunchMode.externalApplication);
            }
            return NavigationActionPolicy.CANCEL;
          }
        }

        // 2. externalDomains → always open in external browser
        if (_matchesDomain(host, AppConfig.externalDomains)) {
          final parsedUri = Uri.tryParse(url);
          if (parsedUri != null && await canLaunchUrl(parsedUri)) {
            await launchUrl(parsedUri, mode: LaunchMode.externalApplication);
          }
          return NavigationActionPolicy.CANCEL;
        }

        // 3. allowedDomains → if list is non-empty, only allow listed domains
        if (AppConfig.allowedDomains.isNotEmpty &&
            !_matchesDomain(host, AppConfig.allowedDomains)) {
          final parsedUri = Uri.tryParse(url);
          if (parsedUri != null && await canLaunchUrl(parsedUri)) {
            await launchUrl(parsedUri, mode: LaunchMode.externalApplication);
          }
          return NavigationActionPolicy.CANCEL;
        }

        // 4. All other URLs → open inside WebView
        return NavigationActionPolicy.ALLOW;
      },

      // ── Permissions (WebRTC / camera / mic) ───────────────────────────────
      onPermissionRequest: (_, request) async {
        if (AppConfig.enableWebRTC) {
          await _requestWebRTCPermissions();
          return PermissionResponse(
            resources: request.resources,
            action: PermissionResponseAction.GRANT,
          );
        }
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.DENY,
        );
      },

      // ── Geolocation ───────────────────────────────────────────────────────
      onGeolocationPermissionsShowPrompt: (_, origin) async {
        if (AppConfig.enableGeolocation) {
          await _requestGeolocationPermission();
          return GeolocationPermissionShowPromptResponse(
            origin: origin,
            allow: true,
            retain: true,
          );
        }
        return GeolocationPermissionShowPromptResponse(
          origin: origin,
          allow: false,
          retain: false,
        );
      },

      // ── File download ─────────────────────────────────────────────────────
      // File upload on Android is handled natively by the plugin
      // (system file picker opens automatically when <input type="file"> is clicked).
      onDownloadStartRequest: (_, request) {
        if (!AppConfig.enableFileDownload) return;
        DownloadService.instance.download(
          context: context,
          url: request.url.toString(),
          suggestedFilename: request.suggestedFilename,
        );
      },

      // ── JS Dialogs — alert / confirm / prompt ────────────────────────────
      onJsAlert: (_, request) async {
        if (!context.mounted) return JsAlertResponse(handledByClient: false);
        final host = request.url?.host;
        await WebDialog.alert(
          context,
          message: request.message ?? '',
          host: host,
        );
        return JsAlertResponse(handledByClient: true);
      },

      onJsConfirm: (_, request) async {
        if (!context.mounted) return JsConfirmResponse(handledByClient: false);
        final confirmed = await WebDialog.confirm(
          context,
          message: request.message ?? '',
          host: request.url?.host,
        );
        return JsConfirmResponse(
          handledByClient: true,
          action: confirmed
              ? JsConfirmResponseAction.CONFIRM
              : JsConfirmResponseAction.CANCEL,
        );
      },

      onJsPrompt: (_, request) async {
        if (!context.mounted) return JsPromptResponse(handledByClient: false);
        final inputValue = await WebDialog.prompt(
          context,
          message: request.message ?? '',
          defaultValue: request.defaultValue,
          host: request.url?.host,
        );
        return JsPromptResponse(
          handledByClient: true,
          action: inputValue != null
              ? JsPromptResponseAction.CONFIRM
              : JsPromptResponseAction.CANCEL,
          value: inputValue,
        );
      },

      // ── Console log ───────────────────────────────────────────────────────
      onConsoleMessage: (_, msg) {
        if (kDebugMode) {
          debugPrint('[WebView] ${msg.messageLevel}: ${msg.message}');
        }
      },
    );
  }
}
