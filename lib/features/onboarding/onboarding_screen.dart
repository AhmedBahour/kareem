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
      subtitle: 'العلاج الطبيعي بمنظور ذكي',
      description: 'حلول علاجية منزلية مبتكرة تساعدك على التعافي واستعادة جودة حياتك بأمان.',
      icon: Icons.healing_rounded,
      color: AppTheme.primaryTeal,
    ),
    OnboardingPage(
      title: 'رصد دقيق للأداء',
      subtitle: 'توجيهات حية وفورية',
      description: 'نظام رصد متطور يحلل حركاتك عبر الكاميرا لضمان أداء التمارين بأعلى مستوى من الدقة.',
      icon: Icons.track_changes_rounded,
      color: AppTheme.accentOrange,
    ),
    OnboardingPage(
      title: 'أنت في أمان',
      subtitle: 'خصوصية ومزامنة سحابية',
      description: 'بياناتك الطبية وتقدمك محفوظان بدقة، مع إمكانية الوصول إليهما من أي مكان وفي أي وقت.',
      icon: Icons.security_rounded,
      color: AppTheme.deepTeal,
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
            PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) => setState(() => _currentPage = page),
              itemCount: pages.length,
              itemBuilder: (context, index) => _buildPage(pages[index]),
            ),

            // Indicator
            Positioned(
              bottom: 180,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? pages[_currentPage].color : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Buttons
            Positioned(
              bottom: 60,
              left: 30,
              right: 30,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == pages.length - 1) {
                          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                        } else {
                          _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutQuart);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pages[_currentPage].color,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        _currentPage == pages.length - 1 ? 'ابدأ الآن' : 'استمرار',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_currentPage < pages.length - 1)
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false),
                      child: const Text('تخطي العرض', style: TextStyle(color: AppTheme.softGrey, fontWeight: FontWeight.bold)),
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
          PulseContainer(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(color: page.color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Center(child: Icon(page.icon, size: 100, color: page.color)),
            ),
          ),
          const SizedBox(height: 60),
          Text(
            page.title,
            style: TextStyle(color: page.color, fontSize: 32, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            page.subtitle,
            style: const TextStyle(color: AppTheme.deepTeal, fontSize: 20, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            style: const TextStyle(color: AppTheme.softGrey, fontSize: 16, height: 1.6, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 150),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({required this.title, required this.subtitle, required this.description, required this.icon, required this.color});
}
