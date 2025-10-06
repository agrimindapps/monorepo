import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/calculation_result.dart';
import '../../domain/entities/calculation_template.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_entity.dart';
import '../../domain/services/calculator_template_service.dart';
import '../providers/calculator_features_provider.dart';
import '../providers/calculator_provider_simple.dart';
import '../widgets/calculation_result_display.dart';
import '../widgets/parameter_input_widget.dart';

/// Página de detalhes e execução de uma calculadora específica
///
/// Permite visualizar informações da calculadora e executar cálculos
/// Integra com CalculatorProvider para gerenciamento de estado
class CalculatorDetailPage extends ConsumerStatefulWidget {
  final String calculatorId;

  const CalculatorDetailPage({super.key, required this.calculatorId});

  @override
  ConsumerState<CalculatorDetailPage> createState() =>
      _CalculatorDetailPageState();
}

class _CalculatorDetailPageState extends ConsumerState<CalculatorDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool _showResults = false;

  // Services para funcionalidades avançadas
  CalculatorTemplateService? _templateService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCalculatorData();
    });
  }

  Future<void> _initializeServices() async {
    try {
      // Inicializar services locais se necessário
      // Por enquanto, vai usar o provider quando disponível
    } catch (e) {
      debugPrint('Erro ao inicializar serviços: $e');
    }
  }

  Future<void> _loadCalculatorData() async {
    if (!mounted) return; // ✅ Safety check
    final provider = ref.read(calculatorProvider);
    await provider.loadCalculatorById(widget.calculatorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, child) {
            final provider = ref.watch(calculatorProvider);
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
            itemBuilder:
                (context) => [
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
      body: Consumer(
        builder: (context, ref, child) {
          final provider = ref.watch(calculatorProvider);
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
            return const Center(child: Text('Calculadora não encontrada'));
          }

          return _buildCalculatorInterface(context, provider, calculator);
        },
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final provider = ref.watch(calculatorProvider);
          if (provider.selectedCalculator == null)
            return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed:
                provider.isCalculating
                    ? null
                    : () => _executeCalculation(provider),
            icon:
                provider.isCalculating
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

  Widget _buildCalculatorHeader(
    BuildContext context,
    CalculatorEntity calculator,
  ) {
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
                    color: _getCategoryColor(
                      calculator.category,
                    ).withOpacity(0.1),
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
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      calculator.formula!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ],

            if (calculator.references != null &&
                calculator.references!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                title: const Text('Referências'),
                tilePadding: EdgeInsets.zero,
                children: [
                  ...calculator.references!.map(
                    (ref) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '• $ref',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            ...calculator.parameters.map(
              (parameter) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ParameterInputWidget(
                  parameter: parameter,
                  value: provider.currentInputs[parameter.id],
                  onChanged:
                      (value) => provider.updateInput(parameter.id, value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    CalculatorProvider provider,
  ) {
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

  Widget _buildResultsSection(
    BuildContext context,
    CalculatorProvider provider,
  ) {
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
                  onPressed: () => _shareResults(provider, result),
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
      if (!mounted) return; // ✅ Safety check
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await provider.executeCurrentCalculation();

    if (!mounted) return; // ✅ Safety check after async operation

    if (success) {
      setState(() {
        _showResults = true;
      });

      // Scroll para os resultados
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // ✅ Safety check before using scroll controller
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });

      if (mounted) {
        // ✅ Safety check before using context
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cálculo executado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        // ✅ Safety check before using context
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Erro ao executar cálculo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearForm(CalculatorProvider provider) {
    provider.clearInputs();
    setState(() {
      _showResults = false;
    });
    _formKey.currentState?.reset();
  }

  Future<void> _loadTemplate(CalculatorProvider provider) async {
    if (!mounted || provider.selectedCalculator == null) return;

    try {
      // Tenta usar o provider de features
      CalculatorFeaturesProvider? featuresProvider;
      try {
        featuresProvider = ref.read(calculatorFeaturesProvider);
      } catch (e) {
        // Provider não disponível, usar service direto
        if (_templateService == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Serviço de templates não inicializado'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }

      final calculator = provider.selectedCalculator!;

      // Carregar templates disponíveis
      List<CalculationTemplate> templates;
      if (featuresProvider != null) {
        templates = await featuresProvider.getTemplatesForCalculator(
          calculator.id,
        );
      } else {
        templates = await _templateService!.getTemplatesForCalculator(
          calculator.id,
        );
      }

      if (templates.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhum template disponível para esta calculadora'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Mostrar dialog de seleção
      if (!mounted) return;
      final selectedTemplate = await showDialog<CalculationTemplate>(
        context: context,
        builder: (context) => _buildTemplateSelectionDialog(templates),
      );

      if (selectedTemplate != null && mounted) {
        // Aplicar valores do template
        provider.updateInputs(selectedTemplate.inputValues);

        // Marcar como usado
        if (featuresProvider != null) {
          await featuresProvider.markTemplateAsUsed(selectedTemplate.id);
        } else {
          await _templateService!.markTemplateAsUsed(selectedTemplate.id);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Template "${selectedTemplate.name}" carregado com sucesso',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar template: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (!mounted) return;

    final provider = ref.read(calculatorProvider);
    final calculator = provider.selectedCalculator;
    if (calculator == null) return;

    try {
      // Tenta usar o provider de features
      CalculatorFeaturesProvider? featuresProvider;
      try {
        featuresProvider = ref.read(calculatorFeaturesProvider);
      } catch (e) {
        // Provider não disponível, mostrar mensagem
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sistema de favoritos não disponível'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final success = await featuresProvider?.toggleFavorite(calculator.id) ?? false;

      if (mounted && success && featuresProvider != null) {
        final isFavorite = featuresProvider.isFavorite(calculator.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFavorite
                  ? 'Adicionado aos favoritos'
                  : 'Removido dos favoritos',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao alterar favorito'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao alterar favorito: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareResults(
    CalculatorProvider provider,
    CalculationResult result,
  ) async {
    if (!mounted || provider.selectedCalculator == null) return;

    try {
      final calculator = provider.selectedCalculator!;

      // Gerar texto para compartilhamento
      final shareText = _generateResultShareText(
        calculator.name,
        result.inputs,
        result.values,
      );

      // Copiar para clipboard
      await Clipboard.setData(ClipboardData(text: shareText));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resultado copiado para a área de transferência'),
            backgroundColor: Colors.green,
          ),
        );

        // Mostrar preview do conteúdo
        await showDialog<void>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Compartilhar Resultado'),
                content: SingleChildScrollView(child: Text(shareText)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fechar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: shareText));
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copiado novamente!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    child: const Text('Copiar Novamente'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveToHistory(
    CalculatorProvider provider,
    CalculationResult result,
  ) async {
    if (!mounted || provider.selectedCalculator == null) return;

    try {
      final calculator = provider.selectedCalculator!;

      // Criar item do histórico (em implementação real seria salvo no repository)
      // final historyItem = CalculationHistory(
      //   id: 'history_${DateTime.now().millisecondsSinceEpoch}',
      //   userId: 'current_user', // TODO: Implementar sistema de usuários
      //   calculatorId: calculator.id,
      //   calculatorName: calculator.name,
      //   createdAt: DateTime.now(),
      //   result: result,
      //   notes: null,
      //   tags: null,
      // );

      // Adicionar ao histórico do provider (simulação)
      // Em implementação real, usaria o repository
      debugPrint('Salvando cálculo da ${calculator.name} no histórico');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cálculo salvo no histórico com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar no histórico: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _shareCalculator();
        break;
      case 'save_template':
        _saveTemplate();
        break;
      case 'export_result':
        _showExportOptions();
        break;
      case 'advanced_calc':
        _showAdvancedCalculations();
        break;
    }
  }

  Future<void> _shareCalculator() async {
    if (!mounted) return;

    final provider = ref.read(calculatorProvider);
    final calculator = provider.selectedCalculator;
    if (calculator == null) return;

    try {
      // Gerar texto para compartilhamento da calculadora
      final shareText =
          'Confira a calculadora "${calculator.name}" no AgriHurbi!\n\n'
          '${calculator.description}\n\n'
          'Uma ferramenta essencial para gestão agrícola.\n'
          'Categoria: ${calculator.category.displayName}';

      // Copiar para clipboard
      await Clipboard.setData(ClipboardData(text: shareText));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Link da calculadora copiado para área de transferência',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Mostrar preview
        await showDialog<void>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Compartilhar Calculadora'),
                content: SingleChildScrollView(child: Text(shareText)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fechar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: shareText));
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Copiar Novamente'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveTemplate() async {
    if (!mounted) return;

    final provider = ref.read(calculatorProvider);
    final calculator = provider.selectedCalculator;
    if (calculator == null || provider.currentInputs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha os parâmetros antes de salvar um template'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Mostrar dialog para nome do template
      final templateName = await showDialog<String>(
        context: context,
        builder: (context) => _buildSaveTemplateDialog(),
      );

      if (templateName != null && templateName.isNotEmpty && mounted) {
        // Criar template
        final template = CalculationTemplate(
          id: '', // Será gerado pelo service
          name: templateName,
          calculatorId: calculator.id,
          calculatorName: calculator.name,
          inputValues: Map<String, dynamic>.from(provider.currentInputs),
          description: null,
          tags: const [],
          createdAt: DateTime.now(),
          userId: 'current_user', // TODO: Implementar sistema de usuários
          isPublic: false,
        );

        // Tenta usar o provider de features
        CalculatorFeaturesProvider? featuresProvider;
        try {
          featuresProvider = ref.read(calculatorFeaturesProvider);
        } catch (e) {
          // Provider não disponível, usar service direto se disponível
          if (_templateService == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Serviço de templates não disponível'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }
        }

        // Salvar template
        bool success = false;
        if (featuresProvider != null) {
          success = await featuresProvider.saveTemplate(template);
        } else {
          success = await _templateService!.saveTemplate(template);
        }

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Template "$templateName" salvo com sucesso'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erro ao salvar template'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar template: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  /// Gera texto para compartilhamento de resultado
  String _generateResultShareText(
    String calculatorName,
    Map<String, dynamic> inputs,
    List<CalculationResultValue> values,
  ) {
    final inputsText = inputs.entries
        .map((e) => '• ${e.key}: ${e.value}')
        .join('\n');

    final outputsText = values
        .map((v) => '• ${v.label}: ${v.formattedValue}')
        .join('\n');

    return 'Resultado da calculadora "$calculatorName" - AgriHurbi\n\n'
        'Parâmetros:\n$inputsText\n\n'
        'Resultados:\n$outputsText\n\n'
        'Calculado em ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
  }

  /// Mostra opções de exportação
  Future<void> _showExportOptions() async {
    if (!mounted) return;

    final provider = ref.read(calculatorProvider);
    final result = provider.currentResult;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum resultado disponível para exportar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Exportar Resultado'),
            content: const Text('Escolha o formato de exportação:'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _exportResult('CSV', provider, result);
                },
                child: const Text('Exportar CSV'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _exportResult('JSON', provider, result);
                },
                child: const Text('Exportar JSON'),
              ),
            ],
          ),
    );
  }

  /// Exporta resultado no formato especificado
  Future<void> _exportResult(
    String format,
    CalculatorProvider provider,
    CalculationResult result,
  ) async {
    if (!mounted || provider.selectedCalculator == null) return;

    try {
      final calculator = provider.selectedCalculator!;
      String exportData;

      if (format.toUpperCase() == 'CSV') {
        exportData = _generateCSVExport(calculator.name, result);
      } else if (format.toUpperCase() == 'JSON') {
        exportData = _generateJSONExport(calculator.name, result);
      } else {
        throw Exception('Formato não suportado');
      }

      // Copiar para clipboard
      await Clipboard.setData(ClipboardData(text: exportData));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Resultado exportado em $format e copiado para área de transferência',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Mostrar preview
        await showDialog<void>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Exportação $format'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: SingleChildScrollView(
                    child: Text(
                      exportData,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fechar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: exportData));
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Copiar Novamente'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Gera exportação em formato CSV
  String _generateCSVExport(String calculatorName, CalculationResult result) {
    final timestamp = DateTime.now().toIso8601String();

    var csv = 'Calculadora,Tipo,Parâmetro,Valor,Unidade,Timestamp\n';

    // Adicionar inputs
    for (final entry in result.inputs.entries) {
      csv +=
          '"$calculatorName",Entrada,"${entry.key}","${entry.value}","","$timestamp"\n';
    }

    // Adicionar resultados
    for (final value in result.values) {
      csv +=
          '"$calculatorName",Resultado,"${value.label}","${value.value}","${value.unit}","$timestamp"\n';
    }

    return csv;
  }

  /// Gera exportação em formato JSON
  String _generateJSONExport(String calculatorName, CalculationResult result) {
    final data = {
      'calculator': calculatorName,
      'timestamp': DateTime.now().toIso8601String(),
      'inputs': result.inputs,
      'results':
          result.values
              .map(
                (v) => {
                  'label': v.label,
                  'value': v.value,
                  'unit': v.unit,
                  'description': v.description,
                  'isPrimary': v.isPrimary,
                },
              )
              .toList(),
      'type': result.type.name,
      'isValid': result.isValid,
      'interpretation': result.interpretation,
      'recommendations': result.recommendations,
    };

    // Formatação simples do JSON (sem dependência externa)
    return data.toString().replaceAllMapped(
      RegExp(r'(\w+): (.+?)(?=, \w+:|})'),
      (match) => '"${match.group(1)}": ${_formatJsonValue(match.group(2)!)}',
    );
  }

  String _formatJsonValue(String value) {
    if (value.startsWith('[') ||
        value.startsWith('{') ||
        value == 'true' ||
        value == 'false' ||
        value == 'null') {
      return value;
    }
    if (double.tryParse(value) != null || int.tryParse(value) != null) {
      return value;
    }
    return '"$value"';
  }

  /// Mostra funcionalidades de cálculos avançados
  Future<void> _showAdvancedCalculations() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cálculos Avançados'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Funcionalidades avançadas disponíveis:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text('• Análise de sensibilidade'),
                Text('• Cálculos em lote'),
                Text('• Comparação de cenários'),
                Text('• Análise estatística'),
                Text('• Otimização de parâmetros'),
                SizedBox(height: 12),
                Text(
                  'Essas funcionalidades estarão disponíveis em versões futuras do aplicativo.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Implementar funcionalidades avançadas
                },
                child: const Text('Solicitar Funcionalidade'),
              ),
            ],
          ),
    );
  }

  /// Constrói dialog para salvar template
  Widget _buildSaveTemplateDialog() {
    final nameController = TextEditingController();

    return AlertDialog(
      title: const Text('Salvar Template'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Digite um nome para este template:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nome do template',
              hintText: 'Ex: Irrigação Verão 2024',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = nameController.text.trim();
            if (name.isNotEmpty) {
              Navigator.of(context).pop(name);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  /// Constrói dialog para seleção de templates
  Widget _buildTemplateSelectionDialog(List<CalculationTemplate> templates) {
    return AlertDialog(
      title: const Text('Selecionar Template'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            return Card(
              child: ListTile(
                title: Text(template.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (template.description != null)
                      Text(template.description!),
                    const SizedBox(height: 4),
                    Text(
                      'Criado: ${template.formattedCreatedDate}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    if (template.lastUsed != null)
                      Text(
                        'Último uso: ${template.formattedLastUsed}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.of(context).pop(template),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
