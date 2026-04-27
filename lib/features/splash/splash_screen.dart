import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/route_names.dart';
import '../../providers/settings_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    final settings = ref.read(settingsNotifierProvider);
    if (settings.hasCompletedOnboarding) {
      context.go(RoutePaths.today);
    } else {
      context.go(RoutePaths.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.event_note_rounded,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 600.ms, curve: Curves.easeOut)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.easeOut,
            ),
      ),
    );
  }
}
