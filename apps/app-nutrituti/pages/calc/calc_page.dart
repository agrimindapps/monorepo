// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import 'alcool_sangue/index.dart';
import 'calorias_diarias/index.dart';
import 'calorias_por_exercicio/index.dart';
import 'cintura_quadril/index.dart';
import 'deficit_superavit/index.dart';
import 'densidade_nutrientes/index.dart';
import 'densidade_ossea/index.dart';
import 'gasto_energetico/index.dart';
import 'macronutrientes/view/macronutrientes_page_new.dart';
import 'massa_corporea/index.dart';
import 'necessidade_hidrica/index.dart';
import 'peso_ideal/index.dart';
import 'proteinas_diarias/index.dart';
import 'taxa_metabolica_basal/index.dart';
import 'volume_sanguineo/index.dart';

class CalcPage extends StatefulWidget {
  const CalcPage({super.key});

  @override
  State<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends State<CalcPage> {
  String _currentCategory = 'Todos';

  final List<String> _categorias = [
    'Todos',
    'Corpo',
    'Nutrição',
    'Calorias',
  ];

  final List<CalculoInfo> calculosCorpo = [
    CalculoInfo(
      title: 'Massa Corpórea (IMC)',
      subtitle: 'Calcule seu Índice de Massa Corpórea',
      icon: Icons.accessibility,
      color: Colors.blue.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MassaCorporeaPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Volume Sanguíneo',
      subtitle: 'Cálculo de volume de sangue no corpo',
      icon: Icons.opacity,
      color: Colors.red.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VolumeSanguineoCalcPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: '% Álcool Sangue',
      subtitle: 'Concentração de álcool no sangue',
      icon: Icons.local_bar,
      color: Colors.purple.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AlcoolSangueCalcPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Peso Ideal',
      subtitle: 'Determinação de peso ideal para saúde',
      icon: Icons.monitor_weight,
      color: Colors.teal.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PesoIdealCalcPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Relação Cintura-Quadril',
      subtitle: 'Avalie seu risco cardiovascular',
      icon: Icons.straighten,
      color: Colors.orange.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CinturaQuadrilPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Densidade Óssea',
      subtitle: 'Análise de saúde óssea',
      icon: Icons.healing,
      color: Colors.brown.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DensidadeOsseaCalcPage(),
          ),
        );
      },
    ),
    // CalculoInfo(
    //   title: 'Índice Adiposidade Corporal',
    //   subtitle: 'Avalie percentual de gordura corporal',
    //   icon: Icons.line_weight,
    //   color: Colors.indigo.shade700,
    //   onTap: (context) {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => const IndiceAdiposidadeCalcPage(),
    //       ),
    //     );
    //   },
    // ),
  ];

  final List<CalculoInfo> calculosNutricao = [
    CalculoInfo(
      title: 'Macronutrientes',
      subtitle: 'Distribuição ideal de carboidratos, proteínas e gorduras',
      icon: Icons.pie_chart,
      color: Colors.green.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MacronutrientesPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Proteína Diária',
      subtitle: 'Cálculo da ingestão ideal de proteínas',
      icon: Icons.egg_alt,
      color: Colors.amber.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProteinasDiariasPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Densidade de Nutrientes',
      subtitle: 'Avaliação da qualidade nutricional dos alimentos',
      icon: Icons.food_bank,
      color: Colors.lime.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ZNewDensidadeNutrientesPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Necessidade Hídrica',
      subtitle: 'Calcule sua necessidade diária de água',
      icon: Icons.water_drop,
      color: Colors.lightBlue.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NecessidadeHidricaCalcPage(),
          ),
        );
      },
    ),
  ];

  final List<CalculoInfo> calculosCalorias = [
    CalculoInfo(
      title: 'Calorias Diárias',
      subtitle: 'Necessidade calórica diária',
      icon: Icons.local_fire_department,
      color: Colors.deepOrange.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CaloriasDiariasPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Calorias por Exercício',
      subtitle: 'Cálculo de gasto calórico em atividades físicas',
      icon: Icons.fitness_center,
      color: Colors.cyan.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CaloriasPorExercicioCalcPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Taxa Metabólica Basal',
      subtitle: 'Cálculo do metabolismo em repouso',
      icon: Icons.whatshot,
      color: Colors.red.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TaxaMetabolicaBasalCalcPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Gasto Energético Total',
      subtitle: 'Consumo de energia diário com atividades',
      icon: Icons.bolt,
      color: Colors.yellow.shade800,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GastoEnergeticoPage(),
          ),
        );
      },
    ),
    CalculoInfo(
      title: 'Déficit/Superávit Calórico',
      subtitle: 'Cálculo para perda ou ganho de peso',
      icon: Icons.scale,
      color: Colors.deepPurple.shade700,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DeficitSuperavitCalcPage(),
          ),
        );
      },
    ),
  ];

  // Filtra a lista de cálculos com base na categoria selecionada
  List<CalculoInfo> _getFilteredList() {
    List<CalculoInfo> fullList = [];

    if (_currentCategory == 'Todos' || _currentCategory == 'Corpo') {
      fullList.addAll(calculosCorpo);
    }

    if (_currentCategory == 'Todos' || _currentCategory == 'Nutrição') {
      fullList.addAll(calculosNutricao);
    }

    if (_currentCategory == 'Todos' || _currentCategory == 'Calorias') {
      fullList.addAll(calculosCalorias);
    }

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

    final filteredCalculos = _getFilteredList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadoras'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Calculadoras Nutricionais',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ferramentas para acompanhar sua saúde e nutrição',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 16),

                          // Filtros de categoria
                          SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categorias.length,
                              itemBuilder: (context, index) {
                                final categoria = _categorias[index];
                                final isSelected =
                                    _currentCategory == categoria;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: FilterChip(
                                    label: Text(categoria),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        _currentCategory = categoria;
                                      });
                                    },
                                    backgroundColor: Colors.grey.shade200,
                                    selectedColor: Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.2),
                                    checkmarkColor:
                                        Theme.of(context).primaryColor,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Resultados da pesquisa
                    Expanded(
                      child: filteredCalculos.isEmpty
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
                                    'Tente outras categorias',
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
                                itemCount: filteredCalculos.length,
                                itemBuilder: (context, index) {
                                  return CalculoCard(
                                      calculo: filteredCalculos[index]);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
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
                      const SizedBox(height: 8),
                      Text(
                        calculo.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                      color: Colors.black.withValues(alpha: 0.7),
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
