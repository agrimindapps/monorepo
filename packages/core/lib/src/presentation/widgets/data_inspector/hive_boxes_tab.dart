import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../infrastructure/services/database_inspector_service.dart';
import '../../../domain/entities/database_record.dart';
import '../../theme/data_inspector_theme.dart';

/// Hive Boxes tab showing all available boxes with management capabilities
/// Based on app-receituagro implementation with enhanced features
class HiveBoxesTab extends StatefulWidget {
  final List<String> boxes;
  final DatabaseInspectorService inspector;
  final DataInspectorTheme theme;
  final VoidCallback onRefresh;

  const HiveBoxesTab({
    super.key,
    required this.boxes,
    required this.inspector,
    required this.theme,
    required this.onRefresh,
  });

  @override
  State<HiveBoxesTab> createState() => _HiveBoxesTabState();
}

class _HiveBoxesTabState extends State<HiveBoxesTab> {
  String _searchQuery = '';
  bool _isLoading = false;

  List<String> get _filteredBoxes {
    if (_searchQuery.isEmpty) return widget.boxes;
    
    return widget.boxes.where((boxKey) {
      final displayName = widget.inspector.getBoxDisplayName(boxKey);
      final searchLower = _searchQuery.toLowerCase();
      return boxKey.toLowerCase().contains(searchLower) ||
             displayName.toLowerCase().contains(searchLower);
    }).toList();
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
                    hintText: 'Pesquisar boxes...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: DataInspectorDesignTokens.spacingM,
                      vertical: DataInspectorDesignTokens.spacingS,
                    ),
                    hintStyle: TextStyle(color: widget.theme.onSurfaceColor.withValues(alpha: 0.6)),
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
                onPressed: _isLoading ? null : () {
                  setState(() => _isLoading = true);
                  widget.onRefresh();
                  Future<void>.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) setState(() => _isLoading = false);
                  });
                },
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Atualizar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.theme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: DataInspectorDesignTokens.spacingS),
          Text(
            '${_filteredBoxes.length} de ${widget.boxes.length} boxes',
            style: DataInspectorDesignTokens.captionTextStyle.copyWith(
              color: widget.theme.onSurfaceColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final filteredBoxes = _filteredBoxes;
    
    if (widget.boxes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.storage_outlined,
        title: 'Nenhuma Hive Box encontrada',
        subtitle: 'As boxes aparecerão aqui quando forem criadas',
      );
    }

    if (filteredBoxes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: 'Nenhuma box encontrada',
        subtitle: 'Tente ajustar os termos de pesquisa',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh();
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
        itemCount: filteredBoxes.length,
        itemBuilder: (context, index) {
          final boxKey = filteredBoxes[index];
          return _buildBoxCard(boxKey);
        },
      ),
    );
  }

  Widget _buildBoxCard(String boxKey) {
    final displayName = widget.inspector.getBoxDisplayName(boxKey);
    final description = widget.inspector.getBoxDescription(boxKey);
    final stats = widget.inspector.getBoxStats(boxKey);
    final isOpen = stats['isOpen'] ?? false;
    final recordCount = stats['totalRecords'] ?? 0;
    final hasError = stats.containsKey('error');

    return Card(
      margin: const EdgeInsets.only(bottom: DataInspectorDesignTokens.spacingS),
      color: widget.theme.cardColor,
      elevation: DataInspectorDesignTokens.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusM),
      ),
      child: InkWell(
        onTap: (isOpen == true && !hasError) ? () => _viewBoxData(boxKey) : null,
        borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
          child: Row(
            children: [
              // Leading icon with status indicator
              Container(
                padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingS),
                decoration: BoxDecoration(
                  color: _getBoxStatusColor(stats).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
                ),
                child: Icon(
                  hasError ? Icons.error : Icons.storage,
                  color: _getBoxStatusColor(stats),
                  size: DataInspectorDesignTokens.iconL,
                ),
              ),
              const SizedBox(width: DataInspectorDesignTokens.spacingM),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: DataInspectorDesignTokens.titleTextStyle.copyWith(
                        color: widget.theme.onSurfaceColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: DataInspectorDesignTokens.spacingXs),
                    Text(
                      'Box: $boxKey',
                      style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                        color: widget.theme.onSurfaceColor.withValues(alpha: 0.7),
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: DataInspectorDesignTokens.spacingXs),
                      Text(
                        description,
                        style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                          color: widget.theme.onSurfaceColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                    const SizedBox(height: DataInspectorDesignTokens.spacingS),
                    
                    // Status and record count
                    Row(
                      children: [
                        _buildStatusChip(hasError ? 'Erro' : (isOpen == true ? 'Aberta' : 'Fechada')),
                        const SizedBox(width: DataInspectorDesignTokens.spacingS),
                        _buildRecordCountChip(recordCount as int),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions menu
              PopupMenuButton<String>(
                onSelected: (value) => _handleBoxAction(value, boxKey),
                itemBuilder: (context) => [
                  if (isOpen == true && !hasError)
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility),
                          SizedBox(width: 8),
                          Text('Visualizar'),
                        ],
                      ),
                    ),
                  if (isOpen == true && !hasError)
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.download),
                          SizedBox(width: 8),
                          Text('Exportar'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'info',
                    child: Row(
                      children: [
                        Icon(Icons.info),
                        SizedBox(width: 8),
                        Text('Informações'),
                      ],
                    ),
                  ),
                ],
                icon: Icon(
                  Icons.more_vert,
                  color: widget.theme.onSurfaceColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final isError = status == 'Erro';
    final isOpen = status == 'Aberta';
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DataInspectorDesignTokens.spacingS,
        vertical: DataInspectorDesignTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: (isError ? widget.theme.errorColor : 
               isOpen ? widget.theme.successColor : 
               widget.theme.warningColor).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
      ),
      child: Text(
        status,
        style: DataInspectorDesignTokens.captionTextStyle.copyWith(
          color: isError ? widget.theme.errorColor : 
                isOpen ? widget.theme.successColor : 
                widget.theme.warningColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRecordCountChip(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DataInspectorDesignTokens.spacingS,
        vertical: DataInspectorDesignTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: widget.theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
      ),
      child: Text(
        '$count registro${count != 1 ? 's' : ''}',
        style: DataInspectorDesignTokens.captionTextStyle.copyWith(
          color: widget.theme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: DataInspectorDesignTokens.iconXl * 1.5,
            color: widget.theme.onSurfaceColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: DataInspectorDesignTokens.spacingM),
          Text(
            title,
            style: DataInspectorDesignTokens.titleTextStyle.copyWith(
              color: widget.theme.onSurfaceColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: DataInspectorDesignTokens.spacingS),
          Text(
            subtitle,
            style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
              color: widget.theme.onSurfaceColor.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getBoxStatusColor(Map<String, dynamic> stats) {
    if (stats.containsKey('error')) {
      return widget.theme.errorColor;
    }
    
    final isOpen = stats['isOpen'] as bool? ?? false;
    return isOpen ? widget.theme.successColor : widget.theme.warningColor;
  }

  void _handleBoxAction(String action, String boxKey) {
    switch (action) {
      case 'view':
        _viewBoxData(boxKey);
        break;
      case 'export':
        _exportBoxData(boxKey);
        break;
      case 'info':
        _showBoxInfo(boxKey);
        break;
    }
  }

  void _viewBoxData(String boxKey) async {
    try {
      _showLoadingDialog('Carregando dados da box...');
      
      final records = await widget.inspector.loadHiveBoxData(boxKey);
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        await showDialog<void>(
          context: context,
          builder: (context) => BoxDataDialog(
            boxKey: boxKey,
            displayName: widget.inspector.getBoxDisplayName(boxKey),
            records: records,
            inspector: widget.inspector,
            theme: widget.theme,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorSnackbar('Erro ao carregar dados: $e');
      }
    }
  }

  void _exportBoxData(String boxKey) async {
    try {
      _showLoadingDialog('Exportando dados da box...');
      
      final file = await widget.inspector.exportBoxData(boxKey);
      
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

  void _showBoxInfo(String boxKey) {
    final stats = widget.inspector.getBoxStats(boxKey);
    final description = widget.inspector.getBoxDescription(boxKey);
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusM),
        ),
        title: Text(
          'Informações da Box',
          style: TextStyle(color: widget.theme.onSurfaceColor),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Nome', widget.inspector.getBoxDisplayName(boxKey)),
              _buildInfoRow('Chave', boxKey),
              if (description != null)
                _buildInfoRow('Descrição', description),
              _buildInfoRow('Status', stats['isOpen'] == true ? 'Aberta' : 'Fechada'),
              _buildInfoRow('Registros', '${stats['totalRecords'] ?? 0}'),
              if (stats['path'] != null)
                _buildInfoRow('Caminho', stats['path'] as String),
              _buildInfoRow('Lazy', stats['lazy'] == true ? 'Sim' : 'Não'),
              if (stats['sampleKeys'] != null) ...[
                const SizedBox(height: DataInspectorDesignTokens.spacingM),
                Text(
                  'Exemplo de chaves:',
                  style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
                    color: widget.theme.onSurfaceColor,
                    fontWeight: FontWeight.w600,
                  ),
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
                    (stats['sampleKeys'] as List).join(', '),
                    style: DataInspectorDesignTokens.codeTextStyle.copyWith(
                      color: widget.theme.onSurfaceColor,
                    ),
                  ),
                ),
              ],
              if (stats['error'] != null) ...[
                const SizedBox(height: DataInspectorDesignTokens.spacingM),
                Text(
                  'Erro:',
                  style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
                    color: widget.theme.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DataInspectorDesignTokens.spacingS),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingS),
                  decoration: BoxDecoration(
                    color: widget.theme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
                  ),
                  child: Text(
                    stats['error'] as String,
                    style: DataInspectorDesignTokens.codeTextStyle.copyWith(
                      color: widget.theme.errorColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DataInspectorDesignTokens.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                color: widget.theme.onSurfaceColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                color: widget.theme.onSurfaceColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DataInspectorDesignTokens.getLoadingDialog(message, theme: widget.theme),
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

/// Dialog for displaying box data with search and navigation
class BoxDataDialog extends StatefulWidget {
  final String boxKey;
  final String displayName;
  final List<DatabaseRecord> records;
  final DatabaseInspectorService inspector;
  final DataInspectorTheme theme;

  const BoxDataDialog({
    super.key,
    required this.boxKey,
    required this.displayName,
    required this.records,
    required this.inspector,
    required this.theme,
  });

  @override
  State<BoxDataDialog> createState() => _BoxDataDialogState();
}

class _BoxDataDialogState extends State<BoxDataDialog> {
  String _searchQuery = '';
  
  List<DatabaseRecord> get _filteredRecords {
    if (_searchQuery.isEmpty) return widget.records;
    
    return widget.records.where((record) {
      final searchLower = _searchQuery.toLowerCase();
      return record.id.toLowerCase().contains(searchLower) ||
             record.data.toString().toLowerCase().contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
      backgroundColor: widget.theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusM),
      ),
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildRecordsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
      decoration: BoxDecoration(
        color: widget.theme.primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DataInspectorDesignTokens.radiusM),
          topRight: Radius.circular(DataInspectorDesignTokens.radiusM),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.storage,
            color: Colors.white,
            size: DataInspectorDesignTokens.iconL,
          ),
          const SizedBox(width: DataInspectorDesignTokens.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.displayName,
                  style: DataInspectorDesignTokens.titleTextStyle.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${widget.records.length} registro${widget.records.length != 1 ? 's' : ''}',
                  style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Fechar',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Pesquisar registros...',
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DataInspectorDesignTokens.spacingM,
            vertical: DataInspectorDesignTokens.spacingS,
          ),
          hintStyle: TextStyle(color: widget.theme.onSurfaceColor.withValues(alpha: 0.6)),
        ),
        style: TextStyle(color: widget.theme.onSurfaceColor),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildRecordsList() {
    final records = _filteredRecords;
    
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.data_object : Icons.search_off,
              size: DataInspectorDesignTokens.iconXl,
              color: widget.theme.onSurfaceColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: DataInspectorDesignTokens.spacingM),
            Text(
              _searchQuery.isEmpty
                  ? 'Nenhum registro encontrado'
                  : 'Nenhum resultado para a pesquisa',
              style: DataInspectorDesignTokens.titleTextStyle.copyWith(
                color: widget.theme.onSurfaceColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: DataInspectorDesignTokens.spacingM),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(record);
      },
    );
  }

  Widget _buildRecordCard(DatabaseRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: DataInspectorDesignTokens.spacingS),
      color: widget.theme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: widget.theme.primaryColor,
            radius: 16,
            child: const Icon(
              Icons.data_object,
              color: Colors.white,
              size: 16,
            ),
          ),
          title: Text(
            'ID: ${record.id}',
            style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
              color: widget.theme.onSurfaceColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${record.data.keys.length} campo${record.data.keys.length != 1 ? 's' : ''}',
            style: DataInspectorDesignTokens.captionTextStyle.copyWith(
              color: widget.theme.onSurfaceColor.withValues(alpha: 0.7),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Dados:',
                        style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
                          color: widget.theme.onSurfaceColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _copyToClipboard(
                          widget.inspector.formatAsJsonString(record.data),
                        ),
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copiar JSON'),
                        style: TextButton.styleFrom(
                          foregroundColor: widget.theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DataInspectorDesignTokens.spacingS),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 200),
                    padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
                    decoration: BoxDecoration(
                      color: widget.theme.backgroundColor,
                      borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
                      border: Border.all(
                        color: widget.theme.onSurfaceColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        widget.inspector.formatAsJsonString(record.data),
                        style: DataInspectorDesignTokens.codeTextStyle.copyWith(
                          color: widget.theme.onSurfaceColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      DataInspectorDesignTokens.getSuccessSnackbar(
        'Dados copiados para a área de transferência',
        theme: widget.theme,
      ),
    );
  }
}