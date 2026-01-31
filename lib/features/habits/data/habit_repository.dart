import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gita/features/habits/data/habit.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HabitRepository {
  static const String habitBoxName = 'habits';
  static const String logBoxName = 'habit_logs';

  Future<void> addHabit(Habit habit) async {
    final box = Hive.box<Habit>(habitBoxName);
    await box.put(habit.id, habit);
  }

  List<Habit> getAllHabits() {
    final box = Hive.box<Habit>(habitBoxName);
    return box.values.toList();
  }

  Future<void> deleteHabit(String id) async {
    final box = Hive.box<Habit>(habitBoxName);
    await box.delete(id);
    
    // Also cleanup logs for this habit
    final logBox = Hive.box<HabitLog>(logBoxName);
    final keysToDelete = logBox.values
        .where((log) => log.habitId == id)
        .map((log) => log.id)
        .toList();
    await logBox.deleteAll(keysToDelete);
  }

  Future<void> logHabit(HabitLog log) async {
    final box = Hive.box<HabitLog>(logBoxName);
    // Use a composite key habitId_date to easily find/update logs for a specific day
    final dateStr = log.date.toIso8601String().split('T')[0];
    final key = '${log.habitId}_$dateStr';
    await box.put(key, log);
  }

  HabitLog? getLogForHabit(String habitId, DateTime date) {
    final box = Hive.box<HabitLog>(logBoxName);
    final dateStr = date.toIso8601String().split('T')[0];
    final key = '${habitId}_$dateStr';
    return box.get(key);
  }

  List<HabitLog> getLogsForDate(DateTime date) {
    final box = Hive.box<HabitLog>(logBoxName);
    final dateStr = date.toIso8601String().split('T')[0];
    return box.values.where((log) {
      return log.date.toIso8601String().split('T')[0] == dateStr;
    }).toList();
  }

  Stream<BoxEvent> watchHabits() => Hive.box<Habit>(habitBoxName).watch();
  Stream<BoxEvent> watchLogs() => Hive.box<HabitLog>(logBoxName).watch();
}

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

final habitsProvider = StreamProvider<List<Habit>>((ref) async* {
  final repo = ref.watch(habitRepositoryProvider);
  yield repo.getAllHabits();
  yield* repo.watchHabits().map((_) => repo.getAllHabits());
});

final habitLogsForDateProvider = StreamProvider.family<List<HabitLog>, DateTime>((ref, date) async* {
  final repo = ref.watch(habitRepositoryProvider);
  yield repo.getLogsForDate(date);
  yield* repo.watchLogs().map((_) => repo.getLogsForDate(date));
});
