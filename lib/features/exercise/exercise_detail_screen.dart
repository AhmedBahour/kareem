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
            // Sliver Header with Hero-like effect
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              stretch: true,
              backgroundColor: AppTheme.primaryOrange,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryOrange, AppTheme.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.accessibility_new_rounded,
                      size: 100,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                title: Text(
                  exercise.title,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise Info Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _DetailInfoTile(
                          label: 'المدة',
                          value: '${exercise.durationMinutes} د',
                          icon: Icons.timer_outlined,
                        ),
                        _DetailInfoTile(
                          label: 'المستوى',
                          value: exercise.level,
                          icon: Icons.speed_rounded,
                        ),
                        _DetailInfoTile(
                          label: 'الهدف',
                          value: '${exercise.targetAccuracy.toInt()}%',
                          icon: Icons.bolt_rounded,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'عن الجلسة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      exercise.description,
                      style: TextStyle(height: 1.6, color: Colors.grey[700], fontSize: 15),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'خطوات التنفيذ',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 20),

                    // Instruction List
                    ...exercise.instructions.asMap().entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _InstructionCard(
                            stepNumber: entry.key + 1,
                            instruction: entry.value,
                          ),
                        )),

                    const SizedBox(height: 24),

                    // Wellness Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7F6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF2D7969).withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF2D7969)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'نصيحة طبية',
                                  style: TextStyle(
                                    color: Color(0xFF2D7969),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  exercise.wellnessNote,
                                  style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 120), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: AnimatedButton(
            onPressed: user == null
                ? () {}
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LiveSessionScreen(exercise: exercise),
                      ),
                    );
                  },
            label: 'ابدأ الجلسة الآن',
            icon: Icons.play_circle_fill_rounded,
          ),
        ),
      ),
    );
  }
}

class _DetailInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailInfoTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Icon(icon, color: AppTheme.primaryOrange, size: 24),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}

class _InstructionCard extends StatelessWidget {
  final int stepNumber;
  final String instruction;

  const _InstructionCard({required this.stepNumber, required this.instruction});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              instruction,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
