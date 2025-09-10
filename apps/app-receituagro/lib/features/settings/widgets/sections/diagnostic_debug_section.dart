import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/enhanced_diagnostic_integration_service.dart';

/// Seção de debug para o sistema de diagnósticos aprimorado
/// 
/// Permite verificar a qualidade dos dados e testar o sistema de enriquecimento
/// de nomes de pragas, culturas e defensivos
class DiagnosticDebugSection extends StatefulWidget {
  const DiagnosticDebugSection({super.key});

  @override
  State<DiagnosticDebugSection> createState() => _DiagnosticDebugSectionState();
}

class _DiagnosticDebugSectionState extends State<DiagnosticDebugSection> {
  DiagnosticDataQuality? _dataQuality;
  Map<String, dynamic>? _cacheStats;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bug_report,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Debug: Sistema de Diagnósticos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Botões de ação
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _analyzeDataQuality,
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.analytics),
                  label: const Text('Analisar Qualidade'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _clearCache,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpar Cache'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Mensagem de erro
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Resultados da análise
            if (_dataQuality != null) ...[
              _buildDataQualityCard(),
              const SizedBox(height: 16),
            ],
            
            // Estatísticas do cache
            if (_cacheStats != null) ...[
              _buildCacheStatsCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataQualityCard() {
    final quality = _dataQuality!;
    
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Qualidade dos Dados',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Estatísticas gerais
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    '${quality.total}',
                    Icons.dataset,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Completos',
                    '${quality.completePercentage.toStringAsFixed(1)}%',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Breakdown por campo
            _buildProgressItem(
              'Nomes de Defensivos',
              quality.defensivoNamePercentage,
              Colors.purple,
            ),
            _buildProgressItem(
              'Nomes de Culturas',
              quality.culturaNamePercentage,
              Colors.orange,
            ),
            _buildProgressItem(
              'Nomes de Pragas',
              quality.pragaNamePercentage,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheStatsCard() {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cache Statistics',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ...(_cacheStats!.entries.map((entry) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${entry.key}:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${entry.value}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Future<void> _analyzeDataQuality() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Obtém o enhanced service
      final enhancedService = sl<EnhancedDiagnosticIntegrationService>();
      
      // Analisa qualidade dos dados
      final quality = await enhancedService.getDiagnosticDataQuality();
      final cacheStats = enhancedService.getCacheStats();
      
      setState(() {
        _dataQuality = quality;
        _cacheStats = cacheStats;
        _isLoading = false;
      });
      
      // Mostra resultado no console para debug
      debugPrint('📊 Diagnostic Data Quality Analysis:');
      debugPrint(quality.toString());
      debugPrint('💾 Cache Stats: $cacheStats');
      
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = 'Erro na análise: $e';
        _isLoading = false;
      });
      
      debugPrint('❌ Error analyzing data quality: $e');
      debugPrint('📚 Stack trace: $stackTrace');
    }
  }

  void _clearCache() {
    try {
      // Limpa o cache do enhanced service
      final enhancedService = sl<EnhancedDiagnosticIntegrationService>();
      enhancedService.clearCache();
      
      // Atualiza estatísticas
      if (_cacheStats != null) {
        final enhancedService = sl<EnhancedDiagnosticIntegrationService>();
        setState(() {
          _cacheStats = enhancedService.getCacheStats();
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache limpo com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao limpar cache: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}