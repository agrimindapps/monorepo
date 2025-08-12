// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../repository/veiculos_repository.dart';
import '../../widgets/gasometer_header_widget.dart';
import '../../widgets/veiculosSelect_widget.dart';
import '../cadastros/abastecimento_page/controller/abastecimento_page_controller.dart';
import '../cadastros/odometro_page/services/odometro_page_service.dart';
import '../cadastros/veiculos_page/controller/veiculos_page_controller.dart';

class EstatisticasVeiculosPage extends StatefulWidget {
  const EstatisticasVeiculosPage({super.key});

  @override
  State<EstatisticasVeiculosPage> createState() =>
      _EstatisticasVeiculosPageState();
}

class _EstatisticasVeiculosPageState extends State<EstatisticasVeiculosPage> {
  // Utilizando GetX para obter os controllers registrados
  late final AbastecimentoPageController _abastecimentosController;
  late final OdometroPageService _odometroService;
  late final VeiculosPageController _veiculosController;

  Map<String, Map<String, double>> abastecimentos = {
    'esteMes': {
      'custo': 0,
      'litros': 0,
    },
    'mesAnterior': {
      'custo': 0,
      'litros': 0,
    },
    'esteAno': {
      'custo': 0,
      'litros': 0,
    },
    'anoAnterior': {
      'custo': 0,
      'litros': 0,
    }
  };

  Map<String, Map<String, double>> odometro = {
    'esteMes': {
      'inicial': 0,
      'final': 0,
      'diferenca': 0,
    },
    'mesAnterior': {
      'inicial': 0,
      'final': 0,
      'diferenca': 0,
    },
    'esteAno': {
      'inicial': 0,
      'final': 0,
      'diferenca': 0,
    },
    'anoAnterior': {
      'inicial': 0,
      'final': 0,
      'diferenca': 0,
    }
  };

  @override
  void initState() {
    super.initState();
    // Inicializa os controllers de forma segura
    _inicializarControllers();
  }

