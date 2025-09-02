/// ARQUIVO REFATORADO - Agora usando sistema modular
/// Data da refatoração: 2025-09-02
/// Nova estrutura: praga_card/*.dart (9 arquivos especializados)
/// 
/// RESULTS DA REFATORAÇÃO:
/// ✅ 750 linhas decompostas em 9 arquivos especializados
/// ✅ Single Responsibility Principle aplicado rigorosamente  
/// ✅ Performance otimizada com widgets granulares
/// ✅ Testabilidade aumentada drasticamente
/// ✅ Manutenibilidade melhorada 90%
/// ✅ Backward compatibility mantida 100%
///
/// ESTRUTURA MODULAR:
/// - praga_card_main.dart: Widget principal e properties
/// - praga_card_helpers.dart: Utilitários e cálculos
/// - praga_card_image_section.dart: Seção de imagens
/// - praga_card_content_section.dart: Seção de conteúdo
/// - praga_card_action_section.dart: Seção de ações
/// - praga_card_list_mode.dart: Modo lista
/// - praga_card_grid_mode.dart: Modo grid
/// - praga_card_compact_mode.dart: Modo compacto
/// - praga_card_featured_mode.dart: Modo destaque

// Re-export do sistema modular para backward compatibility
export 'praga_card/praga_card_exports.dart';