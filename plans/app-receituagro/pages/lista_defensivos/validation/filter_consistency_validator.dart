import '../models/defensivo_model.dart';
import '../models/migrated_lista_defensivos_state.dart';

/// Validador de consistência para filtros de lista
/// Garante que o estado nunca fica inconsistente entre operações
class FilterConsistencyValidator {
  
  /// Valida consistência básica do estado
  static bool validateBasicConsistency(MigratedListaDefensivosState state) {
    try {
      // Executa validação de invariants
      state.validateInvariants();
      
      // Validações específicas de consistência
      final completos = state.defensivosCompletos;
      final list = state.defensivosList;
      final filtered = state.defensivosListFiltered;
      
      // 1. Lista completa e lista com ordenação devem ter mesmo tamanho
      if (completos.length != list.length) {
        print('❌ Inconsistência: defensivosCompletos (${completos.length}) != defensivosList (${list.length})');
        return false;
      }
      
      // 2. Lista filtrada não pode ter mais itens que a lista completa
      if (filtered.length > completos.length) {
        print('❌ Inconsistência: filtered (${filtered.length}) > completos (${completos.length})');
        return false;
      }
      
      // 3. Se não há busca, filtered deve mostrar itens ordenados da lista completa
      if (state.searchText.isEmpty) {
        final expectedFiltered = completos.take(filtered.length).toList();
        if (!_listsEqual(filtered, expectedFiltered)) {
          print('❌ Inconsistência: filtered não corresponde aos primeiros itens de completos');
          return false;
        }
      }
      
      // 4. Verificar paginação
      if (state.currentPage < 0) {
        print('❌ Inconsistência: página atual negativa');
        return false;
      }
      
      print('✅ Estado consistente: ${completos.length} total, ${filtered.length} exibidos, página ${state.currentPage}');
      return true;
    } catch (e) {
      print('❌ Erro na validação: $e');
      return false;
    }
  }
  
  /// Valida consistência durante operação de filtro
  static bool validateFilterOperation(
    MigratedListaDefensivosState beforeState,
    MigratedListaDefensivosState afterState,
    String searchText,
  ) {
    try {
      // Validação básica
      if (!validateBasicConsistency(afterState)) {
        return false;
      }
      
      // Validações específicas da operação de filtro
      
      // 1. Dados fonte não devem ter mudado
      if (!_listsEqual(beforeState.defensivosCompletos, afterState.defensivosCompletos)) {
        print('❌ Inconsistência: dados fonte mudaram durante filtro');
        return false;
      }
      
      // 2. Texto de busca deve estar atualizado
      if (afterState.searchText != searchText) {
        print('❌ Inconsistência: searchText não atualizado');
        return false;
      }
      
      // 3. Se limpar busca, deve voltar ao estado inicial
      if (searchText.isEmpty && afterState.defensivosListFiltered.isNotEmpty) {
        final sourceData = afterState.defensivosCompletos;
        final maxExpected = sourceData.length > 20 ? 20 : sourceData.length; // itemsPerPage padrão
        if (afterState.defensivosListFiltered.length > maxExpected) {
          print('❌ Inconsistência: muitos itens após limpar busca');
          return false;
        }
      }
      
      print('✅ Operação de filtro consistente: "$searchText" -> ${afterState.defensivosListFiltered.length} resultados');
      return true;
    } catch (e) {
      print('❌ Erro na validação de filtro: $e');
      return false;
    }
  }
  
  /// Valida consistência durante operação de ordenação
  static bool validateSortOperation(
    MigratedListaDefensivosState beforeState,
    MigratedListaDefensivosState afterState,
    String sortField,
    bool isAscending,
  ) {
    try {
      // Validação básica
      if (!validateBasicConsistency(afterState)) {
        return false;
      }
      
      // Validações específicas da operação de ordenação
      
      // 1. Parâmetros de ordenação devem estar atualizados
      if (afterState.sortField != sortField || afterState.isAscending != isAscending) {
        print('❌ Inconsistência: parâmetros de ordenação não atualizados');
        return false;
      }
      
      // 2. Verificar se ordenação foi aplicada corretamente
      final sortedList = afterState.defensivosList;
      if (sortedList.length > 1) {
        final isCorrectlySorted = _isListSorted(sortedList, sortField, isAscending);
        if (!isCorrectlySorted) {
          print('❌ Inconsistência: lista não está ordenada corretamente');
          return false;
        }
      }
      
      // 3. Paginação deve ter resetado
      if (afterState.currentPage != 0) {
        print('❌ Inconsistência: paginação não resetou após ordenação');
        return false;
      }
      
      print('✅ Operação de ordenação consistente: $sortField ${isAscending ? "ASC" : "DESC"}');
      return true;
    } catch (e) {
      print('❌ Erro na validação de ordenação: $e');
      return false;
    }
  }
  
