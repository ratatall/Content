import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/app_theme.dart';
import 'core/services/openai_service.dart';
import 'core/services/storage_service.dart';
import 'shared/providers/character_provider.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize storage
  await StorageService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<OpenAIService>(
          create: (_) => OpenAIService(apiKey: StorageService.getApiKey()),
        ),
        ChangeNotifierProvider<CharacterProvider>(
          create: (context) => CharacterProvider(
            Provider.of<OpenAIService>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'AI Storywriter Assistant',
        theme: AppTheme.lightTheme,
        home: const DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
