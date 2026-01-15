import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/quote_search_controller.dart';
import '../../../core/constants/app_routes.dart';
import '../widgets/quote_card.dart';

/// Screen for searching quotes
class SearchQuotesScreen extends ConsumerStatefulWidget {
  const SearchQuotesScreen({super.key});

  @override
  ConsumerState<SearchQuotesScreen> createState() =>
      _SearchQuotesScreenState();
}

class _SearchQuotesScreenState extends ConsumerState<SearchQuotesScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      ref.read(quoteSearchProvider.notifier).loadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _handleSearch(String query) {
    ref.read(quoteSearchProvider.notifier).updateQuery(query);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(quoteSearchProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(quoteSearchProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF101022)
          : const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? const Color(0xFF101022).withOpacity(0.8)
            : const Color(0xFFF6F6F8).withOpacity(0.8),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: const Text(
          'Search & Browse',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            onPressed: () {
              context.push(AppRoutes.profile);
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: _buildBody(context, searchState, isDarkMode, colorScheme),
    );
  }

  Widget _buildBody(BuildContext context, QuoteSearchState searchState,
      bool isDarkMode, ColorScheme colorScheme) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey[200]!.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Icon(
                      Icons.search,
                      color: colorScheme.primary.withOpacity(0.6),
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search quotes, authors...',
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      onChanged: _handleSearch,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.tune,
                      color: isDarkMode ? Colors.white.withOpacity(0.4) : Colors.grey[400],
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!searchState.hasQuery) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Categories',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 4/5,
                children: [
                  _buildCategoryCard(
                    context,
                    title: 'Motivation',
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBdPF8JL8oLExkcXwbl0ayJyUw5pBEhqOK8ciiH_76kkwKZoewRNOlXJKxTU4O1jURDzp2oTjgVycmlYZqErulUjL6aIh_hoFhc6U_a49TUOpKQ2TGNgHmt84Q-_K9_b7V-YLKnmlV81PnykraLitbXAlOsNrvj_vELCLsn0-s1RYxOGZhARAl62LSHh1FqfCuBEZ9x2qHspX7scmF6IiCHigMkItpyQEAphgA84IelQcfGccEO7aGLKWVFBmZQ0jLySf3Uxor0R3M',
                    icon: Icons.bolt,
                    color: const Color(0xFF17B0CF),
                    onTap: () => context.push(AppRoutes.quotes),
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Philosophy',
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAE7e2mwnRsQVfLXrA3EBGSo6eEvYU5gt1gW2u2CrYKDH8bN0CtFEqKTdxk-nF_SD93BQjYMhaBSpymkzjGafE60ffATfAOVVwFSd8Pj_Row4KeYIxyTHVbRQzzn4BBq6vhnpcpE72kwfAJtvh7ONPgFuF-jd1R_rAnhALKJGOWvWdAbF8Rka96J2ceyNunZRK7bAdXMJzp1tZTABuG6yIpsWaCbne3JjybPpSJlgDCauZeP9qoVD1Kw1NP30T8flWBfYaX7htuDIM',
                    icon: Icons.psychology,
                    color: const Color(0xFF4ECDC4),
                    onTap: () => context.push(AppRoutes.quotes),
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Minimalism',
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBg9FtMivxfojzlOYH2dh_1Lfgr6J8W-DvijbONO25KKZLgo1Vd_0eOrCw7Ui-qH0zrDQP8CMCFZnw2J3nqVSEJ8lAOXEDH1OL_kMHlqr7qz2azI81XnDtsdhSxD9kV6yM7oGNeqgWAw9PE2DxskmVVOyXGp-CO1_sz_3bIQxFr7gBLD1hm0GNsIVO1_7VSeO0rQF-1BIMBELbK71ak1A-y1fGiOz8D1ytXHLqMT67GTzeN-icg7bB_EuhtYOCcfhUpTSi0uevD8Us',
                    icon: Icons.clear_all,
                    color: const Color(0xFF45B7D1),
                    onTap: () => context.push(AppRoutes.quotes),
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Wisdom',
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAMibjy3iYaANplr9mOOvhZlepLyv5LblzSyJE-CsDYOrHffgYkkpAEnXHShO_i0tSMAP9A79lZBdn55KsnhWzkHj-sieW5Do4WUeNtc7mDT938E6bxmgCPpGzlhivS91Q-cRKg8-n7ApbGLrnFCnEdUgtH2GmePkBuii7lC9rx47ABgbGWr1JRO7hseR8JlDPHnbeaQk4bJ_asm69LKUjIC8qV-piAlhqZptc3fiQLLWnEoGhFr-rd3xwhNG6nzGC01AlaMCf3fsg',
                    icon: Icons.auto_stories,
                    color: const Color(0xFFFF6B6B),
                    onTap: () => context.push(AppRoutes.quotes),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Column(
                children: [
                  Container(
                    width: 192,
                    height: 192,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCgMz4XfgpI1cIrTAYurzG1WqGYexgEcCw-17fqRJ6vYeRu-bBPgAbDFnphHN2iVxdkf6p9BVHuMVFJfBzkaaznSdFFEmxx8XpO6EKtRJ4_ZuJUhazlLusjO8UvyWRJomzrdC76d1rfZqWBjlsmhb49fPRuHlL-agkMWbfoLFsvu3Wqnmo0C7tWPkUtX842XTF-HeT1H7IQSn169C5flkI69m-2Zq-qmPfM9D0b96GrgNH9aBRNaK6NWEwWXu_iDJP5S1f2cJrVfiE',
                        width: 192,
                        height: 192,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Begin your journey',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      children: [
                        const TextSpan(text: 'Discover timeless wisdom from the world\'s greatest thinkers. Try searching for '),
                        TextSpan(
                          text: '"Marcus Aurelius"',
                          style: TextStyle(
                            color: colorScheme.primary.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const TextSpan(text: ' or '),
                        TextSpan(
                          text: '"Happiness"',
                          style: TextStyle(
                            color: colorScheme.primary.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.quotes),
                    icon: const Icon(Icons.explore),
                    label: const Text('Explore Daily Quotes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else if (searchState.isSearching) ...[
          SliverToBoxAdapter(
            child: const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ] else if (searchState.errorMessage != null) ...[
          SliverToBoxAdapter(
            child: _buildErrorState(context, searchState.errorMessage!),
          ),
        ] else if (searchState.isEmpty) ...[
          SliverToBoxAdapter(
            child: _buildEmptyResults(context, searchState.searchQuery),
          ),
        ] else ...[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < searchState.results.length) {
                  final quote = searchState.results[index];
                  return QuoteCard(
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
                } else if (searchState.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'End of results',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
              },
              childCount: searchState.results.length + (searchState.isLoadingMore ? 1 : 0) + (!searchState.pagination.hasMore ? 1 : 0),
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: const SizedBox(height: 96),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context,
      {required String title,
      required String imageUrl,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Image with Gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Icon
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),

            // Title
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Search for quotes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter at least 2 characters to search',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Keep typing...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter at least 2 characters to search',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResults(BuildContext context, String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Search query: "$query"',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Search failed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _handleSearch(_searchController.text);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

