import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgressProvider>();
    final auth = context.watch<AuthProvider>();
    final userId = auth.currentUser?.id;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('التقدم والسجل', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'يتم سحب الجلسات من SQLite وعرضها هنا حتى بدون إنترنت.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: 'متوسط الدقة',
                  value: '${provider.averageAccuracy.toStringAsFixed(0)}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryTile(
                  label: 'إجمالي التكرارات',
                  value: '${provider.totalReps}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: 'الجلسات',
                  value: '${provider.sessions.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryTile(
                  label: 'الدقائق',
                  value: '${provider.totalMinutes}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: userId == null
                ? null
                : () async {
                    final progressProvider = context.read<ProgressProvider>();
                    final date = await showDatePicker(
                      context: context,
                      initialDate: provider.selectedDate,
                      firstDate: DateTime(2025),
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
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded),
                  const SizedBox(width: 12),
                  Text(
                    'اليوم المحدد: ${DateFormat('dd/MM/yyyy', 'ar').format(provider.selectedDate)}',
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          ...provider.sessions.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            session.exerciseTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: session.isSynced
                                ? const Color(0xFFE2F5EF)
                                : const Color(0xFFFFF1DF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(session.isSynced ? 'تمت المزامنة' : 'محلي فقط'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('hh:mm a', 'ar').format(session.completedAt),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricLine(
                            label: 'الدقة',
                            value: '${session.accuracyScore.toStringAsFixed(0)}%',
                          ),
                        ),
                        Expanded(
                          child: _MetricLine(
                            label: 'التكرارات',
                            value: '${session.repsCompleted}',
                          ),
                        ),
                        Expanded(
                          child: _MetricLine(
                            label: 'المدة',
                            value: '${session.durationSeconds ~/ 60} د',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(session.feedback),
                    const SizedBox(height: 8),
                    Text(
                      session.offlineFeedback,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF0F6E6E),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (provider.sessions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'لا توجد جلسات حتى الآن. ابدأ أول جلسة وسيتم حفظها محليًا وتظهر هنا مباشرة.',
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
