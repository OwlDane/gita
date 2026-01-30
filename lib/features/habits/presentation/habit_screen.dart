import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gita/core/theme/app_colors.dart';
import 'package:gita/features/habits/data/habit.dart';
import 'package:gita/features/habits/data/habit_repository.dart';
import 'package:gita/features/habits/presentation/habit_providers.dart';
import 'package:gita/features/habits/presentation/widgets/habit_day_selector.dart';
import 'package:gita/features/habits/presentation/widgets/add_habit_sheet.dart';
import 'package:gita/features/habits/presentation/widgets/log_habit_sheet.dart';
import 'package:intl/intl.dart';

class HabitScreen extends ConsumerWidget {
  const HabitScreen({super.key});

  void _showAddHabit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddHabitSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(habitSelectedDateProvider);
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kebiasaan'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => _showAddHabit(context),
            icon: const Icon(Icons.add_rounded, size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HabitDaySelector(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              'Log',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: habitsAsync.when(
              data: (habits) {
                if (habits.isEmpty) {
                  return const _EmptyState();
                }
                
                final dayOfWeek = selectedDate.weekday;
                final filteredHabits = habits.where((h) => h.daysOfWeek.contains(dayOfWeek)).toList();
                
                if (filteredHabits.isEmpty) {
                  return const _EmptyDay();
                }

                filteredHabits.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: filteredHabits.length,
                  itemBuilder: (context, index) {
                    final habit = filteredHabits[index];
                    return _HabitCard(habit: habit, date: selectedDate);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitCard extends ConsumerWidget {
  final Habit habit;
  final DateTime date;

  const _HabitCard({required this.habit, required this.date});

  void _showLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => LogHabitSheet(habit: habit, date: date),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(habitLogsForDateProvider(date));
    
    final log = logsAsync.when(
      data: (logs) => logs.where((l) => l.habitId == habit.id).firstOrNull,
      loading: () => null,
      error: (_, __) => null,
    );

    final String timeStr = DateFormat.Hm().format(DateTime(2024, 1, 1, habit.hour, habit.minute));
    
    Widget statusIcon = const Icon(Icons.add_circle_outline_rounded, color: Colors.blueAccent);
    
    if (log != null) {
      if (log.status == HabitStatus.completed) {
        statusColor = Colors.green.withValues(alpha: 0.1);
        statusIcon = const Icon(Icons.check_circle_rounded, color: Colors.green);
      } else if (log.status == HabitStatus.skipped) {
        statusColor = Colors.orange.withValues(alpha: 0.1);
        statusIcon = const Icon(Icons.do_not_disturb_on_rounded, color: Colors.orange);
      }
    }

    return GestureDetector(
      onTap: () => _showLogSheet(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: log?.status == HabitStatus.completed ? Colors.green.withValues(alpha: 0.05) : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: log?.status == HabitStatus.completed ? Colors.green.withValues(alpha: 0.3) : AppColors.divider, 
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(child: Icon(Icons.star_rounded, color: AppColors.primary)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeStr,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    habit.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ),
            statusIcon,
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 24),
          Text(
            'Mulai kebiasaan baikmu!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Klik tombol + untuk menambah\nkebiasaan harian.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏖️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 24),
          Text(
            'Hari ini terjadwal santai!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tidak ada kebiasaan yang perlu\ndilakukan hari ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
