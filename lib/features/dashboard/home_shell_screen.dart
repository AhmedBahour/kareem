import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/exercise_model.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exercise_catalog_provider.dart';
import '../../providers/progress_provider.dart';
import '../auth/auth_screen.dart';
import '../exercise/exercise_detail_screen.dart';
import '../progress/progress_screen.dart';

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
    final auth = context.watch<AuthProvider>();
    final pages = [
      _DashboardTab(
        onOpenAuth: () => _openAuth(context),
      ),
      const _ExercisesTab(),
      const ProgressScreen(),
      _ProfileTab(
        onOpenAuth: () => _openAuth(context),
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (value) => setState(() => _currentIndex = value),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_rounded),
            label: 'التمارين',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.insights_rounded),
            label: 'التقدم',
          ),
          BottomNavigationBarItem(
            icon: Icon(auth.isGuest ? Icons.person_add_alt_1 : Icons.person),
            label: 'الحساب',
          ),
        ],
      ),
    );
  }

  void _openAuth(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({required this.onOpenAuth});

  final VoidCallback onOpenAuth;

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
                      'جلسات علاج منزلي آمنة وخفيفة لليدين والكتفين والإطالات.',
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
              gradient: const LinearGradient(
                colors: [Color(0xFF12343B), Color(0xFF0F6E6E), Color(0xFF2C8C7B)],
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
                  'ابدأ بإحماء خفيف ثم تمرين كتف أو ذراع لمدة 5 إلى 7 دقائق حسب راحتك.',
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
                color: const Color(0xFFFFF5EC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFC08A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_sync_rounded, color: Color(0xFFDE6B48)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'أنت الآن بوضع محلي. أنشئ حسابًا لتفعيل Firebase ومزامنة الجلسات على السحابة.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: onOpenAuth,
                    child: const Text('تفعيل الحساب'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 22),
          Text('تمارين مقترحة', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          ...exercises.take(3).map(
                (exercise) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _ExerciseCard(exercise: exercise),
                ),
              ),
        ],
      ),
    );
  }
}

class _ExercisesTab extends StatelessWidget {
  const _ExercisesTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExerciseCatalogProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('مكتبة التمارين', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'تصنيف بسيط وواضح يناسب العلاج الطبيعي المنزلي الخفيف.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: provider.categories
                  .map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: provider.selectedCategory == category,
                        onSelected: (_) => provider.selectCategory(category),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          ...provider.visibleExercises.map(
            (exercise) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ExerciseCard(exercise: exercise),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.onOpenAuth});

  final VoidCallback onOpenAuth;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final appState = context.watch<AppStateProvider>();
    final user = auth.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الملف الشخصي', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFFE5F3F0),
                      child: Icon(
                        auth.isGuest ? Icons.person_outline : Icons.person,
                        size: 34,
                        color: const Color(0xFF0F6E6E),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.name ?? 'مستخدم محلي',
                              style: Theme.of(context).textTheme.titleLarge),
                          Text(
                            auth.isGuest ? 'وضع محلي بدون مزامنة' : user?.email ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _InfoTile(label: 'المدينة', value: user?.city ?? 'غزة'),
                _InfoTile(label: 'العمر', value: '${user?.age ?? 0}'),
                _InfoTile(
                  label: 'حالة الاتصال',
                  value: appState.isOnline ? 'متصل' : 'غير متصل',
                ),
                _InfoTile(
                  label: 'Firebase',
                  value: appState.isFirebaseAvailable ? 'مفعل' : 'غير متاح حاليًا',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (auth.isGuest)
            ElevatedButton(
              onPressed: onOpenAuth,
              child: const Text('إنشاء حساب للمزامنة'),
            )
          else
            OutlinedButton(
              onPressed: () => auth.logout(),
              child: const Text('تسجيل الخروج'),
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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ExerciseDetailScreen(exercise: exercise),
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
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE3D1), Color(0xFFE4F4F2)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.accessibility_new_rounded,
                size: 34,
                color: Color(0xFF0F6E6E),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(exercise.subtitle, style: Theme.of(context).textTheme.bodyMedium),
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
        color: isOnline ? const Color(0xFFE2F5EF) : const Color(0xFFFFE8E0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 10,
            color: isOnline ? const Color(0xFF0F6E6E) : const Color(0xFFDE6B48),
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
        color: const Color(0xFFF3F7F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF45666A),
            ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
