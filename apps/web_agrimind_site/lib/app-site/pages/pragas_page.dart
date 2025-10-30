import 'package:flutter/material.dart';

import '../classes/pragas_class.dart';
import '../repository/pragas_repository.dart';
import 'pragas_dialog.dart';

class PragasListPage extends StatefulWidget {
  @override
  _PragasListPageState createState() => _PragasListPageState();
}

class _PragasListPageState extends State<PragasListPage> {
  final PragasRepository _repository = PragasRepository();
  late Future<List<Pragas>> _pragas;

  @override
  void initState() {
    super.initState();
    _pragas = _repository.getAllPragas();
  }

  void _showEditDialog(Pragas? praga) async {
    final result = await showDialog(
      context: context,
      builder: (context) => PragasDialog(praga: praga),
    );
    if (result == true) {
      setState(() {
        _pragas = _repository.getAllPragas();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pragas')),
      body: FutureBuilder<List<Pragas>>(
        future: _pragas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final pragas = snapshot.data ?? [];
          return ListView.builder(
            itemCount: pragas.length,
            itemBuilder: (context, index) {
              final praga = pragas[index];
              return ListTile(
                title: Text(praga.nomeComum),
                subtitle: Text(praga.nomeCientifico),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showEditDialog(praga),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await _repository.deletePraga(praga.objectId);
                        setState(() {
                          _pragas = _repository.getAllPragas();
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
