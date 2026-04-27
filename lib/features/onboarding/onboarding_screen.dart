import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/route_names.dart';
import '../../providers/settings_provider.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    OnboardingPage(
      icon: Icons.today_rounded,
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      iconColor: AppColors.primary,
    ),
    OnboardingPage(
      icon: Icons.calendar_month_rounded,
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      iconColor: AppColors.accent,
    ),
    OnboardingPage(
      icon: Icons.category_rounded,
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      iconColor: AppColors.accentLight,
    ),
    OnboardingPage(
      icon: Icons.lock_rounded,
      title: AppStrings.onboardingTitle4,
      description: AppStrings.onboardingDesc4,
      iconColor: AppColors.primaryDark,
    ),
  ];

  void _complete() {
    ref.read(settingsNotifierProvider.notifier).completeOnboarding();
    context.go(RoutePaths.today);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _complete,
                child: const Text(
                  AppStrings.skip,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: _pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: const WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 12,
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.divider,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _complete();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? AppStrings.getStarted
                            : AppStrings.next,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
}
