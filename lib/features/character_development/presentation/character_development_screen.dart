import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/openai_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/providers/character_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

class CharacterDevelopmentScreen extends StatefulWidget {
  const CharacterDevelopmentScreen({super.key});

  @override
  State<CharacterDevelopmentScreen> createState() => _CharacterDevelopmentScreenState();
}

class _CharacterDevelopmentScreenState extends State<CharacterDevelopmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _additionalDetailsController = TextEditingController();
  
  String _selectedGenre = AppConstants.genres.first;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    final characterProvider = Provider.of<CharacterProvider>(context, listen: false);
    // Load characters for the default project (in a real app, this would be the current project)
    await characterProvider.loadCharacters('default');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _additionalDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Development'),
        backgroundColor: AppTheme.primaryColor,
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
                _buildCharacterForm(),
                const SizedBox(height: AppTheme.spacing24),
                _buildExistingCharacters(),
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
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.05),
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
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: const Icon(
                  Icons.person,
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
                      'Character Development',
                      style: AppTheme.heading2,
                    ),
                    Text(
                      'Create compelling characters with AI assistance',
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

  Widget _buildCharacterForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Character',
                style: AppTheme.heading3,
              ),
              const SizedBox(height: AppTheme.spacing16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Character Name *',
                  hintText: 'Enter character\'s name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a character name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing16),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Role in Story *',
                  hintText: 'e.g., Protagonist, Antagonist, Supporting Character',
                  prefixIcon: Icon(Icons.theater_comedy),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the character\'s role';
                  }
                  return null;
                },
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
              TextFormField(
                controller: _additionalDetailsController,
                decoration: const InputDecoration(
                  labelText: 'Additional Details (Optional)',
                  hintText: 'Any specific traits, background, or requirements',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppTheme.spacing24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateCharacter,
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
                  label: Text(_isGenerating ? 'Generating...' : 'Generate Character'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExistingCharacters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Characters',
          style: AppTheme.heading3,
        ),
        const SizedBox(height: AppTheme.spacing16),
        Consumer<CharacterProvider>(
          builder: (context, characterProvider, child) {
            if (characterProvider.characters.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: characterProvider.characters.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacing12),
              itemBuilder: (context, index) {
                final character = characterProvider.characters[index];
                return _buildCharacterCard(character);
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
            Icons.person_add,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: AppTheme.spacing16),
          Text(
            'No characters yet',
            style: AppTheme.heading3,
          ),
          SizedBox(height: AppTheme.spacing8),
          Text(
            'Create your first character using the form above',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCard(character) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            character.name.isNotEmpty ? character.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          character.name,
          style: AppTheme.heading3,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(character.role),
            const SizedBox(height: 4),
            Text(
              character.genre,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryColor),
            ),
          ],
        ),
        trailing: PopupMenuButton(
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
                _viewCharacterDetails(character);
                break;
              case 'edit':
                _editCharacter(character);
                break;
              case 'delete':
                _deleteCharacter(character);
                break;
            }
          },
        ),
      ),
    );
  }

  Future<void> _generateCharacter() async {
    if (!_formKey.currentState!.validate()) return;

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
      final characterProvider = Provider.of<CharacterProvider>(context, listen: false);
      
      // Make sure the OpenAI service has the API key
      final openaiService = Provider.of<OpenAIService>(context, listen: false);
      openaiService.setApiKey(apiKey);
      
      final character = await characterProvider.generateCharacter(
        projectId: 'default', // TODO: Use actual project ID
        name: _nameController.text.trim(),
        role: _roleController.text.trim(),
        genre: _selectedGenre,
        additionalDetails: _additionalDetailsController.text.trim().isEmpty 
            ? null 
            : _additionalDetailsController.text.trim(),
      );

      if (mounted && character != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Character generated successfully!'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );

        // Clear form
        _nameController.clear();
        _roleController.clear();
        _additionalDetailsController.clear();
        setState(() {
          _selectedGenre = AppConstants.genres.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate character: $e'),
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

  void _viewCharacterDetails(character) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(character.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailSection('Role', character.role),
              _buildDetailSection('Genre', character.genre),
              if (character.description.isNotEmpty)
                _buildDetailSection('Description', character.description),
              if (character.appearance.isNotEmpty)
                _buildDetailSection('Appearance', character.appearance),
              if (character.personality.isNotEmpty)
                _buildDetailSection('Personality', character.personality),
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

  void _editCharacter(character) {
    // TODO: Implement character editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Character editing coming soon!')),
    );
  }

  void _deleteCharacter(character) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Character'),
        content: Text('Are you sure you want to delete ${character.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<CharacterProvider>(context, listen: false)
                  .deleteCharacter(character.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Character deleted')),
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
