import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../core/extensions/praga_drift_extension.dart';
import '../../../core/services/diagnostico_compatibility_service_drift.dart';
import '../../../core/services/diagnostico_entity_resolver_drift.dart';
import '../../../core/services/diagnostico_integration_service.dart';

/// Bottom sheet aprimorado para exibir defensivos de uma praga
///
/// Utiliza os novos serviços para:
/// - Validação de compatibilidade
/// - Resolução consistente de nomes
/// - Cache otimizado
/// - Sugestões inteligentes
class EnhancedDefensivosBottomSheet extends StatefulWidget {
  final PragaPorCultura pragaPorCultura;
  final VoidCallback? onDefensivoTap;

  const EnhancedDefensivosBottomSheet({
    super.key,
    required this.pragaPorCultura,
    this.onDefensivoTap,
  });

  @override
  State<EnhancedDefensivosBottomSheet> createState() =>
      _EnhancedDefensivosBottomSheetState();
}

class _EnhancedDefensivosBottomSheetState
    extends State<EnhancedDefensivosBottomSheet> {
  final _resolver = DiagnosticoEntityResolver.instance;
  final _compatibilityService = DiagnosticoCompatibilityServiceDrift.instance;
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredDefensivos = [];
  List<String> _allDefensivos = [];
  final Map<String, CompatibilityValidation> _compatibilityCache = {};
  bool _isLoadingCompatibility = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _allDefensivos = List.from(widget.pragaPorCultura.defensivosRelacionados);
    _filteredDefensivos = List.from(_allDefensivos);
    unawaited(_validateCompatibilityInBackground());

    setState(() {});
  }

  Future<void> _validateCompatibilityInBackground() async {
    if (_isLoadingCompatibility) return;

    setState(() => _isLoadingCompatibility = true);

    try {
      for (final defensivo in _allDefensivos) {
        final validation = await _compatibilityService
            .validateFullCompatibility(
              idDefensivo: defensivo,
              idCultura: '', // Cultura não disponível em PragaPorCultura
              idPraga: widget.pragaPorCultura.praga.idPraga,
              includeAlternatives: false,
            );

        _compatibilityCache[defensivo] = validation;
      }
    } catch (e) {
      debugPrint('❌ Erro ao validar compatibilidade: $e');
    }

    setState(() => _isLoadingCompatibility = false);
  }

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredDefensivos = List.from(_allDefensivos);
      });
      return;
    }
    final filtered = <String>[];
    for (final defensivoId in _allDefensivos) {
      final resolvedName = await _resolver.resolveDefensivoNome(
        idDefensivo: defensivoId,
      );
      if (resolvedName.toLowerCase().contains(query.toLowerCase())) {
        filtered.add(defensivoId);
      }
    }

    if (mounted) {
      setState(() {
        _filteredDefensivos = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildSearchBar(context),
            const SizedBox(height: 12),
            _buildStatsRow(context),
            const SizedBox(height: 16),
            Expanded(child: _buildDefensivosList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final pragaName = widget.pragaPorCultura.praga.displayName;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FontAwesomeIcons.vial,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Defensivos disponíveis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  pragaName,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar defensivo...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final validCount = _compatibilityCache.values
        .where((v) => v.isValid)
        .length;
    final totalCount = _filteredDefensivos.length;

    return Row(
      children: [
        _buildStatChip(
          context,
          icon: Icons.list_alt,
          label: 'Total: $totalCount',
          color: Colors.blue,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          context,
          icon: Icons.check_circle,
          label: 'Válidos: $validCount',
          color: Colors.green,
        ),
        const SizedBox(width: 8),
        if (_isLoadingCompatibility)
          _buildStatChip(
            context,
            icon: Icons.refresh,
            label: 'Validando...',
            color: Colors.orange,
            isLoading: true,
          ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          else
            Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefensivosList(BuildContext context) {
    final theme = Theme.of(context);

    if (_filteredDefensivos.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      itemCount: _filteredDefensivos.length,
      separatorBuilder: (context, index) =>
          Divider(color: theme.dividerColor.withValues(alpha: 0.3)),
      itemBuilder: (context, index) {
        final defensivo = _filteredDefensivos[index];
        return _buildDefensivoTile(context, defensivo, index);
      },
    );
  }

  Widget _buildDefensivoTile(
    BuildContext context,
    String defensivoId,
    int index,
  ) {
    final theme = Theme.of(context);
    final compatibility = _compatibilityCache[defensivoId];
    return FutureBuilder<String>(
      future: _resolver.resolveDefensivoNome(idDefensivo: defensivoId),
      builder: (context, snapshot) {
        final resolvedName = snapshot.data ?? 'Defensivo não encontrado';

        return RepaintBoundary(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getCompatibilityBorderColor(compatibility),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getCompatibilityColor(
                    compatibility,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  FontAwesomeIcons.vial,
                  color: _getCompatibilityColor(compatibility),
                  size: 16,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      resolvedName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  _buildCompatibilityIndicator(compatibility),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Defensivo registrado para esta praga',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (compatibility != null && !compatibility.isValid)
                    ...compatibility.issues
                        .take(1)
                        .map(
                          (issue) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '⚠️ $issue',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onTap: () {
                Navigator.of(context).pop();
                widget.onDefensivoTap?.call();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompatibilityIndicator(CompatibilityValidation? compatibility) {
    if (compatibility == null) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: _getCompatibilityColor(compatibility),
        shape: BoxShape.circle,
      ),
      child: Icon(
        compatibility.isValid ? Icons.check : Icons.warning,
        color: Colors.white,
        size: 14,
      ),
    );
  }

  Color _getCompatibilityColor(CompatibilityValidation? compatibility) {
    if (compatibility == null) return Colors.grey;
    return compatibility.isValid ? Colors.green : Colors.orange;
  }

  Color _getCompatibilityBorderColor(CompatibilityValidation? compatibility) {
    return _getCompatibilityColor(compatibility).withValues(alpha: 0.3);
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final hasSearchQuery = _searchController.text.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasSearchQuery ? Icons.search_off : Icons.warning_outlined,
              size: 40,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearchQuery
                ? 'Nenhum resultado encontrado'
                : 'Nenhum defensivo encontrado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearchQuery
                ? 'Tente ajustar os termos da busca.'
                : 'Esta praga não possui defensivos registrados em nossa base de dados.',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (hasSearchQuery) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
              icon: const Icon(Icons.clear),
              label: const Text('Limpar busca'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
