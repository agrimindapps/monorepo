import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/base_model.dart';

BaseModel? getModelFromCollection(String colecao, Map<String, dynamic> map) {
  switch (colecao) {
    default:
      debugPrint('Nenhum modelo encontrado para a coleção: $colecao');
      return null;
  }
}

class SincronizacaoService {
  static final SincronizacaoService _instance =
      SincronizacaoService._internal();

  factory SincronizacaoService() {
    return _instance;
  }

  SincronizacaoService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sincronizarDados<T>({
    required String colecao,
    required int ultimaDataSincronismo,
  }) async {
    if (!await hasInternetConnection()) {
      debugPrint('Sem conexão com a internet. Sincronização não realizada.');
      return;
    }

    Box<T>? localBox;

    try {
      final userId = _auth.currentUser;
      if (userId == null) {
        debugPrint('Usuário não autenticado.');
        return;
      }
      // Buscar registros do Firestore
      QuerySnapshot firebaseSnapshot =
          await _firestore
              .collection('users')
              .doc(userId.uid)
              .collection(colecao)
              .where('updatedAt', isGreaterThan: ultimaDataSincronismo)
              .get();

      List<Map<String, dynamic>> firebaseRegistros =
          firebaseSnapshot.docs
              .map(
                (doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>},
              )
              .toList();

      debugPrint('Registros no Firebase: ${firebaseRegistros.length}');

      // Abre a box correspondente ao nome da coleção
      if (Hive.isBoxOpen(colecao)) {
        var box = Hive.box(colecao);
        if (box is Box<T>) {
          localBox = box;
        } else {
          debugPrint('Box "$colecao" is open but has wrong type.');
          // Optionally, close the box and reopen with the correct type
          await box.close();
          localBox = await Hive.openBox<T>(colecao);
        }
      } else {
        localBox = await Hive.openBox<T>(colecao);
      }

      List<BaseModel> localRegistros =
          localBox.values.cast<BaseModel>().toList();

      // Inserir registros do Firebase que não existem localmente
      for (var registroFirebase in firebaseRegistros) {
        var existeLocal = localRegistros.any(
          (local) => local.id == registroFirebase['id'],
        );
        if (!existeLocal) {
          debugPrint(
            'Inserindo registro localmente: ${registroFirebase['id']}',
          );

          BaseModel? novoRegistro = getModelFromCollection(
            colecao,
            registroFirebase,
          );
          if (novoRegistro != null) {
            localBox.put(registroFirebase['id'], novoRegistro as T);
          }
        }
      }

      // Inserir registros locais que não existem no Firebase
      for (var registroLocal in localRegistros) {
        var existeFirebase = firebaseRegistros.any(
          (firebase) => firebase['id'] == registroLocal.id,
        );
        if (!existeFirebase) {
          await _firestore
              .collection('users')
              .doc(userId.uid)
              .collection(colecao)
              .doc(registroLocal.id)
              .set(registroLocal.toMap());
        }
      }

      // Atualizar registros existentes baseado no campo updatedAt
      for (var registroFirebase in firebaseRegistros) {
        var registroLocal = localRegistros.firstWhere(
          (local) => local.id == registroFirebase['id'],
          orElse: () => null as BaseModel,
        );

        if (registroLocal != null) {
          int localUpdatedAt = registroLocal.updatedAt;
          int firebaseUpdatedAt = registroFirebase['updatedAt'] as int;

          if (localUpdatedAt < firebaseUpdatedAt) {
            // Atualizar local com os dados do Firebase
            BaseModel? novoRegistro = getModelFromCollection(
              colecao,
              registroFirebase,
            );
            if (novoRegistro != null) {
              localBox.put(registroFirebase['id'], novoRegistro as T);
            }
          } else if (localUpdatedAt > firebaseUpdatedAt) {
            // Atualizar Firebase com os dados locais
            await _firestore
                .collection('users')
                .doc(userId.uid)
                .collection(colecao)
                .doc(registroLocal.id)
                .update(registroLocal.toMap());
          }
        }
      }

      // fechar a box ao final
      await localBox.close();
    } on FirebaseException catch (e) {
      debugPrint('Erro do Firebase: ${e.message}');
    } catch (e) {
      debugPrint('Erro inesperado: $e');
    }
  }

  /// Verifica conexão com a internet
  Future<bool> hasInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  // Verifica se o usuário está logado
  Future<bool> usuarioEstaLogado() async {
    return _auth.currentUser != null;
  }

  /// Atualiza a data do último sincronismo no localStorage
  Future<void> atualizarUltimaDataSincronismo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int dt = DateTime.now().millisecondsSinceEpoch;
    await prefs.setString('ultimaSincronismo', dt.toString());
    debugPrint('Data do último sincronismo atualizada.');
  }

  /// Recupera a data do último sincronismo do localStorage
  Future<int> obterUltimaDataSincronismo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('ultimaSincronismo');
    return data != null ? int.parse(data) : 0;
  }
}

// Exemplo de sicronismo de varias coleções ao mesmo tempo
// Future<void> sincronizarVariasColecoesParaleloComErros(List<String> colecoes) async {
//   List<Future<void>> tarefas = [];

//   for (String colecao in colecoes) {
//     tarefas.add(() async {
//       try {
//         DateTime ultimaDataSincronismo = await obterUltimaDataSincronismo(colecao) ??
//             DateTime.fromMillisecondsSinceEpoch(0);

//         print('Sincronizando $colecao...');
//         await sincronizarDados(
//           colecao: colecao,
//           ultimaDataSincronismo: ultimaDataSincronismo,
//         );
//         print('$colecao sincronizada.');
//       } catch (e) {
//         print('Erro ao sincronizar $colecao: $e');
//       }
//     }());
//   }

//   await Future.wait(tarefas);
//   print('Sincronização de todas as coleções concluída.');
// }
