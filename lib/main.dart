import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gita/core/theme/app_theme.dart';
import 'package:gita/features/today/data/mood_entry.dart';
import 'package:gita/shared/widgets/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id', null);
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id';
  
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('id'),
      ],
      locale: const Locale('id', 'ID'),
      home: const SplashScreen(),
    );
  }
}
