import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gita/features/today/data/mood_entry.dart';
import 'package:gita/features/history/data/mood_repository.dart';
import 'package:gita/features/history/presentation/edit_entry_provider.dart';
import 'package:gita/features/today/presentation/widgets/mood_picker.dart';
import 'package:gita/features/today/presentation/widgets/intensity_picker.dart';
import 'package:gita/core/theme/app_colors.dart';

class EntryDetailScreen extends ConsumerStatefulWidget {
  final MoodEntry entry;

  const EntryDetailScreen({super.key, required this.entry});

  @override
  ConsumerState<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends ConsumerState<EntryDetailScreen> {
  bool _isEditing = false;
  late TextEditingController _journalController;

  @override
  void initState() {
    super.initState();
    _journalController = TextEditingController(text: widget.entry.journal);
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  String _getEmoji(MoodType type) {
    switch (type) {
      case MoodType.sedih: return '😞';
      case MoodType.biasaAja: return '😐';
      case MoodType.senang: return '🙂';
      case MoodType.sangatSenang: return '😄';
    }
  }

  String _getMoodLabel(MoodType type) {
    switch (type) {
      case MoodType.sedih: return 'Sedih';
      case MoodType.biasaAja: return 'Biasa Aja';
      case MoodType.senang: return 'Senang';
      case MoodType.sangatSenang: return 'Sangat Senang';
    }
  }

  void _toggleEdit() {
    if (!_isEditing) {
      ref.read(editEntryProvider.notifier).loadEntry(widget.entry);
      _journalController.text = widget.entry.journal;
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    final success = await ref.read(editEntryProvider.notifier).saveEntry(
      ref.read(moodRepositoryProvider),
    );

    if (success && mounted) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan berhasil disimpan ✨')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(editEntryProvider);
    final editNotifier = ref.read(editEntryProvider.notifier);

    // If not editing, we use the widget.entry directly. 
    // If editing, we use the editState.
    final currentMood = _isEditing ? editState.selectedMood : widget.entry.mood;
    final currentJournal = _isEditing ? editState.journalText : widget.entry.journal;
    final currentIntensity = _isEditing ? editState.intensity : widget.entry.intensity;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Cerita' : 'Detail Cerita'),
        actions: [
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: _toggleEdit,
            ),
            IconButton(
              icon: editState.isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check_rounded),
              onPressed: _saveChanges,
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _toggleEdit,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, d MMMM yyyy', 'id').format(widget.entry.date),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 32),
            
            if (_isEditing) ...[
              Text(
                'Gimana perasaan kamu?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              MoodPicker(
                selectedMood: editState.selectedMood,
                onSelect: editNotifier.selectMood,
              ),
              const SizedBox(height: 32),
              IntensityPicker(
                intensity: editState.intensity,
                onChanged: editNotifier.updateIntensity,
              ),
              const SizedBox(height: 32),
              Text(
                'Mau ubah ceritanya?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _journalController,
                maxLines: 6,
                onChanged: editNotifier.updateJournal,
                decoration: InputDecoration(
                  hintText: 'Tulis ceritamu di sini...',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.divider, width: 1),
                ),
                child: Row(
                  children: [
                    Text(
                      _getEmoji(widget.entry.mood),
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mood Kamu',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _getMoodLabel(widget.entry.mood),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Intensitas: ${widget.entry.intensity}/5',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (widget.entry.journal.isNotEmpty) ...[
                const Text(
                  'Cerita kamu:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.entry.journal,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: AppColors.textMain,
                  ),
                ),
              ] else 
                const Center(
                  child: Text(
                    'Kamu tidak menulis cerita hari ini.',
                    style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
