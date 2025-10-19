import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../core/services/admob_service.dart';
import '../../core/services/return_service.dart';
import '../../core/services/tts_service.dart';
import '../../core/widgets/appbar.dart';
import '../../core/widgets/search_widget.dart';
import '../classes/termo_class.dart';
import '../repository/comentarios_repository.dart';
import '../repository/termos_repository.dart';
import '../widgets/comentarios_widget.dart';

class TermosPage extends StatefulWidget {
  const TermosPage({super.key, this.favoritePage = false});

  final bool favoritePage;

  @override
  TermosPageState createState() => TermosPageState();
}

class TermosPageState extends State<TermosPage> {
  final TtsService _ttsService = TtsService();

  Map<String, dynamic> categoria = {};
  List<Termo> termos = [];
  List<Termo> termosFiltered = [];
  bool _isLoaded = false;
  int itensPerScroll = 50;

  final ScrollController _scrollController = ScrollController();
  final textController = TextEditingController();

  List<dynamic> comentarios = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    textController.addListener(() {
      filtrarTermos(true);
      setState(() {});
    });

    initTermos();
  }

  void carregaComentarios() async {
    comentarios.clear();
    await Future.delayed(const Duration(milliseconds: 5));
    comentarios = await ComentariosRepository()
        .getComentariosByFerramenta(categoria['descricao']);
    setState(() {
      comentarios;
    });
  }

  void _scrollListener() async {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent) {
      filtrarTermos(false);
      setState(() {});
    }
  }

  void filtrarTermos(bool isSearch) {
    List<Termo> tempTermosFiltered = [];

    if (isSearch) {
      termosFiltered = [];
    }

    // Filtro por texto
    if (textController.text.length >= 3) {
      String t = textController.text.toLowerCase();
      tempTermosFiltered =
          termos.where((e) => e.termo.toLowerCase().contains(t)).toList();
    } else {
      tempTermosFiltered = termos;
    }

    // Filtro por scroll
    if (termosFiltered.length == termos.length) {
      return;
    }

    if (tempTermosFiltered.length > termosFiltered.length) {
      setState(() {
        int additems = 0;
        if (tempTermosFiltered.length <= itensPerScroll) {
          additems = tempTermosFiltered.length;
        } else {
          int tlen = termos.length;
          int tflen = tempTermosFiltered.length;
          additems =
              (tflen + itensPerScroll) >= tlen ? tlen : tflen + itensPerScroll;
        }

        termosFiltered = tempTermosFiltered.sublist(0, additems);
      });
    }
  }

  Widget _buildLoader() {
    // Verifica se todos os termos foram carregados e se há termos filtrados
    int tflen = termosFiltered.length;
    bool isAllLoaded = termos.length == tflen && termosFiltered.isNotEmpty;

    // Se todos os termos foram carregados, exibe a mensagem "Fim dos registros"
    if (isAllLoaded) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
        child: Text(
          'Fim dos registros',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    // Caso contrário, retorna um widget vazio
    return const SizedBox.shrink();
  }

  void initTermos() async {
    categoria = await TermosTecnicos().getCategoria();

    List<Termo> tempTermos = _filtrarTermosPorCategoria();

    if (widget.favoritePage) {
      _filtrarEOrdenarTermosFavoritos(tempTermos);
    } else {
      termos = termosFiltered = tempTermos;
    }

    _limitarTermosFiltrados();

    setState(() {
      _isLoaded = true;
    });

    carregaComentarios();
  }

  List<Termo> _filtrarTermosPorCategoria() {
    return TermosTecnicos()
        .listaTermos
        .where((e) => e.categoria == categoria['descricao'])
        .toList();
  }

  void _filtrarEOrdenarTermosFavoritos(List<Termo> tempTermos) {
    termos = termosFiltered = tempTermos.where((e) => e.favorito).toList();
    termos.sort((a, b) => a.termo.compareTo(b.termo));
    termosFiltered.sort((a, b) => a.termo.compareTo(b.termo));
  }

  void _limitarTermosFiltrados() {
    bool isFinal = termosFiltered.length > itensPerScroll;
    termosFiltered = termosFiltered.sublist(
        0, isFinal ? itensPerScroll : termosFiltered.length);
  }

  Future<void> setFavorito(Termo item) async {
    bool result = await TermosTecnicos().setFavorito(item.id);
    if (result) {
      item.favorito = !item.favorito;
    }
    setState(() {});
  }

  // void _alterarVisibilidade(Termo item) {
  //   setState(() {
  //     item.visible = !item.visible;
  //     item.isComment = false;
  //   });
  // }

  String _titleSession() {
    if (categoria.isEmpty) {
      return 'Termos - Carregando';
    }

    String descricao = categoria['descricao'];
    if (widget.favoritePage) {
      return 'Favoritos - $descricao';
    } else {
      return 'Termos - $descricao';
    }
  }

  @override
  Widget build(BuildContext context) {
    returnScope.setContext(context);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Center(
          child: SizedBox(
            width: 1120,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _titleBar(),
                    const SizedBox(height: 8),
                    SearchTextFieldWidget(controller: textController),
                    const SizedBox(height: 8),
                    _termosContent(),
                    if (_isLoaded) _buildLoader()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _termosContent() {
    if (_isLoaded && widget.favoritePage && termosFiltered.isEmpty) {
      return _semFavoritos();
    }

    if (_isLoaded && termosFiltered.isEmpty && termos.isNotEmpty) {
      return _nenhumRegistro();
    }

    if (_isLoaded && termosFiltered.isNotEmpty) {
      return _listViewItems();
    }

    return _carregando();
  }

  Widget _nenhumRegistro() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text('Nenhum registro encontrado'),
      ),
    );
  }

  Widget _carregando() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _semFavoritos() {
    return const SizedBox(
      width: double.infinity,
      height: 300,
      child: Image(
        image: AssetImage('assets/semfavoritos.png'),
        height: 200,
      ),
    );
  }

  Widget _listViewItems() {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;

    if (screenWidth < 600) {
      crossAxisCount = 1;
    } else if (screenWidth < 900) {
      crossAxisCount = 2;
    } else if (screenWidth < 1100) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 3;
    }

    return StaggeredGrid.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        for (var item in termosFiltered) _personalizedListTile(item),
      ],
    );
  }

  Widget _optionsTile(Termo item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buttomIcon(
            icon: item.favorito ? Icons.favorite : Icons.favorite_border,
            color: Colors.red,
            onPressed: () => setFavorito(item),
          ),
          buttomIcon(
            icon: Icons.copy,
            color: Colors.grey,
            onPressed: () => TermosTecnicos().copiarTexto(item),
          ),
          buttomIcon(
            icon: Icons.share,
            color: Colors.blue,
            onPressed: () => TermosTecnicos().compartilhar(item),
          ),
          buttomIcon(
            icon: Icons.open_in_new,
            color: Colors.green,
            onPressed: () => TermosTecnicos().abrirExterno(item),
          ),
          buttomIcon(
            icon: FontAwesome.volume_low_solid,
            color: Colors.grey.shade700,
            onPressed: () {
              if (!AdmobRepository().isPremiumAd.value) {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Recursos Avançados'),
                    content: const Text(
                        'Para utilizar a função de transcrição para voz, '
                        'é necessario uma pequena quantidade do seu tempo '
                        'nos ajudando com consumo de publicidade. '
                        'Mais detalhes em opções.'),
                    actions: [
                      OutlinedButton(
                        onPressed: () {
                          Get.back();
                          Navigator.of(context).pushNamed('/config');
                        },
                        child: const Text('Acessar'),
                      ),
                    ],
                  ),
                );
              } else {
                _ttsService.speak('${item.termo} - ${item.descricao}');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _personalizedListTile(Termo item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.termo,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    FontAwesome.up_right_and_down_left_from_center_solid,
                    size: 14,
                  ),
                  onPressed: () => _dialogTermo(item),
                ),
              ],
            ),
            Text(
              (item.descricao.length > 100
                  ? '${item.descricao.substring(0, 100)}...'
                  : item.descricao),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  Widget buttomIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          size: 20,
          color: color,
        ),
      ),
    );
  }

  Widget _titleBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        Text(
          _titleSession(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future _dialogTermo(Termo item) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
          width: 400,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.termo,
                maxLines: 1,
                style: const TextStyle(fontSize: 16),
              ),
              Text(item.descricao),
              _optionsTile(item),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Comentários', style: TextStyle(fontSize: 16)),
                  Divider(height: 8),
                ],
              ),
              ListView.builder(
                itemCount: comentarios
                    .where((c) => c.pkIdentificador == item.id)
                    .length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  var comentarioFiltrado = comentarios
                      .where((c) => c.pkIdentificador == item.id)
                      .toList()[index];
                  return ComentariosCard(
                    comentario: comentarioFiltrado,
                    ferramenta: '${item.termo} - ${categoria['descricao']}',
                    pkIdentificador: item.id,
                    onSave: () => carregaComentarios(),
                  );
                },
              ),
              ComentariosCard(
                  isFixed: true,
                  ferramenta: '${item.termo} - ${categoria['descricao']}',
                  pkIdentificador: item.id,
                  onSave: () => carregaComentarios()),
            ],
          ),
        ),
      ),
    );
  }
}
