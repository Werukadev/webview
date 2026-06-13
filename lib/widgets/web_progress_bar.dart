import 'package:flutter/material.dart';
import '../config/app_config.dart';

class WebProgressBar extends StatelessWidget {
  const WebProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.showProgressBar || progress >= 1.0) {
      return const SizedBox.shrink();
    }
    return LinearProgressIndicator(
      value: progress,
      minHeight: AppConfig.progressBarColor == Colors.transparent ? 0 : 3,
      backgroundColor: Colors.transparent,
      valueColor: AlwaysStoppedAnimation<Color>(AppConfig.progressBarColor),
    );
  }
}
