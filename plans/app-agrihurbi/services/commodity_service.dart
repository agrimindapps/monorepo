// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// Project imports:
import '../models/commodity_model.dart';

class CommodityService extends GetxService {
  static CommodityService get instance => Get.find<CommodityService>();

  final RxBool _isLoading = false.obs;
  final RxList<CommodityModel> _commodities = <CommodityModel>[].obs;
  final RxString _errorMessage = ''.obs;
  final Rx<CommodityMarketStatus?> _marketStatus =
      Rx<CommodityMarketStatus?>(null);

  Timer? _updateTimer;
  String? _apiKey;
  String? _baseUrl;

  bool get isLoading => _isLoading.value;
  List<CommodityModel> get commodities => _commodities;
  String get errorMessage => _errorMessage.value;
  CommodityMarketStatus? get marketStatus => _marketStatus.value;

  final List<CommodityCategory> _categories = [
    CommodityCategory(
      id: 'graos',
      name: 'Grãos',
      description: 'Soja, Milho, Arroz, Feijão',
      icon: '🌾',
      commodityIds: ['SOJA', 'MILHO', 'ARROZ', 'FEIJAO'],
    ),
    CommodityCategory(
      id: 'cafe_acucar',
      name: 'Café e Açúcar',
      description: 'Café Arábica, Açúcar Cristal',
      icon: '☕',
      commodityIds: ['CAFE', 'ACUCAR'],
    ),
    CommodityCategory(
      id: 'carnes',
      name: 'Carnes',
      description: 'Boi Gordo, Suíno, Frango',
      icon: '🥩',
      commodityIds: ['BOI_GORDO', 'SUINO', 'FRANGO'],
    ),
  ];

  List<CommodityCategory> get categories => _categories;

  void initialize({String? apiKey, String? baseUrl}) {
    _apiKey = apiKey;
    _baseUrl = baseUrl;
    _initializeMockData();
    _startPeriodicUpdates();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    final mockCommodities = [
      CommodityModel(
        id: 'SOJA',
        name: 'Soja',
        symbol: 'SOJA',
        currentPrice: 175.30,
        previousPrice: 174.18,
        unit: 'saca 60kg',
        category: 'graos',
        lastUpdate: now,
        exchange: 'CEPEA',
        history: _generateMockHistory(175.30),
        metadata: {'region': 'Paraná', 'quality': 'Standard'},
      ),
      CommodityModel(
        id: 'MILHO',
        name: 'Milho',
        symbol: 'MILHO',
        currentPrice: 75.45,
        previousPrice: 75.69,
        unit: 'saca 60kg',
        category: 'graos',
        lastUpdate: now,
        exchange: 'CEPEA',
        history: _generateMockHistory(75.45),
        metadata: {'region': 'Mato Grosso', 'quality': 'Standard'},
      ),
      CommodityModel(
        id: 'CAFE',
        name: 'Café Arábica',
        symbol: 'CAFE',
        currentPrice: 1250.80,
        previousPrice: 1223.45,
        unit: 'saca 60kg',
        category: 'cafe_acucar',
        lastUpdate: now,
        exchange: 'CEPEA',
        history: _generateMockHistory(1250.80),
        metadata: {'region': 'Minas Gerais', 'quality': 'Tipo 6'},
      ),
      CommodityModel(
        id: 'BOI_GORDO',
        name: 'Boi Gordo',
        symbol: 'BOI',
        currentPrice: 320.15,
        previousPrice: 318.92,
        unit: '@',
        category: 'carnes',
        lastUpdate: now,
        exchange: 'CEPEA',
        history: _generateMockHistory(320.15),
        metadata: {'region': 'São Paulo', 'weight': '15@'},
      ),
      CommodityModel(
        id: 'ARROZ',
        name: 'Arroz',
        symbol: 'ARROZ',
        currentPrice: 92.65,
        previousPrice: 91.54,
        unit: 'saca 50kg',
        category: 'graos',
        lastUpdate: now,
        exchange: 'CEPEA',
        history: _generateMockHistory(92.65),
        metadata: {'region': 'Rio Grande do Sul', 'quality': 'Tipo 1'},
      ),
    ];

    _commodities.value = mockCommodities;
    _marketStatus.value = CommodityMarketStatus(
      isOpen: _isMarketOpen(),
      status: _getMarketStatusText(),
      nextOpen: _getNextMarketOpen(),
      nextClose: _getNextMarketClose(),
      timezone: 'America/Sao_Paulo',
    );
  }

  CommodityPriceHistory _generateMockHistory(double currentPrice) {
    final random = Random();
    final now = DateTime.now();

    List<CommodityPricePoint> daily = [];
    for (int i = 30; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final basePrice = currentPrice * (1 + (random.nextDouble() - 0.5) * 0.1);
      const variation = 0.02;

      daily.add(CommodityPricePoint(
        date: date,
        open: basePrice * (1 + (random.nextDouble() - 0.5) * variation),
        high: basePrice * (1 + random.nextDouble() * variation),
        low: basePrice * (1 - random.nextDouble() * variation),
        close: basePrice,
        volume: random.nextDouble() * 1000000,
      ));
    }

    return CommodityPriceHistory(
      daily: daily,
      weekly: [],
      monthly: [],
      stats: CommodityStats(
        high52Week: currentPrice * 1.25,
        low52Week: currentPrice * 0.75,
        average30Day: currentPrice * 0.98,
        volatility: 0.15,
        volume30Day: 500000,
      ),
    );
  }

