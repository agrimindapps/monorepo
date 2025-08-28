import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/calorie_output.dart';
import '../providers/calorie_provider.dart';
import '../widgets/calorie_activity_condition_step.dart';
import '../widgets/calorie_basic_info_step.dart';
import '../widgets/calorie_physiological_step.dart';
import '../widgets/calorie_quick_presets.dart';
import '../widgets/calorie_result_card.dart';
import '../widgets/calorie_review_step.dart';
import '../widgets/calorie_special_conditions_step.dart';
import '../widgets/calorie_step_indicator.dart';

/// Página principal da Calculadora de Necessidades Calóricas
/// Implementa formulário step-by-step para melhor UX
class CaloriePage extends ConsumerStatefulWidget {
  const CaloriePage({super.key});

  @override
  ConsumerState<CaloriePage> createState() => _CaloriePageState();
}

class _CaloriePageState extends ConsumerState<CaloriePage> 
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    // Para animação em andamento para evitar memory leak
    try {
      if (_fadeController.status == AnimationStatus.forward || 
          _fadeController.status == AnimationStatus.reverse) {
        _fadeController.stop();
      }
    } catch (e) {
      // Controller já foi disposed, continuar
    }
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calorieProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Necessidades Calóricas'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showCalorieGuide(context),
            tooltip: 'Guia de Cálculo',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'presets',
                child: ListTile(
                  leading: Icon(Icons.speed),
                  title: Text('Presets Rápidos'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Resetar'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'history',
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Histórico'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Exportar'),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicador de progresso
          _buildProgressIndicator(state),
          
          // Conteúdo do step atual
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: state.hasResult 
                  ? _buildResultView(state)
                  : _buildStepperView(state),
            ),
          ),
          
          // Barra de navegação
          _buildNavigationBar(state),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(CalorieState state) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CalorieStepIndicator(
        currentStep: state.currentStep,
        totalSteps: state.totalSteps,
        isComplete: state.hasResult,
      ),
    );
  }

  Widget _buildStepperView(CalorieState state) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        ref.read(calorieProvider.notifier).goToStep(index);
        _animateTransition();
      },
      children: [
        // Step 0: Informações Básicas
        CalorieBasicInfoStep(
          input: state.input,
          validationErrors: state.validationErrors,
          onInputChanged: (input) => 
              ref.read(calorieProvider.notifier).updateInput(input),
        ),
        
        // Step 1: Estado Fisiológico
        CaloriePhysiologicalStep(
          input: state.input,
          validationErrors: state.validationErrors,
          onInputChanged: (input) => 
              ref.read(calorieProvider.notifier).updateInput(input),
        ),
        
        // Step 2: Atividade e Condição Corporal
        CalorieActivityConditionStep(
          input: state.input,
          validationErrors: state.validationErrors,
          onInputChanged: (input) => 
              ref.read(calorieProvider.notifier).updateInput(input),
        ),
        
        // Step 3: Condições Especiais
        CalorieSpecialConditionsStep(
          input: state.input,
          validationErrors: state.validationErrors,
          onInputChanged: (input) => 
              ref.read(calorieProvider.notifier).updateInput(input),
        ),
        
        // Step 4: Revisão e Cálculo
        CalorieReviewStep(
          input: state.input,
          isLoading: state.isLoading,
          error: state.error,
          onCalculate: () => ref.read(calorieProvider.notifier).calculate(),
        ),
      ],
    );
  }

  Widget _buildResultView(CalorieState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Resultado principal
          CalorieResultCard(
            output: state.output!,
            onSaveAsFavorite: () => ref.read(calorieProvider.notifier).saveAsFavorite(),
            onRecalculate: () {
              ref.read(calorieProvider.notifier).clearResult();
              ref.read(calorieProvider.notifier).resetSteps();
              _goToPage(0);
            },
          ),
          
          const SizedBox(height: 16),
          
          // Botões de ação
          _buildActionButtons(state),
        ],
      ),
    );
  }

  Widget _buildActionButtons(CalorieState state) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showShareDialog(state.output!),
            icon: const Icon(Icons.share),
            label: const Text('Compartilhar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(calorieProvider.notifier).clearResult();
              ref.read(calorieProvider.notifier).resetSteps();
              _goToPage(0);
            },
            icon: const Icon(Icons.calculate),
            label: const Text('Novo Cálculo'),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationBar(CalorieState state) {
    if (state.hasResult) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          // Botão Voltar
          if (!state.isFirstStep) ...[
            OutlinedButton.icon(
              onPressed: () => _goToPreviousStep(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar'),
            ),
            const SizedBox(width: 16),
          ],
          
          // Espaçador
          const Spacer(),
          
          // Botão Avançar/Calcular
          Consumer(
            builder: (context, ref, child) {
              final canProceed = ref.watch(calorieCanProceedProvider);
              final isLastStep = state.isLastStep;
              
              return ElevatedButton.icon(
                onPressed: canProceed ? () => _goToNextStep(isLastStep) : null,
                icon: Icon(isLastStep ? Icons.calculate : Icons.arrow_forward),
                label: Text(isLastStep ? 'Calcular' : 'Avançar'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _goToNextStep(bool isLastStep) {
    if (isLastStep) {
      // Executar cálculo
      ref.read(calorieProvider.notifier).calculate();
    } else {
      // Avançar para próximo step
      ref.read(calorieProvider.notifier).nextStep();
      _goToPage(ref.read(calorieProvider).currentStep);
    }
  }

  void _goToPreviousStep() {
    ref.read(calorieProvider.notifier).previousStep();
    _goToPage(ref.read(calorieProvider).currentStep);
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _animateTransition();
  }

  void _animateTransition() {
    // Verificar se o widget ainda está montado e controller não foi disposed
    if (!mounted) return;
    
    // Verificar status do controller para evitar operações em controller disposed
    try {
      _fadeController.reset();
      _fadeController.forward();
    } catch (e) {
      // Controller foi disposed, não executar animação
      return;
    }
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'presets':
        _showPresetsDialog();
        break;
      case 'reset':
        _showResetDialog();
        break;
      case 'history':
        _showHistoryDialog();
        break;
      case 'export':
        _showExportDialog();
        break;
    }
  }

  void _showPresetsDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Presets Rápidos'),
        content: SizedBox(
          width: double.maxFinite,
          child: CalorieQuickPresets(
            onPresetSelected: (preset) {
              ref.read(calorieProvider.notifier).loadPreset(preset);
              Navigator.of(context).pop();
              _goToPage(4); // Ir direto para revisão
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Calculadora'),
        content: const Text(
          'Isso irá limpar todos os dados inseridos. Deseja continuar?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(calorieProvider.notifier).reset();
              Navigator.of(context).pop();
              _goToPage(0);
            },
            child: const Text('Resetar'),
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog() {
    final history = ref.read(calorieHistoryProvider);
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Histórico de Cálculos'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: history.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Nenhum cálculo realizado ainda'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final result = history[index];
                    return ListTile(
                      title: Text('${result.dailyEnergyRequirement.round()} kcal/dia'),
                      subtitle: Text(
                        '${result.input.species.displayName} • ${result.input.weight}kg • '
                        '${result.calculatedAt?.day}/${result.calculatedAt?.month}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.restore),
                        onPressed: () {
                          ref.read(calorieProvider.notifier).loadFromHistory(index);
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    final output = ref.read(calorieOutputProvider);
    if (output == null) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Resultado'),
        content: const Text(
          'Escolha como deseja exportar o resultado do cálculo:'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implementar export para PDF
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export PDF em desenvolvimento')),
              );
            },
            child: const Text('PDF'),
          ),
          ElevatedButton(
            onPressed: () => _shareResult(output),
            child: const Text('Compartilhar'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(CalorieOutput output) {
    _shareResult(output);
  }

  void _shareResult(CalorieOutput output) {
    final text = '''
🐾 Cálculo de Necessidades Calóricas

Animal: ${output.input.species.displayName}
Peso: ${output.input.weight}kg
Idade: ${output.input.age} meses

📊 Resultados:
• RER: ${output.restingEnergyRequirement.round()} kcal/dia
• DER: ${output.dailyEnergyRequirement.round()} kcal/dia
• Proteína: ${output.proteinRequirement.round()}g/dia
• Água: ${output.waterRequirement.round()}ml/dia

🍽️ Alimentação:
• ${output.feedingRecommendations.mealsPerDay}x refeições/dia
• ${output.feedingRecommendations.gramsPerMeal.round()}g por refeição

Calculado em: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}
via PetiVeti App
''';

    // TODO: Implementar share nativo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Texto copiado para área de transferência'),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Resultado para Compartilhar'),
                content: SingleChildScrollView(
                  child: Text(text),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCalorieGuide(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guia de Cálculo Calórico'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fórmulas Utilizadas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• RER = 70 × peso^0.75 (>2kg)'),
              Text('• RER = 30 × peso + 70 (≤2kg)'),
              Text('• DER = RER × fatores multiplicadores'),
              SizedBox(height: 16),
              Text(
                'Fatores Multiplicadores:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Adulto normal: 1.6x'),
              Text('• Castrado: 1.4x'),
              Text('• Gestação: 1.8-2.6x'),
              Text('• Lactação: 2.0x + 0.25x/filhote'),
              Text('• Crescimento: 2.0-3.0x'),
              Text('• Idoso: 1.2x'),
              SizedBox(height: 16),
              Text(
                'Importante:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              SizedBox(height: 8),
              Text('• Valores são estimativas'),
              Text('• Monitorar peso regularmente'),
              Text('• Consultar veterinário para casos especiais'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}