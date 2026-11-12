import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear cart?'),
          content: const Text('All books will be removed from your cart.'),
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
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;

    if (shouldClear == true) {
      context.read<Cart>().clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cart'),
        actions: [
          TextButton(
            onPressed: () => _confirmClear(context),
            child: const Text('Clear cart'),
          ),
        ],
      ),
      body: Consumer<Cart>(
        builder: (context, cart, _) {
          final items = cart.items;

          if (items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final book = items[index];
                    final quantity = cart.qtyOf(book);

                    return ListTile(
                      title: Text(book.title),
                      subtitle: Text('${book.price} ₸ each • Qty: $quantity'),
                      leading: IconButton(
                        tooltip: 'Remove book',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          cart.remove(book);
                        },
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('×$quantity'),
                          IconButton(
                            tooltip: 'Increase quantity',
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              cart.increment(book);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Consumer<Cart>(
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long),
                      SizedBox(width: 8),
                      Text('Total'),
                    ],
                  ),
                  builder: (context, cart, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        child!,
                        Text(
                          '${cart.total} ₸',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
