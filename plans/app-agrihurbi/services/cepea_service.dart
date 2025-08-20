// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';

class CommodityPrice {
  final String name;
  final double price;
  final String unit;
  final double changePercent;
  final DateTime lastUpdate;

  CommodityPrice({
    required this.name,
    required this.price,
    required this.unit,
    required this.changePercent,
    required this.lastUpdate,
  });

  bool get isUp => changePercent >= 0;

  String get formattedPrice =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  String get formattedChange =>
      '${isUp ? '+' : ''}${changePercent.toStringAsFixed(2).replaceAll('.', ',')}%';
}

class CepeaService {
  // Singleton pattern
  static final CepeaService _instance = CepeaService._internal();
  factory CepeaService() => _instance;
  CepeaService._internal();

  // Simulando dados iniciais baseados em valores reais
  final Map<String, CommodityPrice> _initialData = {
    'Soja': CommodityPrice(
      name: 'Soja',
      price: 175.30,
      unit: 'saca 60kg',
      changePercent: 0.75,
      lastUpdate: DateTime.now(),
    ),
    'Milho': CommodityPrice(
      name: 'Milho',
      price: 75.45,
      unit: 'saca 60kg',
      changePercent: -0.32,
      lastUpdate: DateTime.now(),
    ),
    'Arroz': CommodityPrice(
      name: 'Arroz',
      price: 92.65,
      unit: 'saca 50kg',
      changePercent: 1.20,
      lastUpdate: DateTime.now(),
    ),
    'Feijão': CommodityPrice(
      name: 'Feijão',
      price: 320.10,
      unit: 'saca 60kg',
      changePercent: -0.18,
      lastUpdate: DateTime.now(),
    ),
    'Café': CommodityPrice(
      name: 'Café',
      price: 1250.80,
      unit: 'saca 60kg',
      changePercent: 2.15,
      lastUpdate: DateTime.now(),
    ),
  };

  // Dados atualizados
  final Map<String, CommodityPrice> _currentData = {};

  // Controlador para emitir atualizações
  final StreamController<Map<String, CommodityPrice>> _controller =
      StreamController<Map<String, CommodityPrice>>.broadcast();

  // Stream para que os widgets possam ouvir atualizações
  Stream<Map<String, CommodityPrice>> get pricesStream => _controller.stream;

  // Última atualização
  DateTime _lastUpdate = DateTime.now();
  DateTime get lastUpdate => _lastUpdate;

  // Inicializar o serviço
  void init() {
    _currentData.addAll(_initialData);
    _controller.add(_currentData);

    // Em produção, programaria atualizações periódicas
    Timer.periodic(const Duration(minutes: 5), (_) {
      fetchLatestPrices();
    });
  }

  // Método para buscar preços mais recentes
  // Em produção, faria uma chamada HTTP real
  Future<void> fetchLatestPrices() async {
    try {
      // Simulando uma chamada assíncrona
      await Future.delayed(const Duration(seconds: 1));

      // Em produção, isso seria algo como:
      /*
      final response = await http.get(
        Uri.parse('https://api.exemplo.com/cepea/cotacoes'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Parse dos dados...
      }
      */

      // Simulando atualizações aleatórias para fins de demonstração
      _simulateRandomUpdates();

      _lastUpdate = DateTime.now();
      _controller.add(_currentData);

      if (kDebugMode) {
        debugPrint('Preços atualizados em: $_lastUpdate');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao atualizar preços: $e');
      }
    }
  }

  // Simula variações de preço para demonstração
  void _simulateRandomUpdates() {
    final random = Random();

    _currentData.forEach((key, value) {
      // Simula uma variação de preço de até 1,5%
      final variation = (random.nextDouble() * 3 - 1.5) / 100;
      final newPrice = value.price * (1 + variation);

      // Simula uma variação na mudança percentual
      final changeVariation = random.nextDouble() * 0.5 - 0.25;
      final newChange = value.changePercent + changeVariation;

      _currentData[key] = CommodityPrice(
        name: value.name,
        price: newPrice,
        unit: value.unit,
        changePercent: newChange,
        lastUpdate: DateTime.now(),
      );
    });
  }

  // Retorna uma cópia dos dados atuais
  Map<String, CommodityPrice> getCurrentPrices() {
    return Map.from(_currentData);
  }

  // Liberar recursos quando não for mais necessário
  void dispose() {
    _controller.close();
  }
}
