import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gita/core/constants/breakpoints.dart';
import 'package:gita/core/theme/app_colors.dart';
import 'package:gita/features/today/presentation/today_provider.dart';
import 'package:gita/features/history/data/mood_repository.dart';
import 'package:gita/features/habits/data/habit.dart';
import 'package:gita/features/habits/data/habit_repository.dart';
import 'package:gita/features/today/presentation/widgets/greeting_header.dart';
import 'package:gita/features/today/presentation/widgets/mood_picker.dart';
import 'package:gita/features/today/presentation/widgets/mood_calendar.dart';
import 'package:gita/features/today/presentation/widgets/intensity_picker.dart';
import 'package:gita/shared/providers/navigation_provider.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = ref.read(moodRepositoryProvider);
      ref.read(todayProvider.notifier).checkTodayEntry(repo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Decorative Blobs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.moodSedih.withValues(alpha: 0.03),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Builder(
                builder: (context) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  
                  // Responsive width handling
                  final double horizontalPadding = screenWidth > AppBreakpoints.tablet 
                      ? screenWidth * 0.2 
                      : 24.0;

                  final hasEntry = ref.watch(todayProvider.select((s) => s.existingId != null));

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 32, horizontalPadding, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _AnimatedFadeIn(child: GreetingHeader()),
                        const SizedBox(height: 32),
                        const _AnimatedFadeIn(
                          delay: Duration(milliseconds: 100),
                          child: MoodCalendar(),
                        ),
                        const SizedBox(height: 48),
                        if (hasEntry) ...[
                          const _AnimatedFadeIn(
                            delay: Duration(milliseconds: 200),
                            child: TodayCompletionSection(),
                          ),
                          const SizedBox(height: 32),
                          const _AnimatedFadeIn(
                            delay: Duration(milliseconds: 400),
                            child: HabitSummaryCard(),
                          ),
                          const SizedBox(height: 32),
                          const _AnimatedFadeIn(
                            delay: Duration(milliseconds: 600),
                            child: DailyQuote(),
                          ),
                        ] else ...[
                          const _AnimatedFadeIn(
                            delay: Duration(milliseconds: 200),
                            child: MoodSection(),
                          ),
                          const SizedBox(height: 48),
                          const _AnimatedFadeIn(
                            delay: Duration(milliseconds: 400),
                            child: JournalInput(),
                          ),
                          const SizedBox(height: 40),
                          const _AnimatedFadeIn(
                            delay: Duration(milliseconds: 600),
                            child: SaveButton(),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class JournalInput extends ConsumerStatefulWidget {
  const JournalInput({super.key});

  @override
  ConsumerState<JournalInput> createState() => _JournalInputState();
}

class _JournalInputState extends ConsumerState<JournalInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(todayProvider).journalText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(todayProvider.notifier);

    // Sync controller with state if state changes from outside (e.g. loadEntry)
    ref.listen(todayProvider.select((s) => s.existingId), (prev, next) {
      if (next != null && prev != next) {
        _controller.text = ref.read(todayProvider).journalText;
      } else if (next == null && prev != null) {
        _controller.text = '';
      }
    });

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
          controller: _controller,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Tulis apa pun yang kamu rasain hari ini...',
            hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.3)),
            filled: true,
            fillColor: AppColors.surface,
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
    final isSaving = ref.watch(todayProvider.select((s) => s.isSaving));
    final hasMood = ref.watch(todayProvider.select((s) => s.selectedMood != null));
    final isEditing = ref.watch(todayProvider.select((s) => s.existingId != null));
    final repo = ref.read(moodRepositoryProvider);
    final isEnabled = hasMood && !isSaving;

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
      child: isSaving 
        ? const SizedBox(
            height: 20, 
            width: 20, 
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          ) 
        : Text(isEditing ? 'Perbarui Cerita' : 'Simpan Cerita'),
    );
  }
}

