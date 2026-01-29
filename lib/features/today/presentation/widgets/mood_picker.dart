import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mood_entry.dart';
import '../../../core/theme/app_colors.dart';

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
          label: 'Biasa Aja',
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
          label: 'Sangat Senang',
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
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isSelected ? 72 : 64,
            height: isSelected ? 72 : 64,
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ]
                  : [],
            ),
            alignment: Alignment.center,
            child: Text(
              emoji,
              style: TextStyle(fontSize: isSelected ? 38 : 32),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.textMain : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
