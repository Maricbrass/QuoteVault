/// Domain model representing a quote
/// Independent of any backend implementation
class Quote {
  final String id;
  final String text;
  final String author;
  final String category;
  final DateTime createdAt;

  const Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    required this.createdAt,
  });

  /// Create Quote from JSON (from Supabase)
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      text: json['text'] as String,
      author: json['author'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert Quote to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  Quote copyWith({
    String? id,
    String? text,
    String? author,
    String? category,
    DateTime? createdAt,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Quote &&
        other.id == id &&
        other.text == text &&
        other.author == author &&
        other.category == category &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        author.hashCode ^
        category.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'Quote(id: $id, author: $author, category: $category)';
  }
}

