import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../infrastructure/services/database_inspector_service.dart';
import '../../../domain/entities/shared_preferences_record.dart';
import '../../theme/data_inspector_theme.dart';

/// SharedPreferences tab with enhanced search and filtering
/// Based on app-plantis implementation with real-time features
class SharedPreferencesTab extends StatefulWidget {
  final DatabaseInspectorService inspector;
  final DataInspectorTheme theme;

  const SharedPreferencesTab({
    super.key,
    required this.inspector,
    required this.theme,
  });

  @override
  State<SharedPreferencesTab> createState() => _SharedPreferencesTabState();
}

class _SharedPreferencesTabState extends State<SharedPreferencesTab> {
  List<SharedPreferencesRecord>? _records;
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final records = await widget.inspector.loadSharedPreferencesData();
      
      if (mounted) {
        setState(() {
          _records = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<SharedPreferencesRecord> get _filteredRecords {
    if (_records == null || _searchQuery.isEmpty) return _records ?? [];
    
    return _records!.where((record) => 
      record.key.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      record.value.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
      record.type.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
      color: widget.theme.surfaceColor,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar chaves, valores ou tipos...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: DataInspectorDesignTokens.spacingM,
                      vertical: DataInspectorDesignTokens.spacingS,
                    ),
                    hintStyle: TextStyle(
                      color: widget.theme.onSurfaceColor.withValues(alpha: 0.6),
                    ),
                  ),
                  style: TextStyle(color: widget.theme.onSurfaceColor),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: DataInspectorDesignTokens.spacingS),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _exportData,
                icon: const Icon(Icons.download),
                label: const Text('Exportar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.theme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: DataInspectorDesignTokens.spacingS),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _loadData,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Atualizar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.theme.accentColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: DataInspectorDesignTokens.spacingS),
          if (_records != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredRecords.length} de ${_records!.length} chaves',
                  style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                    color: widget.theme.onSurfaceColor.withValues(alpha: 0.7),
                  ),
                ),
                if (_records!.isNotEmpty)
                  Text(
                    'Tamanho total: ${_getTotalSizeFormatted()}',
                    style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                      color: widget.theme.onSurfaceColor.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(widget.theme.primaryColor),
            ),
            const SizedBox(height: DataInspectorDesignTokens.spacingM),
            Text(
              'Carregando SharedPreferences...',
              style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
                color: widget.theme.onSurfaceColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    final records = _filteredRecords;

    if (records.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return SharedPreferencesCard(
            record: record,
            theme: widget.theme,
            onRemove: () => _removeKey(record.key),
            onCopy: () => _copyValue(record.value.toString()),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: DataInspectorDesignTokens.iconXl * 1.5,
            color: widget.theme.errorColor,
          ),
          const SizedBox(height: DataInspectorDesignTokens.spacingM),
          Text(
            'Erro ao carregar SharedPreferences',
            style: DataInspectorDesignTokens.titleTextStyle.copyWith(
              color: widget.theme.errorColor,
            ),
          ),
          const SizedBox(height: DataInspectorDesignTokens.spacingS),
          Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingS),
            decoration: BoxDecoration(
              color: widget.theme.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
            ),
            child: Text(
              _error!,
              style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                color: widget.theme.errorColor,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: DataInspectorDesignTokens.spacingM),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.theme.errorColor,
              foregroundColor: Colors.white,
            ),
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
          Icon(
            _searchQuery.isEmpty ? Icons.settings_outlined : Icons.search_off,
            size: DataInspectorDesignTokens.iconXl * 1.5,
            color: widget.theme.onSurfaceColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: DataInspectorDesignTokens.spacingM),
          Text(
            _searchQuery.isEmpty
                ? 'Nenhum dado no SharedPreferences'
                : 'Nenhum resultado encontrado',
            style: DataInspectorDesignTokens.titleTextStyle.copyWith(
              color: widget.theme.onSurfaceColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: DataInspectorDesignTokens.spacingS),
          Text(
            _searchQuery.isEmpty
                ? 'Os dados aparecerão aqui quando forem salvos'
                : 'Tente ajustar os termos de pesquisa',
            style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
              color: widget.theme.onSurfaceColor.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: DataInspectorDesignTokens.spacingM),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Limpar Pesquisa'),
            ),
          ],
        ],
      ),
    );
  }

  String _getTotalSizeFormatted() {
    if (_records == null) return '0 B';
    
    final totalBytes = _records!.fold<int>(0, (sum, r) => sum + r.sizeInBytes);
    
    if (totalBytes < 1024) return '${totalBytes} B';
    if (totalBytes < 1024 * 1024) return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _exportData() async {
    try {
      _showLoadingDialog('Exportando SharedPreferences...');
      
      final file = await widget.inspector.exportSharedPreferencesData();
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showSuccessSnackbar('Dados exportados para: ${file.path}');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorSnackbar('Erro ao exportar dados: $e');
      }
    }
  }

  Future<void> _removeKey(String key) async {
    // Confirm deletion first
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusM),
        ),
        title: Text(
          'Confirmar Remoção',
          style: TextStyle(color: widget.theme.onSurfaceColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem certeza que deseja remover esta chave?',
              style: TextStyle(color: widget.theme.onSurfaceColor),
            ),
            const SizedBox(height: DataInspectorDesignTokens.spacingS),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingS),
              decoration: BoxDecoration(
                color: widget.theme.surfaceColor,
                borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
              ),
              child: Text(
                key,
                style: DataInspectorDesignTokens.codeTextStyle.copyWith(
                  color: widget.theme.onSurfaceColor,
                ),
              ),
            ),
            const SizedBox(height: DataInspectorDesignTokens.spacingS),
            Text(
              'Esta ação não pode ser desfeita.',
              style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                color: widget.theme.errorColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.theme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        final success = await widget.inspector.removeSharedPreferencesKey(key);
        
        if (success) {
          _showSuccessSnackbar('Chave "$key" removida com sucesso');
          // Reload data to reflect changes
          _loadData();
        } else {
          _showErrorSnackbar('Falha ao remover a chave "$key"');
        }
      } catch (e) {
        _showErrorSnackbar('Erro ao remover chave: $e');
      }
    }
  }

  void _copyValue(String value) {
    Clipboard.setData(ClipboardData(text: value));
    _showSuccessSnackbar('Valor copiado para a área de transferência');
  }

  void _showLoadingDialog(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DataInspectorDesignTokens.getLoadingDialog(
        message,
        theme: widget.theme,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      DataInspectorDesignTokens.getSuccessSnackbar(message, theme: widget.theme),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      DataInspectorDesignTokens.getErrorSnackbar(message, theme: widget.theme),
    );
  }
}

