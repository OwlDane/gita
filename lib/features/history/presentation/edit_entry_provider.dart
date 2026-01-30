import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gita/features/history/data/mood_repository.dart';
import 'package:gita/features/today/data/mood_entry.dart';
import 'package:uuid/uuid.dart';

class EditEntryState {
  final MoodType? selectedMood;
  final int intensity;
  final String journalText;
  final bool isSaving;
  final String? existingId;
  final DateTime? editingDate;
  final DateTime? createdAt;

  EditEntryState({
    this.selectedMood,
    this.intensity = 3,
    this.journalText = '',
    this.isSaving = false,
    this.existingId,
    this.editingDate,
    this.createdAt,
  });

  EditEntryState copyWith({
    MoodType? selectedMood,
    int? intensity,
    String? journalText,
    bool? isSaving,
    String? existingId,
    DateTime? editingDate,
    DateTime? createdAt,
  }) {
    return EditEntryState(
      selectedMood: selectedMood ?? this.selectedMood,
      intensity: intensity ?? this.intensity,
      journalText: journalText ?? this.journalText,
      isSaving: isSaving ?? this.isSaving,
      existingId: existingId ?? this.existingId,
      editingDate: editingDate ?? this.editingDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class EditEntryNotifier extends StateNotifier<EditEntryState> {
  EditEntryNotifier() : super(EditEntryState());

  void loadEntry(MoodEntry entry) {
    state = EditEntryState(
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

  Future<bool> saveEntry(MoodRepository repository) async {
    if (state.selectedMood == null || state.isSaving) return false;

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
    return true;
  }
}

final editEntryProvider = StateNotifierProvider<EditEntryNotifier, EditEntryState>((ref) {
  return EditEntryNotifier();
});
