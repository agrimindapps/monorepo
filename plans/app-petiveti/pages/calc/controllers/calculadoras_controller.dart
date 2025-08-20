// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/base_state_manager.dart';
import '../condicao_corporal/index.dart';
import '../conversao/index.dart';
import '../diabetes_insulina/index.dart';
import '../dieta_caseira/index.dart';
import '../dosagem_anestesico/index.dart';
import '../dosagem_medicamento/index.dart';
import '../fluidoterapia/index.dart';
import '../gestacao/index.dart';
import '../gestacao_parto/index.dart';
import '../hidratacao_fluidoterapia/index.dart';
import '../idade_animal/index.dart';
import '../necessidade_calorias/index.dart';
import '../peso_ideal_condicao_corporal/index.dart';

/// Modelo para informações de cálculo
class CalculoInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget Function() pageBuilder;
  final bool isInDevelopment;
  final String category;

  CalculoInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.pageBuilder,
    this.isInDevelopment = false,
    required this.category,
  });
}

/// Controller para gerenciar estado da página de calculadoras
class CalculadorasController extends BaseStateManager with ListStateMixin<CalculoInfo> {
  // Estado reativo para categoria atual
  final _currentCategory = 'Todas'.obs;
  
  // Lista de categorias disponíveis
  final List<String> _categorias = [
    'Todas',
    'Medicação',
    'Nutrição',
    'Gestação',
    'Diagnóstico'
  ];

  // Getters
  String get currentCategory => _currentCategory.value;
  List<String> get categorias => _categorias;

  @override
  Future<void> initialize() async {
    await loadData(
      () async {
        final calculadoras = _initializeCalculadoras();
        setItems(calculadoras);
        return calculadoras;
      },
      errorMessage: 'Erro ao inicializar calculadoras',
      isEmpty: false,
    );
  }

  @override
  Future<void> refresh() async {
    // Para calculadoras, não há necessidade de refresh já que são estáticas
    await initialize();
  }

  /// Atualiza a categoria selecionada
  void setCategory(String category) {
    _currentCategory.value = category;
    setFilter(category);
  }

