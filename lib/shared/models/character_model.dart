class Character {
  final String id;
  final String projectId;
  final String name;
  final String role;
  final String genre;
  final String description;
  final String appearance;
  final String personality;
  final String backstory;
  final String motivations;
  final String skillsAbilities;
  final String relationships;
  final String dialogueStyle;
  final String internalConflicts;
  final List<String> traits;
  final DateTime createdAt;
  final DateTime lastModified;
  
  const Character({
    required this.id,
    required this.projectId,
    required this.name,
    required this.role,
    required this.genre,
    required this.description,
    required this.appearance,
    required this.personality,
    required this.backstory,
    required this.motivations,
    required this.skillsAbilities,
    required this.relationships,
    required this.dialogueStyle,
    required this.internalConflicts,
    required this.traits,
    required this.createdAt,
    required this.lastModified,
  });
  
  Character copyWith({
    String? id,
    String? projectId,
    String? name,
    String? role,
    String? genre,
    String? description,
    String? appearance,
    String? personality,
    String? backstory,
    String? motivations,
    String? skillsAbilities,
    String? relationships,
    String? dialogueStyle,
    String? internalConflicts,
    List<String>? traits,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return Character(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      role: role ?? this.role,
      genre: genre ?? this.genre,
      description: description ?? this.description,
      appearance: appearance ?? this.appearance,
      personality: personality ?? this.personality,
      backstory: backstory ?? this.backstory,
      motivations: motivations ?? this.motivations,
      skillsAbilities: skillsAbilities ?? this.skillsAbilities,
      relationships: relationships ?? this.relationships,
      dialogueStyle: dialogueStyle ?? this.dialogueStyle,
      internalConflicts: internalConflicts ?? this.internalConflicts,
      traits: traits ?? this.traits,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'role': role,
      'genre': genre,
      'description': description,
      'appearance': appearance,
      'personality': personality,
      'backstory': backstory,
      'motivations': motivations,
      'skillsAbilities': skillsAbilities,
      'relationships': relationships,
      'dialogueStyle': dialogueStyle,
      'internalConflicts': internalConflicts,
      'traits': traits,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastModified': lastModified.millisecondsSinceEpoch,
    };
  }
  
  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      id: map['id'] ?? '',
      projectId: map['projectId'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      genre: map['genre'] ?? '',
      description: map['description'] ?? '',
      appearance: map['appearance'] ?? '',
      personality: map['personality'] ?? '',
      backstory: map['backstory'] ?? '',
      motivations: map['motivations'] ?? '',
      skillsAbilities: map['skillsAbilities'] ?? '',
      relationships: map['relationships'] ?? '',
      dialogueStyle: map['dialogueStyle'] ?? '',
      internalConflicts: map['internalConflicts'] ?? '',
      traits: List<String>.from(map['traits'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastModified: DateTime.fromMillisecondsSinceEpoch(map['lastModified'] ?? 0),
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Character && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
