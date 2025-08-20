// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pluto_grid/pluto_grid.dart';

// Project imports:
import '../../controllers/database_controller.dart';
import '../../services/data_conversion_service.dart';
import '../../utils/database_helpers.dart';
import 'export_options_widget.dart';

class DataTableWidget extends StatefulWidget {
  final DatabaseController controller;

  const DataTableWidget({
    super.key,
    required this.controller,
  });

  @override
  State<DataTableWidget> createState() => _DataTableWidgetState();
}

class _DataTableWidgetState extends State<DataTableWidget> {
  PlutoGridStateManager? _stateManager;

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.hasData) {
      return const SizedBox.shrink();
    }

    if (!widget.controller.isValidForDisplay()) {
      return _buildTooLargeWarning();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: DatabaseHelpers.getCardBorderRadius(),
      ),
      child: Padding(
        padding: DatabaseHelpers.getCardPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(child: _buildPlutoGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Box: ${widget.controller.selectedBox?.displayName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              _buildSubtitle(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        Row(
          children: [
            ExportOptionsWidget(controller: widget.controller),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Recarregar dados',
              onPressed: widget.controller.refreshData,
            ),
          ],
        ),
      ],
    );
  }

  String _buildSubtitle() {
    if (widget.controller.isFiltered) {
      return '${widget.controller.filteredRecords} de ${widget.controller.totalRecords} registros';
    }
    return DatabaseHelpers.formatRecordCount(widget.controller.totalRecords);
  }

  Widget _buildPlutoGrid() {
    final tableData = widget.controller.tableData;
    final columns = DataConversionService.createPlutoColumns(tableData);
    final rows = DataConversionService.createPlutoRows(tableData, columns);

    return PlutoGrid(
      columns: columns,
      rows: rows,
      onLoaded: (PlutoGridOnLoadedEvent event) {
        _stateManager = event.stateManager;
        _setupGridFilters();
      },
      configuration: DataConversionService.createGridConfiguration(),
      mode: PlutoGridMode.readOnly,
      createFooter: (stateManager) {
        return DataConversionService.createGridFooter(stateManager);
      },
    );
  }

  void _setupGridFilters() {
    if (_stateManager == null) return;

    // Apply search filter if there's a search term
    if (widget.controller.searchTerm.isNotEmpty) {
      _stateManager!.setFilter((row) {
        final searchTerm = widget.controller.searchTerm.toLowerCase();
        
        for (var cell in row.cells.values) {
          if (cell.value.toString().toLowerCase().contains(searchTerm)) {
            return true;
          }
        }
        return false;
      });
    }
  }

  Widget _buildTooLargeWarning() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: DatabaseHelpers.getCardBorderRadius(),
      ),
      child: Container(
        padding: DatabaseHelpers.getCardPadding(),
        child: DatabaseHelpers.buildEmptyState(
          icon: Icons.warning_amber,
          title: 'Muitos dados para exibir',
          subtitle: 'Esta box contém muitos registros ou campos para serem exibidos em uma tabela. Use a funcionalidade de exportação para acessar os dados.',
          action: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Registros: ${widget.controller.totalRecords}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Campos: ${widget.controller.tableData.fields.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExportOptionsWidget(controller: widget.controller),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: widget.controller.refreshData,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Recarregar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
