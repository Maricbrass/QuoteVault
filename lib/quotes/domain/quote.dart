/// Domain model representing a quote
/// Independent of any backend implementation details
class Quote {
  final String id;
  final String text;
  final String author;
  final String? category;
  final List<String>? tags;
  final String? source;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Quote({
    required this.id,
    required this.text,
    required this.author,
    this.category,
    this.tags,
    this.source,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Quote from JSON
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      text: json['text'] as String,
      author: json['author'] as String,
      category: json['category'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
      source: json['source'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert Quote to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'category': category,
      'tags': tags,
      'source': source,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  Quote copyWith({
    String? id,
    String? text,
    String? author,
    String? category,
    List<String>? tags,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
        other.source == source;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        author.hashCode ^
        category.hashCode ^
        source.hashCode;
  }

  @override
  String toString() {
    return 'Quote(id: $id, text: $text, author: $author)';
  }
}