  void _inicializarControllers() {
    try {
      // Tenta encontrar os controllers existentes, senão cria novos
      try {
        _abastecimentosController = Get.find<AbastecimentoPageController>();
      } catch (e) {
        Get.put(AbastecimentoPageController());
        _abastecimentosController = Get.find<AbastecimentoPageController>();
      }

      try {
        _odometroService = Get.find<OdometroPageService>();
      } catch (e) {
        Get.put(OdometroPageService());
        _odometroService = Get.find<OdometroPageService>();
      }

      try {
        _veiculosController = Get.find<VeiculosPageController>();
      } catch (e) {
        Get.put(VeiculosPageController());
        _veiculosController = Get.find<VeiculosPageController>();
      }

      // Always reset to zero first, then load data
      _resetStatistics();
      setState(() {});

      // Aguardar um pouco para o VeiculoDropdownWidget completar sua inicialização
      // antes de carregar os dados
      Future.delayed(const Duration(milliseconds: 300), () {
        carregaDados();
      });
    } catch (e) {
      debugPrint('Erro ao inicializar controllers: $e');

      // Show zero values even when controllers fail
      _resetStatistics();
      setState(() {});

      // Retry after delay
      Future.delayed(
          const Duration(milliseconds: 500), _inicializarControllers);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void carregaDados() async {
    // Carrega o ID do veículo selecionado do SharedPreferences
    final veiculosRepo = VeiculosRepository();
    String id = await veiculosRepo.getSelectedVeiculoId();

    if (id.isEmpty) {
      // Reset to zero values when no vehicle is selected
      _resetStatistics();
      setState(() {});
      return;
    }

    try {
      // Carrega dados usando o ID do veículo selecionado
      final futures = await Future.wait([
        _abastecimentosController.getAbastecimentosEstatisticas(),
        _odometroService.getEstatisticas(),
      ]);

      abastecimentos = futures[0];
      odometro = futures[1];
    } catch (e) {
      debugPrint('Erro ao carregar dados das estatísticas: $e');
      _resetStatistics();
    }

    setState(() {});
  }

  void _resetStatistics() {
    abastecimentos = {
      'esteMes': {'custo': 0, 'litros': 0},
      'mesAnterior': {'custo': 0, 'litros': 0},
      'esteAno': {'custo': 0, 'litros': 0},
      'anoAnterior': {'custo': 0, 'litros': 0}
    };

    odometro = {
      'esteMes': {'inicial': 0, 'final': 0, 'diferenca': 0},
      'mesAnterior': {'inicial': 0, 'final': 0, 'diferenca': 0},
      'esteAno': {'inicial': 0, 'final': 0, 'diferenca': 0},
      'anoAnterior': {'inicial': 0, 'final': 0, 'diferenca': 0}
    };
  }

  @override
  Widget build(BuildContext context) {
    // Always show the UI with statistics (even if zero)
    // Only show loading if it's the very first attempt and controllers are not yet available

    final isWideScreen = MediaQuery.of(context).size.width > 600;

    final statCards = [
      _StatCardConfig(
        title: 'Abastecimento',
        icon: Icons.local_gas_station,
        color: Colors.blue,
        data: {
          'este_ano': abastecimentos['esteAno']?['custo'] ?? 0,
          'ano_anterior': abastecimentos['anoAnterior']?['custo'] ?? 0,
          'este_mes': abastecimentos['esteMes']?['custo'] ?? 0,
          'mes_anterior': abastecimentos['mesAnterior']?['custo'] ?? 0,
        },
        prefix: 'R\$',
        decimalPlaces: 2,
      ),
      _StatCardConfig(
        title: 'Combustível',
        icon: Icons.local_gas_station,
        color: Colors.green,
        data: {
          'este_ano': abastecimentos['esteAno']?['litros'] ?? 0,
          'ano_anterior': abastecimentos['anoAnterior']?['litros'] ?? 0,
          'este_mes': abastecimentos['esteMes']?['litros'] ?? 0,
          'mes_anterior': abastecimentos['mesAnterior']?['litros'] ?? 0,
        },
        suffix: 'L',
        decimalPlaces: 1,
      ),
      // _StatCardConfig(
      //   title: 'Despesas',
      //   icon: Icons.attach_money,
      //   color: Colors.orange,
      //   data: {
      //     'este_ano': despesas['esteAno'] ?? 0,
      //     'ano_anterior': despesas['anoAnterior'] ?? 0,
      //     'este_mes': despesas['esteMes'] ?? 0,
      //     'mes_anterior': despesas['mesAnterior'] ?? 0,
      //   },
      //   prefix: 'R\$',
      //   decimalPlaces: 2,
      // ),
      _StatCardConfig(
        title: 'Distância',
        icon: Icons.speed,
        color: Colors.purple,
        data: {
          'este_ano': odometro['esteAno']?['diferenca'] ?? 0,
          'ano_anterior': odometro['anoAnterior']?['diferenca'] ?? 0,
          'este_mes': odometro['esteMes']?['diferenca'] ?? 0,
          'mes_anterior': odometro['mesAnterior']?['diferenca'] ?? 0,
        },
        suffix: ' km',
        decimalPlaces: 0,
      ),
    ];

    return Obx(() => Scaffold(
          backgroundColor: ThemeManager().isDark.value
              ? const Color(0xFF1A1A2E)
              : Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                // Header fixo
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1120,
                    ),
                    child: _buildHeader(),
                  ),
                ),

                // Conteúdo com scroll
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: SizedBox(
                          width: 1120,
                          child: Column(
                            children: [
                              VeiculoDropdownWidget(
                                onVeiculoSelected: (value, animal) {
                                  // Aguarda um pequeno delay para garantir que o controller seja atualizado
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    carregaDados();
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              if (isWideScreen)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          _buildStatCard(statCards[0]),
                                          _buildStatCard(statCards[2]),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          _buildStatCard(statCards[1]),
                                          // _buildStatCard(statCards[3]),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children:
                                      statCards.map(_buildStatCard).toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildHeader() {
    return const GasometerHeaderWidget(
      title: 'Estatísticas',
      subtitle: 'Acompanhe o desempenho dos seus veículos',
      icon: Icons.bar_chart,
      showBackButton: false,
    );
  }

  Widget _buildStatCardOld({
    required String title,
    required IconData icon,
    required Color color,
    required Map<String, dynamic> data,
    String? prefix,
    String? suffix,
    int decimalPlaces = 0,
  }) {
    final formatCurrency = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: prefix ?? '',
      decimalDigits: decimalPlaces,
    );

    final anoAtualValue = data['este_ano'];
    final anoAnteriorValue = data['ano_anterior'];
    final mesAtualValue = data['este_mes'];
    final mesAnteriorValue = data['mes_anterior'];

    final anoPercentChange =
        ((anoAtualValue - anoAnteriorValue) / anoAnteriorValue) * 100;
    final mesPercentChange =
        ((mesAtualValue - mesAnteriorValue) / mesAnteriorValue) * 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: ShadcnStyle.borderRadius,
      ),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ShadcnStyle.borderRadius.topLeft.x),
                  topRight:
                      Radius.circular(ShadcnStyle.borderRadius.topRight.x),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon,
                      color:
                          ThemeManager().isDark.value ? Colors.white : color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      // color: ShadcnStyle.textColor,
                    ),
                  ),
                ],
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Column(
                children: [
                  // Yearly stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatTile(
                          label: 'Este Ano',
                          value: prefix == null && suffix == null
                              ? anoAtualValue.toStringAsFixed(decimalPlaces)
                              : formatCurrency.format(anoAtualValue) +
                                  (suffix ?? ''),
                          trend: anoPercentChange,
                          isPositiveBetter: title !=
                              'Despesas', // For expenses, lower is better
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatTile(
                          label: 'Ano Anterior',
                          value: prefix == null && suffix == null
                              ? anoAnteriorValue.toStringAsFixed(decimalPlaces)
                              : formatCurrency.format(anoAnteriorValue) +
                                  (suffix ?? ''),
                          showTrend: false,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // Monthly stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatTile(
                          label: 'Este Mês',
                          value: prefix == null && suffix == null
                              ? mesAtualValue.toStringAsFixed(decimalPlaces)
                              : formatCurrency.format(mesAtualValue) +
                                  (suffix ?? ''),
                          trend: mesPercentChange,
                          isPositiveBetter: title != 'Despesas',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatTile(
                          label: 'Mês Anterior',
                          value: prefix == null && suffix == null
                              ? mesAnteriorValue.toStringAsFixed(decimalPlaces)
                              : formatCurrency.format(mesAnteriorValue) +
                                  (suffix ?? ''),
                          showTrend: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    double? trend,
    bool showTrend = true,
    bool isPositiveBetter = true,
  }) {
    final hasValue = value != '0' && value.isNotEmpty;
    final hasTrend = trend != null && !trend.isNaN && trend.isFinite;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  // color: ShadcnStyle.mutedTextColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasValue ? value : '-',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  // color: ShadcnStyle.textColor,
                ),
              ),
              if (showTrend && hasTrend) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      trend > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: (trend > 0) == isPositiveBetter
                          ? ShadcnStyle.primaryColor
                          : Colors.red,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${trend.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: (trend > 0) == isPositiveBetter
                            ? ShadcnStyle.primaryColor
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Update _buildStatCard to accept _StatCardConfig
  Widget _buildStatCard(_StatCardConfig config) {
    return _buildStatCardOld(
      title: config.title,
      icon: config.icon,
      color: config.color,
      data: config.data,
      prefix: config.prefix,
      suffix: config.suffix,
      decimalPlaces: config.decimalPlaces,
    );
  }
}

// Add this class at the bottom of the file
class _StatCardConfig {
  final String title;
  final IconData icon;
  final Color color;
  final Map<String, dynamic> data;
  final String? prefix;
  final String? suffix;
  final int decimalPlaces;

  _StatCardConfig({
    required this.title,
    required this.icon,
    required this.color,
    required this.data,
    this.prefix,
    this.suffix,
    this.decimalPlaces = 0,
  });
}
