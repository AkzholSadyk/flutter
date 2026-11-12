
import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.book,
  });

  final Book book;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete book?'),
          content: Text("Delete '${book.title}'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;

    if (confirmed == true) {
      Navigator.of(context).pop(BookAction.delete);
    }
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      title: Text(
        label,
        style: textTheme.labelLarge,
      ),
      subtitle: Text(
        value,
        style: textTheme.bodyLarge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    child: Text(
                      book.title.isEmpty ? '?' : book.title[0],
                      style: textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    book.title,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.author,
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                _detailRow(
                  context,
                  'Author',
                  book.author,
                ),
                _detailRow(
                  context,
                  'Pages',
                  '${book.pages}',
                ),
                _detailRow(
                  context,
                  'Year',
                  book.year?.toString() ?? 'Year unknown',
                ),
                _detailRow(
                  context,
                  'Reading status',
                  book.read ? 'Read' : 'Unread',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop(
                BookAction.toggleRead,
              );
            },
            icon: Icon(
              book.read ? Icons.markunread : Icons.check,
            ),
            label: Text(
              book.read ? 'Mark as unread' : 'Mark as read',
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () => _delete(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
