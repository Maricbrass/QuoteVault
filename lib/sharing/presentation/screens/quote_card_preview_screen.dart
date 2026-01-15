import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../quotes/domain/quote.dart';
import '../../domain/quote_card_style.dart';
import '../controllers/quote_share_controller.dart';
import '../widgets/exportable_quote_card.dart';

/// Screen for previewing and customizing quote card before sharing
class QuoteCardPreviewScreen extends ConsumerStatefulWidget {
  final Quote quote;

  const QuoteCardPreviewScreen({
    super.key,
    required this.quote,
  });

  @override
  ConsumerState<QuoteCardPreviewScreen> createState() =>
      _QuoteCardPreviewScreenState();
}

class _QuoteCardPreviewScreenState
    extends ConsumerState<QuoteCardPreviewScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  late PageController _pageController;
  int _currentStyleIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _generateAndSave() async {
    // Generate image
    await ref
        .read(quoteShareControllerProvider.notifier)
        .generateImage(_repaintKey, widget.quote);

    final shareState = ref.read(quoteShareControllerProvider);

    if (shareState.generatedImage != null && mounted) {
      // Save to gallery
      await ref
          .read(quoteShareControllerProvider.notifier)
          .saveToGallery(shareState.generatedImage!, widget.quote);
    }
  }

  Future<void> _generateAndShare() async {
    // Generate image
    await ref
        .read(quoteShareControllerProvider.notifier)
        .generateImage(_repaintKey, widget.quote);

    final shareState = ref.read(quoteShareControllerProvider);

    if (shareState.imagePath != null && mounted) {
      // Share image
      await ref
          .read(quoteShareControllerProvider.notifier)
          .shareImage(shareState.imagePath!, widget.quote);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedStyle = ref.watch(selectedQuoteCardStyleProvider);
    final shareState = ref.watch(quoteShareControllerProvider);
    final allStyles = QuoteCardStyle.allStyles();

    // Show success message
    if (shareState.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(shareState.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(quoteShareControllerProvider.notifier).clearMessages();
      });
    }

    // Show error message
    if (shareState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(shareState.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        ref.read(quoteShareControllerProvider.notifier).clearMessages();
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Quote Card'),
        actions: [
          // Save to gallery
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: shareState.isProcessing || shareState.isGeneratingImage
                ? null
                : _generateAndSave,
            tooltip: 'Save to Gallery',
          ),
          // Share
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: shareState.isProcessing || shareState.isGeneratingImage
                ? null
                : _generateAndShare,
            tooltip: 'Share',
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview area
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Card preview with swipe
                  PageView.builder(
                    controller: _pageController,
                    itemCount: allStyles.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentStyleIndex = index;
                      });
                      ref.read(selectedQuoteCardStyleProvider.notifier).state =
                          allStyles[index];
                    },
                    itemBuilder: (context, index) {
                      final style = allStyles[index];
                      return Center(
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: RepaintBoundary(
                            key: index == _currentStyleIndex
                                ? _repaintKey
                                : null,
                            child: ExportableQuoteCard(
                              quote: widget.quote,
                              style: style,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Loading overlay
                  if (shareState.isGeneratingImage || shareState.isProcessing)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Style selector
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Style name
                Text(
                  selectedStyle.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedStyle.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // Style thumbnails
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: allStyles.length,
                    itemBuilder: (context, index) {
                      final style = allStyles[index];
                      final isSelected = index == _currentStyleIndex;

                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            gradient: style.backgroundGradient,
                            color: style.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              style.name[0],
                              style: TextStyle(
                                color: style.textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Page indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    allStyles.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentStyleIndex
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

