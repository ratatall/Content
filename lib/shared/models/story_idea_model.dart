class StoryIdea {
  final String id;
  final String projectId;
  final String title;
  final String genre;
  final String tone;
  final String themes;
  final String coreConcept;
  final String protagonist;
  final String centralConflict;
  final String setting;
  final String stakes;
  final String uniqueElements;
  final List<String> plotPoints;
  final String characterRelationships;
  final String thematicElements;
  final String hook;
  final DateTime createdAt;
  final DateTime lastModified;
  
  const StoryIdea({
    required this.id,
    required this.projectId,
    required this.title,
    required this.genre,
    required this.tone,
    required this.themes,
    required this.coreConcept,
    required this.protagonist,
    required this.centralConflict,
    required this.setting,
    required this.stakes,
    required this.uniqueElements,
    required this.plotPoints,
    required this.characterRelationships,
    required this.thematicElements,
    required this.hook,
    required this.createdAt,
    required this.lastModified,
  });
  
  StoryIdea copyWith({
    String? id,
    String? projectId,
    String? title,
    String? genre,
    String? tone,
    String? themes,
    String? coreConcept,
    String? protagonist,
    String? centralConflict,
    String? setting,
    String? stakes,
    String? uniqueElements,
    List<String>? plotPoints,
    String? characterRelationships,
    String? thematicElements,
    String? hook,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return StoryIdea(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      tone: tone ?? this.tone,
      themes: themes ?? this.themes,
      coreConcept: coreConcept ?? this.coreConcept,
      protagonist: protagonist ?? this.protagonist,
      centralConflict: centralConflict ?? this.centralConflict,
      setting: setting ?? this.setting,
      stakes: stakes ?? this.stakes,
      uniqueElements: uniqueElements ?? this.uniqueElements,
      plotPoints: plotPoints ?? this.plotPoints,
      characterRelationships: characterRelationships ?? this.characterRelationships,
      thematicElements: thematicElements ?? this.thematicElements,
      hook: hook ?? this.hook,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'genre': genre,
      'tone': tone,
      'themes': themes,
      'coreConcept': coreConcept,
      'protagonist': protagonist,
      'centralConflict': centralConflict,
      'setting': setting,
      'stakes': stakes,
      'uniqueElements': uniqueElements,
      'plotPoints': plotPoints,
      'characterRelationships': characterRelationships,
      'thematicElements': thematicElements,
      'hook': hook,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastModified': lastModified.millisecondsSinceEpoch,
    };
  }
  
  factory StoryIdea.fromMap(Map<String, dynamic> map) {
    return StoryIdea(
      id: map['id'] ?? '',
      projectId: map['projectId'] ?? '',
      title: map['title'] ?? '',
      genre: map['genre'] ?? '',
      tone: map['tone'] ?? '',
      themes: map['themes'] ?? '',
      coreConcept: map['coreConcept'] ?? '',
      protagonist: map['protagonist'] ?? '',
      centralConflict: map['centralConflict'] ?? '',
      setting: map['setting'] ?? '',
      stakes: map['stakes'] ?? '',
      uniqueElements: map['uniqueElements'] ?? '',
      plotPoints: List<String>.from(map['plotPoints'] ?? []),
      characterRelationships: map['characterRelationships'] ?? '',
      thematicElements: map['thematicElements'] ?? '',
      hook: map['hook'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastModified: DateTime.fromMillisecondsSinceEpoch(map['lastModified'] ?? 0),
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoryIdea && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
