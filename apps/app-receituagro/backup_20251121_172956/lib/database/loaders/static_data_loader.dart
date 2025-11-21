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

  /// Carrega informações complementares de plantas/culturas do JSON
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

        // Precisamos encontrar o culturaId correspondente
        // O idReg no PlantasInf corresponde ao idCultura na tabela Culturas
        final culturaQuery = db.select(db.culturas)
          ..where((c) => c.idCultura.equals(idReg));
        final cultura = await culturaQuery.getSingleOrNull();

        if (cultura == null) {
          developer.log(
            'Cultura not found for idReg: $idReg, skipping plantas info',
            name: 'StaticDataLoader',
          );
          continue;
        }

        await db
            .into(db.plantasInf)
            .insert(
              PlantasInfCompanion.insert(
                idReg: idReg,
                culturaId: cultura.id,
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
                margemFolha: Value(data['margemFolha'] as String?),
                folha: Value(data['folha'] as String?),
                base: Value(data['base'] as String?),
                formaBase: Value(data['formaBase'] as String?),
                apice: Value(data['apice'] as String?),
                formaApice: Value(data['formaApice'] as String?),
                tipoFlor: Value(data['tipoFlor'] as String?),
                corFlor: Value(data['corFlor'] as String?),
                tipoFruto: Value(data['tipoFruto'] as String?),
                corFruto: Value(data['corFruto'] as String?),
                tipoSemente: Value(data['tipoSemente'] as String?),
                corSemente: Value(data['corSemente'] as String?),
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
        'assets/database/json/tbplantasinf/TBPLANTASINF.json',
      );
      final jsonList = json.decode(jsonString) as List<dynamic>;

      developer.log(
        'Loading ${jsonList.length} pragas info...',
        name: 'StaticDataLoader',
      );

      int loaded = 0;
      for (final item in jsonList) {
        final data = item as Map<String, dynamic>;

        final idReg = data['idReg'] as String?;
        if (idReg == null) continue;

        // Precisamos encontrar o pragaId correspondente
        // O idReg no PragasInf corresponde ao idPraga na tabela Pragas
        final pragaQuery = db.select(db.pragas)
          ..where((p) => p.idPraga.equals(idReg));
        final praga = await pragaQuery.getSingleOrNull();

        if (praga == null) {
          developer.log(
            'Praga not found for idReg: $idReg, skipping info',
            name: 'StaticDataLoader',
          );
          continue;
        }

        await db
            .into(db.pragasInf)
            .insert(
              PragasInfCompanion.insert(
                idReg: idReg,
                pragaId: praga.id,
                sintomas: Value(data['sintomas'] as String?),
                controle: Value(data['controle'] as String?),
                danos: Value(data['danos'] as String?),
                condicoesFavoraveis: Value(
                  data['condicoesFavoraveis'] as String?,
                ),
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
    final files = [
      'TBFITOSSANITARIOS_FUNGICIDAS_BACTERICIDAS.json',
      'TBFITOSSANITARIOS_HERBICIDAS.json',
      'TBFITOSSANITARIOS_INSETICIDAS_ACARICIDAS.json',
      'TBFITOSSANITARIOS_ADJUVANTES.json',
      'TBFITOSSANITARIOS_BIOLOGICOS.json',
    ];

    int totalLoaded = 0;

    for (final file in files) {
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

          // JSON: idReg, nomeComum (produto comercial)
          // Drift: idDefensivo, nome, nomeComum, fabricante, classe, classeAgronomica, ingredienteAtivo, registroMapa, status, comercializado, elegivel
          final idReg = data['idReg'] as String?;
          final nomeComum = data['nomeComum'] as String?;
          final nomeTecnico = data['nomeTecnico'] as String?;
          final fabricante = data['fabricante'] as String?;
          final classeAgronomica = data['classeAgronomica'] as String?;
          final ingredienteAtivo = data['ingredienteAtivo'] as String?;
          final mapa = data['mapa'] as String?;
          final status = data['status'] != null ? data['status'] as bool : true;
          final comercializado = data['comercializado'] != null
              ? data['comercializado'] as int
              : 1;
          final elegivel = data['elegivel'] != null
              ? data['elegivel'] as bool
              : true;

          if (idReg == null || nomeComum == null) {
            continue;
          }

          // Inferir classe do nome do arquivo
          String? classe;
          if (file.contains('FUNGICIDAS')) {
            classe = 'fungicida';
          } else if (file.contains('HERBICIDAS')) {
            classe = 'herbicida';
          } else if (file.contains('INSETICIDAS')) {
            classe = 'inseticida';
          } else if (file.contains('ADJUVANTES')) {
            classe = 'adjuvante';
          } else if (file.contains('BIOLOGICOS')) {
            classe = 'biológico';
          }

          await db
              .into(db.fitossanitarios)
              .insert(
                FitossanitariosCompanion.insert(
                  idDefensivo: idReg,
                  nome: nomeTecnico ?? nomeComum,
                  nomeComum: Value(nomeComum),
                  fabricante: Value(fabricante),
                  classe: Value(classe),
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
      } catch (e, stack) {
        developer.log(
          'Error loading fitossanitarios from $file: $e',
          name: 'StaticDataLoader',
          error: e,
          stackTrace: stack,
        );
        // Continua com os próximos arquivos
      }
    }

    developer.log(
      'Loaded $totalLoaded total fitossanitarios',
      name: 'StaticDataLoader',
    );
  }

  /// Carrega informações de fitossanitários dos JSONs
  Future<void> loadFitossanitariosInfo() async {
    // Lista todos os arquivos TBFITOSSANITARIOSINFO_*.json
    // Como não podemos listar diretórios em assets, usamos lista conhecida
    final prefixes = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z',
    ];

    int totalLoaded = 0;

    for (final prefix in prefixes) {
      final file = 'TBFITOSSANITARIOSINFO_$prefix.json';

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

          // Encontrar o defensivoId correspondente
          final defensivoQuery = db.select(db.fitossanitarios)
            ..where((f) => f.idDefensivo.equals(idReg));
          final defensivo = await defensivoQuery.getSingleOrNull();

          if (defensivo == null) {
            // Info sem defensivo correspondente - pode ser que ainda não foi carregado
            continue;
          }

          await db
              .into(db.fitossanitariosInfo)
              .insert(
                FitossanitariosInfoCompanion.insert(
                  idReg: idReg,
                  defensivoId: defensivo.id,
                  modoAcao: Value(data['modoAcao'] as String?),
                  formulacao: Value(data['formulacao'] as String?),
                  toxicidade: Value(data['toxicidade'] as String?),
                  carencia: Value(data['carencia'] as String?),
                  informacoesAdicionais: Value(
                    data['informacoesAdicionais'] as String?,
                  ),
                ),
                mode: InsertMode.insertOrIgnore,
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
      } catch (e) {
        // Arquivo pode não existir, ignora silenciosamente
        continue;
      }
    }

    developer.log(
      'Loaded $totalLoaded total fitossanitarios info',
      name: 'StaticDataLoader',
    );
  }
}
