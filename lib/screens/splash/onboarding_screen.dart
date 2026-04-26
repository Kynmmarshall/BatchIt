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
      heroIcon: Icons.shopping_basket_rounded,
      accentColor: Color(0xFFEF5350),
    ),
    _OnboardingSlide(
      title: 'Introducing Smart Local Batches',
      description:
          'Discover nearby batches within your area and collaborate with trusted community hubs.',
      buttonLabel: 'Continue',
      heroIcon: Icons.location_on_rounded,
      accentColor: Color(0xFF8D6E63),
    ),
    _OnboardingSlide(
      title: 'Your Daily Grocery Partner',
      description:
          'Track live progress, get notified when thresholds are reached, and collect with ease.',
      buttonLabel: 'Get Started',
      heroIcon: Icons.auto_graph_rounded,
      accentColor: Color(0xFF42A5F5),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_currentPage == _slides.length - 1) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
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
    required this.heroIcon,
    required this.accentColor,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final IconData heroIcon;
  final Color accentColor;
}

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.15),
                radius: 0.9,
                colors: [
                  Colors.white,
                  slide.accentColor.withValues(alpha: 0.11),
                ],
              ),
            ),
          ),
        ),
        const Positioned(top: 10, left: 20, child: _Particle(size: 12)),
        const Positioned(top: 84, right: 30, child: _Particle(size: 10)),
        const Positioned(bottom: 90, left: 28, child: _Particle(size: 14)),
        const Positioned(bottom: 56, right: 24, child: _Particle(size: 16)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      slide.accentColor.withValues(alpha: 0.20),
                      slide.accentColor.withValues(alpha: 0.08),
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 32,
                          offset: Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Icon(
                            slide.heroIcon,
                            color: slide.accentColor,
                            size: 34,
                          ),
                        ),
                        Image.asset(
                          'assets/icon/logo.png',
                          width: 120,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
