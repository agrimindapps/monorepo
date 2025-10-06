import 'package:flutter/material.dart';

import '../classes/cultura_class.dart';
import '../repository/culturas_repository.dart';
import 'culturas_dialog.dart';

class CulturaListPage extends StatefulWidget {
  const CulturaListPage({super.key});

  @override
  _CulturaListPageState createState() => _CulturaListPageState();
}

class _CulturaListPageState extends State<CulturaListPage> {
  final CulturaRepository _repository = CulturaRepository();
  late Future<List<Cultura>> _culturas;

  @override
  void initState() {
    super.initState();
    _culturas = _repository.getAllCulturas();
  }

  void _showEditDialog(Cultura? cultura) async {
    final result = await showDialog(
      context: context,
      builder: (context) => CulturaDialog(cultura: cultura),
    );
    if (result == true) {
      setState(() {
        _culturas = _repository.getAllCulturas();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Culturas')),
      body: FutureBuilder<List<Cultura>>(
        future: _culturas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final culturas = snapshot.data ?? [];
          return ListView.builder(
            itemCount: culturas.length,
            itemBuilder: (context, index) {
              final cultura = culturas[index];
              return ListTile(
                title: Text(cultura.cultura),
                subtitle: Text('Status: ${cultura.status}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showEditDialog(cultura),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await _repository.deleteCultura(cultura.objectId);
                        setState(() {
                          _culturas = _repository.getAllCulturas();
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
