import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/body_condition_output.dart';
import '../providers/body_condition_provider.dart';

/// Enhanced visual feedback widget for BCS calculations with animations
class BcsCalculationFeedback extends ConsumerStatefulWidget {
  const BcsCalculationFeedback({super.key});

  @override
  ConsumerState<BcsCalculationFeedback> createState() => _BcsCalculationFeedbackState();
}

class _BcsCalculationFeedbackState extends ConsumerState<BcsCalculationFeedback>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Pulse animation for loading states
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Progress animation for calculation phases
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Fade animation for result reveal
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Scale animation for BCS score reveal
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Setup animations
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _colorAnimation = ColorTween(
      begin: Colors.blue[100],
      end: Colors.blue[400],
    ).animate(_pulseController);

    // Repeat pulse animation
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(bodyConditionProvider);
    final output = ref.watch(bodyConditionOutputProvider);

    // Listen for state changes to trigger animations
    ref.listen<dynamic>(bodyConditionProvider, (previous, current) {
      _handleStateChange(previous, current);
    });

    if (state.isLoading) {
      return _buildCalculationInProgress(theme);
    }

    if (output != null && !state.isLoading) {
      return _buildResultReveal(theme, output);
    }

    if (state.hasError) {
      return _buildErrorFeedback(theme, state.error);
    }

    return const SizedBox.shrink();
  }

  void _handleStateChange(dynamic previous, dynamic current) {
    if (previous?.isLoading == false && current.isLoading == true) {
      // Started calculation - begin progress animation
      _progressController.reset();
      _progressController.forward();
    } else if (previous?.isLoading == true && current.isLoading == false) {
      // Finished calculation - trigger result reveal
      _triggerResultReveal();
    }
  }

  void _triggerResultReveal() {
    _pulseController.stop();
    _fadeController.reset();
    _scaleController.reset();
    
    // Sequence the reveal animations
    _fadeController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _scaleController.forward();
      });
    });
  }

  Widget _buildCalculationInProgress(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Animated header with pulse effect
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: AnimatedBuilder(
                      animation: _colorAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _colorAnimation.value,
                          ),
                          child: const Icon(
                            Icons.calculate,
                            size: 40,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              Text(
                'Analisando Condição Corporal',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Processando dados biométricos...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Progress indicator with phases
              _buildCalculationPhases(theme),
              
              const SizedBox(height: 20),
              
              // Progress bar
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Column(
                    children: [
                      LinearProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_progressAnimation.value * 100).round()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculationPhases(ThemeData theme) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final progress = _progressAnimation.value;
        final phases = [
          {'label': 'Validação de dados', 'threshold': 0.2},
          {'label': 'Cálculo BCS', 'threshold': 0.5},
          {'label': 'Análise de riscos', 'threshold': 0.8},
          {'label': 'Geração de recomendações', 'threshold': 1.0},
        ];

        return Column(
          children: phases.map((phase) {
            final threshold = phase['threshold'] as double;
            final label = phase['label'] as String;
            final isActive = progress >= threshold;
            final isCompleted = progress > threshold;
            
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted 
                          ? Colors.green 
                          : isActive 
                              ? theme.colorScheme.primary 
                              : Colors.grey[300],
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                          : isActive
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                        color: isActive 
                            ? theme.colorScheme.onSurface 
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildResultReveal(ThemeData theme, BodyConditionOutput output) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Success header
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Cálculo Concluído!',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Animated BCS score reveal
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildBcsScoreDisplay(theme, output),
                ),
                
                const SizedBox(height: 20),
                
                // Quick status summary
                _buildQuickSummary(theme, output),
                
                const SizedBox(height: 16),
                
                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to detailed results
                      _navigateToDetailedResults();
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Ver Resultados Detalhados'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBcsScoreDisplay(ThemeData theme, BodyConditionOutput output) {
    final color = Color(
      int.parse(output.statusColor.substring(1), radix: 16) + 0xFF000000,
    );
    
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${output.bcsScore}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'BCS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSummary(ThemeData theme, BodyConditionOutput output) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            output.classification.displayName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(
                int.parse(output.statusColor.substring(1), radix: 16) + 0xFF000000,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            output.statusDescription,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickMetric(
                'Urgência',
                output.actionUrgency.displayName,
                _getUrgencyIcon(output.actionUrgency),
                _getUrgencyColor(output.actionUrgency),
              ),
              _buildQuickMetric(
                'Risco',
                output.metabolicRisk,
                Icons.monitor_heart,
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorFeedback(ThemeData theme, String? error) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red[100],
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 30,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Erro no Cálculo',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error ?? 'Ocorreu um erro durante o cálculo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(bodyConditionProvider.notifier).clearError();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[700],
                  side: BorderSide(color: Colors.red[300]!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getUrgencyIcon(ActionUrgency urgency) {
    switch (urgency) {
      case ActionUrgency.urgent:
        return Icons.emergency;
      case ActionUrgency.veterinary:
        return Icons.medical_services;
      case ActionUrgency.monitor:
        return Icons.monitor_heart;
      case ActionUrgency.routine:
      default:
        return Icons.check_circle;
    }
  }

  Color _getUrgencyColor(ActionUrgency urgency) {
    switch (urgency) {
      case ActionUrgency.urgent:
        return Colors.red;
      case ActionUrgency.veterinary:
        return Colors.orange;
      case ActionUrgency.monitor:
        return Colors.blue;
      case ActionUrgency.routine:
      default:
        return Colors.green;
    }
  }

  void _navigateToDetailedResults() {
    // This would typically trigger a tab switch or navigation
    // For now, we'll just show a placeholder
  }
}