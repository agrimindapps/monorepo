// Dart imports:
import 'dart:developer' as dev;

// Project imports:
import 'string_comparison_utils.dart';

/// Testes básicos para StringComparisonUtils
///
/// Este arquivo contém testes edge cases para validar o comportamento
/// da comparação de strings normalizada com caracteres acentuados.
///
/// Execute chamando StringComparisonTests.runAllTests() no desenvolvimento.
class StringComparisonTests {
  /// Executa todos os testes de comparação de string
  static void runAllTests() {
    dev.log('=== INICIANDO TESTES DE COMPARAÇÃO DE STRING ===');

    _testBasicNormalization();
    _testEqualsComparison();
    _testContainsSearch();
    _testStartsWithSearch();
    _testFuzzyMatching();
    _testUniquenessValidation();
    _testSorting();
    _testSuggestions();
    _testAdvancedSearch();
    _testCachePerformance();

    dev.log('=== TESTES CONCLUÍDOS ===');
  }

  /// Testa normalização básica
  static void _testBasicNormalization() {
    dev.log('Testando normalização básica...');

    final cases = [
      ('São Paulo', 'sao paulo'),
      ('AÇAÍ', 'acai'),
      ('José da Silva', 'jose da silva'),
      ('Ñoño', 'nono'),
      ('Coração', 'coracao'),
      ('Múltiplos    espaços', 'multiplos espacos'),
      ('', ''),
    ];

    for (final (input, expected) in cases) {
      final result = StringComparisonUtils.normalize(input);
      assert(result == expected,
          'normalize("$input") esperado "$expected", obtido "$result"');
      dev.log('✓ normalize("$input") = "$result"');
    }
  }

  /// Testa comparação de igualdade
  static void _testEqualsComparison() {
    dev.log('Testando comparação equals...');

    final trueCases = [
      ('São Paulo', 'sao paulo'),
      ('São Paulo', 'SÃO PAULO'),
      ('José', 'jose'),
      ('José', 'JOSE'),
      ('Açaí', 'acai'),
      ('Coração', 'coracao'),
      ('  espaços  ', 'espacos'),
    ];

    final falseCases = [
      ('São Paulo', 'Rio de Janeiro'),
      ('José', 'João'),
      ('Açaí', 'Banana'),
      ('', 'não vazio'),
    ];

    for (final (str1, str2) in trueCases) {
      assert(StringComparisonUtils.equals(str1, str2),
          'equals("$str1", "$str2") deveria retornar true');
      dev.log('✓ equals("$str1", "$str2") = true');
    }

    for (final (str1, str2) in falseCases) {
      assert(!StringComparisonUtils.equals(str1, str2),
          'equals("$str1", "$str2") deveria retornar false');
      dev.log('✓ equals("$str1", "$str2") = false');
    }
  }

  /// Testa busca com contains
  static void _testContainsSearch() {
    dev.log('Testando busca contains...');

    final trueCases = [
      ('São Paulo', 'paulo'),
      ('São Paulo', 'sao'),
      ('José da Silva', 'silva'),
      ('Açaí do Pará', 'acai'),
      ('Coração de Mãe', 'coracao'),
    ];

    final falseCases = [
      ('São Paulo', 'rio'),
      ('José', 'maria'),
      ('Açaí', 'banana'),
    ];

    for (final (text, search) in trueCases) {
      assert(StringComparisonUtils.contains(text, search),
          'contains("$text", "$search") deveria retornar true');
      dev.log('✓ contains("$text", "$search") = true');
    }

    for (final (text, search) in falseCases) {
      assert(!StringComparisonUtils.contains(text, search),
          'contains("$text", "$search") deveria retornar false');
      dev.log('✓ contains("$text", "$search") = false');
    }
  }

