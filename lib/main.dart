import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/today/data/mood_entry.dart';

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
      home: const Scaffold(
        body: Center(
          child: Text(
            'Gimana Tadi?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
