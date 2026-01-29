import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gita/core/constants/breakpoints.dart';
import 'package:gita/core/theme/app_colors.dart';
import 'package:gita/features/today/presentation/today_provider.dart';
import 'package:gita/features/history/data/mood_repository.dart';
import 'package:gita/features/today/presentation/widgets/greeting_header.dart';
import 'package:gita/features/today/presentation/widgets/mood_picker.dart';
import 'package:gita/features/today/presentation/widgets/mood_calendar.dart';

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
                color: AppColors.primary.withOpacity(0.05),
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
                color: AppColors.moodSedih.withOpacity(0.03),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Guard against unconstrained width
                  final maxWidth = constraints.maxWidth.isInfinite 
                      ? MediaQuery.of(context).size.width 
                      : constraints.maxWidth;
                  
                  // Responsive width handling
                  final double horizontalPadding = maxWidth > AppBreakpoints.tablet 
                      ? maxWidth * 0.2 
                      : 24.0;

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
        : Text(state.existingId != null ? 'Perbarui Cerita' : 'Simpan Cerita'),
    );
  }
}

class MoodSection extends StatelessWidget {
  const MoodSection({super.key});

  @override
  Widget build(BuildContext context) {
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
        const MoodPicker(),
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
    final intensity = ref.watch(todayProvider).intensity;
    final notifier = ref.read(todayProvider.notifier);

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
            Text(
              '$intensity/5',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surface,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
            trackHeight: 12,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 4,
            ),
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: intensity.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (value) => notifier.updateIntensity(value.toInt()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Biasa aja', style: Theme.of(context).textTheme.labelSmall),
              Text('Banget!', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ],
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
