import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receituagro_web/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/secure_logger.dart';
import '../core/services/cache_service.dart';

class DefensivosRepository extends GetxController {
  static final DefensivosRepository _singleton =
      DefensivosRepository._internal();

  factory DefensivosRepository() {
    return _singleton;
  }

  DefensivosRepository._internal();
  final int pageSize = 12;
  List<dynamic> allDefensivosSearch = [];
  RxInt currentPage = 0.obs;
  RxBool isLoading = false.obs;
  RxList<dynamic> filteredDefensivos = [].obs;
  RxList<dynamic> defensivosOnScreen = [].obs;
  RxMap<dynamic, dynamic> defensivo = {
    'caracteristicas': {},
    'diagnosticos': [],
  }.obs;
  int get totalPages => filteredDefensivos.isEmpty
      ? 1
      : (filteredDefensivos.length / pageSize).ceil();

  Future<void> fetchAllDefensivos({bool forceRefresh = false}) async {
    if (!forceRefresh && allDefensivosSearch.isNotEmpty) {
      SecureLogger.debug('Usando dados já carregados em memória');
      return;
    }

    const cacheKey = 'all_defensivos';
    const cacheTtl = Duration(hours: 2); // Cache por 2 horas

    isLoading.value = true;

    try {
      final cachedData = await CacheService.get<List<dynamic>>(
        cacheKey,
        ttl: cacheTtl,
        deserializer: (data) => List<dynamic>.from(data),
      );

      if (cachedData != null && !forceRefresh) {
        SecureLogger.debug('Dados carregados do cache');
        allDefensivosSearch = cachedData;
        todosOsDefensivos();
        return;
      }
      SecureLogger.debug('Buscando dados da API');
      List<dynamic> allDefensivos = [];

      Supabase ins = Supabase.instance;
      final response = await ins.client.from('vw_fitossanitarios').select();

      final data = response;
      for (var row in data) {
        allDefensivos.addAll(row['produtos'] as List);
      }

      allDefensivos.sort((a, b) => a['nomecomum'].compareTo(b['nomecomum']));
      await CacheService.set(cacheKey, allDefensivos, ttl: cacheTtl);

      allDefensivosSearch = allDefensivos;
      todosOsDefensivos();
      _scheduleBackgroundRefresh();
    } catch (e) {
      SecureLogger.error('Erro ao buscar defensivos', error: e);
      final cachedData = await CacheService.get<List<dynamic>>(
        cacheKey,
        ttl: const Duration(days: 7), // Cache extendido em caso de erro
        deserializer: (data) => List<dynamic>.from(data),
      );

      if (cachedData != null) {
        SecureLogger.warning('Usando dados do cache devido a erro na API');
        allDefensivosSearch = cachedData;
        todosOsDefensivos();
      } else {
        Get.snackbar(
          'Erro',
          SecureLogger.getUserFriendlyError(e),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<dynamic>> fetchDefensivoView(String idreg) async {
    final cacheKey = 'defensivo_view_$idreg';
    const cacheTtl = Duration(hours: 6); // Cache por 6 horas

    try {
      final cachedData = await CacheService.get<List<dynamic>>(
        cacheKey,
        ttl: cacheTtl,
        deserializer: (data) => List<dynamic>.from(data),
      );

      if (cachedData != null) {
        SecureLogger.debug('Detalhes do defensivo carregados do cache');
        return cachedData;
      }
      final response = await Supabase.instance.client
          .from('vw_diagnosticos')
          .select()
          .eq('fkiddefensivo', idreg)
          .limit(1);

      Function decode = SupabaseService().dbDecode;

      for (var e in response) {
        e['toxico'] = decode(e['toxico']);
        e['modoacao'] = decode(e['modoacao']);
        e['classeagronomica'] = decode(e['classeagronomica']);
        e['classambiental'] = decode(e['classambiental']);
        e['formulacao'] = decode(e['formulacao']);
      }

      final List<Map<dynamic, dynamic>> diagnosticos = response;
      await CacheService.set(cacheKey, diagnosticos, ttl: cacheTtl);

      return diagnosticos;
    } catch (e) {
      SecureLogger.error('Erro ao buscar detalhes do defensivo', error: e);
      return [];
    }
  }

  void todosOsDefensivos() {
    currentPage.value = 0;

    filteredDefensivos.clear();
    filteredDefensivos.assignAll(allDefensivosSearch);

    currentItems();
  }

  /// Agenda atualização em background
  void _scheduleBackgroundRefresh() {
    Timer.periodic(const Duration(minutes: 30), (timer) async {
      if (allDefensivosSearch.isNotEmpty) {
        try {
          await fetchAllDefensivos(forceRefresh: true);
          SecureLogger.debug('Cache atualizado em background');
        } catch (e) {
          SecureLogger.warning('Erro ao atualizar cache em background',
              error: e);
        }
      }
    });
  }

  /// Força atualização dos dados
  @override
  Future<void> refresh() async {
    await fetchAllDefensivos(forceRefresh: true);
  }

  /// Limpa cache específico
  Future<void> clearCache() async {
    await CacheService.remove('all_defensivos');
    await CacheService.invalidatePattern('defensivo_view_');
  }

  /// Obtém métricas de cache
  Map<String, dynamic> getCacheMetrics() {
    return CacheService.getMetrics();
  }

  void currentItems() {
    if (filteredDefensivos.isEmpty) {
      defensivosOnScreen.clear();
      return;
    }
    if (currentPage.value < 0) {
      currentPage.value = 0;
    }
    if (currentPage.value >= totalPages) {
      currentPage.value = totalPages - 1;
    }

    int start = currentPage.value * pageSize;
    int end = start + pageSize;

    defensivosOnScreen.clear();

    int filteredLen = filteredDefensivos.length;
    if (start >= filteredLen) {
      currentPage.value = totalPages - 1;
      start = currentPage.value * pageSize;
      end = start + pageSize;
    }

    int validEnd = end > filteredLen ? filteredLen : end;

    if (start < filteredLen && validEnd > start) {
      List partDefensivos = filteredDefensivos.sublist(start, validEnd);
      defensivosOnScreen.assignAll(partDefensivos);
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      currentPage.value++;
    }
    currentItems();
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
    currentItems();
  }

  void firstPage() {
    currentPage.value = 0;
    currentItems();
  }

  void lastPage() {
    currentPage.value = totalPages - 1;
    currentItems();
  }

  List<int> get pageNumbers {
    double tam = MediaQuery.of(Get.context!).size.width;

    int start = currentPage.value - (tam < 600 ? 1 : 2);
    int end = currentPage.value + (tam < 600 ? 1 : 2);

    if (start < 0) {
      end += (0 - start);
      start = 0;
    }

    if (end >= totalPages) {
      end = totalPages - 1;
    }

    return List.generate(end - start + 1, (index) => start + index);
  }

  Future<void> buscaDefensivos(String text) async {
    if (allDefensivosSearch.isEmpty) {
      await fetchAllDefensivos();
    }

    isLoading.value = true;

    try {
      List result = allDefensivosSearch
          .where((e) =>
              e['nomecomum'].toLowerCase().contains(text.toLowerCase()) ||
              e['ingredienteativo'].toLowerCase().contains(text.toLowerCase()))
          .toList();

      result.sort((a, b) => a['nomecomum'].compareTo(b['nomecomum']));
      currentPage.value = 0;
      filteredDefensivos.clear();
      filteredDefensivos.assignAll(result);
      currentItems();
    } catch (e) {
      SecureLogger.error('Erro ao buscar defensivos por texto', error: e);
      filteredDefensivos.clear();
      defensivosOnScreen.clear();
      Get.snackbar(
        'Erro na Busca',
        SecureLogger.getUserFriendlyError(e),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
