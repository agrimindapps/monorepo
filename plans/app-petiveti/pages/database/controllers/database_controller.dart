// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/box_type_model.dart';
import '../models/database_data_model.dart';
import '../services/data_export_service.dart';
import '../services/hive_service.dart';
import '../utils/database_constants.dart';

class DatabaseController extends ChangeNotifier {
  final HiveService _hiveService = HiveService();
  final DataExportService _exportService = DataExportService();

  // State
  BoxType? _selectedBox;
  DatabaseTableData _tableData = DatabaseTableData.empty();
  bool _isLoading = false;
  String? _errorMessage;
  String _searchTerm = '';
  List<BoxInfo> _availableBoxes = [];

  // Getters
  BoxType? get selectedBox => _selectedBox;
  DatabaseTableData get tableData => _tableData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  String get searchTerm => _searchTerm;
  List<BoxInfo> get availableBoxes => List.unmodifiable(_availableBoxes);

  bool get hasSelectedBox => _selectedBox != null;
  bool get hasData => _tableData.hasRecords;
  bool get isEmpty => _tableData.isEmpty;
  bool get isFiltered => _searchTerm.isNotEmpty;
  int get totalRecords => _tableData.totalRecords;
  int get filteredRecords => _tableData.filteredRecordCount;

  // Initialization
  Future<void> initialize() async {
    await _loadAvailableBoxes();
  }

  Future<void> _loadAvailableBoxes() async {
    try {
      _setLoading(true);
      _availableBoxes = await _hiveService.getAvailableBoxes();
      _setLoading(false);
    } catch (e) {
      _setError('Erro ao carregar boxes disponíveis: ${e.toString()}');
    }
  }

  // Box selection
  Future<void> selectBox(BoxType boxType) async {
    try {
      _selectedBox = boxType;
      _searchTerm = '';
      notifyListeners();

      await _loadBoxData(boxType);
    } catch (e) {
      _setError('Erro ao selecionar box: ${e.toString()}');
    }
  }

  Future<void> _loadBoxData(BoxType boxType) async {
    try {
      _setLoading(true);
      
      final data = await _hiveService.loadBoxData(boxType);
      _tableData = data;
      
      _setLoading(false);
    } catch (e) {
      _setError('Erro ao carregar dados da box "${boxType.displayName}": ${e.toString()}');
    }
  }

  // Search functionality
  void updateSearchTerm(String term) {
    _searchTerm = term;
    _tableData = _tableData.copyWith(searchTerm: term);
    notifyListeners();
  }

  void clearSearch() {
    updateSearchTerm('');
  }

  // Export functionality
  Future<ExportData> exportToJson() async {
    if (!hasData || _selectedBox == null) {
      throw Exception('Nenhum dado para exportar');
    }

    try {
      return await _exportService.exportToJson(
        tableData: _tableData,
        boxType: _selectedBox!,
      );
    } catch (e) {
      throw Exception('Erro ao exportar para JSON: ${e.toString()}');
    }
  }

  Future<ExportData> exportToCsv() async {
    if (!hasData || _selectedBox == null) {
      throw Exception('Nenhum dado para exportar');
    }

    try {
      return await _exportService.exportToCsv(
        tableData: _tableData,
        boxType: _selectedBox!,
      );
    } catch (e) {
      throw Exception('Erro ao exportar para CSV: ${e.toString()}');
    }
  }

  Future<List<ExportData>> exportAllFormats() async {
    if (!hasData || _selectedBox == null) {
      throw Exception('Nenhum dado para exportar');
    }

    try {
      return await _exportService.exportAllFormats(
        tableData: _tableData,
        boxType: _selectedBox!,
      );
    } catch (e) {
      throw Exception('Erro ao exportar dados: ${e.toString()}');
    }
  }

  String getExportSummary() {
    if (!hasData || _selectedBox == null) {
      return 'Nenhum dado para exportar';
    }

    return _exportService.formatExportSummaryText(
      tableData: _tableData,
      boxType: _selectedBox!,
    );
  }

  // Data management
  Future<void> refreshData() async {
    if (_selectedBox != null) {
      await _loadBoxData(_selectedBox!);
    } else {
      await _loadAvailableBoxes();
    }
  }

  Future<void> clearBoxData() async {
    if (_selectedBox == null) return;

    try {
      _setLoading(true);
      await _hiveService.clearBox(_selectedBox!);
      await _loadBoxData(_selectedBox!);
    } catch (e) {
      _setError('Erro ao limpar dados da box: ${e.toString()}');
    }
  }

  // Statistics
  Map<String, dynamic> getDataStatistics() {
    if (!hasData) {
      return {
        'totalRecords': 0,
        'fieldCount': 0,
        'fields': <String>[],
      };
    }

    return {
      'totalRecords': _tableData.totalRecords,
      'filteredRecords': _tableData.filteredRecordCount,
      'fieldCount': _tableData.fields.length,
      'fields': _tableData.sortedFields,
      'isFiltered': _tableData.isFiltered,
      'selectedBox': _selectedBox?.displayName ?? '',
    };
  }

  BoxInfo? getBoxInfo(BoxType boxType) {
    try {
      return _availableBoxes.firstWhere((box) => box.type == boxType);
    } catch (e) {
      return null;
    }
  }

  // Validation
  bool canExport() {
    return hasData && 
           _selectedBox != null && 
           _tableData.totalRecords <= DatabaseConstants.maxExportRecords;
  }

  bool isValidForDisplay() {
    return hasData && 
           _tableData.totalRecords <= DatabaseConstants.maxRecordsToDisplay &&
           _tableData.fields.length <= DatabaseConstants.maxFieldsToDisplay;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

}
