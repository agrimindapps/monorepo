import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../providers/diagnosticos_provider.dart';
import '../../../DetalheDiagnostico/detalhe_diagnostico_page.dart';

/// Widget para tab de diagnósticos com filtros e listagem
/// Responsabilidade única: exibição e navegação de diagnósticos
class DiagnosticosTabWidget extends StatelessWidget {
  final String defensivoName;

  const DiagnosticosTabWidget({
    super.key,
    required this.defensivoName,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DiagnosticosProvider>(
      builder: (context, diagnosticosProvider, child) {
        if (diagnosticosProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (diagnosticosProvider.hasError) {
          return _buildErrorState(context, diagnosticosProvider);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilters(diagnosticosProvider),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildContent(context, diagnosticosProvider),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilters(DiagnosticosProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Campo de pesquisa
          Expanded(
            flex: 1,
            child: _buildSearchField(provider),
          ),
          const SizedBox(width: 12),
          // Seletor de cultura
          Expanded(
            flex: 1,
            child: _buildCulturaSelector(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(DiagnosticosProvider provider) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
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
        );
      },
    );
  }

  Widget _buildCulturaSelector(DiagnosticosProvider provider) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
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
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, DiagnosticosProvider provider) {
    final diagnosticosGrouped = provider.diagnosticosGroupedByCultura;

    if (diagnosticosGrouped.isEmpty) {
      return _buildNoDiagnosticosFound(context, provider);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...diagnosticosGrouped.entries.map((entry) {
          final cultura = entry.key;
          final diagnosticos = entry.value;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCulturaSection(context, cultura, diagnosticos.length),
              const SizedBox(height: 16),
              ...diagnosticos.map((diagnostico) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDiagnosticoItem(context, diagnostico),
              )),
              const SizedBox(height: 24),
            ],
          );
        }),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildCulturaSection(BuildContext context, String cultura, int count) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
            '$cultura ($count diagnóstico${count != 1 ? 's' : ''})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticoItem(BuildContext context, DiagnosticoEntity diagnostico) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _showDiagnosticDialog(context, diagnostico),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
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
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
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
  }

  Widget _buildNoDiagnosticosFound(BuildContext context, DiagnosticosProvider provider) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum diagnóstico encontrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.searchQuery.isNotEmpty
                  ? 'Tente buscar por outros termos ou altere o filtro de cultura'
                  : 'Não há diagnósticos para a cultura selecionada',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, DiagnosticosProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar diagnósticos',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Recarregar seria chamado pela página pai
            },
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  void _showDiagnosticDialog(BuildContext context, DiagnosticoEntity diagnostico) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.dialogBackgroundColor,
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow('Dosagem', diagnostico.dosagem, Icons.medication),
                            const SizedBox(height: 16),
                            _buildInfoRow('Cultura', diagnostico.cultura, Icons.eco),
                            const SizedBox(height: 16),
                            _buildInfoRow('Grupo', diagnostico.grupo, Icons.category),
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
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
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
                            MaterialPageRoute(
                              builder: (context) => DetalheDiagnosticoPage(
                                diagnosticoId: diagnostico.id,
                                nomeDefensivo: defensivoName,
                                nomePraga: diagnostico.nome,
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

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Builder(
      builder: (context) {
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
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}