import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../calendar/calendar_screen.dart';
import '../daily_vision/daily_vision_screen.dart';
import '../progress/progress_screen.dart';
import '../settings/settings_screen.dart';
import 'dashboard_tab.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      context.read<ProgressProvider>().loadForUser(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardTab(),
      const DailyVisionScreen(),
      const CalendarScreen(),
      const ProgressScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      extendBody: true,
      bottomNavigationBar: _MinimalBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _MinimalBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _MinimalBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      height: 70,
      decoration: BoxDecoration(
        color: AppTheme.deepTeal,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepTeal.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(icon: Icons.grid_view_rounded, isSelected: currentIndex == 0, onTap: () => onTap(0)),
          _NavBarItem(icon: Icons.insights_rounded, isSelected: currentIndex == 1, onTap: () => onTap(1)),
          _NavBarItem(icon: Icons.calendar_month_rounded, isSelected: currentIndex == 2, onTap: () => onTap(2)),
          _NavBarItem(icon: Icons.history_rounded, isSelected: currentIndex == 3, onTap: () => onTap(3)),
          _NavBarItem(icon: Icons.person_outline_rounded, isSelected: currentIndex == 4, onTap: () => onTap(4)),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
          size: 24,
        ),
      ),
    );
  }
}
