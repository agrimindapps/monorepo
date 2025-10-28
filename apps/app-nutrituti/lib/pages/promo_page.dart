// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../core/services/ganalytics_service.dart';
import '../const/environment_const.dart';
import '../repository/alimentos_repository.dart';
import '../widgets/appbar.dart';
import 'alimentos_page.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  CategoriasState createState() => CategoriasState();
}

class CategoriasState extends State<CategoriasPage> {
  final _unfocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _pesquisaController = TextEditingController();

  List<Map<String, dynamic>> categorias = [];

  @override
  void initState() {
    super.initState();

    getCategorias();
  }

  void getCategorias() {
    categorias = AlimentosRepository().getCategorias();
    setState(() {});
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    _pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NutriAppBar(),
      key: scaffoldKey,
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 1020,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _menuPromo(),
                  ),
                  const SizedBox(height: 20), // Espaço entre os widgets
                  // Text(
                  //   'Lorem Ipsum',
                  //   style: const TextStyle(fontSize: 24),
                  // ),
                  // ignore: prefer_const_constructors
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      'Descubra informações nutricionais detalhadas sobre'
                      'diversos alimentos e acompanhe sua saúde com cálculos'
                      'de IMC, calorias por atividades e muito mais. '
                      'Clique em uma categoria para saber mais!',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: gridViewCategoria(categorias),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget gridViewCategoria(List<Map<String, dynamic>> categorias) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (screenWidth < 600) {
      crossAxisCount = 2;
    } else if (screenWidth < 900) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    return StaggeredGrid.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        for (var item in categorias)
          StaggeredGridTile.fit(
            crossAxisCellCount: 1,
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                    child: Icon(
                      item['icon'] as IconData? ?? Icons.category,
                      color: Colors.grey,
                      size: 28,
                    ),
                  ),
                  subtitle: Text(
                    item['title'] as String? ?? '',
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AlimentosPage(
                          categoria: item['title'] as String? ?? '',
                          onlyFavorites: false,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget btnOpenSite() {
    return IconButton(
      icon: const Icon(FontAwesome.link_solid, size: 18),
      color: Colors.white,
      onPressed: () async {
        Uri url = Uri.parse(AppEnvironment().siteApp);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          debugPrint('Could not launch $url');
        }
      },
    );
  }

  Widget semRegistros() {
    return const Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('Nenhum registro encontrado'),
          ),
        ],
      ),
    );
  }

  Widget _menuPromo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildColumnLayout();
        } else {
          return _buildRowLayout();
        }
      },
    );
  }

  Widget _buildColumnLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildLogo(),
        const SizedBox(height: 20),
        const Text(
          'NutriTuti: Saúde e bem estar',
          style: TextStyle(fontSize: 24),
        ),
        Text(
          'Alimentação saudável e equilibrada',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 30),
        _buildDownloadButtons(),
      ],
    );
  }

  Widget _buildRowLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildLogo(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'NutriTuti: Saúde e bem estar',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Alimentação saudável e equilibrada',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),
            _buildDownloadButtons(),
          ],
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 24, 20, 4),
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('lib/core/assets/appicon.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(40),
        ),
      ),
    );
  }

  Widget _buildDownloadButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Image.asset(
              'lib/core/assets/download_play_store.png',
              width: 140,
            ),
            onTap: () async {
              Uri url = Uri.parse(AppEnvironment().linkLojaGoogle);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
                GAnalyticsService.instance.logCustomEvent(
                  'button_click',
                  parameters: {
                    'button_name': 'download_play_store',
                  },
                );
              } else {
                debugPrint('Could not launch $url');
              }
            },
          ),
        ),
        const SizedBox(width: 20),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Image.asset(
              'lib/core/assets/download_app_store.png',
              width: 140,
            ),
            onTap: () async {
              Uri url = Uri.parse(AppEnvironment().linkLojaApple);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
                GAnalyticsService.instance.logCustomEvent(
                  'button_click',
                  parameters: {
                    'button_name': 'download_app_store',
                  },
                );
              } else {
                debugPrint('Could not launch $url');
              }
            },
          ),
        ),
      ],
    );
  }
}
