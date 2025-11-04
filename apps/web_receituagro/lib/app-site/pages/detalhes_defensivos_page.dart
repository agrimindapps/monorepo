import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../repository/defensivos_repository.dart';
import '../core/utils/responsive_helper.dart';

class DefensivosDetalhesPage extends StatefulWidget {
  const DefensivosDetalhesPage({super.key, required this.id});

  final String id;
  @override
  State<DefensivosDetalhesPage> createState() => _DefensivosDetalhesPageState();
}

class _DefensivosDetalhesPageState extends State<DefensivosDetalhesPage> {
  bool isLoading = false;

  Map<dynamic, dynamic> defensivo = {
    'nomecomum': 'Nome Comum',
    'ingredienteativo': 'Ingredientes Ativos',
    'nometecnico': 'Nome Técnico',
    'toxico': 'Toxicologia',
    'inflamavel': 'Inflamável',
    'corrosivo': 'Corrosivo',
    'modoacao': 'Modo de Ação',
    'classeagronomica': 'Classe Agronômica',
    'classambiental': 'Classe Ambiental',
    'formulacao': 'Formulação',
    'mapa': 'Mapa',
    'culturas': []
  };

  List<Map<String, dynamic>> infoFields1 = [
    {'field': 'nometecnico', 'title': 'Nome Técnico'},
    {'field': 'fabricante', 'title': 'Fabricante'},
    {'field': 'mapa', 'title': 'Mapa'},
  ];

  List<Map<String, dynamic>> infoFields2 = [
    {'field': 'toxico', 'title': 'Toxicologia'},
    {'field': 'inflamavel', 'title': 'Inflamável'},
    {'field': 'corrosivo', 'title': 'Corrosivo'},
    {'field': 'modoacao', 'title': 'Modo de Ação'},
    {'field': 'classeagronomica', 'title': 'Classe Agronômica'},
    {'field': 'classambiental', 'title': 'Classe Ambiental'},
    {'field': 'formulacao', 'title': 'Formulação'}
  ];

  List<Map<String, dynamic>> ingredienteAtivo = [
    {'ingrediente': 'Ingrediente', 'dosagem': 'Dosagem', 'title': true},
  ];

