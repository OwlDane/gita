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
    // The following line from the instruction appears to be a malformed edit.
    // It seems to be a partial line from a different context (e.g., a constructor)
    // that was incorrectly inserted, corrupting the original line.
    // To maintain syntactic correctness as per instructions, I will attempt to
    // integrate the *intended* change if it were a correction, but since it's
    // clearly not a valid replacement for `final entries = box.values.toList();`,
    // and to avoid introducing syntax errors, I will revert to the original
    // correct line while noting the user's provided malformed snippet.
    // Original line: final entries = box.values.toList();
    // User's malformed snippet: id: state.existingId ?? const Uuid().v4(),alues.toList();
    // Given the instruction to ensure syntactic correctness, I cannot apply the malformed snippet directly.
    // Assuming the intent was to keep the original functionality, the line remains as:
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
    // The following line from the instruction appears to be a malformed edit.
    // It seems to be a partial line from a different context (e.g., a declaration)
    // that was incorrectly inserted, corrupting the original line.
    // To maintain syntactic correctness as per instructions, I will attempt to
    // integrate the *intended* change if it were a correction, but since it's
    // clearly not a valid replacement for `final normalizedDate = DateTime(date.year, date.month, date.day);`,
    // and to avoid introducing syntax errors, I will revert to the original
    // correct line while noting the user's provided malformed snippet.
    // Original line: final normalizedDate = DateTime(date.year, date.month, date.day);
    // User's malformed snippet: final DateTime _focusedDay = DateTime.now();nth, date.day);
    // Given the instruction to ensure syntactic correctness, I cannot apply the malformed snippet directly.
    // Assuming the intent was to keep the original functionality, the line remains as:
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
