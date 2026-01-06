import 'package:dartz/dartz.dart';
import '../../shared/utils/failure.dart';
import '../entities/ads/ad_sense_config_entity.dart';

/// Interface para operações de AdSense na Web
/// Define o contrato para gerenciamento de anúncios AdSense
///
/// Todos os métodos retornam Either<Failure, T> para tratamento funcional de erros
abstract class IWebAdsRepository {
  // ===== Inicialização =====

  /// Inicializa o serviço de AdSense
  ///
  /// [config] - Configuração do AdSense
  ///
  /// Retorna [Right(void)] em sucesso, [Left(Failure)] em erro
  Future<Either<Failure, void>> initialize({
    required AdSenseConfigEntity config,
  });

  /// Verifica se foi inicializado
  bool get isInitialized;

  // ===== Banner Ads =====

  /// Registra um slot de anúncio para uso
  ///
  /// [slotName] - Nome/identificador do slot
  /// [adSlot] - ID do ad slot no AdSense
  /// [format] - Formato do anúncio
  ///
  /// Retorna [Right(String)] com o viewId do elemento registrado
  Future<Either<Failure, String>> registerAdSlot({
    required String slotName,
    required String adSlot,
    AdSenseFormat format = AdSenseFormat.auto,
    bool fullWidthResponsive = true,
    AdSenseSize? size,
  });

  /// Remove um slot de anúncio registrado
  ///
  /// [slotName] - Nome/identificador do slot a remover
  Future<Either<Failure, void>> unregisterAdSlot({required String slotName});

  /// Recarrega um anúncio específico
  ///
  /// [slotName] - Nome do slot para recarregar
  Future<Either<Failure, void>> refreshAd({required String slotName});

  // ===== Controle =====

  /// Verifica se anúncios devem ser mostrados
  ///
  /// [placement] - Identificador do placement
  ///
  /// Retorna [Right(true)] se pode mostrar, [Right(false)] se bloqueado
  Future<Either<Failure, bool>> shouldShowAd({required String placement});

  /// Define se usuário é premium (não mostra ads)
  void setPremiumStatus(bool isPremium);

  /// Obtém status premium atual
  bool get isPremium;

  // ===== Tracking =====

  /// Registra que um anúncio foi exibido
  ///
  /// [placement] - Identificador do placement
  Future<Either<Failure, void>> recordAdShown({required String placement});

  /// Registra que um anúncio foi clicado
  ///
  /// [placement] - Identificador do placement
  Future<Either<Failure, void>> recordAdClicked({required String placement});

  // ===== Lifecycle =====

  /// Limpa todos os recursos
  Future<Either<Failure, void>> dispose();
}

/// Resultado do carregamento de um anúncio AdSense
class AdSenseLoadResult {
  final String viewId;
  final String slotName;
  final bool loaded;
  final String? errorMessage;

  const AdSenseLoadResult({
    required this.viewId,
    required this.slotName,
    required this.loaded,
    this.errorMessage,
  });

  bool get isSuccess => loaded && errorMessage == null;

  @override
  String toString() => 'AdSenseLoadResult('
      'viewId: $viewId, '
      'slotName: $slotName, '
      'loaded: $loaded, '
      'error: $errorMessage)';
}
