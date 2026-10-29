import 'package:flutter/material.dart';

import 'book_row.dart';
import 'cart_badge.dart';
import 'models/book.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String _query = '';

  List<Book> get _shown {
    final q = _query.trim().toLowerCase();
    return books
        .where(
          (b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final shown = _shown;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search books',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: const [CartBadge()],
      ),
      body: ListView.builder(
        itemCount: shown.length,
        itemBuilder: (context, i) => BookRow(book: shown[i]),
      ),
    );
  }
}