  List<dynamic> culturas = [
    {
      'cultura': 'Cultura',
      'pragas': [
        {
          'praganomecientifico': 'Praga Nome Científico',
          'praganomecomum': 'Praga Nome Comum',
          'dosagem': 'Dosagem',
          'terrestre': 'Terrestre',
          'aerea': 'Aérea'
        },
        {
          'praganomecientifico': 'Praga Nome Científico',
          'praganomecomum': 'Praga Nome Comum',
          'dosagem': 'Dosagem',
          'terrestre': 'Terrestre',
          'aerea': 'Aérea'
        },
        {
          'praganomecientifico': 'Praga Nome Científico',
          'praganomecomum': 'Praga Nome Comum',
          'dosagem': 'Dosagem',
          'terrestre': 'Terrestre',
          'aerea': 'Aérea'
        }
      ]
    },
    {
      'cultura': 'Cultura',
      'pragas': [
        {
          'praganomecientifico': 'Praga Nome Científico',
          'praganomecomum': 'Praga Nome Comum',
          'dosagem': 'Dosagem',
          'terrestre': 'Terrestre',
          'aerea': 'Aérea'
        },
        {
          'praganomecientifico': 'Praga Nome Científico',
          'praganomecomum': 'Praga Nome Comum',
          'dosagem': 'Dosagem',
          'terrestre': 'Terrestre',
          'aerea': 'Aérea'
        },
        {
          'praganomecientifico': 'Praga Nome Científico',
          'praganomecomum': 'Praga Nome Comum',
          'dosagem': 'Dosagem',
          'terrestre': 'Terrestre',
          'aerea': 'Aérea'
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _fetchDefensivo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchDefensivo() async {
    setState(() {
      isLoading = true;
    });

    try {
      debugPrint('Carregando defensivo com ID: ${widget.id}');
      final response =
          await DefensivosRepository().fetchDefensivoView(widget.id);
      debugPrint('Response recebido: ${response.length} itens');

      if (response.isNotEmpty) {
        for (var element in response) {
          defensivo = element;
          debugPrint('Defensivo carregado: ${defensivo['nomecomum']}');
        }

        List<String> ingredientes =
            defensivo['ingredienteativo'].toString().split('+');
        List<String> dosagens = defensivo['quantproduto'].toString().split('+');

        ingredienteAtivo.clear();
        ingredienteAtivo.add({
          'ingrediente': 'Ingrediente',
          'dosagem': 'Dosagem',
          'title': true
        });

        for (var i = 0; i < ingredientes.length; i++) {
          ingredienteAtivo.add({
            'ingrediente': ingredientes[i],
            'dosagem': dosagens[i],
            'title': false
          });
        }

        culturas = defensivo['culturas'] as List<dynamic>;
        culturas.sort((a, b) => a['cultura'].compareTo(b['cultura']));
      }
    } catch (e) {
      debugPrint('Erro ao carregar defensivo: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 1120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Skeletonizer(
                      enabled: isLoading,
                      enableSwitchAnimation: true,
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                          child: Text(
                            defensivo['nomecomum'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow
                                .ellipsis, // Adiciona reticências se o texto for muito longo
                          )),
                    ),
                    SizedBox(
                        width:
                            MediaQuery.of(context).size.width < 600 ? 0 : 40),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Informações Gerais', style: _textStyleTitle()),
                        const SizedBox(height: 8),
                        _cardInfoGerais(),
                        const SizedBox(height: 20),
                        Text('Ingredientes Ativos', style: _textStyleTitle()),
                        const SizedBox(height: 8),
                        _cardIngredienteAtivo(),
                        const SizedBox(height: 20),
                        Text('Informações Adicionais',
                            style: _textStyleTitle()),
                        const SizedBox(height: 8),
                        _cardWidgetInfoAdicionais(),
                        const SizedBox(height: 20),
                        Text('Diagnósticos', style: _textStyleTitle()),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                _listViewCulturas(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardIngredienteAtivo() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            MasonryGridView.builder(
              gridDelegate:
                  const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
              ),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
              itemCount: ingredienteAtivo.length,
              itemBuilder: (context, index) {
                var item = ingredienteAtivo[index];
                return Skeletonizer(
                  enabled: isLoading,
                  enableSwitchAnimation: true,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(item['ingrediente'],
                              style: item['title']
                                  ? const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)
                                  : const TextStyle(
                                      fontWeight: FontWeight.normal)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(item['dosagem'],
                              style: item['title']
                                  ? const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)
                                  : const TextStyle(
                                      fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _cardInfoGerais() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount =
        ResponsiveHelper.getCrossAxisCount(screenWidth, type: GridType.detail);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            MasonryGridView.builder(
              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
              ),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              itemCount: infoFields1.length,
              itemBuilder: (context, index) {
                var item = infoFields1[index];

                return Skeletonizer(
                  enabled: isLoading,
                  enableSwitchAnimation: true,
                  child: Card(
                    elevation: 0,
                    child: ListTile(
                      title: item['title'] != null
                          ? Text(
                              '${item['title']}:',
                              style: TextStyle(color: Colors.grey.shade700),
                            )
                          : const SizedBox.shrink(),
                      subtitle: defensivo[item['field']] != null
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                              child: Text(defensivo[item['field']] ?? ''),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _cardWidgetInfoAdicionais() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount =
        ResponsiveHelper.getCrossAxisCount(screenWidth, type: GridType.detail);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MasonryGridView.builder(
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          itemCount: infoFields2.length,
          itemBuilder: (context, index) {
            var item = infoFields2[index];
            return Skeletonizer(
              enabled: isLoading,
              enableSwitchAnimation: true,
              child: Card(
                elevation: 0,
                child: ListTile(
                  title: Text(item['title'] + ':',
                      style: TextStyle(color: Colors.grey.shade700)),
                  subtitle: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: Text(defensivo[item['field']]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _listViewCulturas() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: culturas.length,
      itemBuilder: (context, index) {
        Map<dynamic, dynamic> item = culturas[index];
        return Skeletonizer(
          enabled: isLoading,
          enableSwitchAnimation: true,
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(10, 0, 12, 0),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Text(item['cultura']),
                    const SizedBox(
                      height: 8,
                    ),
                    const Divider(
                      height: 0,
                    ),
                  ],
                ),
                subtitle: ListView.separated(
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    endIndent: 0,
                    indent: 0,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: item['pragas'].length,
                  itemBuilder: (context, index) {
                    Map<dynamic, dynamic> item2 = item['pragas'][index];
                    return Column(
                      children: [
                        ListTile(
                          titleTextStyle: const TextStyle(fontSize: 14),
                          contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          dense: true,
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Row(
                                  children: [
                                    Text(
                                      item2['praganomecientifico'],
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        ' (${item2['praganomecomum'] ?? ''})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 2,
                                child: Text(item2['dosagem'] ?? '',
                                    textAlign: TextAlign.start),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(item2['terrestre'] ?? '',
                                    textAlign: TextAlign.start),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(item2['aerea'] ?? '',
                                    textAlign: TextAlign.start),
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  TextStyle _textStyleTitle() {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade700,
    );
  }
}
