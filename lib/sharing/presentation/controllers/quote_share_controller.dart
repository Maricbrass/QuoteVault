import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import '../../quotes/domain/quote.dart';
import '../domain/quote_card_style.dart';
import '../services/quote_card_export_service.dart';
import '../services/quote_share_service.dart';

/// State for quote sharing
class QuoteShareState {
  final bool isProcessing;
  final bool isGeneratingImage;
  final String? errorMessage;
  final String? successMessage;
  final Uint8List? generatedImage;
  final String? imagePath;

  const QuoteShareState({
    this.isProcessing = false,
    this.isGeneratingImage = false,
    this.errorMessage,
    this.successMessage,
    this.generatedImage,
    this.imagePath,
  });

  QuoteShareState copyWith({
    bool? isProcessing,
    bool? isGeneratingImage,
    String? errorMessage,
    String? successMessage,
    Uint8List? generatedImage,
    String? imagePath,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearImage = false,
  }) {
    return QuoteShareState(
      isProcessing: isProcessing ?? this.isProcessing,
      isGeneratingImage: isGeneratingImage ?? this.isGeneratingImage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      generatedImage: clearImage ? null : (generatedImage ?? this.generatedImage),
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
    );
  }
}

/// Controller for quote sharing
class QuoteShareController extends StateNotifier<QuoteShareState> {
  final QuoteShareService _shareService;
  final QuoteCardExportService _exportService;

  QuoteShareController(
    this._shareService,
    this._exportService,
  ) : super(const QuoteShareState());

  /// Share quote as text
  Future<void> shareText(Quote quote) async {
    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      appLogger.info('Sharing quote as text: ${quote.id}');

      await _shareService.shareQuoteText(quote);

      state = state.copyWith(
        isProcessing: false,
        successMessage: 'Quote shared successfully',
      );

      appLogger.info('Quote text shared');
    } catch (e, stackTrace) {
      appLogger.error('Failed to share quote text', e, stackTrace);
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Failed to share quote. Please try again.',
      );
    }
  }

  /// Generate quote card image
  Future<void> generateImage(GlobalKey key, Quote quote) async {
    state = state.copyWith(
      isGeneratingImage: true,
      clearError: true,
      clearImage: true,
    );

    try {
      appLogger.info('Generating quote card image');

      // Capture widget as image
      final imageBytes = await _exportService.captureWidget(key);

      if (imageBytes == null) {
        throw Exception('Failed to capture image');
      }

      // Save to temp directory
      final tempPath = await _exportService.saveToTemp(imageBytes, quote);

      state = state.copyWith(
        isGeneratingImage: false,
        generatedImage: imageBytes,
        imagePath: tempPath,
      );

      appLogger.info('Quote card image generated');
    } catch (e, stackTrace) {
      appLogger.error('Failed to generate image', e, stackTrace);
      state = state.copyWith(
        isGeneratingImage: false,
        errorMessage: 'Failed to generate image. Please try again.',
      );
    }
  }

  /// Save image to gallery
  Future<void> saveToGallery(Uint8List imageBytes, Quote quote) async {
    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      appLogger.info('Saving image to gallery');

      final success = await _exportService.saveToGallery(imageBytes, quote);

      if (success) {
        state = state.copyWith(
          isProcessing: false,
          successMessage: 'Image saved to gallery',
        );
      } else {
        state = state.copyWith(
          isProcessing: false,
          errorMessage: 'Failed to save image. Please check permissions.',
        );
      }
    } catch (e, stackTrace) {
      appLogger.error('Failed to save image to gallery', e, stackTrace);
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Failed to save image. Please try again.',
      );
    }
  }

  /// Share generated image
  Future<void> shareImage(String imagePath, Quote quote) async {
    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      appLogger.info('Sharing quote card image');

      await _shareService.shareFile(
        filePath: imagePath,
        fileName: 'quote_${quote.id}.png',
        text: 'Check out this quote by ${quote.author}',
      );

      state = state.copyWith(
        isProcessing: false,
        successMessage: 'Image shared successfully',
      );

      appLogger.info('Quote card image shared');
    } catch (e, stackTrace) {
      appLogger.error('Failed to share image', e, stackTrace);
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Failed to share image. Please try again.',
      );
    }
  }

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  /// Clear generated image
  void clearImage() {
    state = state.copyWith(clearImage: true);
  }
}

/// Provider for quote share service
final quoteShareServiceProvider = Provider<QuoteShareService>((ref) {
  return QuoteShareService();
});

/// Provider for quote card export service
final quoteCardExportServiceProvider = Provider<QuoteCardExportService>((ref) {
  return QuoteCardExportService();
});

/// Provider for quote share controller
final quoteShareControllerProvider =
    StateNotifierProvider<QuoteShareController, QuoteShareState>((ref) {
  final shareService = ref.watch(quoteShareServiceProvider);
  final exportService = ref.watch(quoteCardExportServiceProvider);
  return QuoteShareController(shareService, exportService);
});

/// Provider for selected quote card style
final selectedQuoteCardStyleProvider =
    StateProvider<QuoteCardStyle>((ref) => QuoteCardStyle.classic());

