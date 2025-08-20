// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../widgets/page_header_widget.dart';
import 'aplicacao/index.dart';
import 'balanco_nutricional/index.dart';
import 'fertilizantes/index.dart';
import 'fruticultura/index.dart';
import 'manejo_integracao/index.dart';
import 'maquinario/index.dart';
import 'pecuaria/aproveitamento_carcaca/index.dart';
import 'pecuaria/loteamento_bovino/index.dart';
import 'previsao/index.dart';
import 'rendimento/index.dart';
import 'rotacao_culturas/index.dart';
import 'semeadura/index.dart';

class CalculosPage extends StatefulWidget {
  const CalculosPage({super.key});

  @override
  CalculosPageState createState() => CalculosPageState();
}

class CalculosPageState extends State<CalculosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<CalculoInfo> calculosAgricolas = [
    CalculoInfo(
      title: 'Fertilizantes',
      subtitle: 'Cálculos de aplicação de fertilizantes',
      icon: FontAwesome.diagram_project_solid,
      color: Colors.green.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FertilizantesPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Previsão',
      subtitle: 'Previsão de custos e receitas',
      icon: FontAwesome.hand_holding_dollar_solid,
      color: Colors.green.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PrevisaoPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Semeadura',
      subtitle: 'Cálculos de semeadura e plantio',
      icon: FontAwesome.seedling_solid,
      color: Colors.green.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SemeaduraPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Maquinário',
      subtitle: 'Cálculos de maquinário agrícola',
      icon: FontAwesome.tractor_solid,
      color: Colors.green.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MaquinarioPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Aplicação',
      subtitle: 'Cálculos de aplicação de insumos',
      icon: FontAwesome.wheat_awn_solid,
      color: Colors.green.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AplicacaoPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Rotação',
      subtitle: 'Rotação de culturas',
      icon: FontAwesome.arrows_rotate_solid,
      color: Colors.green.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RotacaoCulturasPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Fruticultura',
      subtitle: 'Cálculos para fruticultura',
      icon: FontAwesome.apple_whole_solid,
      color: Colors.green.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FruticulturaPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Balanço Nutricional',
      subtitle: 'Análise de nutrientes',
      icon: FontAwesome.flask_solid,
      color: Colors.green.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BalancoNutricionalPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Manejo Integrado',
      subtitle: 'Manejo integrado de pragas',
      icon: FontAwesome.bug_slash_solid,
      color: Colors.green.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ManejoIntegradoPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Taxa de Rendimento',
      subtitle: 'Cálculos de rendimento para culturas',
      icon: FontAwesome.chart_line_solid,
      color: Colors.green.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RendimentoIndexPage(),
          ),
        );
      },
    ),
  ];

  final List<CalculoInfo> calculosPecuaria = [
    CalculoInfo(
      title: 'Loteamento de Animais',
      subtitle: 'Dimensionamento de lotes de bovinos',
      icon: FontAwesome.cow_solid,
      color: Colors.green.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoteamentoBovinoPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Rendimento de Carcaça',
      subtitle: 'Cálculo de rendimento de carcaça',
      icon: FontAwesome.drumstick_bite_solid,
      color: Colors.green.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AproveitamentoCarcacaPage(),
          ),
        );
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Retorna todos os cálculos disponíveis
  List<CalculoInfo> _getAllCalculos() {
    List<CalculoInfo> fullList = [];
    fullList.addAll(calculosAgricolas);
    fullList.addAll(calculosPecuaria);
    return fullList;
  }

  @override
  Widget build(BuildContext context) {
    // Calcula o número de colunas com base na largura da tela
    final screenWidth = MediaQuery.of(context).size.width;
    int columnCount = 2; // Padrão para telas menores

    // Ajusta o número de colunas dependendo da largura da tela
    if (screenWidth >= 600 && screenWidth < 900) {
      columnCount = 3;
    } else if (screenWidth >= 900) {
      columnCount = 4;
    }

    final allCalculos = _getAllCalculos();

    return SafeArea(
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(72),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: PageHeaderWidget(
              title: 'Calculadoras',
              subtitle: 'Selecione uma calculadora',
              icon: Icons.calculate,
              showBackButton: true,
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resultados da pesquisa
                Expanded(
                  child: allCalculos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off,
                                  size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma calculadora encontrada',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tente outros termos ou categorias',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AlignedGridView.count(
                            crossAxisCount: columnCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            itemCount: allCalculos.length,
                            itemBuilder: (context, index) {
                              return CalculoCard(calculo: allCalculos[index]);
                            },
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
}

class CalculoInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Function(BuildContext) onTap;
  final bool isInDevelopment;

  CalculoInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isInDevelopment = false,
  });
}

class CalculoCard extends StatelessWidget {
  final CalculoInfo calculo;

  const CalculoCard({super.key, required this.calculo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => calculo.onTap(context),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                calculo.color,
                calculo.color.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        calculo.icon,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        calculo.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              if (calculo.isInDevelopment)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Em breve',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
