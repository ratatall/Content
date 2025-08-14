import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/openai_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/feature_card.dart';
import '../../character_development/presentation/character_development_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Storywriter Assistant'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to your writing assistant',
              style: AppTheme.heading2,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Choose a tool to help develop your story',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacing32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppTheme.spacing16,
                mainAxisSpacing: AppTheme.spacing16,
                children: [
                  FeatureCard(
                    title: 'Character Development',
                    description: 'Create compelling characters with detailed profiles',
                    icon: Icons.person,
                    color: AppTheme.primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CharacterDevelopmentScreen(),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    title: 'World Building',
                    description: 'Design rich settings and environments',
                    icon: Icons.public,
                    color: AppTheme.secondaryColor,
                    onTap: () {
                      // TODO: Navigate to world building screen
                      _showComingSoon(context, 'World Building');
                    },
                  ),
                  FeatureCard(
                    title: 'Scene Planner',
                    description: 'Plan and organize your story scenes',
                    icon: Icons.movie,
                    color: AppTheme.accentColor,
                    onTap: () {
                      // TODO: Navigate to scene planner screen
                      _showComingSoon(context, 'Scene Planner');
                    },
                  ),
                  FeatureCard(
                    title: 'Story Ideas',
                    description: 'Generate creative writing prompts and concepts',
                    icon: Icons.lightbulb,
                    color: const Color(0xFF8B5CF6), // Purple variant
                    onTap: () {
                      // TODO: Navigate to story ideas screen
                      _showComingSoon(context, 'Story Ideas');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: AppTheme.heading3,
          ),
          const SizedBox(height: AppTheme.spacing12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showApiKeyDialog(context),
                  icon: const Icon(Icons.key),
                  label: Text(StorageService.getApiKey() != null ? 'Update API Key' : 'Set API Key'),
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showComingSoon(context, 'New Project'),
                  icon: const Icon(Icons.add),
                  label: const Text('New Project'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set OpenAI API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your OpenAI API key to enable AI features:'),
            const SizedBox(height: AppTheme.spacing16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'sk-...',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final apiKey = controller.text.trim();
              if (apiKey.isNotEmpty) {
                try {
                  // Save API key using the correct method
                  await StorageService.saveApiKey(apiKey);
                  
                  // Update the OpenAI service with the new API key
                  final openaiService = Provider.of<OpenAIService>(context, listen: false);
                  openaiService.setApiKey(apiKey);
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API key saved successfully')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving API key: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid API key'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
