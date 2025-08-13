// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/services/progressive_loading_service.dart';
import '../../../core/widgets/skeleton_screens.dart';
import '../models/defensivo_model.dart';

/// Página exemplo que demonstra carregamento progressivo não-bloqueante
/// Substitui o polling bloqueante por streams e skeleton screens
class ProgressiveListaDefensivosPage extends StatefulWidget {
  const ProgressiveListaDefensivosPage({super.key});

  @override
  State<ProgressiveListaDefensivosPage> createState() => _ProgressiveListaDefensivosPageState();
}

class _ProgressiveListaDefensivosPageState extends State<ProgressiveListaDefensivosPage> {
  final ProgressiveLoadingService _loadingService = ProgressiveLoadingService.instance;
  final List<DefensivoModel> _defensivos = [];
  
  ProgressInfo? _currentProgress;
  String _operationId = 'progressive_demo';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startProgressiveLoading();
  }

  @override
  void dispose() {
    _loadingService.cancelOperation(_operationId);
    super.dispose();
  }

  /// Inicia carregamento progressivo não-bloqueante
  void _startProgressiveLoading() async {
    setState(() {
      _isLoading = true;
      _defensivos.clear();
    });

    // Stream progressivo que não bloqueia a UI
    await for (final progress in _loadingService.loadDefensivosProgressively(
      isDatabaseLoaded: true, // Simula database já carregado
      operationId: _operationId,
    )) {
      setState(() {
        _currentProgress = progress;
      });

      // Processa diferentes fases do carregamento
      switch (progress.phase) {
        case LoadingPhase.renderingUI:
        case LoadingPhase.completed:
          if (progress.partialData != null) {
            // Converte dados parciais e atualiza UI progressivamente
            final newDefensivos = progress.partialData!
                .cast<Map<String, dynamic>>()
                .map((item) => DefensivoModel.fromMap(item))
                .toList();
            
            setState(() {
              _defensivos.clear();
              _defensivos.addAll(newDefensivos);
            });
          }
          break;

        case LoadingPhase.error:
          _showError(progress.errorMessage ?? 'Erro desconhecido');
          break;

        default:
          // Outros estados são apenas visuais (inicializing, loadingDatabase, etc)
          break;
      }

      // Para quando completar
      if (progress.phase == LoadingPhase.completed) {
        setState(() {
          _isLoading = false;
        });
        break;
      }
    }
  }

  /// Mostra erro e permite retry
  void _showError(String error) {
    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Tentar novamente',
          textColor: Colors.white,
          onPressed: _retryLoading,
        ),
      ),
    );
  }

  /// Retry do carregamento
  void _retryLoading() {
    _operationId = 'progressive_demo_retry_${DateTime.now().millisecondsSinceEpoch}';
    _startProgressiveLoading();
  }

  /// Cancela carregamento atual
  void _cancelLoading() {
    _loadingService.cancelOperation(_operationId);
    setState(() {
      _isLoading = false;
      _currentProgress = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carregamento Progressivo'),
        actions: [
          if (_isLoading)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelLoading,
              tooltip: 'Cancelar',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _retryLoading,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de progresso e status
          if (_currentProgress != null) _buildProgressHeader(),
          
          // Conteúdo principal
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  /// Constrói header com informações de progresso
  Widget _buildProgressHeader() {
    final progress = _currentProgress!;
    
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Ícone baseado na fase
                Icon(_getPhaseIcon(progress.phase), size: 20),
                const SizedBox(width: 8),
                // Mensagem de status
                Expanded(
                  child: Text(
                    progress.message,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                // Porcentagem
                Text(
                  '${(progress.progress * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Barra de progresso
            LinearProgressIndicator(
              value: progress.progress,
              backgroundColor: Colors.grey[300],
            ),
            if (progress.partialData != null) ...[
              const SizedBox(height: 4),
              Text(
                '${progress.partialData!.length} itens carregados',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Obtém ícone baseado na fase de carregamento
  IconData _getPhaseIcon(LoadingPhase phase) {
    switch (phase) {
      case LoadingPhase.initializing:
        return Icons.play_circle_outline;
      case LoadingPhase.loadingDatabase:
        return Icons.storage;
      case LoadingPhase.processingData:
        return Icons.memory;
      case LoadingPhase.renderingUI:
        return Icons.visibility;
      case LoadingPhase.completed:
        return Icons.check_circle;
      case LoadingPhase.error:
        return Icons.error;
      case LoadingPhase.idle:
        return Icons.pause_circle_outline;
    }
  }

  /// Constrói conteúdo principal com carregamento progressivo
  Widget _buildMainContent() {
    // Se não há dados e está carregando, mostra skeleton
    if (_defensivos.isEmpty && _isLoading) {
      return _buildSkeletonList();
    }
    
    // Se tem dados (mesmo que parciais), mostra dados + skeleton para o resto
    if (_defensivos.isNotEmpty) {
      return _buildProgressiveDataList();
    }
    
    // Estado vazio ou erro
    return _buildEmptyState();
  }

  /// Lista de skeleton enquanto carrega dados iniciais
  Widget _buildSkeletonList() {
    return ListView.builder(
      itemCount: 10, // Mostra 10 skeleton items
      itemBuilder: (context, index) => const DefensivoSkeletonItem(),
    );
  }

  /// Lista progressiva com dados reais + skeleton para dados ainda carregando
  Widget _buildProgressiveDataList() {
    return ProgressiveLoadingWidget(
      isLoading: _isLoading,
      hasPartialData: _defensivos.isNotEmpty,
      partialData: _defensivos,
      dataBuilder: (data) => ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final defensivo = data[index] as DefensivoModel;
          return _buildDefensivoItem(defensivo);
        },
      ),
      skeletonBuilder: () => SizedBox(
        height: 200,
        child: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) => const DefensivoSkeletonItem(),
        ),
      ),
      loadingMessage: _currentProgress?.message ?? 'Carregando...',
    );
  }

  /// Item real de defensivo
  Widget _buildDefensivoItem(DefensivoModel defensivo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            defensivo.line1.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          defensivo.line1,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(defensivo.line2),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(
                    defensivo.classeAgronomica ?? 'N/A',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.blue[100],
                ),
                if (defensivo.ingredienteAtivo != null)
                  Chip(
                    label: Text(
                      defensivo.ingredienteAtivo!,
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: Colors.green[100],
                  ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Get.snackbar(
            'Defensivo selecionado',
            defensivo.line1,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      ),
    );
  }

  /// Estado vazio
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum defensivo encontrado',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão de recarregar para tentar novamente',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _retryLoading,
            icon: const Icon(Icons.refresh),
            label: const Text('Recarregar'),
          ),
        ],
      ),
    );
  }
}