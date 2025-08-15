import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/character_model.dart';
import '../../core/services/huggingface_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/storage_service.dart';

class CharacterProvider extends ChangeNotifier {
  final HuggingFaceService _aiService;
  final Uuid _uuid = const Uuid();
  
  List<Character> _characters = [];
  bool _isLoading = false;
  String? _error;
  
  CharacterProvider(this._aiService);
  
  // Getters
  List<Character> get characters => _characters;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load characters for a project
  Future<void> loadCharacters(String projectId) async {
    _setLoading(true);
    _clearError();
    
    try {
      _characters = await FirestoreService.loadCharacters(projectId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load characters: $e');
    } finally {
      _setLoading(false);
    }
  }
   // Generate a new character using AI
  Future<Character?> generateCharacter({
    required String projectId,
    required String name,
    required String role,
    required String genre,
    String? additionalDetails,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('Starting character generation for: $name');
      
      // Check cache first
      final cacheKey = StorageService.generateCacheKey('character', {
        'name': name,
        'role': role,
        'genre': genre,
        'details': additionalDetails ?? '',
      });
      
      String? cachedResponse = StorageService.getCachedResponse(cacheKey);
      String generatedProfile;
      
      if (cachedResponse != null) {
        print('Using cached response for character: $name');
        generatedProfile = cachedResponse;
      } else {
        print('Generating new profile for character: $name');
        // Generate new profile
        generatedProfile = await _aiService.generateCharacterProfile(
          name: name,
          role: role,
          genre: genre,
          additionalDetails: additionalDetails,
        );
        
        print('Generated profile length: ${generatedProfile.length} characters');
        
        // Cache the response
        await StorageService.cacheResponse(cacheKey, generatedProfile);
      }
      
      // Parse the generated profile into sections
      final parsedProfile = _parseCharacterProfile(generatedProfile);
      print('Parsed profile sections: ${parsedProfile.keys.toList()}');
      
      final character = Character(
        id: _uuid.v4(),
        projectId: projectId,
        name: name,
        role: role,
        genre: genre,
        description: parsedProfile['description'] ?? '',
        appearance: parsedProfile['appearance'] ?? '',
        personality: parsedProfile['personality'] ?? '',
        backstory: parsedProfile['backstory'] ?? '',
        motivations: parsedProfile['motivations'] ?? '',
        skillsAbilities: parsedProfile['skillsAbilities'] ?? '',
        relationships: parsedProfile['relationships'] ?? '',
        dialogueStyle: parsedProfile['dialogueStyle'] ?? '',
        internalConflicts: parsedProfile['internalConflicts'] ?? '',
        traits: _extractTraits(parsedProfile['personality'] ?? ''),
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
      );
      
      print('Character created with ID: ${character.id}');
      await saveCharacter(character);
      print('Character saved successfully');
      return character;
      
    } catch (e) {
      print('Error generating character: $e');
      _setError('Failed to generate character: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Save character
  Future<void> saveCharacter(Character character) async {
    try {
      await FirestoreService.saveCharacter(character);
      
      // Update local list
      final index = _characters.indexWhere((c) => c.id == character.id);
      if (index >= 0) {
        _characters[index] = character;
      } else {
        _characters.add(character);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to save character: $e');
    }
  }
  
  // Update character
  Future<void> updateCharacter(Character character) async {
    final updatedCharacter = character.copyWith(
      lastModified: DateTime.now(),
    );
    
    await saveCharacter(updatedCharacter);
  }
  
  // Delete character
  Future<void> deleteCharacter(String characterId) async {
    try {
      await FirestoreService.deleteCharacter(characterId);
      _characters.removeWhere((c) => c.id == characterId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete character: $e');
    }
  }
  
  // Get character by ID
  Character? getCharacterById(String id) {
    try {
      return _characters.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Filter characters by traits
  List<Character> getCharactersByTraits(List<String> traits) {
    return _characters.where((character) {
      return traits.any((trait) => character.traits.contains(trait));
    }).toList();
  }
  
  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
  
  // Parse AI-generated character profile into sections
  Map<String, String> _parseCharacterProfile(String profile) {
    final sections = <String, String>{};
    final lines = profile.split('\n');
    String currentSection = '';
    String currentContent = '';
    
    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      
      // Check if line is a section header
      if (line.startsWith('**') && line.endsWith('**')) {
        // Save previous section
        if (currentSection.isNotEmpty) {
          sections[_normalizeKey(currentSection)] = currentContent.trim();
        }
        
        // Start new section
        currentSection = line.replaceAll('*', '').replaceAll(':', '').trim();
        currentContent = '';
      } else if (line.contains(':') && line.split(':')[0].length < 30) {
        // Alternative section header format
        if (currentSection.isNotEmpty) {
          sections[_normalizeKey(currentSection)] = currentContent.trim();
        }
        
        final parts = line.split(':');
        currentSection = parts[0].trim();
        currentContent = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
      } else {
        // Continue current section content
        currentContent += line + '\n';
      }
    }
    
    // Save last section
    if (currentSection.isNotEmpty) {
      sections[_normalizeKey(currentSection)] = currentContent.trim();
    }
    
    // If no sections found, treat entire content as description
    if (sections.isEmpty) {
      sections['description'] = profile;
    }
    
    return sections;
  }
  
  String _normalizeKey(String key) {
    final normalizedKey = key.toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('&', '')
        .replaceAll('-', '');
    
    // Map common variations to standard keys
    if (normalizedKey.contains('physical') || normalizedKey.contains('appearance')) {
      return 'appearance';
    } else if (normalizedKey.contains('personality') || normalizedKey.contains('traits')) {
      return 'personality';
    } else if (normalizedKey.contains('backstory') || normalizedKey.contains('background')) {
      return 'backstory';
    } else if (normalizedKey.contains('motivation')) {
      return 'motivations';
    } else if (normalizedKey.contains('skills') || normalizedKey.contains('abilities')) {
      return 'skillsAbilities';
    } else if (normalizedKey.contains('relationship')) {
      return 'relationships';
    } else if (normalizedKey.contains('dialogue') || normalizedKey.contains('speech')) {
      return 'dialogueStyle';
    } else if (normalizedKey.contains('internal') || normalizedKey.contains('conflict')) {
      return 'internalConflicts';
    }
    
    return normalizedKey;
  }
  
  List<String> _extractTraits(String personalityText) {
    // Simple trait extraction - look for common trait words
    final traits = <String>[];
    final text = personalityText.toLowerCase();
    
    for (String trait in [
      'brave', 'cowardly', 'intelligent', 'naive', 'loyal', 'treacherous',
      'kind', 'cruel', 'optimistic', 'pessimistic', 'ambitious', 'lazy',
      'honest', 'deceptive', 'patient', 'impulsive', 'confident', 'insecure',
      'generous', 'selfish', 'humble', 'arrogant', 'calm', 'temperamental'
    ]) {
      if (text.contains(trait)) {
        traits.add(trait[0].toUpperCase() + trait.substring(1));
      }
    }
    
    return traits;
  }
}
