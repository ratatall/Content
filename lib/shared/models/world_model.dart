class World {
  final String id;
  final String projectId;
  final String name;
  final String genre;
  final String setting;
  final String tone;
  final String geography;
  final String society;
  final String politics;
  final String economy;
  final String technology;
  final String history;
  final String religion;
  final String dailyLife;
  final String conflicts;
  final String uniqueElements;
  final DateTime createdAt;
  final DateTime lastModified;
  
  const World({
    required this.id,
    required this.projectId,
    required this.name,
    required this.genre,
    required this.setting,
    required this.tone,
    required this.geography,
    required this.society,
    required this.politics,
    required this.economy,
    required this.technology,
    required this.history,
    required this.religion,
    required this.dailyLife,
    required this.conflicts,
    required this.uniqueElements,
    required this.createdAt,
    required this.lastModified,
  });
  
  World copyWith({
    String? id,
    String? projectId,
    String? name,
    String? genre,
    String? setting,
    String? tone,
    String? geography,
    String? society,
    String? politics,
    String? economy,
    String? technology,
    String? history,
    String? religion,
    String? dailyLife,
    String? conflicts,
    String? uniqueElements,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return World(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      genre: genre ?? this.genre,
      setting: setting ?? this.setting,
      tone: tone ?? this.tone,
      geography: geography ?? this.geography,
      society: society ?? this.society,
      politics: politics ?? this.politics,
      economy: economy ?? this.economy,
      technology: technology ?? this.technology,
      history: history ?? this.history,
      religion: religion ?? this.religion,
      dailyLife: dailyLife ?? this.dailyLife,
      conflicts: conflicts ?? this.conflicts,
      uniqueElements: uniqueElements ?? this.uniqueElements,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'genre': genre,
      'setting': setting,
      'tone': tone,
      'geography': geography,
      'society': society,
      'politics': politics,
      'economy': economy,
      'technology': technology,
      'history': history,
      'religion': religion,
      'dailyLife': dailyLife,
      'conflicts': conflicts,
      'uniqueElements': uniqueElements,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastModified': lastModified.millisecondsSinceEpoch,
    };
  }
  
  factory World.fromMap(Map<String, dynamic> map) {
    return World(
      id: map['id'] ?? '',
      projectId: map['projectId'] ?? '',
      name: map['name'] ?? '',
      genre: map['genre'] ?? '',
      setting: map['setting'] ?? '',
      tone: map['tone'] ?? '',
      geography: map['geography'] ?? '',
      society: map['society'] ?? '',
      politics: map['politics'] ?? '',
      economy: map['economy'] ?? '',
      technology: map['technology'] ?? '',
      history: map['history'] ?? '',
      religion: map['religion'] ?? '',
      dailyLife: map['dailyLife'] ?? '',
      conflicts: map['conflicts'] ?? '',
      uniqueElements: map['uniqueElements'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastModified: DateTime.fromMillisecondsSinceEpoch(map['lastModified'] ?? 0),
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is World && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
