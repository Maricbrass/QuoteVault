/// Domain model for user favorites
class Favorite {
  final String id;
  final String userId;
  final String quoteId;
  final DateTime createdAt;

  const Favorite({
    required this.id,
    required this.userId,
    required this.quoteId,
    required this.createdAt,
  });

  /// Create Favorite from JSON
  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
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
    return other is Favorite &&
        other.id == id &&
        other.userId == userId &&
        other.quoteId == quoteId;
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode ^ quoteId.hashCode;

  @override
  String toString() => 'Favorite(id: $id, quoteId: $quoteId)';
}

