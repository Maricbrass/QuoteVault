import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/utils/logger.dart';
import '../../quotes/domain/quote.dart';

class QuoteCardExportService {
  Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      appLogger.info('Capturing widget as image');

      // Wait for next frame to ensure widget is rendered
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        appLogger.error('RenderRepaintBoundary not found');
        return null;
      }

      // Capture at high resolution
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        appLogger.error('Failed to convert image to bytes');
        return null;
      }

      final bytes = byteData.buffer.asUint8List();
      appLogger.info('Image captured: ${bytes.length} bytes');

      return bytes;
    } catch (e, stackTrace) {
      appLogger.error('Failed to capture widget', e, stackTrace);
      return null;
    }
  }

  /// Save image to temporary directory
  Future<String?> saveToTemp(Uint8List imageBytes, Quote quote) async {
    try {
      appLogger.info('Saving image to temp directory');

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'quote_${quote.id}_$timestamp.png';
      final filePath = '${tempDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      appLogger.info('Image saved to temp: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      appLogger.error('Failed to save image to temp', e, stackTrace);
      return null;
    }
  }

  /// Save image to device gallery
  Future<bool> saveToGallery(Uint8List imageBytes, Quote quote) async {
    try {
      appLogger.info('Saving image to gallery');

      // Request permissions
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        appLogger.warning('Storage permission denied');
        return false;
      }

      // Save to gallery
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'quote_${quote.id}_$timestamp';

      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        quality: 100,
        name: fileName,
      );

      final success = result['isSuccess'] == true;

      if (success) {
        appLogger.info('Image saved to gallery successfully');
      } else {
        appLogger.error('Failed to save image to gallery: $result');
      }

      return success;
    } catch (e, stackTrace) {
      appLogger.error('Failed to save image to gallery', e, stackTrace);
      return false;
    }
  }

  /// Request storage permission
  Future<bool> _requestStoragePermission() async {
    try {
      // Check platform
      if (Platform.isAndroid) {
        // Android 13+ (API 33+) doesn't need storage permission for media
        if (await Permission.photos.isGranted) {
          return true;
        }

        final status = await Permission.photos.request();
        if (status.isGranted) {
          return true;
        }

        // Fallback to storage permission for older Android versions
        if (await Permission.storage.isGranted) {
          return true;
        }

        final storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      } else if (Platform.isIOS) {
        // iOS requires photos permission
        if (await Permission.photos.isGranted) {
          return true;
        }

        final status = await Permission.photos.request();
        return status.isGranted;
      }

      return true;
    } catch (e, stackTrace) {
      appLogger.error('Failed to request storage permission', e, stackTrace);
      return false;
    }
  }

  /// Check if has storage permission
  Future<bool> hasStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        return await Permission.photos.isGranted ||
            await Permission.storage.isGranted;
      } else if (Platform.isIOS) {
        return await Permission.photos.isGranted;
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
