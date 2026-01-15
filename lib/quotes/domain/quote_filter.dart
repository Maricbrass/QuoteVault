/// Filter criteria for quote queries
class QuoteFilter {
  final String? category;
  final String? author;
  final String? searchQuery;

  const QuoteFilter({
    this.category,
    this.author,
    this.searchQuery,
  });

  /// Check if filter has any active criteria
  bool get hasActiveFilters =>
      category != null || author != null || searchQuery != null;

  /// Create empty filter
  factory QuoteFilter.empty() => const QuoteFilter();

  /// Create filter with category
  factory QuoteFilter.byCategory(String category) =>
      QuoteFilter(category: category);

  /// Create filter with author
  factory QuoteFilter.byAuthor(String author) => QuoteFilter(author: author);

  /// Create filter with search query
  factory QuoteFilter.bySearchQuery(String query) =>
      QuoteFilter(searchQuery: query);

  /// Create a copy with modified fields
  QuoteFilter copyWith({
    String? category,
    String? author,
    String? searchQuery,
    bool clearCategory = false,
    bool clearAuthor = false,
    bool clearSearchQuery = false,
  }) {
    return QuoteFilter(
      category: clearCategory ? null : (category ?? this.category),
      author: clearAuthor ? null : (author ?? this.author),
      searchQuery:
          clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuoteFilter &&
        other.category == category &&
        other.author == author &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    return category.hashCode ^ author.hashCode ^ searchQuery.hashCode;
  }

  @override
  String toString() {
    return 'QuoteFilter(category: $category, author: $author, searchQuery: $searchQuery)';
  }
}

