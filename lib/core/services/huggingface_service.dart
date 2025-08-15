import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class HuggingFaceService {
  String? _apiKey;
  
  // Hugging Face Inference API endpoint
  static const String _baseUrl = 'https://api-inference.huggingface.co/models';
  
  // Primary model for creative writing
  static const String _primaryModel = 'microsoft/DialoGPT-large';
  
  // Backup model for when primary is loading
  static const String _backupModel = 'gpt2-medium';
  
  HuggingFaceService({String? apiKey}) : _apiKey = apiKey;
  
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  Future<String> generateText({
    required String prompt,
    int maxTokens = 1000,
    double temperature = 0.7,
  }) async {
    // Get the latest API key from storage
    final latestApiKey = StorageService.getApiKey();
    final keyToUse = latestApiKey ?? _apiKey ?? '';
    
    if (keyToUse.isEmpty) {
      throw Exception('Hugging Face API key not found. Please set it in settings.');
    }
    
    try {
      print('Generating text with Hugging Face API...');
      
      // Try primary model first
      String? result = await _makeRequest(
        keyToUse, 
        prompt, 
        _primaryModel, 
        maxTokens, 
        temperature
      );
      
      if (result != null) {
        await _cacheResponse(prompt, result);
        return result;
      }
      
      // If primary model fails, try backup
      print('Primary model unavailable, trying backup model...');
      result = await _makeRequest(
        keyToUse, 
        prompt, 
        _backupModel, 
        maxTokens, 
        temperature
      );
      
      if (result != null) {
        await _cacheResponse(prompt, result);
        return result;
      }
      
      throw Exception('Both models are unavailable. Please try again later.');
      
    } on SocketException {
      print('Network error, checking cache...');
      final cached = _getCachedResponse(prompt);
      if (cached != null) {
        print('Returning cached response');
        return cached;
      }
      throw Exception('No internet connection and no cached response available.');
    } catch (e) {
      print('Error generating text: $e');
      
      // Try to get cached response as fallback
      final cached = _getCachedResponse(prompt);
      if (cached != null) {
        print('Returning cached response due to error');
        return cached;
      }
      rethrow;
    }
  }

  Future<String?> _makeRequest(
    String apiKey,
    String prompt,
    String model,
    int maxTokens,
    double temperature,
  ) async {
    try {
      final url = '$_baseUrl/$model';
      
      final requestBody = {
        'inputs': prompt,
        'parameters': {
          'max_new_tokens': maxTokens,
          'temperature': temperature,
          'top_p': 0.9,
          'do_sample': true,
          'return_full_text': false,
        },
        'options': {
          'wait_for_model': true,
          'use_cache': false,
        }
      };

      print('Making request to: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is List && data.isNotEmpty) {
          final generatedText = data[0]['generated_text'] as String;
          return _cleanGeneratedText(generatedText, prompt);
        } else if (data is Map && data.containsKey('generated_text')) {
          final generatedText = data['generated_text'] as String;
          return _cleanGeneratedText(generatedText, prompt);
        } else {
          print('Unexpected response format: $data');
          return null;
        }
      } else if (response.statusCode == 503) {
        print('Model is loading (503 error)');
        return null; // Model is loading, will try backup
      } else {
        print('API error ${response.statusCode}: ${response.body}');
        final errorData = json.decode(response.body);
        throw Exception('Hugging Face API error: ${errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Request failed: $e');
      return null;
    }
  }

  String _cleanGeneratedText(String generatedText, String prompt) {
    // Remove the input prompt from the output if it's included
    String cleaned = generatedText;
    if (cleaned.startsWith(prompt)) {
      cleaned = cleaned.substring(prompt.length).trim();
    }
    
    // Clean up any artifacts
    cleaned = cleaned.replaceAll('<|endoftext|>', '');
    cleaned = cleaned.replaceAll('<pad>', '');
    cleaned = cleaned.trim();
    
    return cleaned;
  }

  Future<void> _cacheResponse(String prompt, String response) async {
    try {
      final cacheKey = 'hf_${prompt.hashCode}';
      await StorageService.cacheResponse(cacheKey, response);
      print('Response cached successfully');
    } catch (e) {
      print('Error caching response: $e');
    }
  }

  String? _getCachedResponse(String prompt) {
    try {
      final cacheKey = 'hf_${prompt.hashCode}';
      return StorageService.getCachedResponse(cacheKey);
    } catch (e) {
      print('Error getting cached response: $e');
      return null;
    }
  }
  
  Future<String> generateCharacterProfile({
    required String name,
    required String role,
    required String genre,
    String? additionalDetails,
  }) async {
    final prompt = CharacterPrompts.createCharacterProfile(
      name: name,
      role: role,
      genre: genre,
      additionalDetails: additionalDetails,
    );
    
    return await generateText(prompt: prompt, maxTokens: 1500);
  }
  
  Future<String> generateWorldDescription({
    required String genre,
    required String setting,
    required String tone,
    String? additionalDetails,
  }) async {
    final prompt = WorldBuildingPrompts.createWorldDescription(
      genre: genre,
      setting: setting,
      tone: tone,
      additionalDetails: additionalDetails,
    );
    
    return await generateText(prompt: prompt, maxTokens: 1500);
  }
  
  Future<String> generateSceneSuggestion({
    required String storyContext,
    required String currentScene,
    required String desiredOutcome,
  }) async {
    final prompt = ScenePrompts.createSceneSuggestion(
      storyContext: storyContext,
      currentScene: currentScene,
      desiredOutcome: desiredOutcome,
    );
    
    return await generateText(prompt: prompt, maxTokens: 1000);
  }
  
  Future<String> generateStoryIdea({
    required String genre,
    required String tone,
    String? themes,
  }) async {
    final prompt = StoryPrompts.createStoryIdea(
      genre: genre,
      tone: tone,
      themes: themes,
    );
    
    return await generateText(prompt: prompt, maxTokens: 800);
  }
}

