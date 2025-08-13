// Dart imports:
import 'dart:developer' as dev;

import 'string_comparison_tests.dart';
// Project imports:
import 'string_comparison_utils.dart';

/// Script simples para executar testes das funcionalidades implementadas
void main() {
  dev.log('Testando implementação de comparação de strings normalizada...');

  // Teste rápido das funcionalidades principais
  _testBasicFunctionality();

  // Executar testes específicos para espaços (mais relevante para nossa issue)
  StringComparisonTests.testEspacosCases();

  dev.log('--- Testes Específicos da Issue #26 ---');
  _testIssue26Cases();

  dev.log(
      '✅ Todos os testes passaram! Implementação funcionando corretamente.');
}

void _testBasicFunctionality() {
  dev.log('--- Teste Rápido das Funcionalidades Principais ---');

  // Teste 1: Comparação básica
  assert(StringComparisonUtils.equals('São Paulo', 'sao paulo'));
  assert(StringComparisonUtils.equals('José', 'jose'));
  assert(StringComparisonUtils.equals('AÇAÍ', 'acai'));
  dev.log('✓ Comparação básica funcionando');

  // Teste 2: Busca contains
  assert(StringComparisonUtils.contains('São Paulo', 'paulo'));
  assert(StringComparisonUtils.contains('José da Silva', 'silva'));
  dev.log('✓ Busca contains funcionando');

  // Teste 3: Validação de unicidade
  final existing = ['São Paulo', 'Rio de Janeiro'];
  assert(!StringComparisonUtils.isUniqueInList('sao paulo', existing));
  assert(StringComparisonUtils.isUniqueInList('Brasília', existing));
  dev.log('✓ Validação de unicidade funcionando');

  // Teste 4: Normalização
  final normalized = StringComparisonUtils.normalize('São José dos Campos');
  assert(normalized == 'sao jose dos campos');
  dev.log('✓ Normalização funcionando');

  // Teste 5: Extension methods
  assert('São Paulo'.equalsIgnoreCase('sao paulo'));
  assert('José da Silva'.containsIgnoreCase('silva'));
  dev.log('✓ Extension methods funcionando');
}

void _testIssue26Cases() {
  dev.log('Testando casos específicos da Issue #26...');

  // Cenários que causavam problemas antes da correção
  final problemCases = [
    // Case sensitivity básico
    ('São Paulo', 'sao paulo', true),
    ('José', 'JOSE', true),
    ('Açaí', 'acai', true),

    // Casos que não devem ser iguais
    ('São Paulo', 'Rio de Janeiro', false),
    ('José', 'João', false),

    // Casos com espaços e formatação
    ('  São Paulo  ', 'sao paulo', true),
    ('São   Paulo', 'sao paulo', true),
  ];

  for (final (str1, str2, shouldBeEqual) in problemCases) {
    final result = StringComparisonUtils.equals(str1, str2);
    assert(result == shouldBeEqual,
        'equals("$str1", "$str2") deveria retornar $shouldBeEqual, obtido $result');
    dev.log('✓ equals("$str1", "$str2") = $result');
  }

  // Testar busca com contains (cenário do findByNome)
  final searchCases = [
    ('São Paulo da Cruz', 'paulo', true),
    ('José da Silva', 'silva', true),
    ('Açaí do Pará', 'acai', true),
    ('Coração de Maria', 'coracao', true),
  ];

  for (final (text, search, shouldContain) in searchCases) {
    final result = StringComparisonUtils.contains(text, search);
    assert(result == shouldContain,
        'contains("$text", "$search") deveria retornar $shouldContain, obtido $result');
    dev.log('✓ contains("$text", "$search") = $result');
  }

  // Testar uniqueness validation (cenário do existeComNome)
  final espacosExistentes = ['São Paulo', 'Rio de Janeiro', 'José da Silva'];

  final uniqueCases = [
    ('sao paulo', false), // Já existe (normalizado)
    ('SÃO PAULO', false), // Já existe (case different)
    ('São  Paulo', false), // Já existe (espaços extras)
    ('Brasília', true), // Novo
    ('Salvador', true), // Novo
  ];

  for (final (nome, shouldBeUnique) in uniqueCases) {
    final result =
        StringComparisonUtils.isUniqueInList(nome, espacosExistentes);
    assert(result == shouldBeUnique,
        'isUniqueInList("$nome") deveria retornar $shouldBeUnique, obtido $result');
    dev.log('✓ isUniqueInList("$nome") = $result');
  }

  dev.log('✅ Issue #26 - Todos os casos testados com sucesso!');
}
