// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../constants/care_type_const.dart';

/// Service centralizado para gerenciar tipos de cuidado com plantas
/// Garante consistência de nomenclatura, ícones e cores entre toda a aplicação
class CareTypeService {
  static const CareTypeService _instance = CareTypeService._internal();
  factory CareTypeService() => _instance;
  const CareTypeService._internal();

  /// Obtém o nome padronizado para exibição de um tipo de cuidado
  /// Usa nomenclatura de ação (verbos) para consistência
  static String getName(String tipoCuidado) {
    switch (tipoCuidado) {
      case 'agua': // CareType.agua.value
        return 'Regar';
      case 'adubo': // CareType.adubo.value
        return 'Fertilizar';
      case 'banho_sol': // CareType.banhoSol.value
        return 'Banho de sol';
      case 'inspecao_pragas': // CareType.inspecaoPragas.value
        return 'Inspeção de pragas';
      case 'poda': // CareType.poda.value
        return 'Podar';
      case 'replantio': // CareType.replantio.value
        return 'Replantar';
      default:
        return tipoCuidado;
    }
  }

  /// Obtém o substantivo correspondente ao tipo de cuidado
  /// Para usar em contextos onde se refere ao item/substância
  static String getNoun(String tipoCuidado) {
    switch (tipoCuidado) {
      case 'agua': // CareType.agua.value
        return 'Água';
      case 'adubo': // CareType.adubo.value
        return 'Fertilizante';
      case 'banho_sol': // CareType.banhoSol.value
        return 'Sol';
      case 'inspecao_pragas': // CareType.inspecaoPragas.value
        return 'Pragas';
      case 'poda': // CareType.poda.value
        return 'Poda';
      case 'replantio': // CareType.replantio.value
        return 'Replantio';
      default:
        return tipoCuidado;
    }
  }

  /// Obtém o ícone correspondente ao tipo de cuidado
  static IconData getIcon(String tipoCuidado) {
    switch (tipoCuidado) {
      case 'agua':
        return Icons.water_drop;
      case 'adubo':
        return Icons.grass;
      case 'banho_sol':
        return Icons.wb_sunny;
      case 'inspecao_pragas':
        return Icons.search;
      case 'poda':
        return Icons.content_cut;
      case 'replantar':
        return Icons.move_up;
      default:
        return Icons.task_alt;
    }
  }

  /// Obtém a cor semântica para o tipo de cuidado
  /// Usa cores que fazem sentido contextual (água=azul, sol=laranja, etc.)
  static Color getSemanticColor(String tipoCuidado) {
    switch (tipoCuidado) {
      case 'agua':
        return const Color(0xFF2196F3); // Azul - água
      case 'adubo':
        return const Color(0xFF4CAF50); // Verde - fertilizante/crescimento
      case 'banho_sol':
        return const Color(0xFFFF9800); // Laranja - sol
      case 'inspecao_pragas':
        return const Color(0xFF9C27B0); // Roxo - inspeção/cuidado especial
      case 'poda':
        return const Color(0xFF795548); // Marrom - ferramentas/madeira
      case 'replantar':
        return const Color(0xFF607D8B); // Azul acinzentado - mudança/transição
      default:
        return const Color(0xFF757575); // Cinza padrão
    }
  }

  /// Obtém o intervalo padrão em dias para o tipo de cuidado (compatível com PlantaConfigModel)
  static int getDefaultInterval(String tipoCuidado) {
    switch (tipoCuidado) {
      case 'agua':
        return 1; // Match PlantaConfigModel default
      case 'adubo':
        return 7; // Match PlantaConfigModel default
      case 'banho_sol':
        return 1; // Match PlantaConfigModel default
      case 'inspecao_pragas':
        return 7; // Match PlantaConfigModel default
      case 'poda':
        return 30; // Match PlantaConfigModel default
      case 'replantar':
        return 180; // Match PlantaConfigModel default
      default:
        return 7;
    }
  }

  /// Obtém a descrição detalhada do tipo de cuidado
  static String getDescription(String tipoCuidado) {
    switch (tipoCuidado) {
      case 'agua':
        return 'Fornecer água necessária para hidratação da planta';
      case 'adubo':
        return 'Aplicar fertilizante para nutrição e crescimento';
      case 'banho_sol':
        return 'Expor a planta à luz solar adequada';
      case 'inspecao_pragas':
        return 'Verificar presença de pragas e doenças';
      case 'poda':
        return 'Remover partes desnecessárias ou doentes';
      case 'replantio': // CareType.replantio.value
        return 'Transferir para vaso maior ou novo substrato';
      default:
        return 'Cuidado especial com a planta';
    }
  }

  /// Lista todos os tipos de cuidado disponíveis
  /// Usa CareType.allValidStrings para garantir consistência
  static List<String> getAllTypes() {
    return CareType.allValidStrings;
  }

  /// Verifica se um tipo de cuidado é válido
  /// Usa CareType.isValidCareType para garantir consistência
  static bool isValidType(String tipoCuidado) {
    return CareType.isValidCareType(tipoCuidado);
  }

  /// Métodos helper usando CareType enum diretamente
  /// Para novas implementações, prefira usar estes métodos

  /// Obtém nome usando CareType enum
  static String getNameFromEnum(CareType careType) => getName(careType.value);

  /// Obtém substantivo usando CareType enum
  static String getNounFromEnum(CareType careType) => getNoun(careType.value);

  /// Obtém ícone usando CareType enum
  static IconData getIconFromEnum(CareType careType) => getIcon(careType.value);

  /// Obtém cor usando CareType enum
  static Color getColorFromEnum(CareType careType) => getColor(careType.value);

  /// Método alias para getSemanticColor para compatibilidade
  static Color getColor(String tipoCuidado) => getSemanticColor(tipoCuidado);

  /// Obtém intervalo padrão usando CareType enum
  static int getDefaultIntervalFromEnum(CareType careType) =>
      getDefaultInterval(careType.value);

  /// Obtém descrição usando CareType enum
  static String getDescriptionFromEnum(CareType careType) =>
      getDescription(careType.value);
}