  void _startPeriodicUpdates() {
    _updateTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      fetchLatestPrices();
    });
  }

  Future<void> fetchLatestPrices() async {
    if (_isLoading.value) return;

    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      if (_apiKey != null && _baseUrl != null) {
        await _fetchFromAPI();
      } else {
        await _simulateUpdates();
      }
    } catch (e) {
      _errorMessage.value = 'Erro ao atualizar cotações: $e';
      if (kDebugMode) {
        debugPrint('Erro ao buscar cotações: $e');
      }
    } finally {
      _isLoading.value = false;
      _updateMarketStatus();
    }
  }

  Future<void> _fetchFromAPI() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/commodities'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _parseCommodityData(data);
    } else {
      throw Exception('Falha na API: ${response.statusCode}');
    }
  }

  void _parseCommodityData(Map<String, dynamic> data) {
    // Implementar parsing específico da API escolhida
    // Exemplo genérico:
    if (data['commodities'] != null) {
      final commodityList = data['commodities'] as List;
      _commodities.value =
          commodityList.map((json) => CommodityModel.fromJson(json)).toList();
    }
  }

  Future<void> _simulateUpdates() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final random = Random();
    final updatedCommodities = _commodities.map((commodity) {
      const maxVariation = 0.04;
      final variation = (random.nextDouble() - 0.5) * maxVariation; // ±2%
      final newPrice = commodity.currentPrice * (1 + variation);

      return commodity.copyWith(
        previousPrice: commodity.currentPrice,
        currentPrice: newPrice,
        lastUpdate: DateTime.now(),
      );
    }).toList();

    _commodities.value = updatedCommodities;
  }

  void _updateMarketStatus() {
    _marketStatus.value = CommodityMarketStatus(
      isOpen: _isMarketOpen(),
      status: _getMarketStatusText(),
      nextOpen: _getNextMarketOpen(),
      nextClose: _getNextMarketClose(),
      timezone: 'America/Sao_Paulo',
    );
  }

  bool _isMarketOpen() {
    final now = DateTime.now();
    final hour = now.hour;
    final weekday = now.weekday;

    // Mercado aberto de segunda a sexta, das 9h às 17h
    return weekday >= 1 && weekday <= 5 && hour >= 9 && hour < 17;
  }

  String _getMarketStatusText() {
    if (_isMarketOpen()) {
      return 'Mercado Aberto';
    } else {
      final now = DateTime.now();
      if (now.weekday > 5) {
        return 'Mercado Fechado - Final de Semana';
      } else if (now.hour < 9) {
        return 'Mercado Fechado - Pré-abertura';
      } else {
        return 'Mercado Fechado - Pós-fechamento';
      }
    }
  }

  DateTime? _getNextMarketOpen() {
    final now = DateTime.now();
    DateTime nextOpen;

    if (now.weekday == 6) {
      // Sábado
      nextOpen = now
          .add(const Duration(days: 2))
          .copyWith(hour: 9, minute: 0, second: 0, millisecond: 0);
    } else if (now.weekday == 7) {
      // Domingo
      nextOpen = now
          .add(const Duration(days: 1))
          .copyWith(hour: 9, minute: 0, second: 0, millisecond: 0);
    } else if (now.hour >= 17) {
      // Após fechamento
      nextOpen = now
          .add(const Duration(days: 1))
          .copyWith(hour: 9, minute: 0, second: 0, millisecond: 0);
    } else if (now.hour < 9) {
      // Antes da abertura
      nextOpen = now.copyWith(hour: 9, minute: 0, second: 0, millisecond: 0);
    } else {
      return null; // Mercado já aberto
    }

    return nextOpen;
  }

  DateTime? _getNextMarketClose() {
    if (!_isMarketOpen()) return null;
    return DateTime.now()
        .copyWith(hour: 17, minute: 0, second: 0, millisecond: 0);
  }

  List<CommodityModel> getCommoditiesByCategory(String categoryId) {
    return _commodities.where((c) => c.category == categoryId).toList();
  }

  CommodityModel? getCommodityById(String id) {
    return _commodities.firstWhereOrNull((c) => c.id == id);
  }

  List<CommodityModel> getTopMovers() {
    final sorted = List<CommodityModel>.from(_commodities);
    sorted
        .sort((a, b) => b.changePercent.abs().compareTo(a.changePercent.abs()));
    return sorted.take(3).toList();
  }

  List<CommodityModel> getGainers() {
    return _commodities.where((c) => c.isUp).toList()
      ..sort((a, b) => b.changePercent.compareTo(a.changePercent));
  }

  List<CommodityModel> getLosers() {
    return _commodities.where((c) => c.isDown).toList()
      ..sort((a, b) => a.changePercent.compareTo(b.changePercent));
  }

  String getCommodityIcon(String categoryId) {
    return _categories.firstWhereOrNull((c) => c.id == categoryId)?.icon ??
        '📊';
  }

  @override
  void onClose() {
    _updateTimer?.cancel();
    super.onClose();
  }

  // Método para configurar alertas de preço (futuro)
  void setupPriceAlert(String commodityId, double targetPrice, bool isAbove) {
    // Implementar sistema de alertas
    if (kDebugMode) {
      debugPrint(
          'Alerta configurado para $commodityId: ${isAbove ? 'acima' : 'abaixo'} de R\$ $targetPrice');
    }
  }

  // Método para exportar dados (futuro)
  Future<String> exportData(
      {required String format, required List<String> commodityIds}) async {
    // Implementar exportação em CSV, Excel, etc.
    return 'Dados exportados em formato $format';
  }
}

extension DateTimeExtension on DateTime {
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}
