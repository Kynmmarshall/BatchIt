import 'package:batchit/core/app_routes.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      title: 'Welcome to BatchIt',
      description:
          'Buy together, save together. Join local buyers and reach bulk targets faster.',
      buttonLabel: 'Continue',
      imagePath: 'assets/onboaring/onbaording1.png',
    ),
    _OnboardingSlide(
      title: 'Introducing Smart Local Batches',
      description:
          'Discover nearby batches within your area and collaborate with trusted community hubs.',
      buttonLabel: 'Continue',
      imagePath: 'assets/onboaring/onboarding2.png',
    ),
    _OnboardingSlide(
      title: 'Your Daily Grocery Partner',
      description:
          'Track live progress, get notified when thresholds are reached, and collect with ease.',
      buttonLabel: 'Get Started',
      imagePath: 'assets/onboaring/onboarding3.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    debugPrint('[BatchIt][onboarding] continue tapped currentPage=$_currentPage');
    if (_currentPage == _slides.length - 1) {
      debugPrint('[BatchIt][onboarding] navigating -> ${AppRoutes.login}');
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    debugPrint('[BatchIt][onboarding] nextPage -> ${_currentPage + 1}');
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[BatchIt][onboarding] build currentPage=$_currentPage');
    const darkPanel = Color(0xFF16274D);

    return Scaffold(
      backgroundColor: darkPanel,
      body: SafeArea(
        bottom: false,
        child: PageView.builder(
          controller: _pageController,
          itemCount: _slides.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            final slide = _slides[index];
            return Column(
              children: [
                Expanded(
                  flex: 58,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(36),
                      ),
                    ),
                    child: _OnboardingHero(slide: slide),
                  ),
                ),
                Expanded(
                  flex: 42,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                    child: Column(
                      children: [
                        _DotsIndicator(
                          length: _slides.length,
                          selectedIndex: _currentPage,
                        ),
                        const SizedBox(height: 42),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFC6CEDD),
                            fontSize: 16,
                            height: 1.45,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton(
                            onPressed: _handleContinue,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: darkPanel,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(29),
                              ),
                            ),
                            child: Text(
                              slide.buttonLabel,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.imagePath,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final String imagePath;
}

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            slide.imagePath,
            fit: BoxFit.contain,
          ),
        ),
        const Positioned(top: 10, left: 20, child: _Particle(size: 12)),
        const Positioned(top: 84, right: 30, child: _Particle(size: 10)),
        const Positioned(bottom: 90, left: 28, child: _Particle(size: 14)),
        const Positioned(bottom: 56, right: 24, child: _Particle(size: 16)),
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.length, required this.selectedIndex});

  final int length;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final selected = index == selectedIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: selected ? 30 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: selected ? 0.95 : 0.85),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _Particle extends StatelessWidget {
  const _Particle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.8),
      ),
    );
  }
}
