import 'package:flutter/material.dart';

import '../core/models/database.dart';
import '../hive_models/comentarios_models.dart';
import '../repository/comentarios_repository.dart';

class ComentariosCard extends StatefulWidget {
  final Comentarios? comentario;
  final String? ferramenta;
  final String? pkIdentificador;
  final Function? onSave;
  final Function? onDelete;
  final bool isFixed;

  const ComentariosCard({
    super.key,
    this.comentario,
    required this.ferramenta,
    required this.pkIdentificador,
    this.onSave,
    this.onDelete,
    this.isFixed = false,
  });

  @override
  ComentariosCardState createState() => ComentariosCardState();
}

class ComentariosCardState extends State<ComentariosCard> {
  final ComentariosRepository _repository = ComentariosRepository();
  final TextEditingController _controller = TextEditingController();
  int quantComentarios = 0;

  late Comentarios localComentario;
  bool isEditing = true;
  bool isDeleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.comentario != null) {
      localComentario = widget.comentario!;
      _controller.text = widget.comentario!.conteudo;
      isEditing = false;
    } else {
      isEditing = true;
    }
    _quantComentarios();
  }

  void _quantComentarios() async {
    var comments = await _repository.getAllComentarios();
    quantComentarios = comments.length;
    setState(() {});
  }

  void _toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing && widget.comentario != null) {
        _controller.text = widget.comentario!.conteudo;
      }
    });
  }

  void _saveComentario() {
    if (_controller.text.trim().length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O comentário deve ter pelo menos 5 caracteres'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    var newComentario = Comentarios(
      id: widget.comentario?.id ??
          (DateTime.now()).millisecondsSinceEpoch.toString(),
      createdAt: widget.comentario?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      status: true,
      idReg: widget.comentario?.idReg ?? Database().generateIdReg(),
      titulo: '',
      conteudo: _controller.text,
      ferramenta: widget.ferramenta!,
      pkIdentificador: widget.pkIdentificador!,
    );

    if (widget.comentario == null) {
      _repository.addComentario(newComentario);
      _quantComentarios();
    } else {
      _repository.updateComentario(newComentario);
    }

    widget.comentario?.conteudo = newComentario.conteudo;
    localComentario = newComentario;

    setState(() {
      if (widget.isFixed) {
        _controller.clear();
        isEditing = true;
      } else {
        isEditing = false;
      }
    });

    if (widget.onSave != null) {
      widget.onSave!();
    }
  }

  void _deleteComentario() {
    setState(() {
      if (widget.comentario != null) {
        _repository.deleteComentario(widget.comentario!.id);
        _quantComentarios();
        isDeleted = true;
      }

      if (widget.onDelete != null) {
        widget.onDelete!();
      }
    });
  }

  void _clearComentario() {
    _controller.clear();
    setState(() {});
  }

  String _formatData(DateTime data) {
    return data.toString().substring(0, 10).split('-').reversed.join('/');
  }

  @override
  Widget build(BuildContext context) {
    if (quantComentarios >= _repository.maxComentarios && widget.isFixed) {
      return const SizedBox(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
              'Limite de comentários atingido. Exclua um comentário para adicionar um novo, ou assine o plano premium.',
              textAlign: TextAlign.center),
        ),
      );
    }

    if (isDeleted) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: isEditing
              ? const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0)
              : const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 0.0),
          child: isEditing
              ? Column(
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: 4,
                      maxLength: 200,
                      decoration: InputDecoration(
                        hintText: 'Digite seu comentário',
                        contentPadding:
                            const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        counterStyle: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          color: Theme.of(context).primaryColorDark,
                          icon: const Icon(Icons.cleaning_services_rounded),
                          onPressed: _clearComentario,
                        ),
                        IconButton(
                          color: Theme.of(context).primaryColorDark,
                          icon: const Icon(Icons.save),
                          onPressed: _saveComentario,
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                      child: Text(
                        localComentario.conteudo,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localComentario.ferramenta.split(' - ')[0],
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              localComentario.ferramenta.split(' - ').length > 1
                                  ? '${localComentario.ferramenta.split(' - ')[1]} - ${_formatData(localComentario.createdAt)}'
                                  : _formatData(localComentario.createdAt),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          color: Theme.of(context).primaryColorDark,
                          padding: const EdgeInsets.all(0.0),
                          icon: const Icon(Icons.edit),
                          onPressed: _toggleEditMode,
                        ),
                        IconButton(
                          color: Theme.of(context).primaryColorDark,
                          padding: const EdgeInsets.all(0.0),
                          icon: const Icon(Icons.delete),
                          onPressed: _deleteComentario,
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
