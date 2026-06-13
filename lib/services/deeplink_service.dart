import 'dart:async';
import 'package:app_links/app_links.dart';
import '../config/app_config.dart';

class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final _appLinks = AppLinks();
  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();

  StreamSubscription<Uri>? _subscription;

  Stream<Uri> get onDeepLink => _controller.stream;

  Future<Uri?> init() async {
    if (!AppConfig.enableDeepLink) return null;

    _subscription = _appLinks.uriLinkStream.listen((uri) {
      if (_isHandled(uri)) _controller.add(uri);
    });

    final initial = await _appLinks.getInitialLink();
    if (initial != null && _isHandled(initial)) return initial;
    return null;
  }

  bool _isHandled(Uri uri) {
    if (uri.scheme == AppConfig.deepLinkScheme) {
      return true;
    }
    if (AppConfig.universalLinkDomain.isNotEmpty &&
        uri.host == AppConfig.universalLinkDomain) {
      return true;
    }
    return false;
  }

  /// Konversi deep link URI ke URL WebView.
  String resolveUrl(Uri uri) {
    if (uri.scheme == AppConfig.deepLinkScheme) {
      // myapp://open/path?query=1  →  https://base.url/path?query=1
      final base = Uri.parse(AppConfig.webUrl);
      return base
          .replace(
            path: uri.path.isEmpty ? base.path : uri.path,
            query: uri.query.isEmpty ? base.query : uri.query,
          )
          .toString();
    }
    return uri.toString();
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
