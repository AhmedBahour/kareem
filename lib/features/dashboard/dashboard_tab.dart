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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Header
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.1),
                child: const Icon(Icons.person_rounded, color: AppTheme.primaryOrange, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.isGuest ? 'مرحباً بك' : 'أهلاً، ${auth.currentUser?.name}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                    ),
                    Text(
                      'خطة التعافي ليومك جاهزة',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              _StatusPill(isOnline: appState.isOnline),
            ],
          ),

          const SizedBox(height: 30),

          // Main Action Card (Featured)
          AnimatedCard(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryOrange, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إحصائيات الأسبوع',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _LargeMetric(label: 'جلسات', value: '${progress.sessions.length}'),
                      _LargeMetric(label: 'دقة', value: '${progress.averageAccuracy.toStringAsFixed(0)}%'),
                      _LargeMetric(label: 'دقيقة', value: '${progress.totalMinutes}'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerRight,
                      widthFactor: 0.65, // Example progress
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          if (auth.isGuest) ...[
            _buildGuestNotification(context),
            const SizedBox(height: 30),
          ],

          // Categories or Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التمارين المخصصة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('عرض الكل', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Modern Exercise List
          ...exercises.take(4).map(
                (exercise) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _ModernExerciseCard(exercise: exercise),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildGuestNotification(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7F2),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_upload_rounded, color: AppTheme.primaryOrange),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مزامنة البيانات',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'قم بتسجيل الدخول لحفظ تقدمك سحابياً.',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('تفعيل', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _LargeMetric extends StatelessWidget {
  final String label;
  final String value;

  const _LargeMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 26,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ModernExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;

  const _ModernExerciseCard({required this.exercise});

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
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image/Icon placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Icon(
                  Icons.accessibility_new_rounded,
                  color: AppTheme.primaryOrange.withValues(alpha: 0.6),
                  size: 34,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _SimpleTag(text: exercise.category, color: const Color(0xFF2D7969)),
                      const SizedBox(width: 8),
                      _SimpleTag(text: '${exercise.durationMinutes} د', color: AppTheme.primaryOrange),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.grey),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

class _SimpleTag extends StatelessWidget {
  final String text;
  final Color color;

  const _SimpleTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFFE2F5EF) : const Color(0xFFFFF1DF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: isOnline ? const Color(0xFF2D7969) : AppTheme.primaryOrange,
          ),
          const SizedBox(width: 8),
          Text(
            isOnline ? 'متصل' : 'محلي',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: isOnline ? const Color(0xFF2D7969) : AppTheme.primaryOrange,
            ),
          ),
        ],
      ),
    );
  }
}
