// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../widgets/appbar.dart';
import 'categories_section.dart';
import 'feature_section.dart';
import 'header_section.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({super.key});

  @override
  PromoPageState createState() => PromoPageState();
}

class PromoPageState extends State<PromoPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NutriAppBar(),
      key: scaffoldKey,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 1020,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeaderSection(),
                  const SizedBox(height: 40),

                  // Seção de benefícios destacados
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Sobre o NutriTuti',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Descubra informações nutricionais detalhadas sobre '
                            'diversos alimentos e acompanhe sua saúde com cálculos '
                            'de IMC, calorias por atividades e muito mais. '
                            'Clique em uma categoria para saber mais!',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Seção de recursos destacados (componente novo)
                  const FeatureSection(),

                  const SizedBox(height: 30),
                  const Divider(thickness: 1),
                  const SizedBox(height: 16),

                  // Seção de categorias
                  const CategoriesSection(),

                  const SizedBox(height: 50),

                  // Seção de depoimentos ou chamada para ação
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade50,
                          Colors.green.shade100,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Comece sua jornada para uma alimentação mais saudável hoje!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Baixe agora o NutriTuti e tenha acesso a todas estas funcionalidades em seus dispositivos.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
