import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../main.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final storageService = ref.read(storageServiceProvider);
    final hasToken = await storageService.hasValidTokens();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(
        hasToken ? '/home' : '/login',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mic,
                  size: 60,
                  color: AppColors.primary,
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.easeOutBack)
                  .then()
                  .shimmer(duration: 1000.ms),

              const SizedBox(height: AppSpacing.xl),

              // App Name
              Text(
                'AI Whisperer',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

              const SizedBox(height: AppSpacing.sm),

              // Tagline
              Text(
                'No AI needed to craft AI prompts',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

              const SizedBox(height: AppSpacing.xxl),

              // Loading indicator
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
