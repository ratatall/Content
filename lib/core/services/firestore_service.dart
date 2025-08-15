import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/character_model.dart';
import '../../shared/models/project_model.dart';
import '../../shared/models/world_model.dart';
import '../../shared/models/scene_model.dart';
import '../../shared/models/story_idea_model.dart';
import '../constants/app_constants.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Projects
  static Future<void> saveProject(Project project) async {
    try {
      await _firestore
          .collection(AppConstants.projectsCollection)
          .doc(project.id)
          .set(project.toMap());
    } catch (e) {
      throw Exception('Failed to save project: $e');
    }
  }
  
  static Future<List<Project>> loadProjects() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.projectsCollection)
          .orderBy('lastModified', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Project.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load projects: $e');
    }
  }
  
  static Future<void> deleteProject(String projectId) async {
    try {
      await _firestore
          .collection(AppConstants.projectsCollection)
          .doc(projectId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }
  
  // Characters
  static Future<void> saveCharacter(Character character) async {
    try {
      await _firestore
          .collection(AppConstants.charactersCollection)
          .doc(character.id)
          .set(character.toMap());
    } catch (e) {
      throw Exception('Failed to save character: $e');
    }
  }
  
  static Future<List<Character>> loadCharacters(String projectId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.charactersCollection)
          .where('projectId', isEqualTo: projectId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Character.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load characters: $e');
    }
  }
  
  static Future<void> deleteCharacter(String characterId) async {
    try {
      await _firestore
          .collection(AppConstants.charactersCollection)
          .doc(characterId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete character: $e');
    }
  }
  
  // Worlds
  static Future<void> saveWorld(World world) async {
    try {
      await _firestore
          .collection(AppConstants.worldsCollection)
          .doc(world.id)
          .set(world.toMap());
    } catch (e) {
      throw Exception('Failed to save world: $e');
    }
  }
  
  static Future<List<World>> loadWorlds(String projectId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.worldsCollection)
          .where('projectId', isEqualTo: projectId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => World.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load worlds: $e');
    }
  }
  
  static Future<void> deleteWorld(String worldId) async {
    try {
      await _firestore
          .collection(AppConstants.worldsCollection)
          .doc(worldId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete world: $e');
    }
  }
  
  // Scenes
  static Future<void> saveScene(Scene scene) async {
    try {
      await _firestore
          .collection(AppConstants.scenesCollection)
          .doc(scene.id)
          .set(scene.toMap());
    } catch (e) {
      throw Exception('Failed to save scene: $e');
    }
  }
  
  static Future<List<Scene>> loadScenes(String projectId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.scenesCollection)
          .where('projectId', isEqualTo: projectId)
          .orderBy('order')
          .get();
      
      return snapshot.docs
          .map((doc) => Scene.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load scenes: $e');
    }
  }
  
  // Story Ideas
  static Future<void> saveStoryIdea(StoryIdea storyIdea) async {
    try {
      await _firestore
          .collection(AppConstants.storyIdeasCollection)
          .doc(storyIdea.id)
          .set(storyIdea.toMap());
    } catch (e) {
      throw Exception('Failed to save story idea: $e');
    }
  }
  
  static Future<List<StoryIdea>> loadStoryIdeas(String projectId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.storyIdeasCollection)
          .where('projectId', isEqualTo: projectId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => StoryIdea.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load story ideas: $e');
    }
  }
  
  static Future<void> deleteStoryIdea(String storyIdeaId) async {
    try {
      await _firestore
          .collection(AppConstants.storyIdeasCollection)
          .doc(storyIdeaId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete story idea: $e');
    }
  }
}
