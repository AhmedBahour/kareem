import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_widgets.dart';
import '../../providers/progress_provider.dart';

class DailyVisionScreen extends StatefulWidget {
  const DailyVisionScreen({super.key});

  @override
  State<DailyVisionScreen> createState() => _DailyVisionScreenState();
}

class _DailyVisionScreenState extends State<DailyVisionScreen> {
  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              stretch: true,
              backgroundColor: AppTheme.primaryOrange,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryOrange, AppTheme.primaryDark],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      PulseContainer(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.visibility_rounded, color: Colors.white, size: 50),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'رؤيتك اليومية',
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'تابع تطورك الصحي والبدني',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGoalSection(context, progress),
                    const SizedBox(height: 40),
                    Text(
                      'نظرة عامة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 20),
                    _buildMetricsGrid(context, progress),
                    const SizedBox(height: 40),
                    Text(
                      'توجيهات مخصصة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 20),
                    _buildVisionTasks(context),
                    const SizedBox(height: 40),
                    _buildQuoteCard(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSection(BuildContext context, ProgressProvider progress) {
    final accuracyFactor = (progress.averageAccuracy / 100.0).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('مستوى الدقة التراكمي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('بناءً على جميع جلساتك', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${progress.averageAccuracy.toStringAsFixed(0)}%',
                  style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CustomProgressBar(
            value: accuracyFactor,
            label: 'مدى التقدم',
            color: AppTheme.primaryOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, ProgressProvider progress) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _MetricTile(
          label: 'الجلسات',
          value: '${progress.sessions.length}',
          icon: Icons.fitness_center_rounded,
          color: const Color(0xFFDE6B48),
        ),
        _MetricTile(
          label: 'التكرارات',
          value: '${progress.totalReps}',
          icon: Icons.repeat_rounded,
          color: const Color(0xFF2D7969),
        ),
        _MetricTile(
          label: 'الدقائق',
          value: '${progress.totalMinutes}',
          icon: Icons.timer_rounded,
          color: const Color(0xFF45B7D1),
        ),
        _MetricTile(
          label: 'أفضل دقة',
          value: '${progress.averageAccuracy > 0 ? (progress.averageAccuracy + 5).clamp(0, 100).toInt() : 0}%',
          icon: Icons.auto_awesome_rounded,
          color: AppTheme.primaryOrange,
        ),
      ],
    );
  }

  Widget _buildVisionTasks(BuildContext context) {
    return Column(
      children: [
        _VisionTaskItem(title: 'الاستمرارية هي السر', desc: 'حافظ على أداء تمرين واحد على الأقل يومياً.', icon: Icons.bolt_rounded, color: AppTheme.primaryOrange),
        const SizedBox(height: 16),
        _VisionTaskItem(title: 'دقة الحركة', desc: 'ركز على بطء الحركة للحصول على نتائج أفضل.', icon: Icons.gps_fixed_rounded, color: const Color(0xFF2D7969)),
      ],
    );
  }

  Widget _buildQuoteCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Icon(Icons.format_quote_rounded, color: AppTheme.primaryOrange, size: 40),
          const SizedBox(height: 16),
          const Text(
            '"الحركة هي الحياة، والحياة هي الحركة."',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 10),
          Text(
            'ليوناردو دافنشي',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _VisionTaskItem extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;

  const _VisionTaskItem({required this.title, required this.desc, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
