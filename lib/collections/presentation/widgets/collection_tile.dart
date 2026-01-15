import 'package:flutter/material.dart';
import '../../domain/collection.dart';

/// Widget displaying a collection tile
class CollectionTile extends StatelessWidget {
  final Collection collection;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CollectionTile({
    super.key,
    required this.collection,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.collections_bookmark,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          collection.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (collection.description != null &&
                collection.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                collection.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              '${collection.quoteCount} ${collection.quoteCount == 1 ? 'quote' : 'quotes'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                color: Theme.of(context).colorScheme.error,
                tooltip: 'Delete collection',
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

