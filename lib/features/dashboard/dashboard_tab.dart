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
import '../auth/auth_screen.dart';
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
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.isGuest
                          ? 'مرحبًا، ابدأ من حيث أنت'
                          : 'أهلًا ${auth.currentUser?.name}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'حلول صحية متكاملة لتطورك الشخصي',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              _StatusPill(isOnline: appState.isOnline),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryOrange,
                  AppTheme.primaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خطة اليوم',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'ابدأ رحلتك نحو حياة أفضل مع خطتنا المخصصة لك',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricBadge(
                      label: 'جلسات محفوظة',
                      value: '${progress.sessions.length}',
                    ),
                    _MetricBadge(
                      label: 'متوسط الدقة',
                      value: '${progress.averageAccuracy.toStringAsFixed(0)}%',
                    ),
                    _MetricBadge(
                      label: 'إجمالي الدقائق',
                      value: '${progress.totalMinutes}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (auth.isGuest)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_sync_rounded,
                      color: AppTheme.primaryOrange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'أنت الآن بوضع محلي. أنشئ حسابًا لتفعيل Firebase ومزامنة الجلسات على السحابة.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                      );
                    },
                    child: const Text('تفعيل'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 22),
          Text('تمارين مقترحة',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          ...exercises.take(3).map(
                (exercise) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AnimatedCard(
                    duration: const Duration(milliseconds: 500),
                    child: _ExerciseCard(exercise: exercise),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise});

  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () {
        Navigator.push(
          context,
          PageTransitions.slide(
            builder: (_) => ExerciseDetailScreen(exercise: exercise),
            routeName: '/exercise-detail',
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryOrange.withValues(alpha: 0.2),
                    AppTheme.primaryOrange.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.accessibility_new_rounded,
                size: 34,
                color: AppTheme.primaryOrange,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.title,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(exercise.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TinyTag(text: exercise.category),
                      _TinyTag(text: exercise.level),
                      _TinyTag(text: '${exercise.durationMinutes} د'),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isOnline
            ? AppTheme.primaryOrange.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 10,
            color: isOnline ? AppTheme.primaryOrange : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(isOnline ? 'أونلاين' : 'أوفلاين'),
        ],
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _TinyTag extends StatelessWidget {
  const _TinyTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryOrange,
            ),
      ),
    );
  }
}
