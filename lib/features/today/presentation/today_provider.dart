import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../history/data/mood_repository.dart';
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

  Future<void> saveEntry(MoodRepository repository) async {
    if (state.selectedMood == null || state.isSaving) return;

    state = state.copyWith(isSaving: true);

    final entry = MoodEntry.create(
      mood: state.selectedMood!,
      intensity: state.intensity,
      journal: state.journalText,
    );

    await repository.addEntry(entry);
    
    state = state.copyWith(isSaving: false);
    reset();
  }

  void reset() {
    state = TodayState();
  }
}

final todayProvider = StateNotifierProvider<TodayNotifier, TodayState>((ref) {
  return TodayNotifier();
});
