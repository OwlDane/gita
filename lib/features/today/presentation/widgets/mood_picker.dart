import 'package:flutter/material.dart';
import 'package:gita/features/today/data/mood_entry.dart';
import 'package:gita/core/theme/app_colors.dart';

class MoodPicker extends StatelessWidget {
  final MoodType? selectedMood;
  final Function(MoodType) onSelect;

  const MoodPicker({
    super.key,
    required this.selectedMood,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _MoodItem(
          mood: MoodType.sedih,
          iconPath: 'assets/icons/3.png',
          label: 'Sedih',
          color: AppColors.moodSedih,
          isSelected: selectedMood == MoodType.sedih,
          onTap: () => onSelect(MoodType.sedih),
        ),
        _MoodItem(
          mood: MoodType.biasa,
          iconPath: 'assets/icons/2.png',
          label: 'Biasa',
          color: AppColors.moodBiasa,
          isSelected: selectedMood == MoodType.biasa,
          onTap: () => onSelect(MoodType.biasa),
        ),
        _MoodItem(
          mood: MoodType.senang,
          iconPath: 'assets/icons/4.png',
          label: 'Senang',
          color: AppColors.moodSenang,
          isSelected: selectedMood == MoodType.senang,
          onTap: () => onSelect(MoodType.senang),
        ),
        _MoodItem(
          mood: MoodType.marah,
          iconPath: 'assets/icons/1.png',
          label: 'Marah',
          color: AppColors.moodMarah,
          isSelected: selectedMood == MoodType.marah,
          onTap: () => onSelect(MoodType.marah),
        ),
      ],
    );
  }
}

class _MoodItem extends StatelessWidget {
  final MoodType mood;
  final String iconPath;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodItem({
    required this.mood,
    required this.iconPath,
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
            curve: Curves.easeOutQuart,
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isSelected ? color : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : AppColors.divider,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: isSelected ? 0.4 : 0.0),
                  blurRadius: isSelected ? 20.0 : 0.0,
                  spreadRadius: isSelected ? 2.0 : 0.0,
                )
              ],
            ),
            alignment: Alignment.center,
            child: Image.asset(
              iconPath,
              width: isSelected ? 48 : 42,
              height: isSelected ? 48 : 42,
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
