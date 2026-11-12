
class Book {
  Book({
    required this.title,
    required this.author,
    required this.pages,
    this.year,
    this.read = false,
  });

  Book.fromMap(Map<String, dynamic> m)
      : title = m['title'] as String,
        author = m['author'] as String,
        pages = m['pages'] as int,
        year = m['year'] as int?,
        read = m['read'] as bool? ?? false;

  final String title;
  final String author;
  final int pages;
  final int? year;
  bool read;

  @override
  String toString() {
    if (year == null) {
      return '$title — $author, $pages pp.';
    }

    return '$title — $author, $pages pp. ($year)';
  }
}

int totalPages(List<Book> books) {
  return books.fold(0, (sum, book) => sum + book.pages);
}

List<Book> unread(List<Book> books) {
  return books.where((book) => !book.read).toList();
}

List<String> authors(List<Book> books) {
  return books.map((book) => book.author).toSet().toList();
}

final seed = <Book>[
  Book(
    title: 'Абай жолы',
    author: 'М. Әуезов',
    pages: 4000,
    year: 1947,
    read: true,
  ),
  Book(
    title: 'Көшпенділер',
    author: 'І. Есенберлин',
    pages: 400,
    year: 1976,
  ),
  Book(
    title: 'Гаухар тас',
    author: 'Дулат Исабеков',
    pages: 320,
  ),
  Book(
    title: 'Жабайы Алма',
    author: 'Сайын Мұратбеков',
    pages: 320,
  ),
];
