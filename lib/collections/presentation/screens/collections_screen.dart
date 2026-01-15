import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../controllers/collections_controller.dart';
import '../widgets/collection_create_dialog.dart';
import '../widgets/collection_tile.dart';

/// Screen displaying user's collections
class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsState = ref.watch(collectionsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
        actions: [
          // Collections count badge
          if (collectionsState.collections.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Chip(
                  label: Text('${collectionsState.collections.length}'),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(context, ref, collectionsState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: collectionsState.isCreating
            ? null
            : () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Collection'),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    CollectionsState state,
  ) {
    // Loading state
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (state.errorMessage != null) {
      return _buildErrorState(context, ref, state.errorMessage!);
    }

    // Empty state
    if (state.collections.isEmpty) {
      return _buildEmptyState(context);
    }

    // List of collections
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(collectionsControllerProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.collections.length,
        itemBuilder: (context, index) {
          final collection = state.collections[index];
          return CollectionTile(
            collection: collection,
            onTap: () {
              context.push(
                '${AppRoutes.collections}/${collection.id}',
                extra: collection,
              );
            },
            onDelete: () async {
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
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.collections_bookmark_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No collections yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create collections to organize your favorite quotes',
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

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
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
              'Failed to load collections',
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
                ref.read(collectionsControllerProvider.notifier).loadCollections();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
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