// Prompt templates for different features
class CharacterPrompts {
  static String createCharacterProfile({
    required String name,
    required String role,
    required String genre,
    String? additionalDetails,
  }) {
    return '''Create a detailed character profile for $name, a $role in a $genre story.

Character Name: $name
Role: $role
Genre: $genre
${additionalDetails != null ? 'Additional Details: $additionalDetails' : ''}

Provide a comprehensive character profile:

PHYSICAL APPEARANCE:
Describe their physical features, height, build, distinctive marks, and clothing style.

PERSONALITY:
Core personality traits, quirks, habits, and how they interact with others.

BACKSTORY:
Their origin, family background, significant life events, and formative experiences.

MOTIVATIONS & GOALS:
What drives them, their primary objectives, and what they hope to achieve.

SKILLS & ABILITIES:
Special talents, professional skills, and areas of expertise.

RELATIONSHIPS:
Important people in their life and relationship patterns.

DIALOGUE STYLE:
How they speak, vocabulary level, and common phrases.

INTERNAL CONFLICTS:
Personal struggles and contradictions they face.

CHARACTER ARC:
How this character might grow throughout the story.

Make the character feel real and suitable for the $genre genre.''';
  }
}

class WorldBuildingPrompts {
  static String createWorldDescription({
    required String genre,
    required String setting,
    required String tone,
    String? additionalDetails,
  }) {
    return '''Create a rich world setting for a $genre story. The world is a $setting with a $tone tone.

${additionalDetails != null ? 'Requirements: $additionalDetails' : ''}

Provide detailed world description:

OVERVIEW:
A compelling summary of this world and what makes it unique.

GEOGRAPHY & ENVIRONMENT:
Physical landscape, climate, and notable locations.

SOCIETY & CULTURE:
Social structure, customs, traditions, and daily life.

GOVERNMENT & POLITICS:
Power structures, laws, and political dynamics.

ECONOMY & TRADE:
Currency, commerce, and economic systems.

TECHNOLOGY:
Available technology level and its limitations.

HISTORY:
Major historical events that shaped the current world.

CONFLICTS & TENSIONS:
Current problems and sources of drama.

NOTABLE LOCATIONS:
Specific important places with detailed descriptions.

Make the world feel lived-in and perfect for $genre storytelling.''';
  }
}

class ScenePrompts {
  static String createSceneSuggestion({
    required String storyContext,
    required String currentScene,
    required String desiredOutcome,
  }) {
    return '''Help develop the next scene in this story.

Story Context: $storyContext
Current Scene: $currentScene
Desired Outcome: $desiredOutcome

Suggest how to develop this scene:

SCENE PURPOSE:
What this scene accomplishes for the overall story.

CHARACTER ACTIONS:
What the characters should do and why.

DIALOGUE OPPORTUNITIES:
Key conversations that should happen.

CONFLICT/TENSION:
How to create drama and keep readers engaged.

SETTING DETAILS:
Important environmental elements to include.

EMOTIONAL BEATS:
The emotional journey characters go through.

PLOT ADVANCEMENT:
How this moves the story forward.

Provide specific, actionable suggestions for the scene.''';
  }
}

class StoryPrompts {
  static String createStoryIdea({
    required String genre,
    required String tone,
    String? themes,
  }) {
    return '''Generate a creative story idea for a $genre story with a $tone tone.
${themes != null ? 'Themes: $themes' : ''}

Provide a complete story concept:

LOGLINE:
One-sentence summary capturing the story essence.

PREMISE:
Brief engaging description of the core concept.

MAIN CHARACTERS:
Key characters and their roles.

SETTING:
Where and when the story takes place.

CENTRAL CONFLICT:
The main problem driving the story.

PLOT OUTLINE:
Three-act structure with key plot points.

THEMES:
Deeper meanings the story explores.

UNIQUE ELEMENTS:
What makes this story stand out.

Make the idea fresh and well-suited for $genre with $tone tone.''';
  }
}
