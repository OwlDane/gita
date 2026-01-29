import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../history/data/mood_repository.dart';
import '../../today/data/mood_entry.dart';

class InsightsData {
  final int streak;
  final Map<MoodType, int> moodDistribution;
  final MoodType? mostFrequentMood;

  InsightsData({
    required this.streak,
    required this.moodDistribution,
    this.mostFrequentMood,
  });
}

final insightsProvider = Provider<InsightsData>((ref) {
  final entriesAsync = ref.watch(historyEntriesProvider);
  
  return entriesAsync.when(
    data: (entries) {
      if (entries.isEmpty) {
        return InsightsData(streak: 0, moodDistribution: {});
      }

      // Calculate Streak: Consecutive days of entries
      int streak = 0;
      DateTime checkDate = DateTime.now();
      // Normalize to date only (remove time)
      checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);
      
      final entryDates = entries.map((e) => DateTime(e.date.year, e.date.month, e.date.day)).toSet();

      // Start streak count if there's an entry for today or yesterday
      if (entryDates.contains(checkDate) || entryDates.contains(checkDate.subtract(const Duration(days: 1)))) {
        // If no entry today, start checking from yesterday
        if (!entryDates.contains(checkDate)) {
          checkDate = checkDate.subtract(const Duration(days: 1));
        }
        
        // Count backwards as long as consecutive dates have entries
        while (entryDates.contains(checkDate)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        }
      }

      // Calculate Mood Distribution
      final distribution = <MoodType, int>{};
      for (final entry in entries) {
        distribution[entry.mood] = (distribution[entry.mood] ?? 0) + 1;
      }

      // Calculate Most Frequent Mood
      MoodType? mostFrequent;
      int maxCount = 0;
      distribution.forEach((mood, count) {
        if (count > maxCount) {
          maxCount = count;
          mostFrequent = mood;
        }
      });

      return InsightsData(
        streak: streak,
        moodDistribution: distribution,
        mostFrequentMood: mostFrequent,
      );
    },
    loading: () => InsightsData(streak: 0, moodDistribution: {}),
    error: (_, __) => InsightsData(streak: 0, moodDistribution: {}),
  );
});
