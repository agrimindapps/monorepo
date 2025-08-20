// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pluto_grid/pluto_grid.dart';

// Project imports:
import '../models/database_data_model.dart';
import '../utils/database_helpers.dart';

class DataConversionService {
  static List<PlutoColumn> createPlutoColumns(DatabaseTableData tableData) {
    final List<PlutoColumn> columns = [];

    // Always include ID column first
    columns.add(
      PlutoColumn(
        title: 'ID',
        field: 'id',
        type: PlutoColumnType.text(),
        width: DatabaseHelpers.getColumnWidth('id'),
        frozen: PlutoColumnFrozen.start,
      ),
    );

    // Add columns for each field (excluding 'id' which is already added)
    for (final field in tableData.sortedFields.where((f) => f != 'id')) {
      columns.add(
        PlutoColumn(
          title: DatabaseHelpers.formatFieldName(field),
          field: field,
          type: _getColumnType(field, tableData),
          width: DatabaseHelpers.getColumnWidth(field),
        ),
      );
    }

    return columns;
  }

  static List<PlutoRow> createPlutoRows(
    DatabaseTableData tableData,
    List<PlutoColumn> columns,
  ) {
    return tableData.filteredRecords.map((record) {
      final Map<String, PlutoCell> cells = {};

      for (final column in columns) {
        final fieldName = column.field;
        final cellValue =
            fieldName == 'id' ? record.id : record.getValue(fieldName);

        cells[fieldName] = PlutoCell(value: cellValue);
      }

      return PlutoRow(cells: cells);
    }).toList();
  }

  static PlutoColumnType _getColumnType(
      String field, DatabaseTableData tableData) {
    // Analyze the field data to determine the best column type
    for (final record in tableData.records.take(10)) {
      // Sample first 10 records
      final value = record.data[field];

      if (value is num) {
        return PlutoColumnType.number();
      } else if (value is DateTime) {
        return PlutoColumnType.date();
      } else if (value is bool) {
        return PlutoColumnType.select(['true', 'false']);
      }
    }

    // Default to text
    return PlutoColumnType.text();
  }

  static PlutoGridConfiguration createGridConfiguration() {
    return PlutoGridConfiguration(
      columnFilter: const PlutoGridColumnFilterConfig(
        filters: [...FilterHelper.defaultFilters],
      ),
      style: PlutoGridStyleConfig(
        cellTextStyle: DatabaseHelpers.getCellTextStyle(),
        columnTextStyle: DatabaseHelpers.getColumnTextStyle(),
        rowHeight: DatabaseHelpers.getRowHeight(),
        columnHeight: DatabaseHelpers.getColumnHeight(),
        gridBorderColor: DatabaseHelpers.getGridBorderColor(),
        gridBackgroundColor: DatabaseHelpers.getGridBackgroundColor(),
        activatedBorderColor: DatabaseHelpers.getActivatedBorderColor(),
        activatedColor: DatabaseHelpers.getActivatedColor(),
      ),
      scrollbar: const PlutoGridScrollbarConfig(
        isAlwaysShown: true,
      ),
      columnSize: const PlutoGridColumnSizeConfig(
        autoSizeMode: PlutoAutoSizeMode.scale,
      ),
    );
  }

  static Widget createGridFooter(PlutoGridStateManager stateManager) {
    return DatabaseHelpers.buildGridFooter(stateManager);
  }

  static Map<String, dynamic> extractRecordSummary(
      DatabaseTableData tableData) {
    if (tableData.isEmpty) {
      return {
        'totalRecords': 0,
        'fieldCount': 0,
        'fields': <String>[],
        'recordTypes': <String, int>{},
      };
    }

    // Analyze record types and field usage
    final Map<String, int> fieldUsage = {};
    final Map<String, int> recordTypes = {};

    for (final record in tableData.records) {
      // Count field usage
      for (final field in record.data.keys) {
        fieldUsage[field] = (fieldUsage[field] ?? 0) + 1;
      }

      // Determine record type based on available fields
      final sortedFields = record.data.keys.toList()..sort();
      final recordType = sortedFields.take(3).join(', ');
      recordTypes[recordType] = (recordTypes[recordType] ?? 0) + 1;
    }

    return {
      'totalRecords': tableData.totalRecords,
      'fieldCount': tableData.fields.length,
      'fields': tableData.sortedFields,
      'fieldUsage': fieldUsage,
      'recordTypes': recordTypes,
      'mostUsedFields': _getMostUsedFields(fieldUsage),
    };
  }

  static List<String> _getMostUsedFields(Map<String, int> fieldUsage) {
    final entries = fieldUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.take(5).map((e) => e.key).toList();
  }

  static bool validateTableData(DatabaseTableData tableData) {
    if (tableData.isEmpty) return true;

    // Check for basic data integrity
    for (final record in tableData.records) {
      if (record.id.isEmpty) return false;
      if (record.data.isEmpty) return false;
    }

    return true;
  }

  static DatabaseTableData sanitizeTableData(DatabaseTableData tableData) {
    if (tableData.isEmpty) return tableData;

    final sanitizedRecords = tableData.records.where((record) {
      return record.id.isNotEmpty && record.data.isNotEmpty;
    }).toList();

    return tableData.copyWith(records: sanitizedRecords);
  }
}
