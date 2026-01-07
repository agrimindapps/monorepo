
import 'package:flutter/foundation.dart';
import '../adapters/adapters.dart';
import '../classes/fitossanitario_class.dart';
import '../classes/pragas_class.dart';
import '../classes/cultura_class.dart';
import '../classes/diagnostico_class.dart';

/// Example usage of adapters for converting between Supabase models and Core entities
class AdapterUsageExample {
  /// Demonstrates Fitossanitario adapter usage
  static void demonstrateFitossanitarioAdapter() {
    debugPrint('=== Demonstrating Fitossanitario Adapter ===');
    final supabaseModel = Fitossanitario(
      objectId: 'fit001',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      idReg: 'REG001',
      status: 1,
      nomeComum: 'Fungicida XYZ',
      nomeTecnico: 'Azoxystrobin 250g/L',
      classeAgronomica: 'Fungicida',
      fabricante: 'Bayer CropScience',
      comercializado: 1,
      formulacao: 'Concentrado Emulsionável',
      modoAcao: 'Sistêmico',
      mapa: 'MAP123',
      ingredienteAtivo: 'Azoxystrobin',
      quantProduto: '250g/L',
      elegivel: true,
    );
    final coreEntity = FitossanitarioAdapter.toEntity(supabaseModel);
    debugPrint('Original: ${supabaseModel.nomeComum}');
    debugPrint('Core Entity: ${coreEntity.nome} (ID: ${coreEntity.id})');
    final backToSupabase = FitossanitarioAdapter.fromEntity(coreEntity);
    debugPrint('Converted back: ${backToSupabase.nomeComum}');
  }

  /// Demonstrates Praga adapter usage
  static void demonstratePragaAdapter() {
    debugPrint('\n=== Demonstrating Praga Adapter ===');
    
    final supabaseModel = Pragas(
      objectId: 'praga001',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      idReg: 'PRAGA001',
      status: 1,
      nomeComum: 'Lagarta do cartucho',
      nomeCientifico: 'Spodoptera frugiperda',
      familia: 'Noctuidae',
      ordem: 'Lepidoptera',
      genero: 'Spodoptera',
      especie: 'frugiperda',
      tipoPraga: 'Inseto',
    );

    final coreEntity = PragaAdapter.toEntity(supabaseModel);
    debugPrint('Original: ${supabaseModel.nomeComum}');
    debugPrint('Core Entity: ${coreEntity.nomeComum} - ${coreEntity.nomeCientifico}');
    debugPrint('Status: ${coreEntity.isAtiva ? "Ativa" : "Inativa"}');
  }

  /// Demonstrates Cultura adapter usage
  static void demonstrateCulturaAdapter() {
    debugPrint('\n=== Demonstrating Cultura Adapter ===');
    
    final supabaseModel = Cultura(
      objectId: 'cult001',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      idReg: 'CULT001',
      status: 1,
      cultura: 'Milho',
    );

    final coreEntity = CulturaAdapter.toEntity(supabaseModel);
    debugPrint('Original: ${supabaseModel.cultura}');
    debugPrint('Core Entity: ${coreEntity.nomeComum} (Active: ${coreEntity.isAtiva})');
  }

  /// Demonstrates Diagnostico adapter usage
  static void demonstrateDiagnosticoAdapter() {
    debugPrint('\n=== Demonstrating Diagnostico Adapter ===');
    
    final supabaseModel = Diagnostico(
      objectId: 'diag001',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      status: true,
      idReg: 'DIAG001',
      fkIdDefensivo: 'fit001',
      nomeDefensivo: 'Fungicida XYZ',
      fkIdCultura: 'cult001',
      nomeCultura: 'Milho',
      fkIdPraga: 'praga001',
      nomePraga: 'Ferrugem',
      dsMax: '2.5',
      um: 'L/ha',
      epocaAplicacao: 'Início do florescimento',
    );

    final coreEntity = DiagnosticoAdapter.toEntity(supabaseModel);
    debugPrint('Original fields: ${supabaseModel.nomeCultura} + ${supabaseModel.nomePraga}');
    debugPrint('Core Entity Title: ${coreEntity.titulo}');
    debugPrint('Culture: ${coreEntity.cultura}');
    debugPrint('Approved: ${coreEntity.isAprovado}');
  }

