import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gita/core/constants/breakpoints.dart';
import 'package:gita/core/theme/app_colors.dart';
import 'package:gita/features/today/presentation/today_provider.dart';
import 'package:gita/features/history/data/mood_repository.dart';
import 'package:gita/features/today/presentation/widgets/greeting_header.dart';
import 'package:gita/features/today/presentation/widgets/mood_picker.dart';

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
                  const _AnimatedFadeIn(child: GreetingHeader()),
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

class MoodSection extends StatelessWidget {
  const MoodSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gimana perasaan kamu hari ini?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
        ),
        const SizedBox(height: 24),
        const MoodPicker(),
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
