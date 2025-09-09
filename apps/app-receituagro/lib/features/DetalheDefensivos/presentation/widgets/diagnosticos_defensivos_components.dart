import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/spacing_tokens.dart';
import '../../../detalhes_diagnostico/detalhe_diagnostico_page.dart';
import '../../detalhe_defensivo_page.dart' as defensivo_page;
import '../providers/diagnosticos_provider_legacy.dart';

/// Componentes modulares para exibição de diagnósticos em páginas de defensivos
/// 
/// Este arquivo contém todos os widgets auxiliares necessários para replicar
/// a funcionalidade e visual dos diagnósticos da página de pragas, adaptados
/// para funcionar com defensivos.

// ============================================================================
// FILTRO DE DIAGNÓSTICOS
// ============================================================================

/// Widget responsável pelos filtros de diagnósticos
/// 
/// Responsabilidade única: renderizar e gerenciar filtros de pesquisa e cultura
/// - Campo de busca por texto
/// - Dropdown de seleção de cultura
/// - Layout responsivo e design consistente
class DiagnosticoDefensivoFilterWidget extends StatelessWidget {
  const DiagnosticoDefensivoFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Consumer<DiagnosticosProvider>(
        builder: (context, provider, child) {
          
          return Container(
            padding: const EdgeInsets.all(SpacingTokens.sm),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _SearchField(
                    onChanged: (query) => provider.setSearchQuery(query),
                  ),
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  flex: 1,
                  child: _CultureDropdown(
                    value: provider.selectedCultura ?? 'Todas',
                    cultures: provider.availableCulturas,
                    onChanged: (cultura) => provider.setSelectedCultura(cultura),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}

/// Campo de busca personalizado
class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Pesquisar diagnósticos...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}

/// Dropdown de seleção de cultura
class _CultureDropdown extends StatelessWidget {
  final String value;
  final List<String> cultures;
  final ValueChanged<String> onChanged;

  const _CultureDropdown({
    required this.value,
    required this.cultures,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        items: cultures.map<DropdownMenuItem<String>>((String culture) {
          return DropdownMenuItem<String>(
            value: culture,
            child: Text(
              culture,
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
  }
}

// ============================================================================
// GERENCIAMENTO DE ESTADOS
// ============================================================================

/// Widget para gerenciamento de estados da lista de diagnósticos
class DiagnosticoDefensivoStateManager extends StatelessWidget {
  final String defensivoName;
  final Widget Function(List<dynamic>) builder;
  final VoidCallback? onRetry;

  const DiagnosticoDefensivoStateManager({
    super.key,
    required this.defensivoName,
    required this.builder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DiagnosticosProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const DiagnosticoDefensivoLoadingWidget();
        }

        if (provider.hasError) {
          return DiagnosticoDefensivoErrorWidget(
            errorMessage: provider.errorMessage ?? 'Erro desconhecido',
            onRetry: onRetry,
          );
        }

        if (provider.diagnosticos.isEmpty) {
          return DiagnosticoDefensivoEmptyWidget(defensivoName: defensivoName);
        }

        return builder(provider.diagnosticos);
      },
    );
  }
}

/// Widget para estado de carregamento
class DiagnosticoDefensivoLoadingWidget extends StatelessWidget {
  const DiagnosticoDefensivoLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(SpacingTokens.xxl),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

/// Widget para estado de erro
class DiagnosticoDefensivoErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const DiagnosticoDefensivoErrorWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: SpacingTokens.lg),
              Text(
                'Erro ao carregar diagnósticos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: SpacingTokens.lg),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para estado vazio
class DiagnosticoDefensivoEmptyWidget extends StatelessWidget {
  final String defensivoName;

  const DiagnosticoDefensivoEmptyWidget({
    super.key,
    required this.defensivoName,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: SpacingTokens.lg),
              Text(
                'Nenhum diagnóstico encontrado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'Não há diagnósticos disponíveis para $defensivoName',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SEÇÃO DE CULTURA
// ============================================================================

/// Widget para seção de cultura com contador de diagnósticos
class DiagnosticoDefensivoCultureSectionWidget extends StatelessWidget {
  final String cultura;
  final int diagnosticCount;

  const DiagnosticoDefensivoCultureSectionWidget({
    super.key,
    required this.cultura,
    required this.diagnosticCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.sm,
        ),
        margin: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.eco,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                cultura,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.sm,
                vertical: SpacingTokens.xs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$diagnosticCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ITEM DE DIAGNÓSTICO
// ============================================================================

/// Widget responsável por renderizar um item de diagnóstico na lista
/// 
/// Responsabilidade única: exibir dados de um diagnóstico específico
/// - Layout consistente com card design
/// - Informações principais visíveis (nome, ingrediente ativo, dosagem)
/// - Ação de tap configurável
/// - Performance otimizada com RepaintBoundary
class DiagnosticoDefensivoListItemWidget extends StatelessWidget {
  final dynamic diagnostico;
  final VoidCallback onTap;

  const DiagnosticoDefensivoListItemWidget({
    super.key,
    required this.diagnostico,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: _buildCardDecoration(context),
          child: Row(
            children: [
              _buildIcon(context),
              const SizedBox(width: SpacingTokens.lg),
              Expanded(
                child: _buildContent(context),
              ),
              _buildTrailingActions(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Decoração do card do item
  BoxDecoration _buildCardDecoration(BuildContext context) {
    final theme = Theme.of(context);
    
    return BoxDecoration(
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
    );
  }

  /// Ícone representativo do diagnóstico
  Widget _buildIcon(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
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
    );
  }

  /// Conteúdo principal com informações do diagnóstico
  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    
    // Extração de propriedades com fallbacks para diferentes tipos de modelo
    final nome = _getProperty('nomeDefensivo', 'nome') ?? 'Diagnóstico não identificado';
    final ingredienteAtivo = _getProperty('ingredienteAtivo') ?? 'Ingrediente ativo não especificado';
    final cultura = _getProperty('nomeCultura', 'cultura') ?? 'Cultura não especificada';
    final praga = _getProperty('nomePraga', 'grupo') ?? '';
    final dosagem = _getProperty('dosagem') ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nome,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          ingredienteAtivo,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Row(
          children: [
            Expanded(
              child: Text(
                cultura,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (praga.isNotEmpty) ...[
              const SizedBox(width: SpacingTokens.sm),
              Icon(
                Icons.bug_report,
                size: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: SpacingTokens.xs),
              Text(
                praga,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        if (dosagem.isNotEmpty) ...[
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'Dosagem: $dosagem',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }

  /// Ações do lado direito do item
  Widget _buildTrailingActions(BuildContext context) {
    final theme = Theme.of(context);
    
    return Icon(
      Icons.arrow_forward_ios,
      size: 16,
      color: theme.colorScheme.onSurfaceVariant,
    );
  }

  /// Helper para extrair propriedades com fallbacks
  String? _getProperty(String primaryKey, [String? fallbackKey]) {
    try {
      if (diagnostico is Map<String, dynamic>) {
        final map = diagnostico as Map<String, dynamic>;
        return map[primaryKey]?.toString() ?? (fallbackKey != null ? map[fallbackKey]?.toString() : null);
      } else {
        // Tenta acessar como propriedade do objeto
        final primary = _getObjectProperty(diagnostico, primaryKey);
        if (primary != null) return primary.toString();
        
        if (fallbackKey != null) {
          final fallback = _getObjectProperty(diagnostico, fallbackKey);
          if (fallback != null) return fallback.toString();
        }
      }
    } catch (e) {
      // Ignora erros de acesso a propriedades
    }
    return null;
  }

  /// Helper para acessar propriedades de objeto dinamicamente
  dynamic _getObjectProperty(dynamic obj, String property) {
    try {
      switch (property) {
        case 'nomeDefensivo':
          return obj.nomeDefensivo;
        case 'ingredienteAtivo':
          return obj.ingredienteAtivo;
        case 'nomeCultura':
          return obj.nomeCultura;
        case 'cultura':
          return obj.cultura;
        case 'nomePraga':
          return obj.nomePraga;
        case 'grupo':
          return obj.grupo;
        case 'dosagem':
          return obj.dosagem;
        case 'nome':
          return obj.nome;
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }
}

// ============================================================================
// MODAL DE DETALHES
// ============================================================================

/// Widget responsável pelo modal de detalhes do diagnóstico
/// 
/// Responsabilidade única: exibir detalhes completos de um diagnóstico em modal
/// - Layout responsivo com constraints adequados
/// - Informações detalhadas do diagnóstico
/// - Ações para navegar para defensivo ou diagnóstico detalhado
/// - Premium badges para features pagas
class DiagnosticoDefensivoDialogWidget extends StatelessWidget {
  final dynamic diagnostico;
  final String defensivoName;

  const DiagnosticoDefensivoDialogWidget({
    super.key,
    required this.diagnostico,
    required this.defensivoName,
  });

  /// Mostra o modal de detalhes
  static Future<void> show(
    BuildContext context,
    dynamic diagnostico,
    String defensivoName,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) => DiagnosticoDefensivoDialogWidget(
        diagnostico: diagnostico,
        defensivoName: defensivoName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
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
            _buildHeader(context),
            Flexible(
              child: _buildContent(context),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  /// Cabeçalho do modal com título e botão de fechar
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final nome = _getProperty('nomeDefensivo', 'nome') ?? 'Diagnóstico';
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              nome,
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
    );
  }

  /// Conteúdo principal do modal
  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Ingrediente Ativo', _getProperty('ingredienteAtivo') ?? 'Não especificado', context),
          _buildInfoSection('Cultura', _getProperty('nomeCultura', 'cultura') ?? 'Não especificada', context),
          _buildInfoSection('Praga', _getProperty('nomePraga', 'grupo') ?? 'Não especificada', context),
          _buildInfoSection('Dosagem', _getProperty('dosagem') ?? 'Não especificada', context),
          if (_getProperty('unidadeDosagem') != null)
            _buildInfoSection('Unidade', _getProperty('unidadeDosagem')!, context),
          if (_getProperty('modoAplicacao') != null)
            _buildInfoSection('Modo de Aplicação', _getProperty('modoAplicacao')!, context),
          if (_getProperty('intervaloDias') != null)
            _buildInfoSection('Intervalo (dias)', _getProperty('intervaloDias').toString(), context),
          if (_getProperty('observacoes') != null)
            _buildInfoSection('Observações', _getProperty('observacoes')!, context),
        ],
      ),
    );
  }

  /// Constrói uma seção de informação
  Widget _buildInfoSection(String label, String value, BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Ações do modal (botões inferiores)
  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToDetailedDiagnostic(context);
              },
              child: const Text('Ver Detalhes'),
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToDefensivo(context);
              },
              child: const Text('Ver Defensivo'),
            ),
          ),
        ],
      ),
    );
  }

  /// Navega para a página de detalhes do diagnóstico
  void _navigateToDetailedDiagnostic(BuildContext context) {
    final diagnosticoId = _getProperty('id');
    final nomeCultura = _getProperty('nomeCultura', 'cultura') ?? 'Não especificado';
    final nomeDefensivo = _getProperty('nomeDefensivo', 'nome') ?? 'Não especificado';
    final nomePraga = _getProperty('nomePraga', 'grupo') ?? 'Não especificado';
    
    if (diagnosticoId != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => DetalheDiagnosticoPage(
            diagnosticoId: diagnosticoId,
            cultura: nomeCultura,
            nomeDefensivo: nomeDefensivo,
            nomePraga: nomePraga,
          ),
        ),
      );
    }
  }

  /// Navega para a página de detalhes do defensivo
  void _navigateToDefensivo(BuildContext context) {
    final nomeDefensivo = _getProperty('nomeDefensivo', 'nome');
    
    if (nomeDefensivo != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => defensivo_page.DetalheDefensivoPage(
            defensivoName: nomeDefensivo,
            fabricante: 'Não especificado', // Fabricante não disponível no contexto
          ),
        ),
      );
    }
  }

  /// Helper para extrair propriedades com fallbacks
  String? _getProperty(String primaryKey, [String? fallbackKey]) {
    try {
      if (diagnostico is Map<String, dynamic>) {
        final map = diagnostico as Map<String, dynamic>;
        return map[primaryKey]?.toString() ?? (fallbackKey != null ? map[fallbackKey]?.toString() : null);
      } else {
        // Tenta acessar como propriedade do objeto
        final primary = _getObjectProperty(diagnostico, primaryKey);
        if (primary != null) return primary.toString();
        
        if (fallbackKey != null) {
          final fallback = _getObjectProperty(diagnostico, fallbackKey);
          if (fallback != null) return fallback.toString();
        }
      }
    } catch (e) {
      // Ignora erros de acesso a propriedades
    }
    return null;
  }

  /// Helper para acessar propriedades de objeto dinamicamente
  dynamic _getObjectProperty(dynamic obj, String property) {
    try {
      switch (property) {
        case 'id':
          return obj.id;
        case 'idDefensivo':
          return obj.idDefensivo;
        case 'nomeDefensivo':
          return obj.nomeDefensivo;
        case 'ingredienteAtivo':
          return obj.ingredienteAtivo;
        case 'nomeCultura':
          return obj.nomeCultura;
        case 'cultura':
          return obj.cultura;
        case 'nomePraga':
          return obj.nomePraga;
        case 'grupo':
          return obj.grupo;
        case 'dosagem':
          return obj.dosagem;
        case 'unidadeDosagem':
          return obj.unidadeDosagem;
        case 'modoAplicacao':
          return obj.modoAplicacao;
        case 'intervaloDias':
          return obj.intervaloDias;
        case 'observacoes':
          return obj.observacoes;
        case 'nome':
          return obj.nome;
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }
}