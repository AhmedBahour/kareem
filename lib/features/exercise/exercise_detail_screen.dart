import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_widgets.dart';
import '../../data/models/exercise_model.dart';
import '../../providers/auth_provider.dart';
import 'live_session_screen.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key, required this.exercise});

  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: AppTheme.deepTeal,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.deepTeal, AppTheme.primaryTeal],
                          begin: Alignment.bottomRight,
                          end: Alignment.topLeft,
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.fitness_center_rounded,
                        size: 120,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  exercise.title,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18),
                ),
                centerTitle: true,
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(label: 'الهدف', value: '${exercise.targetAccuracy.toInt()}%', icon: Icons.bolt_rounded),
                        _StatItem(label: 'المدة', value: '${exercise.durationMinutes} د', icon: Icons.timer_outlined),
                        _StatItem(label: 'المستوى', value: exercise.level, icon: Icons.bar_chart_rounded),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text('حول التمرين', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    Text(
                      exercise.description,
                      style: TextStyle(height: 1.6, color: AppTheme.softGrey, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 40),
                    Text('الخطوات العلاجية', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 24),
                    ...exercise.instructions.asMap().entries.map((e) => _StepLine(number: e.key + 1, text: e.value)),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppTheme.primaryTeal),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              exercise.wellnessNote,
                              style: const TextStyle(color: AppTheme.deepTeal, height: 1.5, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: AnimatedButton(
            onPressed: user == null ? () {} : () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => LiveSessionScreen(exercise: exercise)));
            },
            label: 'ابدأ الجلسة العلاجية',
            icon: Icons.play_arrow_rounded,
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryTeal, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.deepTeal)),
        Text(label, style: const TextStyle(color: AppTheme.softGrey, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final int number;
  final String text;
  const _StepLine({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: AppTheme.deepTeal, shape: BoxShape.circle),
            child: Center(child: Text(number.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.5, fontWeight: FontWeight.w600, color: AppTheme.deepTeal),
            ),
          ),
        ],
      ),
    );
  }
}
