import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/story_idea_model.dart';
import '../../core/services/huggingface_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/storage_service.dart';

class StoryIdeaProvider extends ChangeNotifier {
  final HuggingFaceService _aiService;
  final Uuid _uuid = const Uuid();
  
  List<StoryIdea> _storyIdeas = [];
  bool _isLoading = false;
  String? _error;
  
  StoryIdeaProvider(this._aiService);
  
  // Getters
  List<StoryIdea> get storyIdeas => _storyIdeas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load story ideas for a project
  Future<void> loadStoryIdeas(String projectId) async {
    _setLoading(true);
    _clearError();
    
    try {
      _storyIdeas = await FirestoreService.loadStoryIdeas(projectId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load story ideas: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Generate a new story idea using AI
  Future<StoryIdea?> generateStoryIdea({
    required String projectId,
    required String genre,
    required String tone,
    String? themes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('Starting story idea generation for: $genre, $tone');
      
      // Check cache first
      final cacheKey = StorageService.generateCacheKey('story_idea', {
        'genre': genre,
        'tone': tone,
        'themes': themes ?? '',
      });
      
      String? cachedResponse = StorageService.getCachedResponse(cacheKey);
      String generatedIdea;
      
      if (cachedResponse != null) {
        print('Using cached response for story idea');
        generatedIdea = cachedResponse;
      } else {
        print('Generating new story idea');
        // Generate new story idea
        generatedIdea = await _aiService.generateStoryIdea(
          genre: genre,
          tone: tone,
          themes: themes,
        );
        
        print('Generated story idea length: ${generatedIdea.length} characters');
        
        // Cache the response
        await StorageService.cacheResponse(cacheKey, generatedIdea);
      }
      
      // Parse the generated idea into sections
      final parsedIdea = _parseStoryIdea(generatedIdea);
      print('Parsed story idea sections: ${parsedIdea.keys.toList()}');
      
      final storyIdea = StoryIdea(
        id: _uuid.v4(),
        projectId: projectId,
        title: parsedIdea['title'] ?? 'Untitled Story',
        genre: genre,
        tone: tone,
        themes: themes ?? '',
        coreConcept: parsedIdea['coreConcept'] ?? '',
        protagonist: parsedIdea['protagonist'] ?? '',
        centralConflict: parsedIdea['centralConflict'] ?? '',
        setting: parsedIdea['setting'] ?? '',
        stakes: parsedIdea['stakes'] ?? '',
        uniqueElements: parsedIdea['uniqueElements'] ?? '',
        plotPoints: _extractPlotPoints(parsedIdea['plotPoints'] ?? ''),
        characterRelationships: parsedIdea['characterRelationships'] ?? '',
        thematicElements: parsedIdea['thematicElements'] ?? '',
        hook: parsedIdea['hook'] ?? '',
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
      );
      
      print('Story idea created with ID: ${storyIdea.id}');
      await saveStoryIdea(storyIdea);
      print('Story idea saved successfully');
      return storyIdea;
      
    } catch (e) {
      print('Error generating story idea: $e');
      _setError('Failed to generate story idea: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Save story idea
  Future<void> saveStoryIdea(StoryIdea storyIdea) async {
    try {
      await FirestoreService.saveStoryIdea(storyIdea);
      
      // Update local list
      final index = _storyIdeas.indexWhere((s) => s.id == storyIdea.id);
      if (index >= 0) {
        _storyIdeas[index] = storyIdea;
      } else {
        _storyIdeas.add(storyIdea);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to save story idea: $e');
    }
  }
  
  // Update story idea
  Future<void> updateStoryIdea(StoryIdea storyIdea) async {
    final updatedStoryIdea = storyIdea.copyWith(
      lastModified: DateTime.now(),
    );
    
    await saveStoryIdea(updatedStoryIdea);
  }
  
  // Delete story idea
  Future<void> deleteStoryIdea(String storyIdeaId) async {
    try {
      await FirestoreService.deleteStoryIdea(storyIdeaId);
      _storyIdeas.removeWhere((s) => s.id == storyIdeaId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete story idea: $e');
    }
  }
  
  // Get story idea by ID
  StoryIdea? getStoryIdeaById(String id) {
    try {
      return _storyIdeas.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Filter story ideas by genre
  List<StoryIdea> getStoryIdeasByGenre(String genre) {
    return _storyIdeas.where((idea) => idea.genre == genre).toList();
  }
  
  // Filter story ideas by tone
  List<StoryIdea> getStoryIdeasByTone(String tone) {
    return _storyIdeas.where((idea) => idea.tone == tone).toList();
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
  
  // Parse AI-generated story idea into sections
  Map<String, String> _parseStoryIdea(String idea) {
    final sections = <String, String>{};
    final lines = idea.split('\n');
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
    
    // If no sections found, treat entire content as core concept
    if (sections.isEmpty) {
      sections['coreConcept'] = idea;
    }
    
    return sections;
  }
  
  String _normalizeKey(String key) {
    final normalizedKey = key.toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('&', '')
        .replaceAll('-', '');
    
    // Map common variations to standard keys
    if (normalizedKey.contains('core') || normalizedKey.contains('concept') || normalizedKey.contains('premise')) {
      return 'coreConcept';
    } else if (normalizedKey.contains('protagonist') || normalizedKey.contains('main') || normalizedKey.contains('hero')) {
      return 'protagonist';
    } else if (normalizedKey.contains('central') || normalizedKey.contains('conflict') || normalizedKey.contains('problem')) {
      return 'centralConflict';
    } else if (normalizedKey.contains('setting') || normalizedKey.contains('location') || normalizedKey.contains('where')) {
      return 'setting';
    } else if (normalizedKey.contains('stakes') || normalizedKey.contains('consequence') || normalizedKey.contains('risk')) {
      return 'stakes';
    } else if (normalizedKey.contains('unique') || normalizedKey.contains('special') || normalizedKey.contains('distinctive')) {
      return 'uniqueElements';
    } else if (normalizedKey.contains('plot') || normalizedKey.contains('event') || normalizedKey.contains('point')) {
      return 'plotPoints';
    } else if (normalizedKey.contains('relationship') || normalizedKey.contains('character')) {
      return 'characterRelationships';
    } else if (normalizedKey.contains('thematic') || normalizedKey.contains('theme') || normalizedKey.contains('meaning')) {
      return 'thematicElements';
    } else if (normalizedKey.contains('hook') || normalizedKey.contains('opening') || normalizedKey.contains('grab')) {
      return 'hook';
    } else if (normalizedKey.contains('title')) {
      return 'title';
    }
    
    return normalizedKey;
  }
  
  List<String> _extractPlotPoints(String plotPointsText) {
    // Extract numbered or bulleted plot points
    final plotPoints = <String>[];
    final lines = plotPointsText.split('\n');
    
    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      
      // Look for numbered or bulleted lists
      if (RegExp(r'^\d+\.').hasMatch(line) || 
          line.startsWith('•') || 
          line.startsWith('-') ||
          line.startsWith('*')) {
        // Remove numbering/bullets and add to list
        final cleanLine = line.replaceAll(RegExp(r'^\d+\.'), '')
                             .replaceAll('•', '')
                             .replaceAll('-', '')
                             .replaceAll('*', '')
                             .trim();
        if (cleanLine.isNotEmpty) {
          plotPoints.add(cleanLine);
        }
      } else if (line.contains(':') && plotPoints.isEmpty) {
        // If no bullets found, try splitting by colons
        final parts = line.split(':');
        if (parts.length > 1) {
          plotPoints.add(parts[1].trim());
        }
      }
    }
    
    // If no structured plot points found, return the whole text as one point
    if (plotPoints.isEmpty && plotPointsText.trim().isNotEmpty) {
      plotPoints.add(plotPointsText.trim());
    }
    
    return plotPoints;
  }
}
