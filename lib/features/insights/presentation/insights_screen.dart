import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gita/features/insights/presentation/insights_provider.dart';
import 'package:gita/features/today/data/mood_entry.dart';
import 'package:gita/core/theme/app_colors.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  String _getEmoji(MoodType type) {
    switch (type) {
      case MoodType.sedih: return '😞';
      case MoodType.biasaAja: return '😐';
      case MoodType.senang: return '🙂';
      case MoodType.sangatSenang: return '😄';
    }
  }

  String _getMoodLabel(MoodType type) {
    switch (type) {
      case MoodType.sedih: return 'Sedih';
      case MoodType.biasaAja: return 'Biasa Aja';
      case MoodType.senang: return 'Senang';
      case MoodType.sangatSenang: return 'Sangat Senang';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wawasan'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AnimatedFadeIn(child: _StreakCard(streak: insights.streak)),
            const SizedBox(height: 32),
            _AnimatedFadeIn(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Distribusi Mood',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (insights.moodDistribution.isEmpty)
              const Center(child: Text('Belum ada data untuk ditampilkan'))
            else
              ...MoodType.values.asMap().entries.map((entry) {
                final index = entry.key;
                final mood = entry.value;
                final count = insights.moodDistribution[mood] ?? 0;
                final total = insights.moodDistribution.values.fold(0, (sum, item) => sum + item);
                final percentage = total > 0 ? count / total : 0.0;
                
                return _AnimatedFadeIn(
                  delay: Duration(milliseconds: 300 + (index * 100)),
                  child: _MoodDistributionBar(
                    mood: _getMoodLabel(mood),
                    emoji: _getEmoji(mood),
                    percentage: percentage,
                    count: count,
                    color: _getMoodColor(mood),
                  ),
                );
              }),
            const SizedBox(height: 32),
            if (insights.mostFrequentMood != null)
              _AnimatedFadeIn(
                delay: const Duration(milliseconds: 800),
                child: _MostFrequentCard(
                  mood: _getMoodLabel(insights.mostFrequentMood!),
                  emoji: _getEmoji(insights.mostFrequentMood!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.sedih: return AppColors.moodSedih;
      case MoodType.biasaAja: return AppColors.moodBiasaAja;
      case MoodType.senang: return AppColors.moodSenang;
      case MoodType.sangatSenang: return AppColors.moodSangatSenang;
    }
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            '🔥',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak Hari',
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'Streak Menulismu',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodDistributionBar extends StatelessWidget {
  final String mood;
  final String emoji;
  final double percentage;
  final int count;
  final Color color;

  const _MoodDistributionBar({
    required this.mood,
    required this.emoji,
    required this.percentage,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mood,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '$count',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 12,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _MostFrequentCard extends StatelessWidget {
  final String mood;
  final String emoji;

  const _MostFrequentCard({required this.mood, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mood Terbanyak',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Minggu ini kamu paling sering merasa $mood',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(emoji, style: const TextStyle(fontSize: 40)),
        ],
      ),
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
