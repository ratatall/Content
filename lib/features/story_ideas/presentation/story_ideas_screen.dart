import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/huggingface_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/providers/story_idea_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

class StoryIdeasScreen extends StatefulWidget {
  const StoryIdeasScreen({super.key});

  @override
  State<StoryIdeasScreen> createState() => _StoryIdeasScreenState();
}

class _StoryIdeasScreenState extends State<StoryIdeasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _themesController = TextEditingController();
  
  String _selectedGenre = AppConstants.genres.first;
  String _selectedTone = AppConstants.storyTones.first;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadStoryIdeas();
  }

  Future<void> _loadStoryIdeas() async {
    final storyIdeaProvider = Provider.of<StoryIdeaProvider>(context, listen: false);
    await storyIdeaProvider.loadStoryIdeas('default');
  }

  @override
  void dispose() {
    _themesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Ideas'),
        backgroundColor: const Color(0xFF8B5CF6), // Purple variant
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppTheme.spacing24),
                _buildStoryIdeaForm(),
                const SizedBox(height: AppTheme.spacing24),
                _buildExistingStoryIdeas(),
              ],
            ),
          ),
          if (_isGenerating) const LoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Story Ideas',
                      style: AppTheme.heading2,
                    ),
                    Text(
                      'Generate creative writing prompts and concepts',
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoryIdeaForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Generate Story Idea',
                style: AppTheme.heading3,
              ),
              const SizedBox(height: AppTheme.spacing16),
              DropdownButtonFormField<String>(
                value: _selectedGenre,
                decoration: const InputDecoration(
                  labelText: 'Genre *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: AppConstants.genres.map((genre) {
                  return DropdownMenuItem(
                    value: genre,
                    child: Text(genre),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedGenre = value;
                    });
                  }
                },
              ),
              const SizedBox(height: AppTheme.spacing16),
              DropdownButtonFormField<String>(
                value: _selectedTone,
                decoration: const InputDecoration(
                  labelText: 'Tone *',
                  prefixIcon: Icon(Icons.mood),
                ),
                items: AppConstants.storyTones.map((tone) {
                  return DropdownMenuItem(
                    value: tone,
                    child: Text(tone),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTone = value;
                    });
                  }
                },
              ),
              const SizedBox(height: AppTheme.spacing16),
              TextFormField(
                controller: _themesController,
                decoration: const InputDecoration(
                  labelText: 'Themes (Optional)',
                  hintText: 'e.g., Love vs Duty, Coming of Age, Redemption',
                  prefixIcon: Icon(Icons.psychology),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppTheme.spacing24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateStoryIdea,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isGenerating ? 'Generating...' : 'Generate Story Idea'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExistingStoryIdeas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Story Ideas',
          style: AppTheme.heading3,
        ),
        const SizedBox(height: AppTheme.spacing16),
        Consumer<StoryIdeaProvider>(
          builder: (context, storyIdeaProvider, child) {
            if (storyIdeaProvider.storyIdeas.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: storyIdeaProvider.storyIdeas.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacing12),
              itemBuilder: (context, index) {
                final storyIdea = storyIdeaProvider.storyIdeas[index];
                return _buildStoryIdeaCard(storyIdea);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing32),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: AppTheme.spacing16),
          Text(
            'No story ideas yet',
            style: AppTheme.heading3,
          ),
          SizedBox(height: AppTheme.spacing8),
          Text(
            'Generate your first story idea using the form above',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryIdeaCard(storyIdea) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF8B5CF6),
                  radius: 20,
                  child: Icon(
                    Icons.lightbulb,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storyIdea.title.isNotEmpty ? storyIdea.title : 'Untitled Story',
                        style: AppTheme.heading3,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            storyIdea.genre,
                            style: AppTheme.bodySmall.copyWith(color: const Color(0xFF8B5CF6)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${storyIdea.tone}',
                            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: ListTile(
                        leading: Icon(Icons.visibility),
                        title: Text('View Details'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: AppTheme.errorColor),
                        title: Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        _viewStoryIdeaDetails(storyIdea);
                        break;
                      case 'edit':
                        _editStoryIdea(storyIdea);
                        break;
                      case 'delete':
                        _deleteStoryIdea(storyIdea);
                        break;
                    }
                  },
                ),
              ],
            ),
            if (storyIdea.coreConcept.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacing12),
              Text(
                storyIdea.coreConcept,
                style: AppTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (storyIdea.themes.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Themes: ${storyIdea.themes}',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generateStoryIdea() async {
    // Check if API key is set
    final apiKey = StorageService.getApiKey();
    if (apiKey == null || apiKey.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set your OpenAI API key in Settings first'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final storyIdeaProvider = Provider.of<StoryIdeaProvider>(context, listen: false);
      
      // Make sure the OpenAI service has the API key
      final huggingfaceService = Provider.of<HuggingFaceService>(context, listen: false);
      huggingfaceService.setApiKey(apiKey);
      
      final storyIdea = await storyIdeaProvider.generateStoryIdea(
        projectId: 'default',
        genre: _selectedGenre,
        tone: _selectedTone,
        themes: _themesController.text.trim().isEmpty 
            ? null 
            : _themesController.text.trim(),
      );

      if (mounted && storyIdea != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Story idea generated successfully!'),
            backgroundColor: Color(0xFF8B5CF6),
          ),
        );

        // Clear form
        _themesController.clear();
        setState(() {
          _selectedGenre = AppConstants.genres.first;
          _selectedTone = AppConstants.storyTones.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate story idea: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _viewStoryIdeaDetails(storyIdea) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(storyIdea.title.isNotEmpty ? storyIdea.title : 'Story Idea'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailSection('Genre', storyIdea.genre),
              _buildDetailSection('Tone', storyIdea.tone),
              if (storyIdea.themes.isNotEmpty)
                _buildDetailSection('Themes', storyIdea.themes),
              if (storyIdea.coreConcept.isNotEmpty)
                _buildDetailSection('Core Concept', storyIdea.coreConcept),
              if (storyIdea.protagonist.isNotEmpty)
                _buildDetailSection('Protagonist', storyIdea.protagonist),
              if (storyIdea.centralConflict.isNotEmpty)
                _buildDetailSection('Central Conflict', storyIdea.centralConflict),
              if (storyIdea.setting.isNotEmpty)
                _buildDetailSection('Setting', storyIdea.setting),
              if (storyIdea.stakes.isNotEmpty)
                _buildDetailSection('Stakes', storyIdea.stakes),
              if (storyIdea.hook.isNotEmpty)
                _buildDetailSection('Hook', storyIdea.hook),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(content, style: AppTheme.bodyMedium),
        ],
      ),
    );
  }

  void _editStoryIdea(storyIdea) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Story idea editing coming soon!')),
    );
  }

  void _deleteStoryIdea(storyIdea) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Story Idea'),
        content: Text('Are you sure you want to delete this story idea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<StoryIdeaProvider>(context, listen: false)
                  .deleteStoryIdea(storyIdea.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Story idea deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
