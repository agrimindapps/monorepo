import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'lib/core/sync/receituagro_sync_config.dart';
import 'lib/features/favoritos/domain/entities/favorito_sync_entity.dart';

/// Teste simples da correção de sincronização
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Teste Sync Fix')),
        body: SyncTestWidget(),
      ),
    );
  }
}

class SyncTestWidget extends StatefulWidget {
  @override
  _SyncTestWidgetState createState() => _SyncTestWidgetState();
}

class _SyncTestWidgetState extends State<SyncTestWidget> {
  String _statusMessage = 'Iniciando teste...';
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    _runTest();
  }

  Future<void> _runTest() async {
    setState(() {
      _testing = true;
      _statusMessage = '🔍 Iniciando teste da correção P0...';
    });

    try {
      // 1. Inicializar sync config
      setState(() => _statusMessage = '📋 Inicializando ReceitaAgroSyncConfig...');
      await ReceitaAgroSyncConfig.configure();
      
      setState(() => _statusMessage = '✅ ReceitaAgroSyncConfig inicializado');
      await Future.delayed(Duration(seconds: 1));

      // 2. Testar criação de favorito
      setState(() => _statusMessage = '🚀 Testando criação de favorito...');
      
      final testEntity = FavoritoSyncEntity(
        id: 'test_favorito_${DateTime.now().millisecondsSinceEpoch}',
        tipo: 'defensivo',
        itemId: 'test_item_456',
        itemData: {'nome': 'Produto Teste', 'categoria': 'Fungicida'},
        adicionadoEm: DateTime.now(),
        userId: 'test_user_123',
        moduleName: 'receituagro',
      );

      final result = await UnifiedSyncManager.instance.create<FavoritoSyncEntity>('receituagro', testEntity);
      
      result.fold(
        (failure) {
          setState(() => _statusMessage = '❌ ERRO: ${failure.message}');
          developer.log('❌ Teste falhou: ${failure.message}', name: 'SyncTest');
        },
        (entityId) {
          setState(() => _statusMessage = '✅ SUCESSO! Favorito criado: $entityId');
          developer.log('✅ Teste passou: Favorito criado com ID $entityId', name: 'SyncTest');
        },
      );

    } catch (e) {
      setState(() => _statusMessage = '❌ EXCEÇÃO: $e');
      developer.log('❌ Exceção durante teste: $e', name: 'SyncTest');
    } finally {
      setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Teste da Correção P0 - String-based Type Registration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 16,
                      color: _statusMessage.contains('✅') ? Colors.green :
                             _statusMessage.contains('❌') ? Colors.red :
                             Colors.blue,
                    ),
                  ),
                  
                  if (_testing) ...[
                    SizedBox(height: 16),
                    LinearProgressIndicator(),
                  ],
                  
                  if (!_testing) ...[
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _runTest,
                      child: Text('Executar Teste Novamente'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          SizedBox(height: 20),
          Text(
            'Correção Implementada:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '• Substituído Map<Type, ...> por Map<String, ...>\n'
            '• Método _getSyncRepository usa T.toString()\n'
            '• Registro de entidades usa entityType.toString()\n'
            '• Debug info atualizado para strings',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}