  /// Implementação do filtro de calculadoras
  @override
  List<CalculoInfo> filterItems(List<CalculoInfo> items, String searchQuery, String filter) {
    var filteredItems = <CalculoInfo>[];

    // Filtrar por categoria
    if (filter == 'Todas' || filter.isEmpty) {
      filteredItems = List.from(items);
    } else {
      filteredItems = items.where((item) => item.category == filter).toList();
    }

    // Filtrar por query de busca se necessário
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredItems = filteredItems.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.subtitle.toLowerCase().contains(query);
      }).toList();
    }

    return filteredItems;
  }

  /// Navega para a página da calculadora
  void navigateToCalculadora(CalculoInfo calculo) {
    if (calculo.isInDevelopment) {
      Get.snackbar(
        'Em Desenvolvimento',
        'Esta calculadora ainda está sendo desenvolvida',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.to(() => calculo.pageBuilder());
  }

  /// Inicializa todas as calculadoras disponíveis
  List<CalculoInfo> _initializeCalculadoras() {
    return [
      // Calculadoras de Medicação
      CalculoInfo(
        title: 'Dosagem de Medicamentos',
        subtitle: 'Cálculo de doses de medicamentos gerais',
        icon: Icons.medication_liquid,
        color: Colors.blue.shade700,
        category: 'Medicação',
        pageBuilder: () => const DosagemMedicamentosPage(),
      ),
      CalculoInfo(
        title: 'Dosagem de Anestésicos',
        subtitle: 'Cálculo de doses de medicamentos anestésicos',
        icon: Icons.medical_services,
        color: Colors.purple.shade700,
        category: 'Medicação',
        pageBuilder: () => const DosagemAnestesicosPage(),
      ),
      CalculoInfo(
        title: 'Fluidoterapia',
        subtitle: 'Cálculo de taxa de fluidoterapia',
        icon: Icons.water_drop,
        color: Colors.cyan.shade700,
        category: 'Medicação',
        pageBuilder: () => const FluidoterapiaPage(),
      ),
      CalculoInfo(
        title: 'Diabetes e Insulina',
        subtitle: 'Cálculo de dosagem de insulina e monitoramento',
        icon: Icons.medication,
        color: Colors.indigo.shade700,
        category: 'Medicação',
        pageBuilder: () => const DiabetesInsulinaPage(),
      ),
      CalculoInfo(
        title: 'Hidratação e Fluidoterapia',
        subtitle: 'Cálculo de necessidades de hidratação',
        icon: Icons.opacity,
        color: Colors.teal.shade700,
        category: 'Medicação',
        pageBuilder: () => const CalcHidratacaoFluidoterapiaPage(),
      ),

      // Calculadoras de Nutrição
      CalculoInfo(
        title: 'Dieta Caseira',
        subtitle: 'Cálculo de nutrientes para dieta caseira',
        icon: Icons.restaurant,
        color: Colors.orange.shade700,
        category: 'Nutrição',
        pageBuilder: () => const DietaCaseiraPage(),
      ),
      CalculoInfo(
        title: 'Necessidades Calóricas',
        subtitle: 'Cálculo de necessidades energéticas diárias',
        icon: Icons.whatshot,
        color: Colors.red.shade700,
        category: 'Nutrição',
        pageBuilder: () => const CalcNecessidadesCaloricas(),
      ),
      CalculoInfo(
        title: 'Peso Ideal e Condição Corporal',
        subtitle: 'Estimativa de peso ideal baseado na condição corporal',
        icon: Icons.fitness_center,
        color: Colors.green.shade700,
        category: 'Nutrição',
        pageBuilder: () => const CalcPesoIdealCondicaoCorporalPage(),
      ),

      // Calculadoras de Gestação
      CalculoInfo(
        title: 'Gestação',
        subtitle: 'Cálculo de período gestacional',
        icon: Icons.pregnant_woman,
        color: Colors.pink.shade700,
        category: 'Gestação',
        pageBuilder: () => const GestacaoPage(),
      ),
      CalculoInfo(
        title: 'Gestação e Parto',
        subtitle: 'Estimativa de data de parto e gestação',
        icon: Icons.child_care,
        color: Colors.purple.shade700,
        category: 'Gestação',
        pageBuilder: () => const CalcGestacaoPartoPage(),
      ),

      // Calculadoras de Diagnóstico
      CalculoInfo(
        title: 'Idade Animal',
        subtitle: 'Conversão da idade do animal para idade humana',
        icon: Icons.pets,
        color: Colors.amber.shade700,
        category: 'Diagnóstico',
        pageBuilder: () => const CalcIdadeAnimalPage(),
      ),
      CalculoInfo(
        title: 'Condição Corporal',
        subtitle: 'Avaliação da condição corporal do animal',
        icon: Icons.monitor_weight,
        color: Colors.brown.shade700,
        category: 'Diagnóstico',
        pageBuilder: () => const CalcCondicaoCorporalPage(),
      ),
      CalculoInfo(
        title: 'Conversão de Unidades',
        subtitle: 'Converter entre diferentes unidades de medida',
        icon: Icons.swap_horiz,
        color: Colors.deepPurple.shade700,
        category: 'Diagnóstico',
        pageBuilder: () => const ConversaoPage(),
      ),
    ];
  }

  /// Calcula o número de colunas baseado na largura da tela
  int getColumnCount(double screenWidth) {
    if (screenWidth >= 900) {
      return 4;
    } else if (screenWidth >= 600) {
      return 3;
    } else {
      return 2;
    }
  }

  /// Obtém estatísticas das calculadoras
  Map<String, int> getCalculadorasStats() {
    final stats = <String, int>{};
    
    for (final categoria in _categorias) {
      if (categoria == 'Todas') continue;
      
      final count = items.where((item) => item.category == categoria).length;
      stats[categoria] = count;
    }
    
    stats['Total'] = items.length;
    return stats;
  }
}
