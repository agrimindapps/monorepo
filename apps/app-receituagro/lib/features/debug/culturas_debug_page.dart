import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart' as di;
import '../../core/repositories/cultura_core_repository.dart';
import '../../core/services/culturas_data_loader.dart';

class CulturasDebugPage extends StatefulWidget {
  const CulturasDebugPage({super.key});

  @override
  State<CulturasDebugPage> createState() => _CulturasDebugPageState();
}

class _CulturasDebugPageState extends State<CulturasDebugPage> {
  Map<String, dynamic>? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => isLoading = true);
    
    final loadedStats = await CulturasDataLoader.getStats();
    
    setState(() {
      stats = loadedStats;
      isLoading = false;
    });
  }

  Future<void> _forceReload() async {
    setState(() => isLoading = true);
    
    await CulturasDataLoader.forceReload();
    await _loadStats();
  }

  Future<void> _testRepository() async {
    setState(() => isLoading = true);
    
    try {
      final repository = di.sl<CulturaCoreRepository>();
      final culturas = await repository.getAllAsync();
      
      print('Repository test: ${culturas.length} culturas');
      for (final cultura in culturas.take(5)) {
        print('- ${cultura.cultura} (${cultura.idReg})');
      }
      
      await _loadStats();
    } catch (e) {
      print('Erro no teste do repositório: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Culturas Debug'),
        actions: [
          IconButton(
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estatísticas de Culturas',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          if (stats != null) ...[
                            Text('Total de culturas: ${stats!['total_culturas']}'),
                            Text('Status carregado: ${stats!['is_loaded']}'),
                            if (stats!['error'] != null)
                              Text(
                                'Erro: ${stats!['error']}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            if (stats!['sample_culturas'] != null) ...[
                              const SizedBox(height: 8),
                              const Text('Exemplos:'),
                              ...((stats!['sample_culturas'] as List<dynamic>)
                                  .map((cultura) => Text('• $cultura'))),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _forceReload,
                        child: const Text('Force Reload'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _testRepository,
                        child: const Text('Test Repository'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/culturas');
                    },
                    child: const Text('Ir para Lista Culturas'),
                  ),
                ],
              ),
      ),
    );
  }
}