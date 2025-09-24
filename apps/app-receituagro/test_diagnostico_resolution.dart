/// Teste rápido para verificar resolução dinâmica de diagnósticos
/// Execute: dart test_diagnostico_resolution.dart

import 'lib/core/extensions/diagnostico_hive_extension.dart';
import 'lib/core/models/diagnostico_hive.dart';

void main() {
  // Criar um diagnóstico de exemplo com nomes vazios para testar a resolução dinâmica
  final diagnosticoTeste = DiagnosticoHive(
    objectId: 'test123',
    createdAt: 0,
    updatedAt: 0,
    idReg: 'DIAG001',
    fkIdDefensivo: 'qdBSaHEOv24yf', // ID real de exemplo
    nomeDefensivo: null, // ❌ VAZIO - deve ser resolvido dinamicamente
    fkIdCultura: 'CULT001', // ID de exemplo
    nomeCultura: null, // ❌ VAZIO - deve ser resolvido dinamicamente  
    fkIdPraga: 'bpsUSZWqVlMRP', // ID real de exemplo
    nomePraga: null, // ❌ VAZIO - deve ser resolvido dinamicamente
    dsMax: '100',
    um: 'ml/ha',
  );
  
  print('=== TESTE DE RESOLUÇÃO DINÂMICA DE DIAGNÓSTICOS ===');
  print('Testando com DiagnosticoHive onde nomes estão null/vazios...');
  print('');
  
  // ✅ ANTES: Mostraria "Defensivo não informado", "Praga não informada", etc.
  // ✅ DEPOIS: Deve resolver dinamicamente usando repositories
  
  print('Nome Defensivo: ${diagnosticoTeste.displayNomeDefensivo}');
  print('Nome Cultura: ${diagnosticoTeste.displayNomeCultura}');  
  print('Nome Praga: ${diagnosticoTeste.displayNomePraga}');
  print('');
  
  final dataMap = diagnosticoTeste.toDataMap();
  print('Mapa de dados completo:');
  dataMap.forEach((key, value) {
    print('  $key: $value');
  });
  
  print('');
  print('=== RESULTADO ESPERADO ===');
  print('✅ Nomes devem ser resolvidos dinamicamente usando os IDs');
  print('✅ Dados técnicos devem vir dos repositórios relacionados');
  print('❌ Se aparecer "não identificado", pode ser que os IDs não existam nos dados carregados');
}