import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../providers/providers.dart';

/// Onboarding screen for ReceitauAgro
/// Uses Riverpod state management with ConsumerStatefulWidget
/// Displays multi-step onboarding flow with validation and progress tracking
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Start onboarding when screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingNotifierProvider.notifier).start();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(onboardingNotifierProvider);
    final steps = ref.watch(onboardingStepsProvider);
    final currentIndex = ref.watch(currentStepIndexProvider);

    return progressAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar onboarding: $error'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(onboardingNotifierProvider.notifier).start();
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
      data: (progress) {
        if (steps.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Onboarding')),
            body: const Center(
              child: Text('Nenhuma etapa de onboarding encontrada'),
            ),
          );
        }

        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor
                      .withAlpha((255 * 0.8).round()),
                  Theme.of(context).primaryColor
                      .withAlpha((255 * 0.3).round()),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, currentIndex, steps.length),
                  Expanded(
                    child: FadeTransition(
                      opacity: _animationController,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: steps.length,
                        onPageChanged: (index) {
                          setState(() {});
                        },
                        itemBuilder: (context, index) {
                          return _buildOnboardingPage(
                            context,
                            steps[index],
                          );
                        },
                      ),
                    ),
                  ),
                  _buildBottomNavigation(
                    context,
                    currentIndex,
                    steps.length,
                    progress,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, int currentIndex, int totalSteps) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ReceitauAgro',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            '${currentIndex + 1} de $totalSteps',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(
    BuildContext context,
    OnboardingStep step,
  ) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((255 * 0.1).round()),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              _getStepIcon(step.id),
              size: 100,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    int currentIndex,
    int totalSteps,
    OnboardingProgress? progress,
  ) {
    final steps = ref.read(onboardingStepsProvider);
    final isLastStep = currentIndex >= totalSteps - 1;
    final currentStep = steps[currentIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (currentIndex + 1) / totalSteps,
            minHeight: 4,
          ),
          const SizedBox(height: 24),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous button
              if (currentIndex > 0)
                ElevatedButton.icon(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Anterior'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                  ),
                ),

              // Skip button (for optional steps)
              if (!currentStep.isRequired)
                ElevatedButton.icon(
                  onPressed: () => _skipStep(currentStep.id),
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Pular'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white12,
                    foregroundColor: Colors.white70,
                  ),
                ),

              // Next/Finish button
              ElevatedButton.icon(
                onPressed: () => isLastStep
                    ? _finishOnboarding()
                    : _completeStep(currentStep.id),
                icon: Icon(
                  isLastStep ? Icons.check : Icons.arrow_forward,
                ),
                label: Text(isLastStep ? 'Finalizar' : 'Próximo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor:
                      Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _previousStep() {
    if (_pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeStep(String stepId) async {
    try {
      await ref.read(onboardingNotifierProvider.notifier).completeStep(stepId);
      final steps = ref.read(onboardingStepsProvider);
      final currentIndex =
          steps.indexWhere((s) => s.id == stepId);
      if (currentIndex < steps.length - 1) {
        await _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao completar etapa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _skipStep(String stepId) async {
    try {
      await ref.read(onboardingNotifierProvider.notifier).skipStep(stepId);
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao pular etapa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  IconData _getStepIcon(String stepId) {
    return switch (stepId) {
      'welcome' => Icons.waving_hand_outlined,
      'explore_database' => Icons.search_outlined,
      'diagnostic_tool' => Icons.analytics_outlined,
      'favorites' => Icons.favorite_outline,
      'premium_features' => Icons.star_outline,
      'notifications' => Icons.notifications_outlined,
      'profile_setup' => Icons.person_outline,
      _ => Icons.info_outline,
    };
  }
}
