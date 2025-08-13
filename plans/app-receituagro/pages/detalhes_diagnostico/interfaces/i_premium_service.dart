// MÓDULO: Detalhes de Diagnóstico
// ARQUIVO: Interface Premium Service
// DESCRIÇÃO: Contrato para serviços de assinatura premium
// RESPONSABILIDADES: Definir verificação de status premium e compras
// DEPENDÊNCIAS: Nenhuma (interface pura)
// CRIADO: 2025-06-22 | ATUALIZADO: 2025-06-22
// AUTOR: Sistema de Desenvolvimento ReceituAgro

/// Interface para serviços premium
abstract class IPremiumService {
  /// Verifica se o usuário tem acesso premium
  bool get isPremium;

  /// Obtém informações da assinatura
  Map<String, dynamic> get subscriptionInfo;

  /// Verifica o status premium atual
  Future<bool> checkPremiumStatus();

  /// Atualiza o status premium
  Future<void> refreshPremiumStatus();
}
