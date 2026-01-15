/// Pagination metadata for quote lists
class PaginationMeta {
  final int currentPage;
  final int pageSize;
  final bool hasMore;
  final int? totalCount;

  const PaginationMeta({
    required this.currentPage,
    required this.pageSize,
    required this.hasMore,
    this.totalCount,
  });

  /// Create initial pagination state
  factory PaginationMeta.initial({int pageSize = 20}) {
    return PaginationMeta(
      currentPage: 0,
      pageSize: pageSize,
      hasMore: true,
    );
  }

  /// Get offset for current page
  int get offset => currentPage * pageSize;

  /// Create next page metadata
  PaginationMeta nextPage({required bool hasMore}) {
    return PaginationMeta(
      currentPage: currentPage + 1,
      pageSize: pageSize,
      hasMore: hasMore,
      totalCount: totalCount,
    );
  }

  /// Reset to first page
  PaginationMeta reset() {
    return PaginationMeta(
      currentPage: 0,
      pageSize: pageSize,
      hasMore: true,
      totalCount: totalCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaginationMeta &&
        other.currentPage == currentPage &&
        other.pageSize == pageSize &&
        other.hasMore == hasMore &&
        other.totalCount == totalCount;
  }

  @override
  int get hashCode {
    return currentPage.hashCode ^
        pageSize.hashCode ^
        hasMore.hashCode ^
        totalCount.hashCode;
  }

  @override
  String toString() {
    return 'PaginationMeta(page: $currentPage, size: $pageSize, hasMore: $hasMore, total: $totalCount)';
  }
}

