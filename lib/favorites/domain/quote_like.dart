/// Domain model for quote likes
class QuoteLike {
  final String id;
  final String userId;
  final String quoteId;
  final DateTime createdAt;

  const QuoteLike({
    required this.id,
    required this.userId,
    required this.quoteId,
    required this.createdAt,
  });

  /// Create QuoteLike from JSON
  factory QuoteLike.fromJson(Map<String, dynamic> json) {
    return QuoteLike(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      quoteId: json['quote_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'quote_id': quoteId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuoteLike &&
        other.id == id &&
        other.userId == userId &&
        other.quoteId == quoteId;
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode ^ quoteId.hashCode;

  @override
  String toString() => 'QuoteLike(id: $id, quoteId: $quoteId)';
}

