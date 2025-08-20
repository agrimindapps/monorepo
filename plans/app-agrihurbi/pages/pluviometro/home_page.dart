// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../repository/pluviometros_repository.dart';
import '../../widgets/page_header_widget.dart';
import 'medicoes_page/view/medicoes_page_view.dart';
import 'pluviometros_page/pluviometros_page.dart';
import 'resultados_page/index.dart';

// Enum para os tipos de ferramentas pluviométricas
enum PluviometriaFeature {
  pluviometros('Pluviômetros', Icons.water_drop_outlined,
      'Cadastre e gerencie seus pluviômetros'),
  medicoes('Medições', Icons.speed_outlined, 'Registre as medições de chuva'),
  resultados('Resultados', Icons.bar_chart_outlined,
      'Visualize relatórios e gráficos');

  final String title;
  final IconData icon;
  final String description;

  const PluviometriaFeature(this.title, this.icon, this.description);
}

class PluviometriaHome extends StatefulWidget {
  const PluviometriaHome({super.key});

  @override
  State<PluviometriaHome> createState() => _PluviometriaHomeState();
}

class _PluviometriaHomeState extends State<PluviometriaHome> {
  @override
  void initState() {
    super.initState();
    _carregaPluviometros();
  }

  void _carregaPluviometros() {
    PluviometrosRepository().getSelectedPluviometroId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: PageHeaderWidget(
                title: 'Pluviometria',
                subtitle: 'Gestão de Pluviômetros',
                icon: Icons.water_drop,
                showBackButton: true,
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1020),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        Center(
                          child: Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            children: PluviometriaFeature.values
                                .map((feature) =>
                                    _buildFeatureCard(context, feature))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildExitModuleButton(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, PluviometriaFeature feature) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _navigateToFeature(context, feature),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                feature.icon,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                feature.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                feature.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToFeature(BuildContext context, PluviometriaFeature feature) {
    Widget page;

    switch (feature) {
      case PluviometriaFeature.pluviometros:
        page = const PluviometrosPage();
        break;
      case PluviometriaFeature.medicoes:
        page = const MedicoesPageView();
        break;
      case PluviometriaFeature.resultados:
        page = const ResultadosPluviometroPage();
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _buildExitModuleButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: InkWell(
            onTap: () => _showExitModuleConfirmation(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.exit_to_app,
                    size: 20,
                    color: Colors.red.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sair do Módulo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade600,
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

  void _showExitModuleConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do Módulo'),
        content: const Text(
          'Tem certeza de que deseja sair do AgriHurbi e retornar ao menu principal?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exitModule(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _exitModule(BuildContext context) {
    Navigator.pop(context);
  }
}
