import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gita/core/theme/app_colors.dart';
import 'package:gita/features/history/data/mood_repository.dart';
import 'package:gita/features/today/data/mood_entry.dart';
import 'package:gita/features/history/presentation/entry_detail_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String _getMoodIcon(MoodType type) {
    switch (type) {
      case MoodType.sedih: return 'assets/icons/3.png';
      case MoodType.biasa: return 'assets/icons/2.png';
      case MoodType.senang: return 'assets/icons/4.png';
      case MoodType.marah: return 'assets/icons/1.png';
    }
  }

  Color _getMoodColor(MoodType type) {
    switch (type) {
      case MoodType.sedih: return AppColors.moodSedih;
      case MoodType.biasa: return AppColors.moodBiasa;
      case MoodType.senang: return AppColors.moodSenang;
      case MoodType.marah: return AppColors.moodMarah;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(moodRepositoryProvider);
    // Watch entries to rebuild on changes
    ref.watch(historyEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Mood'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              locale: 'id_ID',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final entry = repository.getEntryByDate(day);
                  if (entry != null) {
                    return _CalendarDay(
                      day: day,
                      mood: entry.mood,
                      onTap: () => _navigateToDetail(entry),
                    );
                  }
                  return null;
                },
                todayBuilder: (context, day, focusedDay) {
                  final entry = repository.getEntryByDate(day);
                  return _CalendarDay(
                    day: day,
                    mood: entry?.mood,
                    isToday: true,
                    onTap: entry != null ? () => _navigateToDetail(entry) : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(MoodEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryDetailScreen(entry: entry),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keterangan Mood',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: MoodType.values.map((mood) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getMoodColor(mood),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(_getMoodIcon(mood), width: 16, height: 16),
                  const SizedBox(width: 4),
                  Text(
                    _getMoodLabel(mood),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getMoodLabel(MoodType type) {
    switch (type) {
      case MoodType.sedih: return 'Sedih';
      case MoodType.biasa: return 'Biasa';
      case MoodType.senang: return 'Senang';
      case MoodType.marah: return 'Marah';
    }
  }
}

class _CalendarDay extends StatelessWidget {
  final DateTime day;
  final MoodType? mood;
  final bool isToday;
  final VoidCallback? onTap;

  const _CalendarDay({
    required this.day,
    this.mood,
    this.isToday = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    if (mood != null) {
      switch (mood!) {
        case MoodType.sedih: bgColor = AppColors.moodSedih; break;
        case MoodType.biasa: bgColor = AppColors.moodBiasa; break;
        case MoodType.senang: bgColor = AppColors.moodSenang; break;
        case MoodType.marah: bgColor = AppColors.moodMarah; break;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgColor?.withValues(alpha: isToday ? 0.3 : 0.15),
          borderRadius: BorderRadius.circular(12),
          border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? AppColors.primary : AppColors.textMain,
              ),
            ),
            if (mood != null)
              Image.asset(
                _getMoodIcon(mood!),
                width: 14,
                height: 14,
              ),
          ],
        ),
      ),
    );
  }

  String _getMoodIcon(MoodType type) {
    switch (type) {
      case MoodType.sedih: return 'assets/icons/3.png';
      case MoodType.biasa: return 'assets/icons/2.png';
      case MoodType.senang: return 'assets/icons/4.png';
      case MoodType.marah: return 'assets/icons/1.png';
    }
  }
}
