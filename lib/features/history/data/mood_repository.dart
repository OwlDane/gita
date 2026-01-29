import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mood_entry.dart';

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