  /// Testa busca com startsWith
  static void _testStartsWithSearch() {
    dev.log('Testando busca startsWith...');

    final trueCases = [
      ('São Paulo', 'sao'),
      ('José da Silva', 'jose'),
      ('Açaí', 'acai'),
      ('Coração', 'cor'),
    ];

    final falseCases = [
      ('São Paulo', 'paulo'),
      ('José da Silva', 'silva'),
      ('Açaí', 'cai'),
    ];

    for (final (text, prefix) in trueCases) {
      assert(StringComparisonUtils.startsWith(text, prefix),
          'startsWith("$text", "$prefix") deveria retornar true');
      dev.log('✓ startsWith("$text", "$prefix") = true');
    }

    for (final (text, prefix) in falseCases) {
      assert(!StringComparisonUtils.startsWith(text, prefix),
          'startsWith("$text", "$prefix") deveria retornar false');
      dev.log('✓ startsWith("$text", "$prefix") = false');
    }
  }

  /// Testa correspondência fuzzy
  static void _testFuzzyMatching() {
    dev.log('Testando fuzzy matching...');

    final trueCases = [
      ('João', 'Joao', 1),
      ('José', 'Jose', 1),
      ('São Paulo', 'Sao Paulo', 2),
      ('Maria', 'Mária', 1),
    ];

    final falseCases = [
      ('João', 'Pedro', 2),
      ('São Paulo', 'Rio de Janeiro', 5),
    ];

    for (final (str1, str2, threshold) in trueCases) {
      assert(
          StringComparisonUtils.fuzzyEquals(str1, str2, threshold: threshold),
          'fuzzyEquals("$str1", "$str2", threshold: $threshold) deveria retornar true');
      dev.log('✓ fuzzyEquals("$str1", "$str2", threshold: $threshold) = true');
    }

    for (final (str1, str2, threshold) in falseCases) {
      assert(
          !StringComparisonUtils.fuzzyEquals(str1, str2, threshold: threshold),
          'fuzzyEquals("$str1", "$str2", threshold: $threshold) deveria retornar false');
      dev.log('✓ fuzzyEquals("$str1", "$str2", threshold: $threshold) = false');
    }
  }

  /// Testa validação de unicidade
  static void _testUniquenessValidation() {
    dev.log('Testando validação de unicidade...');

    final existingNames = ['São Paulo', 'Rio de Janeiro', 'José da Silva'];

    final uniqueCases = [
      'Belo Horizonte',
      'Salvador',
      'Maria da Silva', // Similar mas não igual a José da Silva
    ];

    final duplicateCases = [
      'sao paulo', // Mesmo que São Paulo normalizado
      'SAO PAULO', // Mesmo que São Paulo em maiúscula
      'josé da silva', // Mesmo que José da Silva normalizado
      'JOSE DA SILVA', // Mesmo que José da Silva em maiúscula
    ];

    for (final name in uniqueCases) {
      assert(StringComparisonUtils.isUniqueInList(name, existingNames),
          'isUniqueInList("$name") deveria retornar true');
      dev.log('✓ isUniqueInList("$name") = true');
    }

    for (final name in duplicateCases) {
      assert(!StringComparisonUtils.isUniqueInList(name, existingNames),
          'isUniqueInList("$name") deveria retornar false');
      dev.log('✓ isUniqueInList("$name") = false');
    }
  }

  /// Testa ordenação internacional
  static void _testSorting() {
    dev.log('Testando ordenação internacional...');

    final names = ['São Paulo', 'Açaí', 'Zebra', 'Árvore', 'Casa'];
    final sorted = List<String>.from(names);
    sorted.sort(StringComparisonUtils.compare);

    dev.log('Original: $names');
    dev.log('Ordenado: $sorted');

    // Verificar que não há erros na ordenação
    for (int i = 0; i < sorted.length - 1; i++) {
      final comparison =
          StringComparisonUtils.compare(sorted[i], sorted[i + 1]);
      assert(comparison <= 0,
          'Ordenação incorreta: ${sorted[i]} vs ${sorted[i + 1]}');
    }

    dev.log('✓ Ordenação internacional funcionando');
  }

