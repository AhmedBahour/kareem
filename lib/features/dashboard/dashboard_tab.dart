import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_widgets.dart';
import '../../core/navigation/page_transitions.dart';
import '../../data/models/exercise_model.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exercise_catalog_provider.dart';
import '../../providers/progress_provider.dart';
import '../exercise/exercise_detail_screen.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final auth = context.watch<AuthProvider>();
    final exercises = context.watch<ExerciseCatalogProvider>().allExercises;
    final progress = context.watch<ProgressProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auth.isGuest ? 'مرحباً بك' : 'أهلاً، ${auth.currentUser?.name}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.deepTeal,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'كيف تشعر اليوم؟',
                    style: TextStyle(color: AppTheme.softGrey, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              _StatusIndicator(isOnline: appState.isOnline),
            ],
          ),

          const SizedBox(height: 32),

          // Featured Progress Card
          AnimatedCard(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.deepTeal, AppTheme.primaryTeal],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.deepTeal.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ملخص النشاط',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      Icon(Icons.auto_awesome_rounded, color: Colors.white.withValues(alpha: 0.6), size: 22),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _CompactStat(label: 'جلسات', value: '${progress.sessions.length}'),
                      _CompactStat(label: 'دقة', value: '${progress.averageAccuracy.toStringAsFixed(0)}%'),
                      _CompactStat(label: 'دقائق', value: '${progress.totalMinutes}'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Categories Grid
          Text(
            'الأقسام العلاجية',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _CategoryCard(title: 'الكتف والذراع', icon: Icons.accessibility_new_rounded, color: AppTheme.primaryTeal),
              _CategoryCard(title: 'الظهر والعمود', icon: Icons.boy_rounded, color: AppTheme.accentOrange),
              _CategoryCard(title: 'اليد والأصابع', icon: Icons.back_hand_rounded, color: const Color(0xFF6B8E23)),
              _CategoryCard(title: 'الإحماء', icon: Icons.local_fire_department_rounded, color: const Color(0xFFCD5C5C)),
            ],
          ),

          const SizedBox(height: 40),

          // Recommended Exercises
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تمارين مقترحة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('المزيد', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryTeal)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...exercises.take(3).map(
                (exercise) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ModernExerciseItem(exercise: exercise),
                ),
              ),
        ],
      ),
    );
  }
}

class _CompactStat extends StatelessWidget {
  final String label;
  final String value;
  const _CompactStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _CategoryCard({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ModernExerciseItem extends StatelessWidget {
  final ExerciseModel exercise;
  const _ModernExerciseItem({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageTransitions.slide(
            builder: (_) => ExerciseDetailScreen(exercise: exercise),
            routeName: '/exercise-detail',
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.fitness_center_rounded, color: AppTheme.primaryTeal, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.speed_rounded, color: AppTheme.softGrey, size: 14),
                      const SizedBox(width: 4),
                      Text(exercise.level, style: TextStyle(color: AppTheme.softGrey, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Icon(Icons.timer_outlined, color: AppTheme.softGrey, size: 14),
                      const SizedBox(width: 4),
                      Text('${exercise.durationMinutes} د', style: TextStyle(color: AppTheme.softGrey, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded, color: Colors.grey, size: 24),
          ],
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final bool isOnline;
  const _StatusIndicator({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFFE0F2F1) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: isOnline ? const Color(0xFF00897B) : const Color(0xFFFB8C00)),
          const SizedBox(width: 8),
          Text(
            isOnline ? 'مزامنة' : 'محلي',
            style: TextStyle(
              color: isOnline ? const Color(0xFF004D40) : const Color(0xFFE65100),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
