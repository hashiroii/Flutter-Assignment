import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _clear(BuildContext context) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('All books will be removed from the cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (sure != true) return;
    if (!context.mounted) return;
    context.read<Cart>().clear();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cart'),
      actions: [
        TextButton(
          onPressed: () => _clear(context),
          child: const Text('Clear cart'),
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: Consumer<Cart>(
            builder: (context, cart, _) => ListView(
              children: [
                for (final b in cart.items)
                  ListTile(
                    title: Text(b.title),
                    subtitle: Text('${b.price} ₸'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('×${cart.qtyOf(b)}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => cart.increment(b),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => cart.remove(b),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        Consumer<Cart>(
          builder: (context, cart, child) => Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                child!,
                const Spacer(),
                Text(
                  '${cart.total} ₸',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.receipt_long),
              SizedBox(width: 8),
              Text('Total'),
            ],
          ),
        ),
      ],
    ),
  );
}
