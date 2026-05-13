import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('النشاطات'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'اليوم'),
              Tab(text: 'هذا الأسبوع'),
              Tab(text: 'الشهر'),
            ],
            labelColor: AppTheme.primaryTeal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryTeal,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildActivityList('اليوم'),
            _buildActivityList('هذا الأسبوع'),
            _buildActivityList('الشهر'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList(String period) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildActivityCard(
          'تمرين الصباح',
          'تمت بنجاح',
          '08:00 صباحاً',
          45,
          Icons.check_circle_rounded,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          'المشي السريع',
          'قيد التقدم',
          '10:30 صباحاً',
          30,
          Icons.schedule_rounded,
          AppTheme.primaryTeal,
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          'تمارين اليوغا',
          'لم تبدأ بعد',
          '06:00 مساءً',
          25,
          Icons.pending_actions_rounded,
          Colors.grey,
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          'تمارين القوة',
          'تم الإلغاء',
          '04:00 مساءً',
          20,
          Icons.cancel_rounded,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildActivityCard(
    String title,
    String status,
    String time,
    int duration,
    IconData statusIcon,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 16,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$duration دقيقة',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