  /// Valida consistência durante paginação
  static bool validatePaginationOperation(
    MigratedListaDefensivosState beforeState,
    MigratedListaDefensivosState afterState,
  ) {
    try {
      // Validação básica
      if (!validateBasicConsistency(afterState)) {
        return false;
      }
      
      // Validações específicas da paginação
      
      // 1. Página deve ter incrementado
      if (afterState.currentPage <= beforeState.currentPage) {
        print('❌ Inconsistência: página não incrementou');
        return false;
      }
      
      // 2. Lista filtrada deve ter crescido ou chegado ao fim
      if (afterState.defensivosListFiltered.length < beforeState.defensivosListFiltered.length) {
        print('❌ Inconsistência: lista filtrada diminuiu durante paginação');
        return false;
      }
      
      // 3. Novos itens devem ser diferentes dos anteriores (sem duplicação)
      final oldItems = beforeState.defensivosListFiltered;
      final newItems = afterState.defensivosListFiltered;
      if (newItems.length > oldItems.length) {
        final addedItems = newItems.sublist(oldItems.length);
        if (_hasItemDuplication(oldItems, addedItems)) {
          print('❌ Inconsistência: itens duplicados na paginação');
          return false;
        }
      }
      
      print('✅ Operação de paginação consistente: ${beforeState.defensivosListFiltered.length} -> ${afterState.defensivosListFiltered.length}');
      return true;
    } catch (e) {
      print('❌ Erro na validação de paginação: $e');
      return false;
    }
  }
  
  /// Testa cenários completos de uso
  static bool runComprehensiveTest(List<DefensivoModel> testData) {
    try {
      print('🧪 Iniciando teste abrangente de consistência...');
      
      // 1. Estado inicial
      final initialState = MigratedListaDefensivosState(
        defensivosCompletos: testData,
        isLoading: false,
      );
      
      if (!validateBasicConsistency(initialState)) {
        return false;
      }
      
      // 2. Teste de filtro
      final filteredState = initialState.applySearch('test');
      if (!validateFilterOperation(initialState, filteredState, 'test')) {
        return false;
      }
      
      // 3. Teste de limpeza de filtro
      final clearedState = filteredState.applySearch('');
      if (!validateFilterOperation(filteredState, clearedState, '')) {
        return false;
      }
      
      // 4. Teste de ordenação
      final sortedState = clearedState.applySorting(sortField: 'line1', isAscending: false);
      if (!validateSortOperation(clearedState, sortedState, 'line1', false)) {
        return false;
      }
      
      // 5. Teste de paginação (simulado)
      final paginatedState = sortedState.nextPage();
      if (paginatedState.currentPage > sortedState.currentPage) {
        if (!validatePaginationOperation(sortedState, paginatedState)) {
          return false;
        }
      }
      
      print('🎉 Todos os testes de consistência passaram!');
      return true;
    } catch (e) {
      print('❌ Erro no teste abrangente: $e');
      return false;
    }
  }
  
  // Métodos auxiliares privados
  
  static bool _listsEqual(List<DefensivoModel> list1, List<DefensivoModel> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].idReg != list2[i].idReg) return false;
    }
    return true;
  }
  
  static bool _isListSorted(List<DefensivoModel> list, String sortField, bool isAscending) {
    if (list.length <= 1) return true;
    
    for (int i = 0; i < list.length - 1; i++) {
      final current = sortField == 'line1' ? list[i].line1 : list[i].line2;
      final next = sortField == 'line1' ? list[i + 1].line1 : list[i + 1].line2;
      
      final comparison = current.toLowerCase().compareTo(next.toLowerCase());
      final expectedComparison = isAscending ? -1 : 1;
      
      if (comparison > 0 && isAscending) return false;
      if (comparison < 0 && !isAscending) return false;
    }
    
    return true;
  }
  
  static bool _hasItemDuplication(List<DefensivoModel> existingItems, List<DefensivoModel> newItems) {
    final existingIds = existingItems.map((item) => item.idReg).toSet();
    for (final item in newItems) {
      if (existingIds.contains(item.idReg)) {
        return true;
      }
    }
    return false;
  }
}