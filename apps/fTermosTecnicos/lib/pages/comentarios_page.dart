import 'package:flutter/material.dart';
import '../core/widgets/appbar.dart';
import '../hive_models/comentarios_models.dart';
import '../repository/comentarios_repository.dart';
import '../widgets/comentarios_widget.dart';

class ComentariosPage extends StatefulWidget {
  const ComentariosPage({super.key});

  @override
  ComentariosPageState createState() => ComentariosPageState();
}

class ComentariosPageState extends State<ComentariosPage> {
  final ComentariosRepository _repository = ComentariosRepository();
  final List<Comentarios> _comentarios = [];

  @override
  void initState() {
    super.initState();
    _fetchComentarios();
  }

  Future<void> _fetchComentarios() async {
    final comentarios = await _repository.getAllComentarios();
    comentarios.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _comentarios.addAll(comentarios);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: const Text('Comentários'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.info_outline),
      //       onPressed: () => _dialogComentariosLocais(),
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 1120,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _titleBar(),
                  _comentariosCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _comentariosCard() {
    return _comentarios.isEmpty
        ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                width: 280,
                child: Text(
                  'Nenhum comentário disponível. Adicione novos comentários via Termos.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        : ListView.builder(
            itemCount: _comentarios.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final comentario = _comentarios[index];
              return ComentariosCard(
                comentario: comentario,
                ferramenta: comentario.ferramenta,
                pkIdentificador: comentario.id,
                // onSave: () => _fetchComentarios(),
                // onDelete: () => _fetchComentarios(),
              );
            },
          );
  }

  // Dialog explicando que os comentários são locais e pessoais
  Future _dialogComentariosLocais() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comentários locais'),
        content: const SizedBox(
          width: 400,
          child: Text(
            'Os comentários são locais e pessoais, ou seja, '
            'não são compartilhados com outros usuários. '
            'Você pode adicionar, editar e excluir comentários livremente.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  Widget _titleBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        const Text(
          'Comentários',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _dialogComentariosLocais(),
        ),
      ],
    );
  }
}
