import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data_inspector_helpers.dart';

/// Widget do tab de SharedPreferences
///
/// Responsabilidades:
/// - Filtros de busca
/// - Lista de SharedPreferences
/// - Cards expansíveis com detalhes
/// - Ações de copiar e remover
class SharedPrefsTabWidget extends StatefulWidget {
  final List<SharedPreferencesRecord> sharedPrefsData;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final Future<bool> Function(String key) onRemoveSharedPref;
  final VoidCallback onShowSuccessSnackBar;
  final ValueChanged<String> onShowErrorSnackBar;

  const SharedPrefsTabWidget({
    super.key,
    required this.sharedPrefsData,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onRemoveSharedPref,
    required this.onShowSuccessSnackBar,
    required this.onShowErrorSnackBar,
  });

  @override
  State<SharedPrefsTabWidget> createState() => _SharedPrefsTabWidgetState();
}

class _SharedPrefsTabWidgetState extends State<SharedPrefsTabWidget> {
  final Set<String> _expandedPrefs = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilters(),
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Buscar SharedPreference',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        onChanged: widget.onSearchChanged,
      ),
    );
  }

  Widget _buildList() {
    final filteredPrefs =
        widget.sharedPrefsData.where((pref) {
          return widget.searchQuery.isEmpty ||
              pref.key
                  .toLowerCase()
                  .contains(widget.searchQuery.toLowerCase()) ||
              pref.value
                  .toString()
                  .toLowerCase()
                  .contains(widget.searchQuery.toLowerCase());
        }).toList();

    if (filteredPrefs.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPrefs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final pref = filteredPrefs[index];
        return _buildCard(pref);
      },
    );
  }

  Widget _buildCard(SharedPreferencesRecord pref) {
    final isExpanded = _expandedPrefs.contains(pref.key);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedPrefs.remove(pref.key);
                } else {
                  _expandedPrefs.add(pref.key);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: DataInspectorHelpers
                          .getTypeColor(pref.type)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      DataInspectorHelpers.getTypeIcon(pref.type),
                      color: DataInspectorHelpers.getTypeColor(pref.type),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pref.key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tipo: ${pref.type}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed:
                            () =>
                                _copyToClipboard('${pref.key}: ${pref.value}'),
                        tooltip: 'Copiar',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            _buildExpandedContent(pref),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedContent(SharedPreferencesRecord pref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            DataInspectorHelpers.formatValue(pref.value),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyToClipboard(pref.value.toString()),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copiar Valor'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmRemoveSharedPref(pref.key),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Remover'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_suggest, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma SharedPreference encontrada',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    widget.onShowSuccessSnackBar();
  }

  Future<void> _confirmRemoveSharedPref(String key) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Remoção'),
            content: Text('Deseja remover a chave "$key"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Remover'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final success = await widget.onRemoveSharedPref(key);
        if (success) {
          widget.onShowSuccessSnackBar();
        } else {
          widget.onShowErrorSnackBar('Falha ao remover');
        }
      } catch (e) {
        widget.onShowErrorSnackBar('Erro: $e');
      }
    }
  }
}
