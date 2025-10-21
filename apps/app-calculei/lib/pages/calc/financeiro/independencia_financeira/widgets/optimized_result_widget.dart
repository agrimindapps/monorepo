// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/widgets/controllers/independencia_financeira_controller.dart';
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/widgets/models/independencia_financeira_model.dart';
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/widgets/utils/rebuild_optimizer.dart';
import 'sharing_widget.dart';

/// Widget otimizado para exibir resultados que evita rebuilds desnecessários
class OptimizedResultWidget extends StatefulWidget {
  final IndependenciaFinanceiraController controller;

  const OptimizedResultWidget({
    super.key,
    required this.controller,
  });

  @override
  State<OptimizedResultWidget> createState() => _OptimizedResultWidgetState();
}

class _OptimizedResultWidgetState extends State<OptimizedResultWidget> 
    with RebuildOptimizationMixin {
  
  IndependenciaFinanceiraModel? _lastModel;
  bool _lastCalculoRealizado = false;
  bool _lastCalculando = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final currentModel = widget.controller.modelo;
    final currentCalculoRealizado = widget.controller.calculoRealizado;
    final currentCalculando = widget.controller.calculando;

    // Só rebuilda se algo relevante mudou
    if (_shouldRebuildResult(currentModel, currentCalculoRealizado, currentCalculando)) {
      _lastModel = currentModel;
      _lastCalculoRealizado = currentCalculoRealizado;
      _lastCalculando = currentCalculando;
      setShouldRebuild(true);
    }
  }

  bool _shouldRebuildResult(
    IndependenciaFinanceiraModel? currentModel,
    bool currentCalculoRealizado,
    bool currentCalculando,
  ) {
    // Rebuilda se status de cálculo mudou
    if (currentCalculoRealizado != _lastCalculoRealizado ||
        currentCalculando != _lastCalculando) {
      return true;
    }

    // Rebuilda se modelo mudou de null para não-null ou vice-versa
    if ((currentModel == null) != (_lastModel == null)) {
      return true;
    }

    // Se ambos são null, não rebuilda
    if (currentModel == null && _lastModel == null) {
      return false;
    }

    // Rebuilda se valores principais mudaram
    if (currentModel != null && _lastModel != null) {
      return currentModel.anosParaIndependencia != _lastModel!.anosParaIndependencia ||
             currentModel.patrimonioNecessario != _lastModel!.patrimonioNecessario ||
             currentModel.rendaMensalAtual != _lastModel!.rendaMensalAtual;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.calculando) {
      return const _LoadingResultWidget();
    }

    if (!widget.controller.calculoRealizado || widget.controller.modelo == null) {
      return const _EmptyResultWidget();
    }

    return _ResultContentWidget(
      modelo: widget.controller.modelo!,
      controller: widget.controller,
    );
  }
}

/// Widget isolado para loading
class _LoadingResultWidget extends StatelessWidget {
  const _LoadingResultWidget();

  @override
  Widget build(BuildContext context) {
    return const IsolatedWidget(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Calculando...'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget isolado para estado vazio
class _EmptyResultWidget extends StatelessWidget {
  const _EmptyResultWidget();

  @override
  Widget build(BuildContext context) {
    return const IsolatedWidget(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calculate,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Preencha os campos para calcular',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget principal do resultado com cache otimizado
class _ResultContentWidget extends StatelessWidget {
  final IndependenciaFinanceiraModel modelo;
  final IndependenciaFinanceiraController controller;

  const _ResultContentWidget({
    required this.modelo,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return IsolatedWidget(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho com compartilhamento
              _buildHeader(context),
              
              const SizedBox(height: 16),
              
              // Resultado principal (cached)
              CachedWidget(
                dependencies: [
                  modelo.anosParaIndependencia,
                  modelo.patrimonioNecessario,
                ],
                builder: (context) => _buildMainResult(context),
              ),
              
              const SizedBox(height: 16),
              
              // Detalhes (cached)
              CachedWidget(
                dependencies: [
                  modelo.patrimonioAtual,
                  modelo.rendaMensalAtual,
                  modelo.despesasMensais,
                ],
                builder: (context) => _buildDetails(context),
              ),
              
              const SizedBox(height: 16),
              
              // Sugestões (cached)
              CachedWidget(
                dependencies: [modelo.anosParaIndependencia],
                builder: (context) => _buildSuggestions(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Resultado',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _showSharingOptions(context),
          tooltip: 'Compartilhar resultado',
        ),
      ],
    );
  }

  Widget _buildMainResult(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: modelo.anosParaIndependencia == 0 
            ? Colors.green.shade50 
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: modelo.anosParaIndependencia == 0 
              ? Colors.green.shade200 
              : Colors.blue.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            modelo.anosParaIndependencia == 0 
                ? Icons.celebration 
                : Icons.access_time,
            size: 48,
            color: modelo.anosParaIndependencia == 0 
                ? Colors.green 
                : Colors.blue,
          ),
          const SizedBox(height: 8),
          Text(
            modelo.anosParaIndependencia == 0 
                ? 'Independência Conquistada!' 
                : 'Tempo para Independência',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            modelo.anosParaIndependencia == 0 
                ? 'Você já pode viver de renda!'
                : controller.formatarAnos(modelo.anosParaIndependencia),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: modelo.anosParaIndependencia == 0 
                  ? Colors.green.shade700 
                  : Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      children: [
        _buildDetailRow(
          'Patrimônio Necessário',
          controller.formatarNumero(modelo.patrimonioNecessario),
          Icons.account_balance,
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          'Renda Mensal Atual',
          controller.formatarNumero(modelo.rendaMensalAtual),
          Icons.monetization_on,
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          'Despesas Mensais',
          controller.formatarNumero(modelo.despesasMensais),
          Icons.shopping_cart,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final sugestao = controller.getSugestaoTexto();
    
    if (sugestao.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.amber.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              sugestao,
              style: TextStyle(
                fontSize: 13,
                color: Colors.amber.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSharingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SharingWidget(
        modelo: modelo,
        onCompartilhado: () {
          // Callback quando compartilhado
        },
      ),
    );
  }
}
