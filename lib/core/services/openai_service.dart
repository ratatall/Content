import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions'; // Hardcoded since this is legacy
  String? _apiKey;
  
  OpenAIService({String? apiKey}) : _apiKey = apiKey;
  
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }
  
  Future<String> generateText({
    required String prompt,
    int maxTokens = 1000,
    double temperature = 0.7,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('OpenAI API key not provided');
    }
    
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini', // Hardcoded since this is legacy
          'messages': [
            {
              'role': 'system',
              'content': 'You are a creative writing assistant that helps authors develop compelling stories, characters, and worlds.'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': maxTokens,
          'temperature': temperature,
        }),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('OpenAI API Error: ${errorData['error']['message']}');
      }
    } catch (e) {
      throw Exception('Failed to generate text: $e');
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
    return '''
Create a detailed character profile for a $genre story. 

Character Name: $name
Role in Story: $role
${additionalDetails != null ? 'Additional Details: $additionalDetails' : ''}

Please provide a comprehensive character profile that includes:

1. **Physical Appearance**: Detailed description of their looks, age, build, distinctive features
2. **Personality Traits**: Core personality characteristics, strengths, flaws, quirks
3. **Backstory**: Key events that shaped them, family background, past experiences
4. **Motivations**: What drives them, their goals, fears, and desires
5. **Skills & Abilities**: What they're good at, special talents or knowledge
6. **Relationships**: How they interact with others, trust issues, social patterns
7. **Character Arc Potential**: How they might grow or change throughout the story
8. **Dialogue Style**: How they speak, vocabulary, accent or speech patterns
9. **Internal Conflicts**: Personal struggles, contradictions in their nature
10. **Role in Plot**: How they serve the story, their function in the narrative

Make the character feel real, complex, and suitable for the $genre genre. Include specific details that make them memorable and unique.
''';
  }
}

class WorldBuildingPrompts {
  static String createWorldDescription({
    required String genre,
    required String setting,
    required String tone,
    String? additionalDetails,
  }) {
    return '''
Create a rich, detailed world description for a $genre story.

Setting Type: $setting
Tone: $tone
${additionalDetails != null ? 'Additional Requirements: $additionalDetails' : ''}

Please provide a comprehensive world description that includes:

1. **Geography & Environment**: Landscapes, climate, natural features, regions
2. **Society & Culture**: Social structure, customs, traditions, values
3. **Politics & Government**: Ruling systems, laws, conflicts, power structures
4. **Economy & Trade**: How people make a living, currency, resources, commerce
5. **Technology Level**: Available technology, magic systems (if applicable), tools
6. **History**: Key historical events, ancient civilizations, recent conflicts
7. **Religion & Beliefs**: Dominant faiths, mythologies, spiritual practices
8. **Daily Life**: How ordinary people live, work, and interact
9. **Conflicts & Tensions**: Ongoing problems, potential story conflicts
10. **Unique Elements**: What makes this world special and different

Create a world that feels lived-in and authentic, with details that can drive plot and character development. Make it engaging for the $tone tone and suitable for $genre stories.
''';
  }
}

class ScenePrompts {
  static String createSceneSuggestion({
    required String storyContext,
    required String currentScene,
    required String desiredOutcome,
  }) {
    return '''
Help develop the next scene in this story.

Story Context: $storyContext
Current Scene: $currentScene
Desired Outcome: $desiredOutcome

Please suggest how to develop this scene, including:

1. **Scene Purpose**: What this scene accomplishes for the overall story
2. **Character Actions**: What the characters should do and why
3. **Dialogue Opportunities**: Key conversations that should happen
4. **Conflict/Tension**: How to create drama and keep readers engaged
5. **Setting Details**: Important environmental elements to include
6. **Pacing**: Whether this should be fast or slow-paced and why
7. **Emotional Beats**: The emotional journey characters go through
8. **Plot Advancement**: How this moves the story forward
9. **Character Development**: How characters grow or change
10. **Transition**: How to smoothly connect to the next scene

Provide specific, actionable suggestions that maintain narrative consistency and work toward the desired outcome.
''';
  }
}

class StoryPrompts {
  static String createStoryIdea({
    required String genre,
    required String tone,
    String? themes,
  }) {
    return '''
Generate a creative story idea for a $genre story with a $tone tone.
${themes != null ? 'Themes to explore: $themes' : ''}

Please provide:

1. **Core Concept**: The main story premise in 2-3 sentences
2. **Protagonist**: Brief description of the main character and their situation
3. **Central Conflict**: The primary challenge or problem driving the story
4. **Setting**: When and where the story takes place
5. **Stakes**: What the protagonist stands to gain or lose
6. **Unique Elements**: What makes this story stand out from others in the genre
7. **Potential Plot Points**: 3-4 key events that could happen in the story
8. **Character Relationships**: Important relationships that drive the plot
9. **Thematic Elements**: Deeper meanings or messages the story could explore
10. **Hook**: An intriguing opening situation to grab readers' attention

Make the idea original, engaging, and well-suited for the $genre genre with a $tone tone. Include enough detail to inspire further development.
''';
  }
}
