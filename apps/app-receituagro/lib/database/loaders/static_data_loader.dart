import 'dart:convert';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../receituagro_database.dart';

/// Carregador de dados estáticos do JSON para o Drift Database
///
/// Esta classe é responsável por carregar os dados estáticos das
/// tabelas de referência (culturas, pragas, fitossanitários) a partir
/// dos arquivos JSON na pasta assets/database/json/.
class StaticDataLoader {
  final ReceituagroDatabase db;

  StaticDataLoader(this.db);

  /// Carrega todos os dados estáticos
  Future<void> loadAll() async {
    developer.log('Starting static data load...', name: 'StaticDataLoader');

    await db.transaction(() async {
      await loadCulturas();
      await loadPlantasInf();
      await loadPragas();
      await loadPragasInf();
      await loadFitossanitarios();
      await loadFitossanitariosInfo();
    });

    developer.log('Static data load complete!', name: 'StaticDataLoader');
  }

  /// Carrega culturas do JSON
  Future<void> loadCulturas() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/database/json/tbculturas/TBCULTURAS.json',
      );
      final jsonList = json.decode(jsonString) as List<dynamic>;

      developer.log(
        'Loading ${jsonList.length} culturas...',
        name: 'StaticDataLoader',
      );

      int loaded = 0;
      for (final item in jsonList) {
        final data = item as Map<String, dynamic>;

        // JSON: idReg, cultura
        // Drift: idCultura, nome, nomeLatino, familia, imagemUrl, descricao
        final idReg = data['idReg'] as String?;
        final cultura = data['cultura'] as String?;

        if (idReg == null || cultura == null) {
          continue;
        }

        await db
            .into(db.culturas)
            .insert(
              CulturasCompanion.insert(
                idCultura: idReg,
                nome: cultura,
                // Campos opcionais não existem no JSON simples
              ),
              mode: InsertMode.insertOrIgnore,
            );
        loaded++;
      }

      developer.log('Loaded $loaded culturas', name: 'StaticDataLoader');
    } catch (e, stack) {
      developer.log(
        'Error loading culturas: $e',
        name: 'StaticDataLoader',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// Carrega informações complementares de plantas do JSON
  /// NOTA: PlantasInf referencia Pragas (plantas daninhas são pragas tipo 3), não Culturas
  Future<void> loadPlantasInf() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/database/json/tbplantasinf/TBPLANTASINF.json',
      );
      final jsonList = json.decode(jsonString) as List<dynamic>;

      developer.log(
        'Loading ${jsonList.length} plantas info...',
        name: 'StaticDataLoader',
      );

      int loaded = 0;
      for (final item in jsonList) {
        final data = item as Map<String, dynamic>;

        final idReg = data['idReg'] as String?;
        if (idReg == null) continue;

        // PlantasInf referencia Pragas via fkIdPraga (plantas daninhas = pragas tipo 3)
        final fkIdPraga = data['fkIdPraga'] as String? ?? idReg;

        await db
            .into(db.plantasInf)
            .insert(
              PlantasInfCompanion.insert(
                idReg: idReg,
                fkIdPraga: fkIdPraga,
                ciclo: Value(data['ciclo'] as String?),
                reproducao: Value(data['reproducao'] as String?),
                habitat: Value(data['habitat'] as String?),
                adaptacoes: Value(data['adaptacoes'] as String?),
                altura: Value(data['altura'] as String?),
                filotaxia: Value(data['filotaxia'] as String?),
                formaLimbo: Value(data['formaLimbo'] as String?),
                superficie: Value(data['superficie'] as String?),
                consistencia: Value(data['consistencia'] as String?),
                nervacao: Value(data['nervacao'] as String?),
                nervacaoComprimento: Value(
                  data['nervacaoComprimento'] as String?,
                ),
                inflorescencia: Value(data['inflorescencia'] as String?),
                perianto: Value(data['perianto'] as String?),
                tipoFruto: Value(data['tipoFruto'] as String?),
                observacoes: Value(data['observacoes'] as String?),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        loaded++;
      }

      developer.log('Loaded $loaded plantas info', name: 'StaticDataLoader');
    } catch (e, stack) {
      developer.log(
        'Error loading plantas info: $e',
        name: 'StaticDataLoader',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// Carrega pragas do JSON
  Future<void> loadPragas() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/database/json/tbpragas/TBPRAGAS.json',
      );
      final jsonList = json.decode(jsonString) as List<dynamic>;

      developer.log(
        'Loading ${jsonList.length} pragas...',
        name: 'StaticDataLoader',
      );

      int loaded = 0;
      for (final item in jsonList) {
        final data = item as Map<String, dynamic>;

        // JSON: idReg, nomeComum, nomeCientifico
        // Drift: idPraga, nome, nomeLatino, tipo, imagemUrl, descricao
        final idReg = data['idReg'] as String?;
        final nomeComum = data['nomeComum'] as String?;
        final nomeCientifico = data['nomeCientifico'] as String?;

        if (idReg == null || nomeComum == null) {
          continue;
        }

        await db
            .into(db.pragas)
            .insert(
              PragasCompanion.insert(
                idPraga: idReg,
                nome: nomeComum,
                nomeLatino: Value(nomeCientifico),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        loaded++;
      }

      developer.log('Loaded $loaded pragas', name: 'StaticDataLoader');
    } catch (e, stack) {
      developer.log(
        'Error loading pragas: $e',
        name: 'StaticDataLoader',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// Carrega informações de pragas do JSON
  Future<void> loadPragasInf() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/database/json/tbpragasinf/TBPRAGASINF.json',
      );
      final jsonList = json.decode(jsonString) as List<dynamic>;

      developer.log(
        'Loading ${jsonList.length} pragas info...',
        name: 'StaticDataLoader',
      );

      // LIMPAR DADOS EXISTENTES antes de inserir novos
      developer.log(
        '🗑️ Clearing existing pragas info data...',
        name: 'StaticDataLoader',
      );
      await db.delete(db.pragasInf).go();

      int loaded = 0;
      for (final item in jsonList) {
        final data = item as Map<String, dynamic>;

        final idReg = data['idReg'] as String?;
        if (idReg == null) continue;

        // fkIdPraga é a FK para Pragas (string)
        final fkIdPraga = data['fkIdPraga'] as String? ?? idReg;

        await db
            .into(db.pragasInf)
            .insert(
              PragasInfCompanion.insert(
                idReg: idReg,
                fkIdPraga: fkIdPraga,
                descricao: Value(data['descrisao'] as String?), // typo no JSON
                sintomas: Value(data['sintomas'] as String?),
                bioecologia: Value(data['bioecologia'] as String?),
                controle: Value(data['controle'] as String?),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        loaded++;
      }

      developer.log('Loaded $loaded pragas info', name: 'StaticDataLoader');
    } catch (e, stack) {
      developer.log(
        'Error loading pragas info: $e',
        name: 'StaticDataLoader',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// Carrega fitossanitários dos JSONs
  Future<void> loadFitossanitarios() async {
    int fileIndex = 0;
    int totalLoaded = 0;

    while (true) {
      final file = 'TBFITOSSANITARIOS$fileIndex.json';
      try {
        final jsonString = await rootBundle.loadString(
          'assets/database/json/tbfitossanitarios/$file',
        );
        final jsonList = json.decode(jsonString) as List<dynamic>;

        developer.log(
          'Loading ${jsonList.length} fitossanitarios from $file...',
          name: 'StaticDataLoader',
        );

        int loaded = 0;
        for (final item in jsonList) {
          final data = item as Map<String, dynamic>;

          // JSON fields: idReg, nomeComum, nomeTecnico, formulacao, modoAcao, 
          // toxico, classAmbiental, corrosivo, inflamavel, quantProduto
          final idReg = data['idReg'] as String?;
          final nomeComum = data['nomeComum'] as String?;
          final nomeTecnico = data['nomeTecnico'] as String?;
          final formulacao = data['formulacao'] as String?;
          final modoAcao = data['modoAcao'] as String?;
          final toxico = data['toxico'] as String?;
          final classAmbiental = data['classAmbiental'] as String?;
          final corrosivo = data['corrosivo'] as String?;
          final inflamavel = data['inflamavel'] as String?;
          final quantProduto = data['quantProduto'] as String?;
          
          // Optional fields from extended JSON
          final fabricante = data['fabricante'] as String?;
          final classeAgronomica = data['classeAgronomica'] as String?;
          final ingredienteAtivo = data['ingredienteAtivo'] as String?;
          final mapa = data['mapa'] as String?;
          final status = data['status'] != null ? data['status'] as bool : true;
          final comercializado = data['comercializado'] != null
              ? int.tryParse(data['comercializado'].toString()) ?? 1
              : 1;
          final elegivel = data['elegivel'] != null
              ? data['elegivel'] as bool
              : true;

          if (idReg == null || nomeComum == null) {
            continue;
          }

          // Inserir Fitossanitario com todos os campos do JSON
          await db
              .into(db.fitossanitarios)
              .insert(
                FitossanitariosCompanion.insert(
                  idDefensivo: idReg,
                  nome: nomeComum,
                  nomeTecnico: Value(nomeTecnico),
                  formulacao: Value(formulacao),
                  modoAcao: Value(modoAcao),
                  classeToxico: Value(toxico),
                  classeAmbiental: Value(classAmbiental),
                  corrosivo: Value(corrosivo),
                  inflamavel: Value(inflamavel),
                  quantProduto: Value(quantProduto),
                  fabricante: Value(fabricante),
                  classeAgronomica: Value(classeAgronomica),
                  ingredienteAtivo: Value(ingredienteAtivo),
                  registroMapa: Value(mapa),
                  status: Value(status),
                  comercializado: Value(comercializado),
                  elegivel: Value(elegivel),
                ),
                mode: InsertMode.insertOrIgnore,
              );

          loaded++;
        }

        totalLoaded += loaded;
        developer.log(
          'Loaded $loaded fitossanitarios from $file',
          name: 'StaticDataLoader',
        );
        fileIndex++;
      } catch (e) {
        // Arquivo não encontrado, fim da lista
        developer.log(
          'Finished loading fitossanitarios files. Last file index: ${fileIndex - 1}',
          name: 'StaticDataLoader',
        );
        break;
      }
    }

    developer.log(
      'Loaded $totalLoaded total fitossanitarios',
      name: 'StaticDataLoader',
    );
  }

  /// Carrega informações de fitossanitários dos JSONs
  /// TBFITOSSANITARIOSINFO contém dados detalhados: embalagens, tecnologia, precauções, etc.
  Future<void> loadFitossanitariosInfo() async {
    int fileIndex = 0;
    int totalLoaded = 0;

    while (true) {
      final file = 'TBFITOSSANITARIOSINFO$fileIndex.json';

      try {
        final jsonString = await rootBundle.loadString(
          'assets/database/json/tbfitossanitariosinfo/$file',
        );
        final jsonList = json.decode(jsonString) as List<dynamic>;

        int loaded = 0;
        for (final item in jsonList) {
          final data = item as Map<String, dynamic>;

          final idReg = data['idReg'] as String?;
          if (idReg == null) continue;

          // fkIdDefensivo é a FK para Fitossanitarios (string)
          final fkIdDefensivo = data['fkIdDefensivo'] as String? ?? idReg;

          // Inserir FitossanitariosInfo com todos os campos do JSON
          await db.into(db.fitossanitariosInfo).insert(
                FitossanitariosInfoCompanion.insert(
                  idReg: idReg,
                  fkIdDefensivo: fkIdDefensivo,
                  embalagens: Value(data['embalagens'] as String?),
                  tecnologia: Value(data['tecnologia'] as String?),
                  precaucoesHumanas: Value(data['pHumanas'] as String?),
                  precaucoesAmbientais: Value(data['pAmbiental'] as String?),
                  manejoResistencia: Value(data['manejoResistencia'] as String?),
                  compatibilidade: Value(data['compatibilidade'] as String?),
                  manejoIntegrado: Value(data['manejoIntegrado'] as String?),
                ),
                mode: InsertMode.insertOrReplace,
              );
          loaded++;
        }

        totalLoaded += loaded;
        if (loaded > 0) {
          developer.log(
            'Loaded $loaded fitossanitarios info from $file',
            name: 'StaticDataLoader',
          );
        }
        fileIndex++;
      } catch (e) {
        // Arquivo não encontrado
        developer.log(
          'Finished loading fitossanitarios info files. Last file index: ${fileIndex - 1}',
          name: 'StaticDataLoader',
        );
        break;
      }
    }

    developer.log(
      'Loaded $totalLoaded total fitossanitarios info',
      name: 'StaticDataLoader',
    );
  }
}
