import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  DownloadService._();
  static final DownloadService instance = DownloadService._();

  final Dio _dio = Dio();

  Future<void> download({
    required BuildContext context,
    required String url,
    String? suggestedFilename,
  }) async {
    final messenger = ScaffoldMessenger.of(context);

    if (!await _requestPermission(messenger)) return;

    final dir = await _downloadDirectory();
    if (dir == null) {
      _showSnack(messenger, 'Tidak dapat menemukan folder Downloads.');
      return;
    }

    final filename = _resolveFilename(url, suggestedFilename);
    final savePath = '${dir.path}/$filename';

    _showSnack(messenger, 'Mengunduh $filename…');

    try {
      await _dio.download(url, savePath);
      _showSnack(
        messenger,
        'Download selesai: $filename',
        action: SnackBarAction(
          label: 'BUKA',
          onPressed: () => OpenFilex.open(savePath),
        ),
      );
    } on DioException catch (e) {
      _showSnack(messenger, 'Download gagal: ${e.message}');
    }
  }

  Future<bool> _requestPermission(ScaffoldMessengerState messenger) async {
    if (Platform.isAndroid) {
      if (!await Permission.storage.isGranted) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          _showSnack(messenger, 'Izin penyimpanan diperlukan untuk download.');
          return false;
        }
      }
    }
    return true;
  }

  Future<Directory?> _downloadDirectory() async {
    if (Platform.isAndroid) {
      final dir = Directory('/storage/emulated/0/Download');
      if (await dir.exists()) return dir;
      return getExternalStorageDirectory();
    }
    return getApplicationDocumentsDirectory();
  }

  String _resolveFilename(String url, String? suggested) {
    if (suggested != null && suggested.isNotEmpty) return suggested;
    final uri = Uri.tryParse(url);
    final name = uri?.pathSegments.lastOrNull ?? 'download';
    return name.contains('.') ? name : '$name.bin';
  }

  void _showSnack(
    ScaffoldMessengerState messenger,
    String message, {
    SnackBarAction? action,
  }) {
    messenger.showSnackBar(SnackBar(content: Text(message), action: action));
  }
}
