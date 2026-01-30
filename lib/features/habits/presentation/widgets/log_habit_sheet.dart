import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gita/features/habits/data/habit.dart';
import 'package:gita/features/habits/data/habit_repository.dart';
import 'package:gita/core/theme/app_colors.dart';
import 'package:uuid/uuid.dart';

class LogHabitSheet extends StatelessWidget {
  final Habit habit;
  final DateTime date;

  const LogHabitSheet({super.key, required this.habit, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(child: Icon(Icons.star_rounded, size: 40, color: AppColors.primary)),
          ),
          const SizedBox(height: 24),
          Text(
            habit.name,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            'Hari ini jam ${TimeOfDay(hour: habit.hour, minute: habit.minute).format(context)}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _log(context, HabitStatus.skipped),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text('Terlewat', style: TextStyle(color: AppColors.textMain)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    return ElevatedButton(
                      onPressed: () => _log(context, HabitStatus.completed, ref),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Sudah'),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _log(BuildContext context, HabitStatus status, [WidgetRef? ref]) async {
    if (ref != null) {
      final log = HabitLog(
        id: const Uuid().v4(),
        habitId: habit.id,
        date: DateTime(date.year, date.month, date.day),
        status: status,
        loggedAt: DateTime.now(),
      );
      await ref.read(habitRepositoryProvider).logHabit(log);
    }
    if (context.mounted) Navigator.pop(context);
  }
}
