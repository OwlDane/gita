import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gita/core/theme/app_colors.dart';
import 'package:gita/features/history/data/mood_repository.dart';
import 'package:gita/features/today/data/mood_entry.dart';
import 'package:gita/features/history/presentation/calendar_screen.dart';

class MoodCalendar extends ConsumerWidget {
  const MoodCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(moodRepositoryProvider);
    // Trigger rebuild when entries change
    ref.watch(historyEntriesProvider);

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kalender Mood',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarScreen()),
                );
              },
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final date = startOfWeek.add(Duration(days: index));
              final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
              final entry = repository.getEntryByDate(date);
              
              return _CalendarItem(
                date: date,
                isToday: isToday,
                mood: entry?.mood,
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _CalendarItem extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final MoodType? mood;

  const _CalendarItem({
    required this.date,
    required this.isToday,
    this.mood,
  });

  String _getMoodIcon(MoodType? mood) {
    switch (mood) {
      case MoodType.sedih: return 'assets/icons/3.png';
      case MoodType.biasa: return 'assets/icons/2.png';
      case MoodType.senang: return 'assets/icons/4.png';
      case MoodType.marah: return 'assets/icons/1.png';
      default: return '';
    }
  }

  Color _getMoodColor(MoodType? mood) {
    switch (mood) {
      case MoodType.sedih: return AppColors.moodSedih;
      case MoodType.biasa: return AppColors.moodBiasa;
      case MoodType.senang: return AppColors.moodSenang;
      case MoodType.marah: return AppColors.moodMarah;
      default: return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('E', 'id').format(date).substring(0, 1);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dayName,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isToday ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: mood != null ? _getMoodColor(mood).withValues(alpha: 0.2) : Colors.transparent,
            shape: BoxShape.circle,
            border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
          ),
          alignment: Alignment.center,
          child: mood != null 
            ? Image.asset(_getMoodIcon(mood), width: 22, height: 22)
            : Text(
                date.day.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isToday ? AppColors.textMain : AppColors.textSecondary.withValues(alpha: 0.5),
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
        ),
      ],
    );
  }
}
