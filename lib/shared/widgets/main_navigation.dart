import 'package:flutter/material.dart';
import 'package:gita/features/today/presentation/today_screen.dart';
import 'package:gita/features/history/presentation/history_screen.dart';
import 'package:gita/features/insights/presentation/insights_screen.dart';
import 'package:gita/core/theme/app_colors.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    TodayScreen(),
    HistoryScreen(),
    InsightsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary.withOpacity(0.4),
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
    );
  }
}
