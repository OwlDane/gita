import 'package:flutter/material.dart';
import 'package:gita/core/theme/app_colors.dart';

class IntensityPicker extends StatelessWidget {
  final int intensity;
  final Function(int) onChanged;

  const IntensityPicker({
    super.key,
    required this.intensity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Seberapa intens rasanya?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$intensity/5',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surface,
            thumbColor: Colors.white,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
            trackHeight: 12,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 14,
              elevation: 4,
              pressedElevation: 8,
            ),
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: intensity.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (value) => onChanged(value.toInt()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ringan', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.5))),
              Text('Kuat', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.5))),
            ],
          ),
        ),
      ],
    );
  }
}
