// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../widgets/page_header_widget.dart';
import 'controller/rendimento_controller.dart';
import 'pages/cereal_page.dart';
import 'pages/grao_page.dart';
import 'pages/leguminosa_page.dart';
import 'widgets/calculadora_card.dart';
import 'widgets/tip_card.dart';

class RendimentoIndexPage extends StatelessWidget {
  const RendimentoIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RendimentoController());
    return GetBuilder<RendimentoController>(
      builder: (controller) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

          return SafeArea(
            child: Scaffold(
              appBar: const PreferredSize(
                preferredSize: Size.fromHeight(72),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: PageHeaderWidget(
                    title: 'Taxa de Rendimento',
                    subtitle: 'Cálculos de produtividade agrícola',
                    icon: Icons.trending_up,
                    showBackButton: true,
                  ),
                ),
              ),
              body: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título e descrição
                          const Text(
                            'Calculadoras de Rendimento',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Escolha o tipo de cultura para calcular o rendimento',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 24),

                          // Cards de calculadoras
                          CalculadoraCard(
                            titulo: 'Leguminosas',
                            descricao:
                                'Cálculo de rendimento para culturas como soja, feijão, ervilha, etc.',
                            icone: FontAwesome.seedling_solid,
                            cor: Colors.green.shade700,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LeguminosaPage(),
                              ),
                            ),
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),

                          CalculadoraCard(
                            titulo: 'Cereais',
                            descricao:
                                'Cálculo de rendimento para trigo, arroz, cevada, etc.',
                            icone: FontAwesome.wheat_awn_solid,
                            cor: Colors.amber.shade700,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CerealPage(),
                              ),
                            ),
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),

                          CalculadoraCard(
                            titulo: 'Grãos',
                            descricao:
                                'Cálculo de rendimento para milho e outros grãos com espigas',
                            icone:
                                FontAwesome.wheat_awn_circle_exclamation_solid,
                            cor: Colors.orange.shade700,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GraoPage(),
                              ),
                            ),
                            isDark: isDark,
                          ),
                          const SizedBox(height: 24),

                          // Cards de dicas
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.lightbulb_outline,
                                          color: isDark
                                              ? Colors.amber.shade300
                                              : Colors.amber.shade700),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Dicas para Aumentar o Rendimento',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TipCard(
                                    title: 'Preparo adequado do solo',
                                    description:
                                        'Um solo bem preparado, com correção de acidez e níveis adequados de nutrientes, é a base para um bom rendimento.',
                                    icon: FontAwesome.tractor_solid,
                                    color: isDark
                                        ? Colors.brown.shade300
                                        : Colors.brown.shade700,
                                  ),
                                  const SizedBox(height: 12),
                                  TipCard(
                                    title: 'Escolha da variedade',
                                    description:
                                        'Selecione variedades adaptadas às condições climáticas locais e com alto potencial produtivo.',
                                    icon: FontAwesome.dna_solid,
                                    color: isDark
                                        ? Colors.purple.shade300
                                        : Colors.purple.shade700,
                                  ),
                                  const SizedBox(height: 12),
                                  TipCard(
                                    title: 'Monitoramento constante',
                                    description:
                                        'Acompanhe o desenvolvimento da cultura e esteja atento ao surgimento de pragas, doenças e deficiências nutricionais.',
                                    icon: FontAwesome.magnifying_glass_solid,
                                    color: isDark
                                        ? Colors.blue.shade300
                                        : Colors.blue.shade700,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
      },
    );
  }
}
