class Scene {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String purpose;
  final String characterActions;
  final String dialogue;
  final String conflict;
  final String setting;
  final String pacing;
  final String emotionalBeats;
  final String plotAdvancement;
  final String characterDevelopment;
  final int order;
  final DateTime createdAt;
  final DateTime lastModified;
  
  const Scene({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.purpose,
    required this.characterActions,
    required this.dialogue,
    required this.conflict,
    required this.setting,
    required this.pacing,
    required this.emotionalBeats,
    required this.plotAdvancement,
    required this.characterDevelopment,
    required this.order,
    required this.createdAt,
    required this.lastModified,
  });
  
  Scene copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    String? purpose,
    String? characterActions,
    String? dialogue,
    String? conflict,
    String? setting,
    String? pacing,
    String? emotionalBeats,
    String? plotAdvancement,
    String? characterDevelopment,
    int? order,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return Scene(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      purpose: purpose ?? this.purpose,
      characterActions: characterActions ?? this.characterActions,
      dialogue: dialogue ?? this.dialogue,
      conflict: conflict ?? this.conflict,
      setting: setting ?? this.setting,
      pacing: pacing ?? this.pacing,
      emotionalBeats: emotionalBeats ?? this.emotionalBeats,
      plotAdvancement: plotAdvancement ?? this.plotAdvancement,
      characterDevelopment: characterDevelopment ?? this.characterDevelopment,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'purpose': purpose,
      'characterActions': characterActions,
      'dialogue': dialogue,
      'conflict': conflict,
      'setting': setting,
      'pacing': pacing,
      'emotionalBeats': emotionalBeats,
      'plotAdvancement': plotAdvancement,
      'characterDevelopment': characterDevelopment,
      'order': order,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastModified': lastModified.millisecondsSinceEpoch,
    };
  }
  
  factory Scene.fromMap(Map<String, dynamic> map) {
    return Scene(
      id: map['id'] ?? '',
      projectId: map['projectId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      purpose: map['purpose'] ?? '',
      characterActions: map['characterActions'] ?? '',
      dialogue: map['dialogue'] ?? '',
      conflict: map['conflict'] ?? '',
      setting: map['setting'] ?? '',
      pacing: map['pacing'] ?? '',
      emotionalBeats: map['emotionalBeats'] ?? '',
      plotAdvancement: map['plotAdvancement'] ?? '',
      characterDevelopment: map['characterDevelopment'] ?? '',
      order: map['order'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastModified: DateTime.fromMillisecondsSinceEpoch(map['lastModified'] ?? 0),
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Scene && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
