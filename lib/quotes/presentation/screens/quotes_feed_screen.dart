import 'dart:ui';

import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart' show Scaffold, AppBar, Text, TextStyle, ScaffoldMessenger, SnackBar, Column, RefreshIndicator, CustomScrollView, ScrollController, SliverToBoxAdapter, SliverList, SliverChildBuilderDelegate, SliverFillRemaining, Padding, EdgeInsets, Container, BoxDecoration, BorderRadius, ThemeData, Theme, Brightness, Color, BoxShadow, Offset, BoxShape, Center, CircularProgressIndicator, Row, Expanded, TextButton, ElevatedButton, ListView, InkWell, MainAxisAlignment, Widget, BuildContext, FontWeight, Colors, Axis, SizedBox, Icon, BackdropFilter, ClipRect, Icons, IconButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../daily_quote/presentation/widgets/daily_quote_widget.dart';
import '../controllers/quote_feed_controller.dart';
import '../providers/quote_providers.dart';
import '../widgets/quote_card.dart' as quote_widgets;

/// Home feed screen displaying paginated quotes
class QuotesFeedScreen extends ConsumerStatefulWidget {
  const QuotesFeedScreen({super.key});

  @override
  ConsumerState<QuotesFeedScreen> createState() => _QuotesFeedScreenState();
}

class _QuotesFeedScreenState extends ConsumerState<QuotesFeedScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      ref.read(quoteFeedProvider.notifier).loadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _handleRefresh() async {
    await ref.read(quoteFeedProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(quoteFeedProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF101022)
          : const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF101022).withOpacity(0.8)
            : const Color(0xFFF6F6F8).withOpacity(0.8),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.format_quote,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: const Text(
          'QuoteVault',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          // Notifications button
          IconButton(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            onPressed: () {
              // TODO: Navigate to notifications
            },
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline banner
          const OfflineBanner(),

          // Main content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Daily Quote Widget
            const SliverToBoxAdapter(
              child: DailyQuoteWidget(),
            ),

            // Categories section
            SliverToBoxAdapter(
              child: _buildCategoriesSection(context),
            ),

            // Feed header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Latest Quotes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),

            // Error message
            if (feedState.errorMessage != null)
              SliverToBoxAdapter(
                child: _buildErrorMessage(context, feedState.errorMessage!),
              ),

            // Loading state
            if (feedState.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )

            // Empty state
            else if (feedState.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(context),
              )

            // Quote list
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < feedState.quotes.length) {
                      final quote = feedState.quotes[index];
                      return quote_widgets.QuoteCard(
                        quote: quote,
                        onTap: () {
                          // TODO: Navigate to quote detail
                        },
                        onAddToCollection: () {
                          // TODO: Show collection picker dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Collections feature coming in next update'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    }
                    return null;
                  },
                  childCount: feedState.quotes.length,
                ),
              ),

            // Loading more indicator
            if (feedState.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),

            // End of list indicator
            if (!feedState.pagination.hasMore && feedState.hasData)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'You\'ve reached the end',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              ),
          ],
        ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCategoriesSection(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length + 1, // +1 for "For You" chip
            itemBuilder: (context, index) {
              if (index == 0) {
                // "For You" chip
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'For You',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }

              final category = categories[index - 1];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    context.push('${AppRoutes.quotes}/category/$category');
                  },
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String message) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          material.Icon(
            material.Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(quoteFeedProvider.notifier).refresh();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          material.Icon(
            material.Icons.format_quote,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No quotes found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try refreshing or check back later',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(quoteFeedProvider.notifier).refresh();
            },
            icon: const material.Icon(material.Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

