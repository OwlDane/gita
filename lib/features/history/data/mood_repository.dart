import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gita/features/today/data/mood_entry.dart';

class MoodRepository {
  static const String boxName = 'mood_entries';

  Future<void> addEntry(MoodEntry entry) async {
    final box = Hive.box<MoodEntry>(boxName);
    await box.put(entry.id, entry);
  }

  List<MoodEntry> getAllEntries() {
    final box = Hive.box<MoodEntry>(boxName);
    final entries = box.values.toList();
    // Sort by date descending
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  Future<void> deleteEntry(String id) async {
    final box = Hive.box<MoodEntry>(boxName);
    await box.delete(id);
  }

  MoodEntry? getEntryByDate(DateTime date) {
    final box = Hive.box<MoodEntry>(boxName);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    try {
      return box.values.firstWhere(
        (e) => DateTime(e.date.year, e.date.month, e.date.day).isAtSameMomentAs(normalizedDate),
      );
    } catch (_) {
      return null;
    }
  }

  Stream<List<MoodEntry>> watchEntries() {
    final box = Hive.box<MoodEntry>(boxName);
    return box.watch().map((_) => getAllEntries());
  }
}

final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return MoodRepository();
});

final historyEntriesProvider = StreamProvider<List<MoodEntry>>((ref) {
  final repo = ref.watch(moodRepositoryProvider);
  return repo.watchEntries();
});
