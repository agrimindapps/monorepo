import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../const/environment_const.dart' as local_env;
import '../../../../core/widgets/appbar.dart';
import 'termos_list_page.dart';
import '../../domain/entities/categoria.dart';
import '../providers/termos_providers.dart';

/// Home page displaying all available categories
/// Uses Riverpod for state management
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _unfocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _analyticsService = FirebaseAnalyticsService();

  @override
  void initState() {
    super.initState();
    // Trigger initial load of termos
    Future.microtask(() => ref.read(termosNotifierProvider));
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch categorias list
    final categoriasAsync = ref.watch(categoriasListProvider);

    return Scaffold(
      key: scaffoldKey,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 1120,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _menuPromo(),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Descubra informações nutricionais detalhadas sobre'
                        'diversos alimentos e acompanhe sua saúde com cálculos'
                        'de IMC, calorias por atividades e muito mais. '
                        'Clique em uma categoria para saber mais!',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Display categorias with AsyncValue pattern matching
                    categoriasAsync.when(
                      data: (categorias) => _buildCategoriaGrid(categorias),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Erro ao carregar categorias: $error',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
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
  }

  Widget _buildCategoriaGrid(List<Categoria> categorias) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;

    if (screenWidth < 600) {
      crossAxisCount = 2;
    } else if (screenWidth < 900) {
      crossAxisCount = 3;
    } else if (screenWidth < 1100) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = 5;
    }

    return StaggeredGrid.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        for (var categoria in categorias)
          _buildCategoriaCard(categoria: categoria),
      ],
    );
  }

  Widget _buildCategoriaCard({required Categoria categoria}) {
    return GestureDetector(
      onTap: () async {
        // Set categoria using Riverpod provider
        await ref
            .read(categoriaAtualNotifierProvider.notifier)
            .setCategoria(categoria);

        // Navigate to termos page
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TermosPage(
                favoritePage: false,
              ),
            ),
          );
        }
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FutureBuilder(
                future: Future.value(Image.asset(categoria.image).image),
                builder: (BuildContext context,
                    AsyncSnapshot<ImageProvider<Object>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Image(
                      image: snapshot.data!,
                      fit: BoxFit.fitHeight,
                      height: 135,
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            SizedBox(
              height: 32,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  categoria.descricao,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
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
          'Termus: Aprendizado e Diversão',
          style: TextStyle(fontSize: 24),
        ),
        Text(
          'Conhecimento',
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
              'Termus: Aprendizado e Diversão',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Conhecimento',
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
            image: AssetImage('lib/assets/appicon.png'),
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
              'lib/assets/download_play_store.png',
              width: 140,
            ),
            onTap: () async {
              final url = Uri.parse(local_env.Environment().linkLojaGoogle);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
                await _analyticsService.logEvent(
                  'button_click',
                  parameters: {
                    'button_name': 'download_play_store',
                  },
                );
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
        ),
        const SizedBox(width: 20),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Image.asset(
              'lib/assets/download_app_store.png',
              width: 140,
            ),
            onTap: () async {
              final url = Uri.parse(local_env.Environment().linkLojaApple);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
                await _analyticsService.logEvent(
                  'button_click',
                  parameters: {
                    'button_name': 'download_app_store',
                  },
                );
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
        ),
      ],
    );
  }
}
