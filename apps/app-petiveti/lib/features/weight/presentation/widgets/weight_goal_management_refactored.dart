import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../providers/weights_provider.dart';
import 'weight_goal_card.dart';
import 'weight_goal_form.dart';
import 'weight_veterinary_guidelines.dart';

/// Refactored weight goal management following SOLID principles
/// 
/// This is the main coordinator widget that composes all extracted components
/// following SRP, OCP, and DIP principles.
class WeightGoalManagementRefactored extends ConsumerStatefulWidget {
  final String? animalId;
  final VoidCallback? onGoalsUpdated;

  const WeightGoalManagementRefactored({
    super.key,
    this.animalId,
    this.onGoalsUpdated,
  });

  @override
  ConsumerState<WeightGoalManagementRefactored> createState() => _WeightGoalManagementRefactoredState();
}

class _WeightGoalManagementRefactoredState extends ConsumerState<WeightGoalManagementRefactored>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weightsState = ref.watch(weightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Metas de Peso'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.track_changes), text: 'Metas Ativas'),
            Tab(icon: Icon(Icons.add_task), text: 'Nova Meta'),
            Tab(icon: Icon(Icons.medical_information), text: 'Diretrizes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveGoalsTab(weightsState),
          _buildNewGoalTab(),
          _buildVeterinaryGuidelinesTab(),
        ],
      ),
    );
  }

  Widget _buildActiveGoalsTab(WeightsState weightsState) {
    final activeGoals = _getMockActiveGoals();

    if (activeGoals.isEmpty) {
      return _buildEmptyGoalsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeGoals.length,
      itemBuilder: (context, index) {
        final goal = activeGoals[index];
        return WeightGoalCard(
          goal: goal,
          onEdit: () => _editGoal(goal),
          onAnalytics: () => _showGoalAnalytics(goal),
          onComplete: () => _completeGoal(goal),
        );
      },
    );
  }

  Widget _buildNewGoalTab() {
    return SingleChildScrollView(
      child: WeightGoalForm(
        onGoalSaved: _onGoalSaved,
        onVeterinaryConsultation: _showVeterinaryConsultationDialog,
      ),
    );
  }

  Widget _buildVeterinaryGuidelinesTab() {
    return const SingleChildScrollView(
      child: WeightVeterinaryGuidelines(),
    );
  }

  Widget _buildEmptyGoalsState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.track_changes,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma meta ativa',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie uma meta de peso para acompanhar o progresso',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _tabController.animateTo(1),
            icon: const Icon(Icons.add),
            label: const Text('Criar Meta'),
          ),
        ],
      ),
    );
  }
  List<Map<String, dynamic>> _getMockActiveGoals() {
    return [
      {
        'id': '1',
        'title': 'Redução de peso saudável',
        'animal': 'Bobby - Labrador',
        'type': 'lose',
        'currentWeight': '32.5',
        'targetWeight': '28.0',
        'targetDate': DateTime.now().add(const Duration(days: 45)),
        'priority': 'high',
        'progress': 0.6,
      },
      {
        'id': '2',
        'title': 'Manutenção do peso ideal',
        'animal': 'Mimi - Persa',
        'type': 'maintain',
        'currentWeight': '4.2',
        'targetWeight': '4.2',
        'targetDate': DateTime.now().add(const Duration(days: 180)),
        'priority': 'medium',
        'progress': 0.9,
      },
    ];
  }

  void _onGoalSaved() {
    widget.onGoalsUpdated?.call();
    _tabController.animateTo(0); // Switch to active goals tab
  }

  void _editGoal(Map<String, dynamic> goal) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Meta'),
        content: const Text('Funcionalidade de edição será implementada em breve.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _completeGoal(Map<String, dynamic> goal) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Concluir Meta'),
        content: Text(
          'Parabéns! Você atingiu sua meta "${goal['title']}".\n'
          'Deseja marcá-la como concluída?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _markGoalAsCompleted(goal);
            },
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
  }

  void _markGoalAsCompleted(Map<String, dynamic> goal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meta "${goal['title']}" concluída com sucesso!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Ver Histórico',
          onPressed: () {
          },
        ),
      ),
    );
    
    setState(() {
    });
  }

  void _showGoalAnalytics(Map<String, dynamic> goal) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Análise - ${goal['title']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Animal: ${goal['animal']}'),
              const SizedBox(height: 8),
              Text('Progresso: ${((goal['progress'] as double) * 100).toStringAsFixed(0)}%'),
              const SizedBox(height: 8),
              Text('Peso Atual: ${goal['currentWeight']} kg'),
              const SizedBox(height: 8),
              Text('Peso Meta: ${goal['targetWeight']} kg'),
              const SizedBox(height: 8),
              Text('Prazo: ${_formatDate(goal['targetDate'] as DateTime)}'),
              const SizedBox(height: 16),
              const Text(
                'Análise detalhada, gráficos e recomendações serão implementados em breve.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showVeterinaryConsultationDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Consulta Veterinária'),
        content: const Text(
          'Recomendamos consultar um veterinário para definir metas de peso adequadas para seu pet.\n\n'
          'O profissional poderá avaliar a condição corporal atual, histórico de saúde e criar um plano personalizado.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _scheduleVeterinaryConsultation();
            },
            child: const Text('Agendar Consulta'),
          ),
        ],
      ),
    );
  }

  void _scheduleVeterinaryConsultation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirecionando para agendamento de consulta...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
