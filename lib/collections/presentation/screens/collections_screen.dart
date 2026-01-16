import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../controllers/collections_controller.dart';
import '../widgets/collection_create_dialog.dart';

/// Modern Collections Screen with search, featured section, and grid layout
class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const CollectionCreateDialog(),
    );

    if (result != null && context.mounted) {
      final name = result['name']!;
      final description = result['description'];

      final collection = await ref
          .read(collectionsControllerProvider.notifier)
          .createCollection(name: name, description: description);

      if (collection != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Collection "${collection.name}" created'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectionsState = ref.watch(collectionsControllerProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF101022)
          : const Color(0xFFF6F6F8),
      body: CustomScrollView(
        slivers: [
          // Modern Header
          SliverAppBar(
            pinned: true,
            elevation: 0,
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
              'Collections',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  onPressed: collectionsState.isCreating
                      ? null
                      : () => _showCreateDialog(context, ref),
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF1A1A3A)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.03 * 255).toInt()),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search your vault',
                    hintStyle: TextStyle(
                      color: isDarkMode
                          ? const Color(0xFF8C8CB4)
                          : const Color(0xFF4C4C9A),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDarkMode
                          ? const Color(0xFF8C8CB4)
                          : const Color(0xFF4C4C9A),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ),

          // Content Body
          _buildSliverBody(context, ref, collectionsState, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildSliverBody(
    BuildContext context,
    WidgetRef ref,
    CollectionsState state,
    bool isDarkMode,
  ) {
    // Loading state
    if (state.isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Error state
    if (state.errorMessage != null) {
      return SliverFillRemaining(
        child: _buildErrorState(context, ref, state.errorMessage!, isDarkMode),
      );
    }

    // Empty state
    if (state.collections.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(context, isDarkMode),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        // Featured Section
        if (state.collections.isNotEmpty)
          _buildFeaturedSection(context, state.collections.first, isDarkMode),

        // My Folders Section Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'My Folders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: isDarkMode ? Colors.white : const Color(0xFF0D0D1B),
            ),
          ),
        ),

        // Grid of Collections
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: state.collections.length,
            itemBuilder: (context, index) {
              final collection = state.collections[index];
              return _buildCollectionCard(
                context,
                ref,
                collection,
                index,
                isDarkMode,
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildFeaturedSection(
    BuildContext context,
    dynamic collection,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Featured',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: isDarkMode ? Colors.white : const Color(0xFF0D0D1B),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF1A1A3A)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode
                    ? const Color(0xFF2A2A4A)
                    : const Color(0xFFEEEEFF),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.05 * 255).toInt()),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Featured Image
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.auto_stories,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                ),
                // Featured Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RECENTLY VIEWED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: isDarkMode
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        collection.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDarkMode ? Colors.white : const Color(0xFF0D0D1B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${collection.quoteCount} Quotes',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? const Color(0xFF8C8CB4)
                                  : const Color(0xFF4C4C9A),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context.push(
                                '${AppRoutes.collections}/${collection.id}',
                                extra: collection,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Explore',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(
    BuildContext context,
    WidgetRef ref,
    dynamic collection,
    int index,
    bool isDarkMode,
  ) {
    // Predefined colors and icons for variety
    final colorSchemes = [
      {'bg': const Color(0xFFF3F4FF), 'darkBg': const Color(0xFF25254D), 'icon': Icons.wb_sunny, 'iconColor': const Color(0xFF1111D4)},
      {'bg': const Color(0xFFFFF7F0), 'darkBg': const Color(0xFF3D2D1D), 'icon': Icons.account_balance, 'iconColor': const Color(0xFFF59E0B)},
      {'bg': const Color(0xFFF0F9FF), 'darkBg': const Color(0xFF1D2D3D), 'icon': Icons.dark_mode, 'iconColor': const Color(0xFF0EA5E9)},
      {'bg': const Color(0xFFF0FDF4), 'darkBg': const Color(0xFF1D3D2D), 'icon': Icons.nature, 'iconColor': const Color(0xFF10B981)},
      {'bg': const Color(0xFFFDF2F8), 'darkBg': const Color(0xFF3D1D2D), 'icon': Icons.work, 'iconColor': const Color(0xFFEC4899)},
    ];

    final scheme = colorSchemes[index % colorSchemes.length];

    return GestureDetector(
      onTap: () {
        context.push(
          '${AppRoutes.collections}/${collection.id}',
          extra: collection,
        );
      },
      onLongPress: () => _showCollectionOptions(context, ref, collection),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF1A1A3A)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode
                ? const Color(0xFF2A2A4A)
                : const Color(0xFFEEEEFF),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.03 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Header
            Container(
              height: 112,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? scheme['darkBg'] as Color
                    : scheme['bg'] as Color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  scheme['icon'] as IconData,
                  size: 36,
                  color: scheme['iconColor'] as Color,
                ),
              ),
            ),
            // Collection Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : const Color(0xFF0D0D1B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${collection.quoteCount} Quotes',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode
                          ? const Color(0xFF8C8CB4)
                          : const Color(0xFF4C4C9A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCollectionOptions(
    BuildContext context,
    WidgetRef ref,
    dynamic collection,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Collection'),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await _showDeleteConfirmation(
                  context,
                  collection.name,
                );

                if (confirmed == true) {
                  try {
                    await ref
                        .read(collectionsControllerProvider.notifier)
                        .deleteCollection(collection.id);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Collection "${collection.name}" deleted'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete collection: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No collections yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create collections to organize your favorite quotes',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Create Collection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load collections',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(collectionsControllerProvider.notifier).loadCollections();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    String collectionName,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection'),
        content: Text(
          'Are you sure you want to delete "$collectionName"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

