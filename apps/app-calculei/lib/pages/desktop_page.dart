// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import 'calc/financeiro/custo_efetivo_total/index.dart';
import 'calc/financeiro/custo_real_credito/index.dart';
import 'calc/financeiro/independencia_financeira/index.dart';
import 'calc/financeiro/juros_compostos/index.dart';
import 'calc/financeiro/orcamento_regra_3050/index.dart';
import 'calc/financeiro/reserva_emergencia/index.dart';
import 'calc/financeiro/valor_futuro/index.dart';
import 'calc/financeiro/vista_vs_parcelado/index.dart';
import 'calc/trabalhistas/decimo_terceiro/index.dart';
import 'calc/trabalhistas/ferias/index.dart';
import 'calc/trabalhistas/horas_extras/index.dart';
import 'calc/trabalhistas/salario_liquido/index.dart';
import 'calc/trabalhistas/seguro_desemprego/index.dart';
import 'login_web_page.dart';
import 'promo_page.dart';

// Calculadoras Trabalhistas

class DesktopPageMain extends StatelessWidget {
  const DesktopPageMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculei'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CalculeiLoginWebPage(),
                ),
              );
            },
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Calculei',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cálculos financeiros e trabalhistas completos para desktop',
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: AlignedGridView.count(
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      // Lista de calculadoras com cores personalizadas e status de disponibilidade
                      final calculadoras = [
                        // Calculadoras Financeiras
                        {
                          'title': 'Juros Compostos',
                          'icon': Icons.trending_up,
                          'type': 'juros_compostos',
                          'color': Colors.blue.shade700,
                          'secondaryColor': Colors.blue.shade200,
                          'available': true
                        },
                        {
                          'title': 'Retorno de Investimento',
                          'icon': Icons.insert_chart,
                          'type': 'roi',
                          'color': Colors.orange.shade700,
                          'secondaryColor': Colors.orange.shade200,
                          'available': true
                        },
                        {
                          'title': 'Orçamento',
                          'icon': Icons.attach_money,
                          'type': 'orcamento',
                          'color': Colors.teal.shade700,
                          'secondaryColor': Colors.teal.shade200,
                          'available': true
                        },
                        {
                          'title': 'Reserva de Emergência',
                          'icon': Icons.shield,
                          'type': 'reserva_emergencia',
                          'color': Colors.redAccent.shade700,
                          'secondaryColor': Colors.redAccent.shade200,
                          'available': true
                        },
                        {
                          'title': 'Vista vs. Parcelado',
                          'icon': Icons.compare_arrows,
                          'type': 'vista_vs_parcelado',
                          'color': Colors.deepPurple.shade700,
                          'secondaryColor': Colors.deepPurple.shade200,
                          'available': true
                        },
                        {
                          'title': 'Custo Efetivo Total',
                          'icon': Icons.trending_up,
                          'type': 'custo_efetivo_total',
                          'color': Colors.green.shade700,
                          'secondaryColor': Colors.green.shade200,
                          'available': true
                        },
                        {
                          'title': 'Custo Real do Crédito',
                          'icon': Icons.credit_card,
                          'type': 'custo_real_credito',
                          'color': Colors.purple.shade700,
                          'secondaryColor': Colors.purple.shade200,
                          'available': true
                        },
                        {
                          'title': 'Independência Financeira',
                          'icon': Icons.auto_graph,
                          'type': 'independencia_financeira',
                          'color': Colors.amber.shade700,
                          'secondaryColor': Colors.amber.shade200,
                          'available': true
                        },
                        // Calculadoras Trabalhistas
                        {
                          'title': 'Décimo Terceiro',
                          'icon': Icons.card_giftcard,
                          'type': 'decimo_terceiro',
                          'color': Colors.green.shade700,
                          'secondaryColor': Colors.green.shade200,
                          'available': true
                        },
                        {
                          'title': 'Férias',
                          'icon': Icons.beach_access,
                          'type': 'ferias',
                          'color': Colors.cyan.shade700,
                          'secondaryColor': Colors.cyan.shade200,
                          'available': true
                        },
                        {
                          'title': 'Horas Extras',
                          'icon': Icons.access_time,
                          'type': 'horas_extras',
                          'color': Colors.orange.shade700,
                          'secondaryColor': Colors.orange.shade200,
                          'available': true
                        },
                        {
                          'title': 'Salário Líquido',
                          'icon': Icons.account_balance_wallet,
                          'type': 'salario_liquido',
                          'color': Colors.teal.shade700,
                          'secondaryColor': Colors.teal.shade200,
                          'available': true
                        },
                        {
                          'title': 'Seguro-Desemprego',
                          'icon': Icons.shield_outlined,
                          'type': 'seguro_desemprego',
                          'color': Colors.indigo.shade700,
                          'secondaryColor': Colors.indigo.shade200,
                          'available': true
                        },
                        // Página Promocional
                        {
                          'title': 'Landing Page',
                          'icon': Icons.web,
                          'type': 'promo_page',
                          'color': Colors.indigo.shade700,
                          'secondaryColor': Colors.indigo.shade200,
                          'available': true
                        },
                        // Calculadoras em Breve
                        {
                          'title': 'Amortização',
                          'icon': Icons.account_balance,
                          'type': 'amortizacao',
                          'color': Colors.blueGrey.shade700,
                          'secondaryColor': Colors.blueGrey.shade200,
                          'available': false
                        },
                        {
                          'title': 'Conversão de Moedas',
                          'icon': Icons.currency_exchange,
                          'type': 'conversao_moedas',
                          'color': Colors.pink.shade700,
                          'secondaryColor': Colors.pink.shade200,
                          'available': false
                        },
                        {
                          'title': 'Depreciação',
                          'icon': Icons.show_chart,
                          'type': 'depreciacao',
                          'color': Colors.red.shade700,
                          'secondaryColor': Colors.red.shade200,
                          'available': false
                        },
                      ];

                      final calc = calculadoras[index];
                      final bool isAvailable = calc['available'] as bool;

                      return _buildCalculatorCard(
                        context,
                        calc['title'] as String,
                        calc['icon'] as IconData,
                        () {
                          if (isAvailable) {
                            _navigateToCalculator(
                                context, calc['type'] as String);
                          }
                        },
                        primaryColor: calc['color'] as Color,
                        secondaryColor: calc['secondaryColor'] as Color,
                        isAvailable: isAvailable,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculatorCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap,
      {required Color primaryColor,
      required Color secondaryColor,
      required bool isAvailable}) {
    return InkWell(
      onTap: isAvailable ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: isAvailable ? 6 : 2,
        shadowColor: isAvailable
            ? primaryColor.withValues(alpha: 0.4)
            : Colors.grey.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.7,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isAvailable
                    ? [primaryColor.withValues(alpha: 0.8), secondaryColor]
                    : [
                        primaryColor.withValues(alpha: 0.5),
                        secondaryColor.withValues(alpha: 0.7)
                      ],
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 56,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isAvailable)
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: Chip(
                      backgroundColor: Colors.black54,
                      label: Text(
                        'EM BREVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 2, vertical: -8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCalculator(BuildContext context, String calculatorType) {
    Widget? calculatorWidget;

    switch (calculatorType) {
      case 'juros_compostos':
        calculatorWidget = const JurosCompostosPage();
        break;
      case 'amortizacao':
        // Adicionar futuramente a calculadora de amortização
        break;
      case 'conversao_moedas':
        // Adicionar futuramente a calculadora de conversão de moedas
        break;
      case 'roi':
        // Usar calculadora de valor futuro para ROI
        calculatorWidget = const ValorFuturoPage();
        break;
      case 'depreciacao':
        // Adicionar futuramente a calculadora de depreciação
        break;
      case 'orcamento':
        calculatorWidget = const OrcamentoRegra5030Page();
        break;
      case 'reserva_emergencia':
        calculatorWidget = const ReservaEmergenciaPage();
        break;
      case 'vista_vs_parcelado':
        calculatorWidget = const VistaVsParceladoPage();
        break;
      case 'custo_efetivo_total':
        calculatorWidget = const CustoEfetivoTotalPage();
        break;
      case 'custo_real_credito':
        calculatorWidget = const CustoRealCreditoPage();
        break;
      case 'independencia_financeira':
        calculatorWidget = const IndependenciaFinanceiraPage();
        break;
      // Calculadoras Trabalhistas
      case 'decimo_terceiro':
        calculatorWidget = const DecimoTerceiroPage();
        break;
      case 'ferias':
        calculatorWidget = const FeriasPage();
        break;
      case 'horas_extras':
        calculatorWidget = const HorasExtrasPage();
        break;
      case 'salario_liquido':
        calculatorWidget = const SalarioLiquidoPage();
        break;
      case 'seguro_desemprego':
        calculatorWidget = const SeguroDesempregoPage();
        break;
      case 'promo_page':
        // Página promocional para visualização
        calculatorWidget = const CalculeiPromoPage();
        break;
    }

    if (calculatorWidget != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => calculatorWidget!,
        ),
      );
    }
  }

}
