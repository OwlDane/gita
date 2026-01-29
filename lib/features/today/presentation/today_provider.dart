import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mood_entry.dart';

class TodayState {
  final MoodType? selectedMood;
  final int intensity;
  final String journalText;
  final bool isSaving;

  TodayState({
    this.selectedMood,
    this.intensity = 3,
    this.journalText = '',
    this.isSaving = false,
  });

  TodayState copyWith({
    MoodType? selectedMood,
    int? intensity,
    String? journalText,
    bool? isSaving,
  }) {
    return TodayState(
      selectedMood: selectedMood ?? this.selectedMood,
      intensity: intensity ?? this.intensity,
      journalText: journalText ?? this.journalText,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class TodayNotifier extends StateNotifier<TodayState> {
  TodayNotifier() : super(TodayState());

  void selectMood(MoodType mood) {
    state = state.copyWith(selectedMood: mood);
  }

  void updateIntensity(int intensity) {
    state = state.copyWith(intensity: intensity);
  }

  void updateJournal(String text) {
    state = state.copyWith(journalText: text);
  }

  void reset() {
    state = TodayState();
  }

  // Save logic will be added when Hive is fully integrated in Phase 3
}

final todayProvider = StateNotifierProvider<TodayNotifier, TodayState>((ref) {
  return TodayNotifier();
});
