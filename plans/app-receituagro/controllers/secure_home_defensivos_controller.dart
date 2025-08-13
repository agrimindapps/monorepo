// Package imports:
import 'package:get/get.dart';

import '../../core/services/logging_service.dart';
import '../repository/defensivos_repository.dart';
// Project imports:
import '../services/secure_navigation_service.dart';

/// Exemplo de controller refatorado usando navegação segura
/// Demonstra como validar inputs antes de navegar
class SecureHomeDefensivosController extends GetxController {
  final SecureNavigationService _secureNavigation = SecureNavigationService.instance;
  final DefensivosRepository _repository = Get.find<DefensivosRepository>();
  
  /// Navegação segura para detalhes com validação completa
  Future<void> onItemTapSecure(String? id) async {
    try {
      // Log da tentativa de navegação
      LoggingService.info(
        'Tentativa de navegação para defensivo: $id',
        tag: 'SecureHomeDefensivosController',
      );
      
      // Validação prévia usando o NavigationService
      if (!_secureNavigation.isValidId(id)) {
        LoggingService.warning(
          'ID inválido fornecido para navegação: $id',
          tag: 'SecureHomeDefensivosController',
        );
        _showInvalidIdError();
        return;
      }
      
      // Validação adicional: verificar se o defensivo existe
      final defensivoExists = await _validateDefensivoExists(id!);
      if (!defensivoExists) {
        LoggingService.warning(
          'Defensivo não encontrado: $id',
          tag: 'SecureHomeDefensivosController',
        );
        _showDefensivoNotFoundError(id);
        return;
      }
      
      // Registrar acesso antes da navegação
      _repository.setDefensivoAcessado(defensivoId: id);
      
      // Navegação segura
      _secureNavigation.navigateToDefensivoDetails(id);
      
      LoggingService.info(
        'Navegação segura executada para defensivo: $id',
        tag: 'SecureHomeDefensivosController',
      );
    } catch (e) {
      LoggingService.error(
        'Erro na navegação segura: $e | ID: $id',
        tag: 'SecureHomeDefensivosController',
      );
      _showNavigationError();
    }
  }
  
  /// Navegação a partir de dados de busca/filtro
  Future<void> onSearchResultTap(Map<String, dynamic>? data) async {
    try {
      if (data == null || data.isEmpty) {
        LoggingService.warning(
          'Dados vazios fornecidos para navegação',
          tag: 'SecureHomeDefensivosController',
        );
        _showInvalidDataError();
        return;
      }
      
      // Extrair e validar ID dos dados
      final id = data['idReg']?.toString();
      if (id == null || id.isEmpty) {
        LoggingService.warning(
          'ID não encontrado nos dados de busca: $data',
          tag: 'SecureHomeDefensivosController',
        );
        _showInvalidDataError();
        return;
      }
      
      // Usar navegação segura padrão
      await onItemTapSecure(id);
    } catch (e) {
      LoggingService.error(
        'Erro na navegação a partir de dados: $e | Data: $data',
        tag: 'SecureHomeDefensivosController',
      );
      _showNavigationError();
    }
  }
  
  /// Navegação em lote (para ações múltiplas)
  void onBatchNavigate(List<String> ids, String targetRoute) {
    try {
      if (ids.isEmpty) {
        LoggingService.warning(
          'Lista de IDs vazia para navegação em lote',
          tag: 'SecureHomeDefensivosController',
        );
        return;
      }
      
      // Validar todos os IDs antes de proceder
      final validIds = <String>[];
      final invalidIds = <String>[];
      
      for (final id in ids) {
        if (_secureNavigation.isValidId(id)) {
          validIds.add(id);
        } else {
          invalidIds.add(id);
        }
      }
      
      // Log dos resultados de validação
      if (invalidIds.isNotEmpty) {
        LoggingService.warning(
          'IDs inválidos encontrados na navegação em lote: $invalidIds',
          tag: 'SecureHomeDefensivosController',
        );
      }
      
      if (validIds.isEmpty) {
        LoggingService.warning(
          'Nenhum ID válido para navegação em lote',
          tag: 'SecureHomeDefensivosController',
        );
        _showNoValidIdsError();
        return;
      }
      
      // Executar navegação com IDs validados
      final arguments = {
        'defensivo_ids': validIds,
        'source': 'batch_navigation',
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _secureNavigation.navigateToRoute(targetRoute, arguments: arguments);
      
      LoggingService.info(
        'Navegação em lote executada: ${validIds.length} IDs válidos para $targetRoute',
        tag: 'SecureHomeDefensivosController',
      );
    } catch (e) {
      LoggingService.error(
        'Erro na navegação em lote: $e | IDs: $ids | Route: $targetRoute',
        tag: 'SecureHomeDefensivosController',
      );
      _showNavigationError();
    }
  }
  
  /// Navegação condicional baseada no tipo de usuário/permissões
  void onConditionalNavigate(String id, {bool requiresPremium = false}) {
    try {
      // Validação de ID primeiro
      if (!_secureNavigation.isValidId(id)) {
        LoggingService.warning(
          'ID inválido para navegação condicional: $id',
          tag: 'SecureHomeDefensivosController',
        );
        _showInvalidIdError();
        return;
      }
      
      // Verificações de permissão (exemplo)
      if (requiresPremium && !_checkPremiumAccess()) {
        LoggingService.info(
          'Acesso premium necessário para: $id',
          tag: 'SecureHomeDefensivosController',
        );
        _showPremiumRequiredError();
        return;
      }
      
      // Navegação normal se todas as validações passaram
      onItemTapSecure(id);
    } catch (e) {
      LoggingService.error(
        'Erro na navegação condicional: $e | ID: $id',
        tag: 'SecureHomeDefensivosController',
      );
      _showNavigationError();
    }
  }
  
  /// Obtém estatísticas de segurança
  Map<String, dynamic> getSecurityStats() {
    return _secureNavigation.getSecurityStats();
  }
  
  // === MÉTODOS PRIVADOS DE VALIDAÇÃO ===
  
  Future<bool> _validateDefensivoExists(String id) async {
    try {
      // Usar o repository para verificar se o defensivo existe
      final defensivo = await _repository.getDefensivoById(id);
      return defensivo.isNotEmpty;
    } catch (e) {
      LoggingService.error(
        'Erro ao validar existência do defensivo: $e | ID: $id',
        tag: 'SecureHomeDefensivosController',
      );
      return false;
    }
  }
  
  bool _checkPremiumAccess() {
    // Implementar lógica de verificação premium
    // Por ora, sempre retorna true
    return true;
  }
  
  // === MÉTODOS DE TRATAMENTO DE ERRO ===
  
  void _showInvalidIdError() {
    Get.snackbar(
      'ID Inválido',
      'O identificador fornecido não é válido',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
  
  void _showDefensivoNotFoundError(String id) {
    Get.snackbar(
      'Defensivo Não Encontrado',
      'O defensivo solicitado não foi encontrado (ID: $id)',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
  
  void _showInvalidDataError() {
    Get.snackbar(
      'Dados Inválidos',
      'Os dados fornecidos para navegação são inválidos',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
  
  void _showNavigationError() {
    Get.snackbar(
      'Erro de Navegação',
      'Não foi possível completar a navegação. Tente novamente.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
  
  void _showNoValidIdsError() {
    Get.snackbar(
      'Nenhum Item Válido',
      'Nenhum item válido foi encontrado para navegação',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
  
  void _showPremiumRequiredError() {
    Get.snackbar(
      'Acesso Premium Necessário',
      'Esta funcionalidade requer acesso premium',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }
}