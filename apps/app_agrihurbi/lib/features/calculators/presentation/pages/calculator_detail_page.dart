import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/calculator_entity.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_parameter.dart';
import '../../domain/entities/calculation_result.dart';
import '../providers/calculator_provider_simple.dart';
import '../widgets/calculation_result_display.dart';
import '../widgets/parameter_input_widget.dart';

/// Página de detalhes e execução de uma calculadora específica
/// 
/// Permite visualizar informações da calculadora e executar cálculos
/// Integra com CalculatorProvider para gerenciamento de estado
class CalculatorDetailPage extends StatefulWidget {
  final String calculatorId;

  const CalculatorDetailPage({
    super.key,
    required this.calculatorId,
  });

  @override
  State<CalculatorDetailPage> createState() => _CalculatorDetailPageState();
}

class _CalculatorDetailPageState extends State<CalculatorDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCalculatorData();
    });
  }

  Future<void> _loadCalculatorData() async {
    final provider = context.read<CalculatorProvider>();
    await provider.loadCalculatorById(widget.calculatorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<CalculatorProvider>(
          builder: (context, provider, child) {
            final calculator = provider.selectedCalculator;
            return Text(calculator?.name ?? 'Calculadora');
          },
        ),
        actions: [
          // Botão de favoritos (implementação futura)
          IconButton(
            onPressed: () => _toggleFavorite(),
            icon: const Icon(Icons.favorite_border),
          ),
          // Menu de opções
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Compartilhar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'save_template',
                child: Row(
                  children: [
                    Icon(Icons.bookmark),
                    SizedBox(width: 8),
                    Text('Salvar como modelo'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<CalculatorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando calculadora...'),
                ],
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar calculadora',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadCalculatorData,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final calculator = provider.selectedCalculator;
          if (calculator == null) {
            return const Center(
              child: Text('Calculadora não encontrada'),
            );
          }

          return _buildCalculatorInterface(context, provider, calculator);
        },
      ),
      floatingActionButton: Consumer<CalculatorProvider>(
        builder: (context, provider, child) {
          if (provider.selectedCalculator == null) return const SizedBox.shrink();
          
          return FloatingActionButton.extended(
            onPressed: provider.isCalculating ? null : () => _executeCalculation(provider),
            icon: provider.isCalculating 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.calculate),
            label: Text(provider.isCalculating ? 'Calculando...' : 'Calcular'),
          );
        },
      ),
    );
  }

  Widget _buildCalculatorInterface(
    BuildContext context, 
    CalculatorProvider provider, 
    CalculatorEntity calculator,
  ) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da calculadora
          _buildCalculatorHeader(context, calculator),
          
          const SizedBox(height: 24),
          
          // Formulário de entrada
          Form(
            key: _formKey,
            child: _buildParametersForm(context, provider, calculator),
          ),
          
          const SizedBox(height: 24),
          
          // Botões de ação
          _buildActionButtons(context, provider),
          
          const SizedBox(height: 24),
          
          // Exibição de resultados
          if (_showResults && provider.currentResult != null)
            _buildResultsSection(context, provider),
          
          const SizedBox(height: 100), // Espaço para o FAB
        ],
      ),
    );
  }

  Widget _buildCalculatorHeader(BuildContext context, CalculatorEntity calculator) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(calculator.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    calculator.category.displayName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _getCategoryColor(calculator.category),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  _getCategoryIcon(calculator.category),
                  color: _getCategoryColor(calculator.category),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              calculator.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              calculator.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            
            if (calculator.formula != null) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                title: const Text('Fórmula utilizada'),
                tilePadding: EdgeInsets.zero,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      calculator.formula!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            if (calculator.references != null && calculator.references!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                title: const Text('Referências'),
                tilePadding: EdgeInsets.zero,
                children: [
                  ...calculator.references!.map((ref) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '• $ref',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParametersForm(
    BuildContext context, 
    CalculatorProvider provider,
    CalculatorEntity calculator,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parâmetros de entrada',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ...calculator.parameters.map((parameter) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ParameterInputWidget(
                parameter: parameter,
                value: provider.currentInputs[parameter.id],
                onChanged: (value) => provider.updateInput(parameter.id, value),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CalculatorProvider provider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _clearForm(provider),
            child: const Text('Limpar'),
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: OutlinedButton(
            onPressed: () => _loadTemplate(provider),
            child: const Text('Modelo'),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSection(BuildContext context, CalculatorProvider provider) {
    final result = provider.currentResult!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Resultados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _shareResults(result),
                  icon: const Icon(Icons.share),
                  tooltip: 'Compartilhar resultados',
                ),
                IconButton(
                  onPressed: () => _saveToHistory(provider, result),
                  icon: const Icon(Icons.bookmark_add),
                  tooltip: 'Salvar no histórico',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            CalculationResultDisplay(result: result),
          ],
        ),
      ),
    );
  }

  Future<void> _executeCalculation(CalculatorProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await provider.executeCurrentCalculation();
    
    if (success) {
      setState(() {
        _showResults = true;
      });
      
      // Scroll para os resultados
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cálculo executado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Erro ao executar cálculo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm(CalculatorProvider provider) {
    provider.clearInputs();
    setState(() {
      _showResults = false;
    });
    _formKey.currentState?.reset();
  }

  void _loadTemplate(CalculatorProvider provider) {
    // TODO: Implementar carregamento de templates salvos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _toggleFavorite() {
    // TODO: Implementar sistema de favoritos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _shareResults(CalculationResult result) {
    // TODO: Implementar compartilhamento de resultados
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _saveToHistory(CalculatorProvider provider, CalculationResult result) {
    // TODO: Implementar salvamento no histórico
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _shareCalculator();
        break;
      case 'save_template':
        _saveTemplate();
        break;
    }
  }

  void _shareCalculator() {
    // TODO: Implementar compartilhamento da calculadora
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _saveTemplate() {
    // TODO: Implementar salvamento como template
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  Color _getCategoryColor(CalculatorCategory category) {
    switch (category) {
      case CalculatorCategory.irrigation:
        return const Color(0xFF2196F3);
      case CalculatorCategory.nutrition:
        return const Color(0xFF4CAF50);
      case CalculatorCategory.livestock:
        return const Color(0xFF795548);
      case CalculatorCategory.yield:
        return const Color(0xFF03A9F4);
      case CalculatorCategory.machinery:
        return const Color(0xFFFF9800);
      case CalculatorCategory.crops:
        return const Color(0xFF9C27B0);
      case CalculatorCategory.management:
        return const Color(0xFF607D8B);
    }
  }

  IconData _getCategoryIcon(CalculatorCategory category) {
    switch (category) {
      case CalculatorCategory.irrigation:
        return Icons.water_drop;
      case CalculatorCategory.nutrition:
        return Icons.eco;
      case CalculatorCategory.livestock:
        return Icons.pets;
      case CalculatorCategory.yield:
        return Icons.trending_up;
      case CalculatorCategory.machinery:
        return Icons.precision_manufacturing;
      case CalculatorCategory.crops:
        return Icons.agriculture;
      case CalculatorCategory.management:
        return Icons.manage_accounts;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}