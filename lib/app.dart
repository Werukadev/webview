import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'screens/webview_screen.dart';

class App extends StatelessWidget {
  const App({super.key, this.initialDeepLinkUrl});

  final String? initialDeepLinkUrl;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConfig.progressBarColor,
        ),
        useMaterial3: true,
      ),
      home: WebViewScreen(initialUrl: initialDeepLinkUrl),
    );
  }
}