/// Card widget for individual SharedPreferences records with enhanced features
class SharedPreferencesCard extends StatelessWidget {
  final SharedPreferencesRecord record;
  final DataInspectorTheme theme;
  final VoidCallback onRemove;
  final VoidCallback onCopy;

  const SharedPreferencesCard({
    super.key,
    required this.record,
    required this.theme,
    required this.onRemove,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: DataInspectorDesignTokens.spacingS),
      color: theme.cardColor,
      elevation: DataInspectorDesignTokens.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusM),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingS),
            decoration: BoxDecoration(
              color: _getTypeColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
            ),
            child: Icon(
              _getTypeIcon(),
              color: _getTypeColor(),
              size: DataInspectorDesignTokens.iconM,
            ),
          ),
          title: Text(
            record.key,
            style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
              color: theme.onSurfaceColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DataInspectorDesignTokens.spacingXs),
              Row(
                children: [
                  _buildTypeChip(),
                  const SizedBox(width: DataInspectorDesignTokens.spacingS),
                  _buildSizeChip(),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onCopy,
                icon: const Icon(Icons.copy, size: 20),
                tooltip: 'Copiar valor',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                iconSize: 20,
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.delete, size: 20, color: theme.errorColor),
                tooltip: 'Remover chave',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                iconSize: 20,
              ),
            ],
          ),
          children: [
            _buildValueDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DataInspectorDesignTokens.spacingS,
        vertical: DataInspectorDesignTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: _getTypeColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
      ),
      child: Text(
        record.type,
        style: DataInspectorDesignTokens.captionTextStyle.copyWith(
          color: _getTypeColor(),
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildSizeChip() {
    final sizeText = record.sizeInBytes < 1024
        ? '${record.sizeInBytes} B'
        : '${(record.sizeInBytes / 1024).toStringAsFixed(1)} KB';
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DataInspectorDesignTokens.spacingS,
        vertical: DataInspectorDesignTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
      ),
      child: Text(
        sizeText,
        style: DataInspectorDesignTokens.captionTextStyle.copyWith(
          color: theme.primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildValueDisplay() {
    return Padding(
      padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Valor:',
                style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
                  color: theme.onSurfaceColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copiar'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DataInspectorDesignTokens.spacingS,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DataInspectorDesignTokens.spacingS),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: 40,
              maxHeight: 200,
            ),
            padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
              border: Border.all(
                color: theme.onSurfaceColor.withValues(alpha: 0.2),
              ),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                _formatValue(),
                style: DataInspectorDesignTokens.codeTextStyle.copyWith(
                  color: theme.onSurfaceColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (record.type.toLowerCase()) {
      case 'string':
        return Colors.blue;
      case 'int':
        return Colors.green;
      case 'bool':
        return Colors.orange;
      case 'double':
        return Colors.purple;
      case 'list<string>':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon() {
    switch (record.type.toLowerCase()) {
      case 'string':
        return Icons.text_fields;
      case 'int':
        return Icons.numbers;
      case 'bool':
        return Icons.toggle_on;
      case 'double':
        return Icons.trending_up;
      case 'list<string>':
        return Icons.list;
      default:
        return Icons.data_object;
    }
  }

  String _formatValue() {
    if (record.type.toLowerCase() == 'list<string>') {
      // Format list for better readability
      final list = record.value as List<dynamic>;
      return list.map((item) => '- $item').join('\n');
    }
    
    if (record.type.toLowerCase() == 'bool') {
      return record.value == true ? 'true' : 'false';
    }
    
    return record.value.toString();
  }
}