import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gita/features/today/presentation/today_screen.dart';
import 'package:gita/features/history/presentation/history_screen.dart';
import 'package:gita/features/insights/presentation/insights_screen.dart';
import 'package:gita/features/habits/presentation/habit_screen.dart';
import 'package:gita/core/theme/app_colors.dart';
import 'package:gita/shared/providers/navigation_provider.dart';

class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  static const List<Widget> _screens = [
    TodayScreen(),
    HabitScreen(),
    HistoryScreen(),
    InsightsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationProvider);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(28, 0, 28, 32),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.textMain.withValues(alpha: 0.08), width: 1.5),
              ),
              child: BottomNavigationBar(
                currentIndex: selectedIndex,
                onTap: (index) {
                  ref.read(navigationProvider.notifier).state = index;
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.textSecondary.withValues(alpha: 0.3),
                showSelectedLabels: false,
                showUnselectedLabels: false,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.grid_view_rounded, size: 24),
                    activeIcon: Icon(Icons.grid_view_rounded, size: 24),
                    label: 'Today',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline_rounded, size: 24),
                    activeIcon: Icon(Icons.check_circle_rounded, size: 24),
                    label: 'Habits',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today_rounded, size: 22),
                    activeIcon: Icon(Icons.calendar_today_rounded, size: 22),
                    label: 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.analytics_outlined, size: 24),
                    activeIcon: Icon(Icons.analytics_rounded, size: 24),
                    label: 'Insights',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
