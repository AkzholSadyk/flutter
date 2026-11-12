import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');

    final cartItems = context.watch<Cart>().items;
    final query = _searchText.trim().toLowerCase();

    final visibleBooks = books.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: 230,
          height: 42,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search books',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
          ),
        ),
        actions: const [CartBadge()],
      ),
      body: visibleBooks.isEmpty
          ? const Center(child: Text('No books found'))
          : ListView.builder(
              itemCount: visibleBooks.length,
              itemBuilder: (context, index) {
                final book = visibleBooks[index];

                debugPrint('row ${book.title}');

                final added = cartItems.contains(book);

                return ListTile(
                  title: Text(book.title),
                  subtitle: Text('${book.author} • ${book.price} ₸'),
                  trailing: added
                      ? const Text(
                          'Added',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      : OutlinedButton(
                          onPressed: () {
                            final ok = context.read<Cart>().add(book);

                            if (ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          child: const Text('Add'),
                        ),
                );
              },
            ),
    );
  }
}
