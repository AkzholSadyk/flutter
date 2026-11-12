
import 'package:flutter/material.dart';

import 'add_book_screen.dart';
import 'detail_screen.dart';
import 'models/book.dart';
import 'widgets/book_tile.dart';

enum Filter { all, unread, read }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Book> _books = seed
      .map(
        (book) => Book(
          title: book.title,
          author: book.author,
          pages: book.pages,
          year: book.year,
          read: book.read,
        ),
      )
      .toList();

  Filter _filter = Filter.all;

  List<Book> get _visible => switch (_filter) {
        Filter.all => _books,
        Filter.unread => unread(_books),
        Filter.read =>
          _books.where((book) => book.read).toList(),
      };

  Widget _buildStat(
    BuildContext context,
    String label,
    int value,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: textTheme.headlineSmall,
          ),
          Text(
            label,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(Filter filter, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == filter,
      onSelected: (selected) {
        if (!selected) return;

        setState(() {
          _filter = filter;
        });
      },
    );
  }

  Future<void> _openDetails(Book book) async {
    final action = await Navigator.of(context).push<BookAction>(
      MaterialPageRoute(
        builder: (_) => DetailScreen(book: book),
      ),
    );

    if (!mounted) return;

    switch (action) {
      case null:
        break;
      case BookAction.toggleRead:
        setState(() {
          book.read = !book.read;
        });
      case BookAction.delete:
        setState(() {
          _books.remove(book);
        });
    }
  }

  Future<void> _addBook() async {
    final book = await Navigator.of(context).push<Book>(
      MaterialPageRoute(
        builder: (_) => const AddBookScreen(),
      ),
    );

    if (!mounted) return;
    if (book == null) return;

    setState(() {
      _books.add(book);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reading list (${_visible.length})'),
      ),
      body: Column(
        children: [
          // Statistics header
          Card(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildStat(
                    context,
                    'Books',
                    _books.length,
                  ),
                  _buildStat(
                    context,
                    'Pages',
                    totalPages(_books),
                  ),
                  _buildStat(
                    context,
                    'Unread',
                    unread(_books).length,
                  ),
                ],
              ),
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip(Filter.all, 'All'),
                _buildFilterChip(Filter.unread, 'Unread'),
                _buildFilterChip(Filter.read, 'Read'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Books list
          Expanded(
            child: _visible.isEmpty
                ? Center(
                    child: Text(
                      'No books here',
                      style: textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      0,
                      12,
                      88,
                    ),
                    itemCount: _visible.length,
                    itemBuilder: (context, index) {
                      final book = _visible[index];

                      return BookTile(
                        book: book,
                        onToggle: () {
                          setState(() {
                            book.read = !book.read;
                          });
                        },
                        onTap: () => _openDetails(book),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        tooltip: 'Add book',
        child: const Icon(Icons.add),
      ),
    );
  }
}
