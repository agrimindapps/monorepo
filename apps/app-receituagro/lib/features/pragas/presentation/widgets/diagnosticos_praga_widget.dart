import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../DetalheDefensivos/detalhe_defensivo_page.dart';
import '../../../DetalheDiagnostico/detalhe_diagnostico_page.dart';
import '../providers/diagnosticos_praga_provider.dart';

/// Widget responsável por exibir diagnósticos relacionados à praga
/// Responsabilidade única: renderizar lista filtrada de diagnósticos
class DiagnosticosPragaWidget extends StatelessWidget {
  final String pragaName;

  const DiagnosticosPragaWidget({
    super.key,
    required this.pragaName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFilters(),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<DiagnosticosPragaProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return _buildLoadingState();
                }

                if (provider.errorMessage != null) {
                  return _buildErrorState(provider.errorMessage!);
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildDiagnosticsList(provider),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Constrói área de filtros
  Widget _buildFilters() {
    return Consumer<DiagnosticosPragaProvider>(
      builder: (context, provider, child) {
        final theme = Theme.of(context);
        
        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Campo de pesquisa (metade esquerda)
              Expanded(
                flex: 1,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextField(
                    onChanged: provider.updateSearchQuery,
                    decoration: const InputDecoration(
                      hintText: 'Pesquisar diagnósticos...',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Seletor de cultura (metade direita)
              Expanded(
                flex: 1,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: provider.selectedCultura,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        provider.updateSelectedCultura(newValue);
                      }
                    },
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    items: provider.culturas.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Constrói lista de diagnósticos filtrados
  List<Widget> _buildDiagnosticsList(DiagnosticosPragaProvider provider) {
    final groupedDiagnostics = provider.groupedDiagnosticos;

    if (groupedDiagnostics.isEmpty) {
      return [_buildEmptyState()];
    }

    List<Widget> widgets = [];

    groupedDiagnostics.forEach((cultura, diagnostics) {
      widgets.add(_buildCulturaSection(cultura, '${diagnostics.length} diagnóstico${diagnostics.length > 1 ? 's' : ''}'));
      widgets.add(const SizedBox(height: 16));

      for (int i = 0; i < diagnostics.length; i++) {
        final diagnostic = diagnostics[i];
        widgets.add(_buildDiagnosticoItem(diagnostic));
        if (i < diagnostics.length - 1) {
          widgets.add(const SizedBox(height: 12));
        }
      }
      widgets.add(const SizedBox(height: 24));
    });

    widgets.add(const SizedBox(height: 80));
    return widgets;
  }

  /// Constrói estado de carregamento
  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Constrói estado de erro
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar diagnósticos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói estado vazio
  Widget _buildEmptyState() {
    return Consumer<DiagnosticosPragaProvider>(
      builder: (context, provider, child) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                provider.diagnosticos.isEmpty ? Icons.bug_report_outlined : Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                provider.diagnosticos.isEmpty 
                    ? 'Nenhum diagnóstico disponível'
                    : 'Nenhum diagnóstico encontrado',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                provider.diagnosticos.isEmpty
                    ? 'Esta praga ainda não possui diagnósticos cadastrados ou os dados estão sendo carregados'
                    : 'Tente ajustar os filtros de pesquisa',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói seção de cultura
  Widget _buildCulturaSection(String cultura, String diagnosticos) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.eco,
                color: theme.colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 12),
              Text(
                '$cultura ($diagnosticos)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Constrói item de diagnóstico
  Widget _buildDiagnosticoItem(DiagnosticoModel diagnostico) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return GestureDetector(
          onTap: () => _showDiagnosticoDialog(context, diagnostico),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.agriculture,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        diagnostico.nome,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        diagnostico.ingredienteAtivo,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dosagem: ${diagnostico.dosagem}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.orange[600],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Mostra diálogo com detalhes do diagnóstico
  void _showDiagnosticoDialog(BuildContext context, DiagnosticoModel diagnostico) {
    final theme = Theme.of(context);
    final provider = Provider.of<DiagnosticosPragaProvider>(context, listen: false);
    
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: MediaQuery.of(context).size.width - 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        diagnostico.nome,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ingrediente Ativo
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          'Ingrediente Ativo: ${diagnostico.ingredienteAtivo}',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      // Information Cards
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildDialogInfoRow(
                              context,
                              'Dosagem',
                              diagnostico.dosagem,
                              Icons.medication,
                              isPremium: true,
                            ),
                            const SizedBox(height: 16),
                            _buildDialogInfoRow(
                              context,
                              'Aplicação Terrestre',
                              '••• L/ha',
                              Icons.agriculture,
                              isPremium: false,
                            ),
                            const SizedBox(height: 16),
                            _buildDialogInfoRow(
                              context,
                              'Aplicação Aérea',
                              '••• L/ha',
                              Icons.flight,
                              isPremium: false,
                            ),
                            const SizedBox(height: 16),
                            _buildDialogInfoRow(
                              context,
                              'Intervalo de Aplicação',
                              '••• dias',
                              Icons.schedule,
                              isPremium: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Actions
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          final defensivoData = provider.getDefensivoData(diagnostico.nome);
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => DetalheDefensivoPage(
                                defensivoName: diagnostico.nome,
                                fabricante: defensivoData?['fabricante'] as String? ?? 'Fabricante Desconhecido',
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Defensivo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => DetalheDiagnosticoPage(
                                diagnosticoId: diagnostico.id,
                                nomeDefensivo: diagnostico.nome,
                                nomePraga: pragaName,
                                cultura: diagnostico.cultura,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Diagnóstico'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói linha de informação no diálogo
  Widget _buildDialogInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    required bool isPremium,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isPremium ? FontWeight.w600 : FontWeight.w300,
                  color: isPremium
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        if (!isPremium) ...[
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.diamond,
                size: 12,
                color: Colors.amber.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'Premium',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.amber.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}