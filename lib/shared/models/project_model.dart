class Project {
  final String id;
  final String name;
  final String description;
  final List<String> genres;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime lastModified;
  
  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.genres,
    required this.tags,
    required this.createdAt,
    required this.lastModified,
  });
  
  Project copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? genres,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'genres': genres,
      'tags': tags,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastModified': lastModified.millisecondsSinceEpoch,
    };
  }
  
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      genres: List<String>.from(map['genres'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastModified: DateTime.fromMillisecondsSinceEpoch(map['lastModified'] ?? 0),
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'Project(id: $id, name: $name, description: $description, genres: $genres, tags: $tags, createdAt: $createdAt, lastModified: $lastModified)';
  }
}
