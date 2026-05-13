import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_widgets.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgressProvider>();
    final auth = context.watch<AuthProvider>();
    final userId = auth.currentUser?.id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('سجل الإنجازات', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _ProgressStatCard(
                    label: 'متوسط الدقة',
                    value: '${provider.averageAccuracy.toStringAsFixed(0)}%',
                    icon: Icons.bolt_rounded,
                    color: AppTheme.primaryTeal,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ProgressStatCard(
                    label: 'إجمالي التكرار',
                    value: '${provider.totalReps}',
                    icon: Icons.repeat_rounded,
                    color: const Color(0xFF2D7969),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ProgressStatCard(
                    label: 'الجلسات المكتملة',
                    value: '${provider.sessions.length}',
                    icon: Icons.fitness_center_rounded,
                    color: const Color(0xFFC97E3E),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ProgressStatCard(
                    label: 'دقائق التمرين',
                    value: '${provider.totalMinutes}',
                    icon: Icons.timer_rounded,
                    color: const Color(0xFF45B7D1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            InkWell(
              onTap: userId == null
                  ? null
                  : () async {
                      final progressProvider = context.read<ProgressProvider>();
                      final date = await showDatePicker(
                        context: context,
                        initialDate: provider.selectedDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now(),
                        locale: const Locale('ar'),
                      );
                      if (!context.mounted || date == null) {
                        return;
                      }
                      await progressProvider.filterByDate(
                        userId: userId,
                        date: date,
                      );
                    },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryTeal, size: 20),
                    const SizedBox(width: 16),
                    Text(
                      'عرض تاريخ: ${DateFormat('dd MMMM yyyy', 'ar').format(provider.selectedDate)}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'تفاصيل الجلسات',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            if (provider.sessions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Icon(Icons.history_rounded, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('لا توجد جلسات في هذا التاريخ', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            else
              ...provider.sessions.map((session) => _ModernSessionItem(session: session)),
          ],
        ),
      ),
    );
  }
}

class _ProgressStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProgressStatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ModernSessionItem extends StatelessWidget {
  final dynamic session;

  const _ModernSessionItem({required this.session});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedCard(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    session.exerciseTitle,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                  ),
                  _SyncBadge(isSynced: session.isSynced),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('hh:mm a', 'ar').format(session.completedAt),
                style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Metric(label: 'الدقة', value: '${session.accuracyScore.toStringAsFixed(0)}%'),
                  _Metric(label: 'التكرار', value: '${session.repsCompleted}'),
                  _Metric(label: 'المدة', value: '${session.durationSeconds ~/ 60} د'),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  session.feedback,
                  style: const TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  final bool isSynced;
  const _SyncBadge({required this.isSynced});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSynced ? const Color(0xFFE2F5EF) : const Color(0xFFFFF1DF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isSynced ? 'متزامن' : 'محلي',
        style: TextStyle(
          color: isSynced ? const Color(0xFF2D7969) : AppTheme.primaryTeal,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
