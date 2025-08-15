class AppConstants {
  // API
  static const String huggingfaceApiUrl = 'https://api-inference.huggingface.co/models';
  static const String huggingfaceModel = 'microsoft/DialoGPT-large';
  
  // Storage keys
  static const String huggingfaceApiKeyKey = 'huggingface_api_key';
  static const String userProjectsKey = 'user_projects';
  static const String cachedResponsesKey = 'cached_responses';
  
  // App info
  static const String appName = 'AI Storywriter Assistant';
  static const String appVersion = '1.0.0';
  
  // Firestore collections
  static const String projectsCollection = 'projects';
  static const String charactersCollection = 'characters';
  static const String worldsCollection = 'worlds';
  static const String scenesCollection = 'scenes';
  static const String storyIdeasCollection = 'story_ideas';
  
  // Character traits
  static const List<String> characterTraits = [
    'Brave', 'Cowardly', 'Intelligent', 'Naive', 'Loyal', 'Treacherous',
    'Kind', 'Cruel', 'Optimistic', 'Pessimistic', 'Ambitious', 'Lazy',
    'Honest', 'Deceptive', 'Patient', 'Impulsive', 'Confident', 'Insecure',
    'Generous', 'Selfish', 'Humble', 'Arrogant', 'Calm', 'Hot-tempered'
  ];
  
  // Genres
  static const List<String> genres = [
    'Fantasy', 'Science Fiction', 'Mystery', 'Romance', 'Thriller',
    'Horror', 'Historical Fiction', 'Contemporary Fiction', 'Adventure',
    'Comedy', 'Drama', 'Young Adult', 'Children\'s Literature'
  ];
  
  // Story tones
  static const List<String> storyTones = [
    'Dark', 'Light', 'Humorous', 'Serious', 'Mysterious', 'Romantic',
    'Action-packed', 'Contemplative', 'Whimsical', 'Gritty', 'Hopeful',
    'Melancholy', 'Suspenseful', 'Satirical'
  ];
}
