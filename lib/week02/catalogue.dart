import 'models.dart';

class Library {
  final List<LibraryItem> items = [];
  late final DateTime openedAt;
  String? _cachedReport;

  void add(LibraryItem item) {
    items.add(item);
  }

  void open() {
    openedAt = DateTime.now();
  }

  Book? findByTitle(String title) {
    final matches = items.whereType<Book>().where((b) => b.title == title);
    return matches.isEmpty ? null : matches.first;
  }

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  List<String> get titles => items.map((i) => i.title).toList();

  List<Book> get recentBooks =>
      items.whereType<Book>().where((b) => b.year > 2010).toList();

  // fold works on an empty iterable because it takes a starting value;
  // reduce has no starting value and throws on an empty iterable instead.
  double get averagePages => items.whereType<Book>().isEmpty
      ? 0
      : items.whereType<Book>().fold<int>(0, (sum, b) => sum + b.pages) /
          items.whereType<Book>().length;

  Map<String, int> get authorBookCounts =>
      items.whereType<Book>().fold<Map<String, int>>(
        {},
        (map, b) => map..update(b.author.name, (v) => v + 1, ifAbsent: () => 1),
      );

  Set<String> get authorNames =>
      items.whereType<Book>().map((b) => b.author.name).toSet();

  Set<Genre> get genresPresent =>
      items.whereType<Book>().map((b) => b.genre).toSet();

  List<String> get displayLines => [
        'CATALOGUE',
        for (final b in items.whereType<Book>()) '${b.title} (${b.year})',
        ...authorNames,
        if (items.whereType<Book>().any((b) => b.pages == 0)) '(incomplete data)',
      ];

  String report() {
    _cachedReport ??= displayLines.join('\n');
    final cached = _cachedReport;
    return cached ?? '';
  }
}
