import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/openai_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/providers/world_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

class WorldBuildingScreen extends StatefulWidget {
  const WorldBuildingScreen({super.key});

  @override
  State<WorldBuildingScreen> createState() => _WorldBuildingScreenState();
}

class _WorldBuildingScreenState extends State<WorldBuildingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _settingController = TextEditingController();
  final _additionalDetailsController = TextEditingController();
  
  String _selectedGenre = AppConstants.genres.first;
  String _selectedTone = AppConstants.storyTones.first;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadWorlds();
  }

  Future<void> _loadWorlds() async {
    final worldProvider = Provider.of<WorldProvider>(context, listen: false);
    await worldProvider.loadWorlds('default');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _settingController.dispose();
    _additionalDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Building'),
        backgroundColor: AppTheme.secondaryColor,
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
                _buildWorldForm(),
                const SizedBox(height: AppTheme.spacing24),
                _buildExistingWorlds(),
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
            AppTheme.secondaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.05),
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
                  color: AppTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: const Icon(
                  Icons.public,
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
                      'World Building',
                      style: AppTheme.heading2,
                    ),
                    Text(
                      'Create rich, immersive story settings',
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

  Widget _buildWorldForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New World',
                style: AppTheme.heading3,
              ),
              const SizedBox(height: AppTheme.spacing16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'World Name *',
                  hintText: 'Enter the name of your world',
                  prefixIcon: Icon(Icons.public_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a world name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing16),
              TextFormField(
                controller: _settingController,
                decoration: const InputDecoration(
                  labelText: 'Setting Type *',
                  hintText: 'e.g., Medieval Kingdom, Space Station, Modern City',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the setting type';
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
                controller: _additionalDetailsController,
                decoration: const InputDecoration(
                  labelText: 'Additional Details (Optional)',
                  hintText: 'Specific cultural elements, history, or unique features',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppTheme.spacing24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateWorld,
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
                  label: Text(_isGenerating ? 'Generating...' : 'Generate World'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExistingWorlds() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Worlds',
          style: AppTheme.heading3,
        ),
        const SizedBox(height: AppTheme.spacing16),
        Consumer<WorldProvider>(
          builder: (context, worldProvider, child) {
            if (worldProvider.worlds.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: worldProvider.worlds.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacing12),
              itemBuilder: (context, index) {
                final world = worldProvider.worlds[index];
                return _buildWorldCard(world);
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
            Icons.public_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: AppTheme.spacing16),
          Text(
            'No worlds yet',
            style: AppTheme.heading3,
          ),
          SizedBox(height: AppTheme.spacing8),
          Text(
            'Create your first world using the form above',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWorldCard(world) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.secondaryColor,
          child: Text(
            world.name.isNotEmpty ? world.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          world.name,
          style: AppTheme.heading3,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(world.setting),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  world.genre,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.secondaryColor),
                ),
                const SizedBox(width: 8),
                Text(
                  '• ${world.tone}',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor),
                ),
              ],
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
                _viewWorldDetails(world);
                break;
              case 'edit':
                _editWorld(world);
                break;
              case 'delete':
                _deleteWorld(world);
                break;
            }
          },
        ),
      ),
    );
  }

  Future<void> _generateWorld() async {
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
      final worldProvider = Provider.of<WorldProvider>(context, listen: false);
      
      // Make sure the OpenAI service has the API key
      final openaiService = Provider.of<OpenAIService>(context, listen: false);
      openaiService.setApiKey(apiKey);
      
      final world = await worldProvider.generateWorld(
        projectId: 'default',
        name: _nameController.text.trim(),
        genre: _selectedGenre,
        setting: _settingController.text.trim(),
        tone: _selectedTone,
        additionalDetails: _additionalDetailsController.text.trim().isEmpty 
            ? null 
            : _additionalDetailsController.text.trim(),
      );

      if (mounted && world != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('World generated successfully!'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );

        // Clear form
        _nameController.clear();
        _settingController.clear();
        _additionalDetailsController.clear();
        setState(() {
          _selectedGenre = AppConstants.genres.first;
          _selectedTone = AppConstants.storyTones.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate world: $e'),
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

  void _viewWorldDetails(world) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(world.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailSection('Setting', world.setting),
              _buildDetailSection('Genre', world.genre),
              _buildDetailSection('Tone', world.tone),
              if (world.geography.isNotEmpty)
                _buildDetailSection('Geography', world.geography),
              if (world.society.isNotEmpty)
                _buildDetailSection('Society & Culture', world.society),
              if (world.politics.isNotEmpty)
                _buildDetailSection('Politics', world.politics),
              if (world.economy.isNotEmpty)
                _buildDetailSection('Economy', world.economy),
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

  void _editWorld(world) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('World editing coming soon!')),
    );
  }

  void _deleteWorld(world) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete World'),
        content: Text('Are you sure you want to delete ${world.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<WorldProvider>(context, listen: false)
                  .deleteWorld(world.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('World deleted')),
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