class MoodSection extends ConsumerWidget {
  const MoodSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gimana perasaan kamu hari ini?',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 20,
              ),
        ),
        const SizedBox(height: 24),
        MoodPicker(
          selectedMood: ref.watch(todayProvider.select((s) => s.selectedMood)),
          onSelect: ref.read(todayProvider.notifier).selectMood,
        ),
        const SizedBox(height: 48),
        const IntensitySection(),
      ],
    );
  }
}

class IntensitySection extends ConsumerWidget {
  const IntensitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intensity = ref.watch(todayProvider.select((s) => s.intensity));
    final notifier = ref.read(todayProvider.notifier);

    return IntensityPicker(
      intensity: intensity,
      onChanged: notifier.updateIntensity,
    );
  }
}

class _AnimatedFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedFadeIn({
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<_AnimatedFadeIn> createState() => _AnimatedFadeInState();
}

class _AnimatedFadeInState extends State<_AnimatedFadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

class TodayCompletionSection extends ConsumerWidget {
  const TodayCompletionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.textMain.withValues(alpha: 0.05), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '✨',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 24),
          const Text(
            'Kamu sudah mengisi cerita hari ini, makasih ya!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Mau cek atau perbarui ceritanya?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              ref.read(navigationProvider.notifier).state = 2; // Index for History (Cerita Kamu)
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              foregroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Buka Riwayat Cerita'),
          ),
        ],
      ),
    );
  }
}

class HabitSummaryCard extends ConsumerWidget {
  const HabitSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final logsAsync = ref.watch(habitLogsForDateProvider(today));

    return habitsAsync.when(
      data: (habits) {
        if (habits.isEmpty) return const SizedBox.shrink();

        final dayOfWeek = now.weekday;
        final todaysHabits = habits.where((h) => h.daysOfWeek.contains(dayOfWeek)).toList();
        if (todaysHabits.isEmpty) return const SizedBox.shrink();

        return logsAsync.when(
          data: (logs) {
            final completedCount = todaysHabits.where((h) {
              final log = logs.where((l) => l.habitId == h.id).firstOrNull;
              return log?.status == HabitStatus.completed;
            }).length;

            final progress = (todaysHabits.isEmpty) ? 0.0 : completedCount / todaysHabits.length;

            return GestureDetector(
              onTap: () => ref.read(navigationProvider.notifier).state = 1, // Habits index
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.textMain.withValues(alpha: 0.05), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progres Kebiasaan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$completedCount/${todaysHabits.length}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: AppColors.background,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      progress == 1.0 
                        ? 'Luar biasa! Semua kebiasaan hari ini sudah tuntas. 🔥' 
                        : 'Yuk, selesaikan ${todaysHabits.length - completedCount} kebiasaan lagi hari ini!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Lihat Detail',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppColors.primary.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class DailyQuote extends StatelessWidget {
  const DailyQuote({super.key});

  @override
  Widget build(BuildContext context) {
    // List of inspiring quotes
    final quotes = [
      "Kebahagiaan bukan sesuatu yang sudah jadi. Itu berasal dari tindakanmu sendiri.",
      "Setiap hari adalah kesempatan baru untuk menjadi lebih baik dari kemarin.",
      "Tarik napas dalam-dalam. Ini hanya hari yang buruk, bukan kehidupan yang buruk.",
      "Fokus pada hal-hal kecil yang membuatmu bersyukur hari ini.",
      "Kamu tidak perlu melihat seluruh tangga, cukup ambil langkah pertama.",
      "Satu-satunya cara untuk melakukan pekerjaan hebat adalah dengan mencintai apa yang kamu lakukan.",
      "Kesehatan mentalmu adalah prioritas. Istirahatlah jika perlu.",
    ];

    // Select quote based on day of year
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final quote = quotes[dayOfYear % quotes.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.moodSedih.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.textMain.withValues(alpha: 0.03)),
      ),
      child: Column(
        children: [
          const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 32),
          const SizedBox(height: 16),
          Text(
            quote,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              height: 1.6,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }
}
