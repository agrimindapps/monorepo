// fitossanitarios_page.dart
import 'package:flutter/material.dart';
import '../classes/fitossanitario_class.dart';
import '../repository/fitossanitarios_repository.dart';
import 'defensivos_dialog.dart';

class FitossanitariosPage extends StatefulWidget {
  final FitossanitarioRepository repository;

  const FitossanitariosPage({super.key, required this.repository});

  @override
  _FitossanitariosPageState createState() => _FitossanitariosPageState();
}

class _FitossanitariosPageState extends State<FitossanitariosPage> {
  late Future<List<Fitossanitario>> _fitossanitarios;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _fitossanitarios = widget.repository.fetchAll();
    });
  }

  void _openDialog([Fitossanitario? fitossanitario]) async {
    final updated = await showDialog<Fitossanitario>(
      context: context,
      builder: (context) => FitossanitarioDialog(
        repository: widget.repository,
        fitossanitario: fitossanitario,
      ),
    );

    if (updated != null) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fitossanitários')),
      body: FutureBuilder<List<Fitossanitario>>(
        future: _fitossanitarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final fitossanitarios = snapshot.data ?? [];

          return ListView.builder(
            itemCount: fitossanitarios.length,
            itemBuilder: (context, index) {
              final fitossanitario = fitossanitarios[index];

              return ListTile(
                title: Text(fitossanitario.nomeComum),
                subtitle: Text(fitossanitario.fabricante ?? 'Sem fabricante'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openDialog(fitossanitario),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await widget.repository.delete(fitossanitario.objectId);
                        _loadData();
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
        child: const Icon(Icons.add),
        onPressed: () => _openDialog(),
      ),
    );
  }
}
