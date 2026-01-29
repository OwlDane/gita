import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import 'today_provider.dart';
import 'widgets/greeting_header.dart';
import 'widgets/mood_picker.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive width handling
            final double horizontalPadding = constraints.maxWidth > AppBreakpoints.tablet 
                ? constraints.maxWidth * 0.2 
                : 24.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GreetingHeader(),
                  const SizedBox(height: 48),
                  Text(
                    'Gimana perasaan kamu hari ini?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 24),
                  const MoodPicker(),
                  const SizedBox(height: 48),
                  const JournalInput(),
                  const SizedBox(height: 40),
                  const SaveButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class JournalInput extends ConsumerWidget {
  const JournalInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(todayProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mau cerita sedikit?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
        ),
        const SizedBox(height: 16),
        TextField(
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Tulis apa pun yang kamu rasain hari ini...',
            hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
            filled: true,
            fillColor: AppColors.creamWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
          onChanged: notifier.updateJournal,
        ),
      ],
    );
  }
}

class SaveButton extends ConsumerWidget {
  const SaveButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(todayProvider);
    final repo = ref.read(moodRepositoryProvider);
    final isEnabled = state.selectedMood != null && !state.isSaving;

    return ElevatedButton(
      onPressed: isEnabled ? () async {
        await ref.read(todayProvider.notifier).saveEntry(repo);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cerita kamu sudah tersimpan ✨'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } : null,
      child: state.isSaving 
        ? const SizedBox(
            height: 20, 
            width: 20, 
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          ) 
        : const Text('Simpan Cerita'),
    );
  }
}
