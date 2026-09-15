// ignore_for_file: avoid_print
import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();

  for (final raw in rawBooks) {
    library.add(Book.fromJson(raw));
  }

  library.open();

  print(library.displayLines.join('\n'));
  print('');
  print('Titles: ${library.titles}');
  print('Recent books: ${library.recentBooks.map((b) => b.title).toList()}');
  print('Average pages: ${library.averagePages}');
  print('Author counts: ${library.authorBookCounts}');
  print('Author names: ${library.authorNames}');
  print('Genres present: ${library.genresPresent}');
  print('Country of Clean Code: ${library.countryOf('Clean Code')}');
  print('Country of Design Patterns: ${library.countryOf('Design Patterns')}');
  print('Opened at: ${library.openedAt}');
  print(library.report());

  final magazine = Magazine(title: 'National Geographic', year: 2015, issue: 42);
  final ghost = Ghost(title: 'Untitled', year: 1990);
  print(magazine.describe());
  print(ghost.describe());

  final firstBook = library.findByTitle('Clean Code');
  if (firstBook != null) {
    print(firstBook.borrowLabel());
  }

  final books = library.items.whereType<Book>().toList();
  final stats = statsOf(books);
  print('Stats: count=${stats.count}, avgPages=${stats.avgPages}');

  print(describe(Empty()));
  print(describe(Ready(books)));
  print(describe(Broken('shelf collapsed')));
}
