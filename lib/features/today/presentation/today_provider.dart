import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gita/features/history/data/mood_repository.dart';
import 'package:gita/features/today/data/mood_entry.dart';
import 'package:uuid/uuid.dart';

class TodayState {
  final MoodType? selectedMood;
  final int intensity;
  final String journalText;
  final bool isSaving;
  final String? existingId;
  final DateTime? editingDate;
  final DateTime? createdAt;

  TodayState({
    this.selectedMood,
    this.intensity = 3,
    this.journalText = '',
    this.isSaving = false,
    this.existingId,
    this.editingDate,
    this.createdAt,
  });

  TodayState copyWith({
    MoodType? selectedMood,
    int? intensity,
    String? journalText,
    bool? isSaving,
    String? existingId,
    bool clearExisting = false,
    DateTime? editingDate,
    DateTime? createdAt,
  }) {
    return TodayState(
      selectedMood: selectedMood ?? this.selectedMood,
      intensity: intensity ?? this.intensity,
      journalText: journalText ?? this.journalText,
      isSaving: isSaving ?? this.isSaving,
      existingId: clearExisting ? null : (existingId ?? this.existingId),
      editingDate: clearExisting ? null : (editingDate ?? this.editingDate),
      createdAt: clearExisting ? null : (createdAt ?? this.createdAt),
    );
  }
}

class TodayNotifier extends StateNotifier<TodayState> {
  TodayNotifier() : super(TodayState());

  void checkTodayEntry(MoodRepository repository) {
    final todayEntry = repository.getEntryByDate(DateTime.now());
    if (todayEntry != null && state.existingId == null) {
      loadEntry(todayEntry);
    }
  }

  void loadEntry(MoodEntry entry) {
    state = TodayState(
      selectedMood: entry.mood,
      intensity: entry.intensity,
      journalText: entry.journal,
      existingId: entry.id,
      editingDate: entry.date,
      createdAt: entry.createdAt,
    );
  }

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

    final entry = MoodEntry(
      id: state.existingId ?? Uuid().v4(),
      mood: state.selectedMood!,
      intensity: state.intensity,
      journal: state.journalText,
      date: state.editingDate ?? DateTime.now(),
      createdAt: state.createdAt ?? DateTime.now(),
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
