import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gita/core/theme/app_colors.dart';
import 'package:gita/features/habits/data/habit.dart';
import 'package:gita/features/habits/data/habit_repository.dart';
import 'package:uuid/uuid.dart';

class AddHabitSheet extends StatefulWidget {
  const AddHabitSheet({super.key});

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final _nameController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7]; // Default all days

  final List<String> _dayNames = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        if (_selectedDays.length > 1) _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  void _applyPreset(String type) {
    setState(() {
      _selectedDays.clear();
      if (type == 'every') {
        _selectedDays.addAll([1, 2, 3, 4, 5, 6, 7]);
      } else if (type == 'weekday') {
        _selectedDays.addAll([1, 2, 3, 4, 5]);
      } else if (type == 'weekend') {
        _selectedDays.addAll([6, 7]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tambah Kebiasaan',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 24),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nama kebiasaan (mis: Minum Air Putih)',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Waktu Harian',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) setState(() => _selectedTime = time);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Hari',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PresetChip(
                    label: 'Setiap Hari',
                    isSelected: _selectedDays.length == 7,
                    onTap: () => _applyPreset('every'),
                  ),
                  const SizedBox(width: 8),
                  _PresetChip(
                    label: 'Weekday',
                    isSelected: _selectedDays.length == 5 && !_selectedDays.contains(6) && !_selectedDays.contains(7),
                    onTap: () => _applyPreset('weekday'),
                  ),
                  const SizedBox(width: 8),
                  _PresetChip(
                    label: 'Weekend',
                    isSelected: _selectedDays.length == 2 && _selectedDays.contains(6) && _selectedDays.contains(7),
                    onTap: () => _applyPreset('weekend'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final dayNum = index + 1;
                final isSelected = _selectedDays.contains(dayNum);
                return GestureDetector(
                  onTap: () => _toggleDay(dayNum),
                  child: Column(
                    children: [
                      Text(
                        _dayNames[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.textMain : AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.textMain : AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: isSelected ? AppColors.textMain : AppColors.divider),
                        ),
                        child: isSelected 
                          ? const Center(child: Icon(Icons.check_rounded, size: 20, color: AppColors.background))
                          : null,
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),
            Consumer(
              builder: (context, ref, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_nameController.text.isEmpty) return;
                      
                      final habit = Habit(
                        id: const Uuid().v4(),
                        name: _nameController.text,
                        hour: _selectedTime.hour,
                        minute: _selectedTime.minute,
                        iconPath: 'star', // Placeholder
                        daysOfWeek: _selectedDays,
                        createdAt: DateTime.now(),
                      );
                      
                      await ref.read(habitRepositoryProvider).addHabit(habit);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Simpan Kebiasaan'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