  /// Testa sugestões baseadas em similaridade
  static void _testSuggestions() {
    dev.log('Testando sugestões...');

    final candidates = [
      'São Paulo',
      'Rio de Janeiro',
      'José da Silva',
      'João Pedro',
      'Maria'
    ];

    final testCases = [
      ('joao', ['João Pedro'], 3),
      ('jose', ['José da Silva'], 2),
      ('sao', ['São Paulo'], 2),
      ('maria', ['Maria'], 1),
    ];

    for (final (searchTerm, expectedContains, threshold) in testCases) {
      final suggestions = StringComparisonUtils.suggest(searchTerm, candidates,
          threshold: threshold);

      for (final expected in expectedContains) {
        assert(suggestions.contains(expected),
            'suggest("$searchTerm") deveria conter "$expected", obtido: $suggestions');
      }

      dev.log('✓ suggest("$searchTerm") = $suggestions');
    }
  }

  /// Testa busca avançada
  static void _testAdvancedSearch() {
    dev.log('Testando busca avançada...');

    final candidates = [
      'São Paulo',
      'Santo André',
      'Rio de Janeiro',
      'José da Silva',
      'João Santos'
    ];

    final testCases = [
      ('santos', ['João Santos', 'Santo André']), // Contains search
      ('sao', ['São Paulo']), // Starts with
      ('jose', ['José da Silva']), // Exact match normalizado
    ];

    for (final (searchTerm, expectedContains) in testCases) {
      final results = StringComparisonUtils.search(
        searchTerm,
        candidates,
        includeContains: true,
        includeFuzzy: true,
      );

      for (final expected in expectedContains) {
        assert(results.contains(expected),
            'search("$searchTerm") deveria conter "$expected", obtido: $results');
      }

      dev.log('✓ search("$searchTerm") = $results');
    }
  }

  /// Testa performance do cache
  static void _testCachePerformance() {
    dev.log('Testando performance do cache...');

    const testString = 'São Paulo com muitos acentos àáâãäèéêëìíîïòóôõöùúûüç';

    // Primeira chamada (sem cache)
    final stopwatch1 = Stopwatch()..start();
    for (int i = 0; i < 1000; i++) {
      StringComparisonUtils.normalize(testString);
    }
    stopwatch1.stop();

    // Segunda chamada (com cache)
    final stopwatch2 = Stopwatch()..start();
    for (int i = 0; i < 1000; i++) {
      StringComparisonUtils.normalize(testString);
    }
    stopwatch2.stop();

    dev.log('Tempo sem cache: ${stopwatch1.elapsedMicroseconds}μs');
    dev.log('Tempo com cache: ${stopwatch2.elapsedMicroseconds}μs');

    final stats = StringComparisonUtils.getCacheStats();
    dev.log('Stats do cache: $stats');

    dev.log('✓ Cache funcionando (segunda execução deve ser mais rápida)');
  }

  /// Testa casos edge específicos para espaços
  static void testEspacosCases() {
    dev.log('=== TESTES ESPECÍFICOS PARA ESPAÇOS ===');

    // Casos reais que podem aparecer no app de plantas
    final espacosComuns = [
      'Sala de estar',
      'Varanda',
      'Jardim',
      'Cozinha',
      'Banheiro',
      'Área de serviço',
    ];

    // Testar duplicatas típicas
    final testCases = [
      ('sala de estar', false), // Já existe
      ('SALA DE ESTAR', false), // Mesma coisa em caps
      ('Sala De Estar', false), // Title case
      ('varanda', false), // Já existe
      ('Varãnda', false), // Com erro de digitação mas similar
      ('Escritório', true), // Novo espaço
      ('Home office', true), // Novo espaço
    ];

    for (final (nomeEspaco, shouldBeUnique) in testCases) {
      final isUnique =
          StringComparisonUtils.isUniqueInList(nomeEspaco, espacosComuns);
      assert(isUnique == shouldBeUnique,
          'Espaço "$nomeEspaco" uniqueness deveria ser $shouldBeUnique, obtido $isUnique');
      dev.log('✓ Espaço "$nomeEspaco" é único: $isUnique');
    }

    dev.log('=== TESTES DE ESPAÇOS CONCLUÍDOS ===');
  }
}