  /// Demonstrates batch conversion
  static void demonstrateBatchConversion() {
    debugPrint('\n=== Demonstrating Batch Conversion ===');
    final supabaseModels = [
      Fitossanitario(
        objectId: 'fit001',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        idReg: 'REG001',
        status: 1,
        nomeComum: 'Produto A',
        nomeTecnico: 'Técnico A',
        classeAgronomica: 'Classe A',
        fabricante: 'Fabricante A',
        comercializado: 1,
        formulacao: 'Formulação A',
        modoAcao: 'Modo A',
        mapa: 'MAP001',
        ingredienteAtivo: 'Ingrediente A',
        quantProduto: '250g/L',
        elegivel: true,
      ),
      Fitossanitario(
        objectId: 'fit002',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        idReg: 'REG002',
        status: 1,
        nomeComum: 'Produto B',
        nomeTecnico: 'Técnico B',
        classeAgronomica: 'Classe B',
        fabricante: 'Fabricante B',
        comercializado: 1,
        formulacao: 'Formulação B',
        modoAcao: 'Modo B',
        mapa: 'MAP002',
        ingredienteAtivo: 'Ingrediente B',
        quantProduto: '500g/L',
        elegivel: true,
      ),
    ];
    final coreEntities = FitossanitarioAdapter.toEntityList(supabaseModels);
    debugPrint('Converted ${supabaseModels.length} Supabase models to ${coreEntities.length} Core entities');
    
    for (int i = 0; i < coreEntities.length; i++) {
      debugPrint('  ${i + 1}. ${coreEntities[i].nome} (ID: ${coreEntities[i].id})');
    }
    final backToSupabase = FitossanitarioAdapter.fromEntityList(coreEntities);
    debugPrint('Converted back to ${backToSupabase.length} Supabase models');
  }

  /// Run all demonstrations
  static void runAllDemonstrations() {
    debugPrint('=== ADAPTER PATTERN DEMONSTRATION ===');
    debugPrint('This shows how receituagro_web bridges Supabase data with Core entities');
    debugPrint('');

    demonstrateFitossanitarioAdapter();
    demonstratePragaAdapter();
    demonstrateCulturaAdapter();
    demonstrateDiagnosticoAdapter();
    demonstrateBatchConversion();

    debugPrint('\n=== NEXT STEPS ===');
    debugPrint('1. Use *EntityRepository methods (fetchAllEntities, searchEntitiesByName, etc.)');
    debugPrint('2. Gradually replace legacy methods with Core entity methods');
    debugPrint('3. Implement full Core package with rich domain logic');
    debugPrint('4. Add business rules and validation to adapters');
    debugPrint('5. Extend stub entities with complete Core entity implementations');
  }
}

/// Repository usage example showing how to work with Core entities
class RepositoryUsageExample {
  /// Shows how to use the new Core entity methods in repositories
  static Future<void> demonstrateRepositoryUsage() async {
    debugPrint('\n=== Repository Usage with Core Entities ===');
    
    debugPrint('Example repository calls:');
    debugPrint('');
    debugPrint('// Fitossanitario Repository');
    debugPrint('final fitossanitarios = await repository.fetchAllEntities();');
    debugPrint('final activeProducts = await repository.fetchActiveEntities();');
    debugPrint('final searchResults = await repository.searchEntitiesByName("fungicida");');
    debugPrint('final byManufacturer = await repository.fetchEntitiesByFabricante("Bayer");');
    debugPrint('');
    debugPrint('// Praga Repository');
    debugPrint('final pragas = await repository.getAllEntities();');
    debugPrint('final activePests = await repository.getActiveEntities();');
    debugPrint('final pestsByType = await repository.getEntitiesByType("Inseto");');
    debugPrint('');
    debugPrint('// Cultura Repository');
    debugPrint('final culturas = await repository.getAllEntities();');
    debugPrint('final activeCultures = await repository.getActiveEntities();');
    debugPrint('final rotationRecommendations = await repository.getRotationRecommendations(currentCultura);');
    debugPrint('');
    debugPrint('// Diagnostico Repository');
    debugPrint('final diagnosticos = await repository.getAllEntities();');
    debugPrint('final approved = await repository.getApprovedEntities();');
    debugPrint('final recommendations = await repository.getRecommendations(');
    debugPrint('  cultura: "milho", praga: "lagarta"');
    debugPrint(');');
  }
}
