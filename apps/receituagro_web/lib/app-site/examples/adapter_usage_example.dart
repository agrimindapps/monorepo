
import '../adapters/adapters.dart';
import '../classes/fitossanitario_class.dart';
import '../classes/pragas_class.dart';
import '../classes/cultura_class.dart';
import '../classes/diagnostico_class.dart';

/// Example usage of adapters for converting between Supabase models and Core entities
class AdapterUsageExample {
  /// Demonstrates Fitossanitario adapter usage
  static void demonstrateFitossanitarioAdapter() {
    print('=== Demonstrating Fitossanitario Adapter ===');
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
    print('Original: ${supabaseModel.nomeComum}');
    print('Core Entity: ${coreEntity.nome} (ID: ${coreEntity.id})');
    final backToSupabase = FitossanitarioAdapter.fromEntity(coreEntity);
    print('Converted back: ${backToSupabase.nomeComum}');
  }

  /// Demonstrates Praga adapter usage
  static void demonstratePragaAdapter() {
    print('\n=== Demonstrating Praga Adapter ===');
    
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
    print('Original: ${supabaseModel.nomeComum}');
    print('Core Entity: ${coreEntity.nomeComum} - ${coreEntity.nomeCientifico}');
    print('Status: ${coreEntity.isAtiva ? "Ativa" : "Inativa"}');
  }

  /// Demonstrates Cultura adapter usage
  static void demonstrateCulturaAdapter() {
    print('\n=== Demonstrating Cultura Adapter ===');
    
    final supabaseModel = Cultura(
      objectId: 'cult001',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      idReg: 'CULT001',
      status: 1,
      cultura: 'Milho',
    );

    final coreEntity = CulturaAdapter.toEntity(supabaseModel);
    print('Original: ${supabaseModel.cultura}');
    print('Core Entity: ${coreEntity.nomeComum} (Active: ${coreEntity.isAtiva})');
  }

  /// Demonstrates Diagnostico adapter usage
  static void demonstrateDiagnosticoAdapter() {
    print('\n=== Demonstrating Diagnostico Adapter ===');
    
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
    print('Original fields: ${supabaseModel.nomeCultura} + ${supabaseModel.nomePraga}');
    print('Core Entity Title: ${coreEntity.titulo}');
    print('Culture: ${coreEntity.cultura}');
    print('Approved: ${coreEntity.isAprovado}');
  }

  /// Demonstrates batch conversion
  static void demonstrateBatchConversion() {
    print('\n=== Demonstrating Batch Conversion ===');
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
    print('Converted ${supabaseModels.length} Supabase models to ${coreEntities.length} Core entities');
    
    for (int i = 0; i < coreEntities.length; i++) {
      print('  ${i + 1}. ${coreEntities[i].nome} (ID: ${coreEntities[i].id})');
    }
    final backToSupabase = FitossanitarioAdapter.fromEntityList(coreEntities);
    print('Converted back to ${backToSupabase.length} Supabase models');
  }

  /// Run all demonstrations
  static void runAllDemonstrations() {
    print('=== ADAPTER PATTERN DEMONSTRATION ===');
    print('This shows how receituagro_web bridges Supabase data with Core entities');
    print('');

    demonstrateFitossanitarioAdapter();
    demonstratePragaAdapter();
    demonstrateCulturaAdapter();
    demonstrateDiagnosticoAdapter();
    demonstrateBatchConversion();

    print('\n=== NEXT STEPS ===');
    print('1. Use *EntityRepository methods (fetchAllEntities, searchEntitiesByName, etc.)');
    print('2. Gradually replace legacy methods with Core entity methods');
    print('3. Implement full Core package with rich domain logic');
    print('4. Add business rules and validation to adapters');
    print('5. Extend stub entities with complete Core entity implementations');
  }
}

/// Repository usage example showing how to work with Core entities
class RepositoryUsageExample {
  /// Shows how to use the new Core entity methods in repositories
  static Future<void> demonstrateRepositoryUsage() async {
    print('\n=== Repository Usage with Core Entities ===');
    
    print('Example repository calls:');
    print('');
    print('// Fitossanitario Repository');
    print('final fitossanitarios = await repository.fetchAllEntities();');
    print('final activeProducts = await repository.fetchActiveEntities();');
    print('final searchResults = await repository.searchEntitiesByName("fungicida");');
    print('final byManufacturer = await repository.fetchEntitiesByFabricante("Bayer");');
    print('');
    print('// Praga Repository');
    print('final pragas = await repository.getAllEntities();');
    print('final activePests = await repository.getActiveEntities();');
    print('final pestsByType = await repository.getEntitiesByType("Inseto");');
    print('');
    print('// Cultura Repository');
    print('final culturas = await repository.getAllEntities();');
    print('final activeCultures = await repository.getActiveEntities();');
    print('final rotationRecommendations = await repository.getRotationRecommendations(currentCultura);');
    print('');
    print('// Diagnostico Repository');
    print('final diagnosticos = await repository.getAllEntities();');
    print('final approved = await repository.getApprovedEntities();');
    print('final recommendations = await repository.getRecommendations(');
    print('  cultura: "milho", praga: "lagarta"');
    print(');');
  }
}