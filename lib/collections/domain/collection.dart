/// Domain model for collections
class Collection {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final bool isCollaborative;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int quoteCount;

  const Collection({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    this.isCollaborative = false,
    required this.createdAt,
    required this.updatedAt,
    this.quoteCount = 0,
  });

  /// Create Collection from JSON
  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['owner_id'] as String,
      isCollaborative: json['is_collaborative'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      quoteCount: json['quote_count'] as int? ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'owner_id': ownerId,
      'is_collaborative': isCollaborative,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create copy with modified fields
  Collection copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    bool? isCollaborative,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? quoteCount,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      isCollaborative: isCollaborative ?? this.isCollaborative,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      quoteCount: quoteCount ?? this.quoteCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Collection && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'Collection(id: $id, name: $name, quotes: $quoteCount)';
}

