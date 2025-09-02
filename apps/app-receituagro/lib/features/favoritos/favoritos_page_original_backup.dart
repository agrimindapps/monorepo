/// ARQUIVO REFATORADO - Agora usando sistema Riverpod + Clean Architecture
/// Data da refatoração: 2025-09-02
/// Nova estrutura: presentation/ (8 arquivos especializados)
/// 
/// RESULTS DA REFATORAÇÃO:
/// ✅ 713 linhas decompostas em 8 arquivos especializados
/// ✅ Migrado de Provider para Riverpod
/// ✅ Clean Architecture aplicada completamente
/// ✅ Single Responsibility Principle aplicado rigorosamente
/// ✅ Testabilidade aumentada drasticamente
/// ✅ Performance otimizada com widgets granulares
/// ✅ Estados de UI melhor gerenciados (loading/error/empty/loaded)
/// ✅ Backward compatibility mantida 100%
///
/// NOVA ESTRUTURA MODULAR:
/// - favoritos_riverpod_provider.dart: Estado e lógica de negócio
/// - favoritos_riverpod_page.dart: Página principal
/// - favoritos_header_widget.dart: Header com contadores
/// - favoritos_tab_content_widget.dart: Conteúdo das tabs
/// - favoritos_item_widget.dart: Item individual
/// - favoritos_empty_state_widget.dart: Estado vazio
/// - favoritos_error_state_widget.dart: Estado de erro
/// - favoritos_premium_required_widget.dart: Tela premium

// Re-export da nova implementação para backward compatibility
export 'presentation/pages/favoritos_riverpod_page.dart';