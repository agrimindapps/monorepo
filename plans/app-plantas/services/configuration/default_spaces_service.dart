// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../constants/default_spaces_config.dart';
import '../../database/espaco_model.dart';

/// Service para gerenciar configurações de espaços padrão
///
/// Este service implementa:
/// - Customização via SharedPreferences
/// - Internacionalização das strings
/// - Suporte à configuração remota (futuro)
/// - Cache das configurações para performance
class DefaultSpacesService extends GetxService {
  static DefaultSpacesService get instance => Get.find<DefaultSpacesService>();

  SharedPreferences? _prefs;
  List<DefaultSpaceConfiguration>? _cachedSpaces;

  @override
  Future<void> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    await _loadConfiguration();
  }

  /// Carrega configuração dos espaços padrão
  Future<void> _loadConfiguration() async {
    try {
      // Verificar se deve usar configuração remota (futuro)
      final useRemoteConfig =
          _prefs?.getBool(DefaultSpacesConfig.useRemoteConfigKey) ?? false;

      if (useRemoteConfig) {
        // TODO: Implementar carregamento de configuração remota
        debugPrint(
            '🌐 Configuração remota não implementada ainda, usando padrão');
        _cachedSpaces = _getDefaultSpaces();
        return;
      }

      // Verificar se há configuração customizada no SharedPreferences
      final customSpacesJson =
          _prefs?.getString(DefaultSpacesConfig.customSpacesKey);

      if (customSpacesJson != null && customSpacesJson.isNotEmpty) {
        try {
          final List<dynamic> jsonList = json.decode(customSpacesJson);
          _cachedSpaces = jsonList
              .map((json) => DefaultSpaceConfiguration.fromJson(
                  json as Map<String, dynamic>))
              .toList();

          debugPrint(
              '📱 Configuração customizada carregada: ${_cachedSpaces?.length} espaços');
          return;
        } catch (e) {
          debugPrint('❌ Erro ao carregar configuração customizada: $e');
          // Fallback para configuração padrão
        }
      }

      // Usar configuração padrão
      _cachedSpaces = _getDefaultSpaces();
      debugPrint(
          '🏠 Usando configuração padrão: ${_cachedSpaces?.length} espaços');
    } catch (e) {
      debugPrint('❌ Erro ao carregar configuração: $e');
      _cachedSpaces = _getDefaultSpaces();
    }
  }

  /// Obtém espaços padrão da configuração
  List<DefaultSpaceConfiguration> _getDefaultSpaces() {
    // Verificar quais espaços estão habilitados
    final enabledSpaces =
        _prefs?.getStringList(DefaultSpacesConfig.enabledSpacesKey) ??
            DefaultSpacesConfig.defaultEnabledSpaces;

    return DefaultSpacesConfig.defaultSpaces
        .where((space) => enabledSpaces.contains(space.nameKey))
        .where((space) => space.isActive)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Obtém lista de espaços padrão configurados
  Future<List<DefaultSpaceConfiguration>>
      getDefaultSpacesConfiguration() async {
    if (_cachedSpaces == null) {
      await _loadConfiguration();
    }
    return _cachedSpaces ?? [];
  }

  /// Cria modelos EspacoModel a partir da configuração
  Future<List<EspacoModel>> createDefaultSpaceModels() async {
    final configurations = await getDefaultSpacesConfiguration();
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;

    final spaces = <EspacoModel>[];

    for (final config in configurations) {
      // Obter strings traduzidas
      final nome = _getTranslatedString(config.nameKey);
      final descricao = _getTranslatedString(config.descriptionKey);

      if (nome.isNotEmpty) {
        final espaco = EspacoModel(
          id: '',
          createdAt: nowMs,
          updatedAt: nowMs,
          nome: nome,
          descricao: descricao,
          ativo: config.isActive,
          dataCriacao: now,
        );

        spaces.add(espaco);
      }
    }

    debugPrint('✅ Criados ${spaces.length} espaços padrão localizados');
    return spaces;
  }

  /// Obtém string traduzida usando GetX
  String _getTranslatedString(String key) {
    try {
      // Usar o método tr() do GetX para obter tradução
      return key.tr;
    } catch (e) {
      // Fallback se o sistema de tradução não estiver disponível
      return _getFallbackTranslation(key);
    }
  }

  /// Tradução de fallback quando GetX não está disponível
  String _getFallbackTranslation(String key) {
    // Mapa de fallbacks básicos em português
    const fallbacks = {
      'espacos.padrao.sala_estar.nome': 'Sala de estar',
      'espacos.padrao.sala_estar.descricao': 'Ambiente principal da casa',
      'espacos.padrao.quarto.nome': 'Quarto',
      'espacos.padrao.quarto.descricao': 'Dormitório',
      'espacos.padrao.cozinha.nome': 'Cozinha',
      'espacos.padrao.cozinha.descricao': 'Área de preparo de alimentos',
      'espacos.padrao.varanda.nome': 'Varanda',
      'espacos.padrao.varanda.descricao': 'Área externa coberta',
      'espacos.padrao.jardim.nome': 'Jardim',
      'espacos.padrao.jardim.descricao': 'Área externa com terra',
    };

    return fallbacks[key] ?? key.split('.').last;
  }

  /// Customiza configuração de espaços padrão
  Future<bool> customizeDefaultSpaces(
      List<DefaultSpaceConfiguration> customSpaces) async {
    try {
      final jsonList = customSpaces.map((space) => space.toJson()).toList();
      final jsonString = json.encode(jsonList);

      final success = await _prefs?.setString(
              DefaultSpacesConfig.customSpacesKey, jsonString) ??
          false;

      if (success) {
        _cachedSpaces = customSpaces;
        debugPrint(
            '✅ Configuração customizada salva: ${customSpaces.length} espaços');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Erro ao salvar configuração customizada: $e');
      return false;
    }
  }

  /// Habilita ou desabilita espaços específicos
  Future<bool> setEnabledSpaces(List<String> enabledSpaceKeys) async {
    try {
      final success = await _prefs?.setStringList(
              DefaultSpacesConfig.enabledSpacesKey, enabledSpaceKeys) ??
          false;

      if (success) {
        // Recarregar configuração
        await _loadConfiguration();
        debugPrint(
            '✅ Espaços habilitados atualizados: ${enabledSpaceKeys.length}');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar espaços habilitados: $e');
      return false;
    }
  }

  /// Reseta para configuração padrão
  Future<bool> resetToDefaultConfiguration() async {
    try {
      await _prefs?.remove(DefaultSpacesConfig.customSpacesKey);
      await _prefs?.remove(DefaultSpacesConfig.enabledSpacesKey);

      // Recarregar configuração
      await _loadConfiguration();

      debugPrint('✅ Configuração resetada para padrão');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao resetar configuração: $e');
      return false;
    }
  }

  /// Obtém configuração atual como JSON (para debug/export)
  Future<Map<String, dynamic>> getCurrentConfigurationAsJson() async {
    final spaces = await getDefaultSpacesConfiguration();

    return {
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
      'enabled_spaces':
          _prefs?.getStringList(DefaultSpacesConfig.enabledSpacesKey) ??
              DefaultSpacesConfig.defaultEnabledSpaces,
      'use_remote_config':
          _prefs?.getBool(DefaultSpacesConfig.useRemoteConfigKey) ?? false,
      'spaces': spaces.map((space) => space.toJson()).toList(),
    };
  }

  /// Valida se uma configuração é válida
  bool validateConfiguration(List<DefaultSpaceConfiguration> spaces) {
    if (spaces.isEmpty) return false;

    // Verificar se todas as chaves de tradução existem
    for (final space in spaces) {
      if (space.nameKey.isEmpty || space.descriptionKey.isEmpty) {
        return false;
      }

      // Verificar se há tradução disponível
      final nome = _getTranslatedString(space.nameKey);
      if (nome.isEmpty || nome == space.nameKey) {
        debugPrint('⚠️ Tradução não encontrada para: ${space.nameKey}');
      }
    }

    return true;
  }

  /// Habilita uso de configuração remota (futuro)
  Future<bool> enableRemoteConfiguration(bool enable) async {
    try {
      final success = await _prefs?.setBool(
              DefaultSpacesConfig.useRemoteConfigKey, enable) ??
          false;

      if (success && enable) {
        // TODO: Implementar sincronização com configuração remota
        debugPrint('🌐 Configuração remota habilitada (implementação futura)');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Erro ao configurar uso remoto: $e');
      return false;
    }
  }

  @override
  void onClose() {
    _cachedSpaces = null;
    super.onClose();
  }
}
