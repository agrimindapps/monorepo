import 'package:flutter/material.dart';
import 'onboarding_service.dart';

/// Onboarding screen for ReceitauAgro
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late OnboardingService _onboardingService;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<OnboardingStep> _steps = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _onboardingService = OnboardingService.instance;
    _pageController = PageController();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadOnboardingData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadOnboardingData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _steps = _onboardingService.getOnboardingSteps();
      await _onboardingService.startOnboarding();
      
      setState(() {
        _isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar onboarding: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _nextStep() {
    if (_currentIndex < _steps.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousStep() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _skipStep() async {
    final currentStep = _steps[_currentIndex];
    
    if (!currentStep.isRequired) {
      try {
        await _onboardingService.skipStep(currentStep.id);
        _nextStep();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao pular etapa: $e')),
          );
        }
      }
    }
  }

  Future<void> _completeStep() async {
    final currentStep = _steps[_currentIndex];
    
    try {
      await _onboardingService.completeStep(currentStep.id);
      _nextStep();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao completar etapa: $e')),
        );
      }
    }
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_steps.isEmpty) {
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
              Theme.of(context).primaryColor.withAlpha((255 * 0.8).round()),
              Theme.of(context).primaryColor.withAlpha((255 * 0.3).round()),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _steps.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildOnboardingPage(_steps[index]);
                    },
                  ),
                ),
              ),
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            '${_currentIndex + 1} de ${_steps.length}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingStep step) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (step.imageAsset != null) ...[
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
          ],
          Text(
            step.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            step.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildStepActions(step),
        ],
      ),
    );
  }

  Widget _buildStepActions(OnboardingStep step) {
    return Column(
      children: [
        if (step.id == 'notifications') ...[
          ElevatedButton(
            onPressed: () async {
              await _completeStep();
            },
            child: const Text('Permitir Notificações'),
          ),
          const SizedBox(height: 12),
        ] else if (step.id == 'profile_setup') ...[
          ElevatedButton(
            onPressed: () {
              _showProfileSetupDialog();
            },
            child: const Text('Configurar Perfil'),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!step.isRequired)
              TextButton(
                onPressed: _skipStep,
                child: const Text(
                  'Pular',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            else
              const SizedBox.shrink(),
            
            ElevatedButton(
              onPressed: step.id == 'notifications' || step.id == 'profile_setup' 
                  ? null 
                  : _completeStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
              ),
              child: Text(_currentIndex == _steps.length - 1 ? 'Finalizar' : 'Próximo'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_steps.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: _currentIndex == index ? 24.0 : 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: _currentIndex == index 
                      ? Colors.white 
                      : Colors.white.withAlpha((255 * 0.3).round()),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentIndex > 0)
                TextButton(
                  onPressed: _previousStep,
                  child: const Text(
                    'Anterior',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              else
                const SizedBox.shrink(),
              
              TextButton(
                onPressed: _finishOnboarding,
                child: const Text(
                  'Pular Tutorial',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProfileSetupDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar Perfil'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Selecione suas culturas principais:'),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('Soja')),
                Chip(label: Text('Milho')),
                Chip(label: Text('Algodão')),
                Chip(label: Text('Café')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _skipStep();
            },
            child: const Text('Pular'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _completeStep();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  IconData _getStepIcon(String stepId) {
    switch (stepId) {
      case 'welcome':
        return Icons.waving_hand;
      case 'explore_database':
        return Icons.search;
      case 'diagnostic_tool':
        return Icons.medical_services;
      case 'favorites':
        return Icons.favorite;
      case 'premium_features':
        return Icons.star;
      case 'notifications':
        return Icons.notifications;
      case 'profile_setup':
        return Icons.person;
      default:
        return Icons.info;
    }
  }
}