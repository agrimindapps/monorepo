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

class MobilePageMain extends StatelessWidget {
  const MobilePageMain({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.purple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calculate,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Calculei',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CalculeiLoginWebPage(),
                ),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade300,
                  Colors.purple.shade300,
                  Colors.teal.shade300,
                  Colors.orange.shade300,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Calculei',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Cálculos financeiros e trabalhistas em um só lugar',
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Seção Financeiras
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Calculadoras Financeiras',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Grid de calculadoras financeiras
              AlignedGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: 9,
                itemBuilder: (context, index) {
                  final calculadorasFinanceiras = [
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
                    // New Financial Calculators
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
                    {
                      'title': 'Landing Page',
                      'icon': Icons.web,
                      'type': 'promo_page',
                      'color': Colors.indigo.shade700,
                      'secondaryColor': Colors.indigo.shade200,
                      'available': true
                    },
                  ];

                  final calc = calculadorasFinanceiras[index];
                  return _buildCalculatorCard(
                    context,
                    calc['title'] as String,
                    calc['icon'] as IconData,
                    () {
                      if (calc['available'] as bool) {
                        _navigateToCalculator(context, calc['type'] as String);
                      }
                    },
                    calc['available'] as bool,
                    calc['color'] as Color,
                    calc['secondaryColor'] as Color,
                  );
                },
              ),
              
              const SizedBox(height: 32),
              // Seção Trabalhistas
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Calculadoras Trabalhistas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Grid de calculadoras trabalhistas
              AlignedGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: 5,
                itemBuilder: (context, index) {
                  final calculadorasTrabalhistas = [
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
                  ];

                  final calc = calculadorasTrabalhistas[index];
                  return _buildCalculatorCard(
                    context,
                    calc['title'] as String,
                    calc['icon'] as IconData,
                    () {
                      if (calc['available'] as bool) {
                        _navigateToCalculator(context, calc['type'] as String);
                      }
                    },
                    calc['available'] as bool,
                    calc['color'] as Color,
                    calc['secondaryColor'] as Color,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculatorCard(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      bool isAvailable,
      Color primaryColor,
      Color secondaryColor) {
    return Material(
      elevation: isAvailable ? 6 : 2,
      shadowColor: isAvailable
          ? primaryColor.withValues(alpha: 0.4)
          : Colors.grey.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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
          child: Opacity(
            opacity: isAvailable ? 1.0 : 0.7,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 30,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isAvailable)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'EM BREVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
      case 'promo_page':
        // Página promocional para visualização
        calculatorWidget = const CalculeiPromoPage();
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
