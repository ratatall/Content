import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/world_model.dart';
import '../../core/services/openai_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/storage_service.dart';

class WorldProvider extends ChangeNotifier {
  final OpenAIService _openaiService;
  final Uuid _uuid = const Uuid();
  
  List<World> _worlds = [];
  bool _isLoading = false;
  String? _error;
  
  WorldProvider(this._openaiService);
  
  // Getters
  List<World> get worlds => _worlds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load worlds for a project
  Future<void> loadWorlds(String projectId) async {
    _setLoading(true);
    _clearError();
    
    try {
      _worlds = await FirestoreService.loadWorlds(projectId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load worlds: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Generate a new world using AI
  Future<World?> generateWorld({
    required String projectId,
    required String name,
    required String genre,
    required String setting,
    required String tone,
    String? additionalDetails,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('Starting world generation for: $name');
      
      // Check cache first
      final cacheKey = StorageService.generateCacheKey('world', {
        'name': name,
        'genre': genre,
        'setting': setting,
        'tone': tone,
        'details': additionalDetails ?? '',
      });
      
      String? cachedResponse = StorageService.getCachedResponse(cacheKey);
      String generatedWorld;
      
      if (cachedResponse != null) {
        print('Using cached response for world: $name');
        generatedWorld = cachedResponse;
      } else {
        print('Generating new world description for: $name');
        // Generate new world description
        generatedWorld = await _openaiService.generateWorldDescription(
          genre: genre,
          setting: setting,
          tone: tone,
          additionalDetails: additionalDetails,
        );
        
        print('Generated world description length: ${generatedWorld.length} characters');
        
        // Cache the response
        await StorageService.cacheResponse(cacheKey, generatedWorld);
      }
      
      // Parse the generated world into sections
      final parsedWorld = _parseWorldDescription(generatedWorld);
      print('Parsed world sections: ${parsedWorld.keys.toList()}');
      
      final world = World(
        id: _uuid.v4(),
        projectId: projectId,
        name: name,
        genre: genre,
        setting: setting,
        tone: tone,
        geography: parsedWorld['geography'] ?? '',
        society: parsedWorld['society'] ?? '',
        politics: parsedWorld['politics'] ?? '',
        economy: parsedWorld['economy'] ?? '',
        technology: parsedWorld['technology'] ?? '',
        history: parsedWorld['history'] ?? '',
        religion: parsedWorld['religion'] ?? '',
        dailyLife: parsedWorld['dailyLife'] ?? '',
        conflicts: parsedWorld['conflicts'] ?? '',
        uniqueElements: parsedWorld['uniqueElements'] ?? '',
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
      );
      
      print('World created with ID: ${world.id}');
      await saveWorld(world);
      print('World saved successfully');
      return world;
      
    } catch (e) {
      print('Error generating world: $e');
      _setError('Failed to generate world: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Save world
  Future<void> saveWorld(World world) async {
    try {
      await FirestoreService.saveWorld(world);
      
      // Update local list
      final index = _worlds.indexWhere((w) => w.id == world.id);
      if (index >= 0) {
        _worlds[index] = world;
      } else {
        _worlds.add(world);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to save world: $e');
    }
  }
  
  // Update world
  Future<void> updateWorld(World world) async {
    final updatedWorld = world.copyWith(
      lastModified: DateTime.now(),
    );
    
    await saveWorld(updatedWorld);
  }
  
  // Delete world
  Future<void> deleteWorld(String worldId) async {
    try {
      await FirestoreService.deleteWorld(worldId);
      _worlds.removeWhere((w) => w.id == worldId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete world: $e');
    }
  }
  
  // Get world by ID
  World? getWorldById(String id) {
    try {
      return _worlds.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Filter worlds by genre
  List<World> getWorldsByGenre(String genre) {
    return _worlds.where((world) => world.genre == genre).toList();
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
  
  // Parse AI-generated world description into sections
  Map<String, String> _parseWorldDescription(String description) {
    final sections = <String, String>{};
    final lines = description.split('\n');
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
    
    // If no sections found, treat entire content as geography
    if (sections.isEmpty) {
      sections['geography'] = description;
    }
    
    return sections;
  }
  
  String _normalizeKey(String key) {
    final normalizedKey = key.toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('&', '')
        .replaceAll('-', '');
    
    // Map common variations to standard keys
    if (normalizedKey.contains('geography') || normalizedKey.contains('environment') || normalizedKey.contains('landscape')) {
      return 'geography';
    } else if (normalizedKey.contains('society') || normalizedKey.contains('culture') || normalizedKey.contains('social')) {
      return 'society';
    } else if (normalizedKey.contains('politics') || normalizedKey.contains('government') || normalizedKey.contains('ruling')) {
      return 'politics';
    } else if (normalizedKey.contains('economy') || normalizedKey.contains('trade') || normalizedKey.contains('commerce')) {
      return 'economy';
    } else if (normalizedKey.contains('technology') || normalizedKey.contains('tech') || normalizedKey.contains('magic')) {
      return 'technology';
    } else if (normalizedKey.contains('history') || normalizedKey.contains('historical') || normalizedKey.contains('past')) {
      return 'history';
    } else if (normalizedKey.contains('religion') || normalizedKey.contains('belief') || normalizedKey.contains('spiritual')) {
      return 'religion';
    } else if (normalizedKey.contains('daily') || normalizedKey.contains('life') || normalizedKey.contains('everyday')) {
      return 'dailyLife';
    } else if (normalizedKey.contains('conflict') || normalizedKey.contains('tension') || normalizedKey.contains('problem')) {
      return 'conflicts';
    } else if (normalizedKey.contains('unique') || normalizedKey.contains('special') || normalizedKey.contains('distinctive')) {
      return 'uniqueElements';
    }
    
    return normalizedKey;
  }
}
