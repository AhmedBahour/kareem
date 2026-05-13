import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'نبض الحركة',
      subtitle: 'خطوتك الأولى نحو التعافي',
      description: 'نرافقك في رحلتك العلاجية بتمارين منزلية ذكية ومصممة خصيصاً لاحتياجاتك البدنية.',
      image: Icons.healing_rounded,
      color: AppTheme.primaryOrange,
    ),
    OnboardingPage(
      title: 'تتبع ذكي بالحساسات',
      subtitle: 'دقة عالية في كل حركة',
      description: 'استخدم كاميرا هاتفك لتحليل حركاتك والحصول على تقييم فوري وتوجيهات دقيقة لتحسين أدائك.',
      image: Icons.visibility_rounded,
      color: const Color(0xFF2D7969),
    ),
    OnboardingPage(
      title: 'سجل تقدمك دائماً',
      subtitle: 'نتائجك محفوظة ومزامنة',
      description: 'تابع تحسنك يوماً بعد يوم، مع تقويم تدريبي متكامل ونظام مزامنة سحابي يضمن أمان بياناتك.',
      image: Icons.analytics_rounded,
      color: AppTheme.primaryDark,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Animated Background Shapes
            Positioned(
              top: -100,
              right: -50,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: pages[_currentPage].color.withValues(alpha: 0.05),
                ),
              ),
            ),

            PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() => _currentPage = page);
              },
              itemCount: pages.length,
              itemBuilder: (context, index) => _buildPage(pages[index]),
            ),

            // Top Bar
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentPage + 1}/${pages.length}',
                    style: TextStyle(
                      color: pages[_currentPage].color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                    },
                    child: Text(
                      'تخطي',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Controls
            Positioned(
              bottom: 50,
              left: 30,
              right: 30,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? pages[_currentPage].color
                              : pages[_currentPage].color.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == pages.length - 1) {
                          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutQuart,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pages[_currentPage].color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == pages.length - 1 ? 'ابدأ الآن' : 'التالي',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedCard(
            duration: const Duration(milliseconds: 800),
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: page.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                page.image,
                size: 130,
                color: page.color,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  color: page.color,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.grey[800],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.7,
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 100), // Space for bottom controls
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData image;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
    required this.color,
  });
}
