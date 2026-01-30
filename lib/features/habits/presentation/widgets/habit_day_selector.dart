import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gita/core/theme/app_colors.dart';
import 'package:gita/features/habits/presentation/habit_providers.dart';

class HabitDaySelector extends ConsumerWidget {
  const HabitDaySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(habitSelectedDateProvider);
    
    // Generate 15 days around today
    final days = List.generate(15, (index) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return today.add(Duration(days: index - 7));
    });

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day.year == selectedDate.year && 
                            day.month == selectedDate.month && 
                            day.day == selectedDate.day;
          
          final isToday = day.year == DateTime.now().year && 
                         day.month == DateTime.now().month && 
                         day.day == DateTime.now().day;

          return GestureDetector(
            onTap: () => ref.read(habitSelectedDateProvider.notifier).state = day,
            child: Column(
              children: [
                Text(
                  DateFormat.E('id').format(day).substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.textMain : AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.textMain : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.textMain : AppColors.divider,
                      width: 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ] : null,
                  ),
                  child: Center(
                    child: Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.background : AppColors.textMain,
                      ),
                    ),
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
