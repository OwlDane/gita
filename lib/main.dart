import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gita/core/theme/app_theme.dart';
import 'package:gita/features/today/data/mood_entry.dart';
import 'package:gita/shared/widgets/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(MoodTypeAdapter());
  Hive.registerAdapter(MoodEntryAdapter());
  
  // Open Box
  await Hive.openBox<MoodEntry>('mood_entries');

  runApp(
    const ProviderScope(
      child: GitaApp(),
    ),
  );
}

class GitaApp extends StatelessWidget {
  const GitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GITA',
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
    );
  }
}
