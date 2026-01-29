import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gita/features/today/data/mood_entry.dart';
import 'package:gita/core/theme/app_colors.dart';
import 'package:gita/features/today/presentation/today_provider.dart';

class MoodPicker extends ConsumerWidget {
  const MoodPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMood = ref.watch(todayProvider).selectedMood;
    final notifier = ref.read(todayProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _MoodItem(
          mood: MoodType.sedih,
          emoji: '😞',
          label: 'Sedih',
          color: AppColors.moodSedih,
          isSelected: selectedMood == MoodType.sedih,
          onTap: () => notifier.selectMood(MoodType.sedih),
        ),
        _MoodItem(
          mood: MoodType.biasaAja,
          emoji: '😐',
          label: 'Biasa',
          color: AppColors.moodBiasaAja,
          isSelected: selectedMood == MoodType.biasaAja,
          onTap: () => notifier.selectMood(MoodType.biasaAja),
        ),
        _MoodItem(
          mood: MoodType.senang,
          emoji: '🙂',
          label: 'Senang',
          color: AppColors.moodSenang,
          isSelected: selectedMood == MoodType.senang,
          onTap: () => notifier.selectMood(MoodType.senang),
        ),
        _MoodItem(
          mood: MoodType.sangatSenang,
          emoji: '😄',
          label: 'Sangat',
          color: AppColors.moodSangatSenang,
          isSelected: selectedMood == MoodType.sangatSenang,
          onTap: () => notifier.selectMood(MoodType.sangatSenang),
        ),
      ],
    );
  }
}

class _MoodItem extends StatelessWidget {
  final MoodType mood;
  final String emoji;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodItem({
    required this.mood,
    required this.emoji,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.elasticOut,
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isSelected ? color : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : AppColors.divider,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            alignment: Alignment.center,
            child: Text(
              emoji,
              style: TextStyle(fontSize: isSelected ? 36 : 30),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected ? AppColors.textMain : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}
