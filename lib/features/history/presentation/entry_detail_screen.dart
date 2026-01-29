import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../today/data/mood_entry.dart';
import '../../../core/theme/app_colors.dart';

class EntryDetailScreen extends StatelessWidget {
  final MoodEntry entry;

  const EntryDetailScreen({super.key, required this.entry});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Cerita'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(entry.date),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.creamWhite,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                children: [
                  Text(
                    _getEmoji(entry.mood),
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
                        _getMoodLabel(entry.mood),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (entry.journal.isNotEmpty) ...[
              const Text(
                'Cerita kamu:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                entry.journal,
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
        ),
      ),
    );
  }
}
