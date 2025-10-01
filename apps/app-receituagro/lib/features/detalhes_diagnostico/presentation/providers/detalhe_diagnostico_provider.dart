import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/diagnostico_hive_extension.dart';
import '../../../../core/interfaces/i_premium_service.dart';
import '../../../../core/data/models/diagnostico_hive.dart';
import '../../../../core/data/repositories/diagnostico_hive_repository.dart';
import '../../../../core/data/repositories/favoritos_hive_repository.dart';
import '../../../../core/services/premium_status_notifier.dart';
import '../../../diagnosticos/data/mappers/diagnostico_mapper.dart';
import '../../../diagnosticos/domain/entities/diagnostico_entity.dart';
import '../../../diagnosticos/domain/repositories/i_diagnosticos_repository.dart';
import '../../../favoritos/favoritos_di.dart';
import '../../../favoritos/presentation/providers/favoritos_provider_simplified.dart';

class DetalheDiagnosticoProvider extends ChangeNotifier {
  final IDiagnosticosRepository _diagnosticosRepository =
      sl<IDiagnosticosRepository>();
  final DiagnosticoHiveRepository _hiveRepository =
      sl<DiagnosticoHiveRepository>();
  final FavoritosHiveRepository _favoritosRepository =
      sl<FavoritosHiveRepository>();
  final IPremiumService _premiumService = sl<IPremiumService>();
  late final FavoritosProviderSimplified _favoritosProvider;

  DetalheDiagnosticoProvider() {
    _favoritosProvider = FavoritosDI.get<FavoritosProviderSimplified>();
  }

  // Estado do loading e erro
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  // Estado dos dados - usando modelo unificado
  DiagnosticoEntity? _diagnostico;
  DiagnosticoHive?
  _diagnosticoHive; // Manter temporariamente para compatibilidade
  Map<String, String> _diagnosticoData = {};
  bool _isFavorited = false;
  bool _isPremium = false;

  // Estado do compartilhamento
  bool _isSharingContent = false;

  // Subscription para mudanças no status premium
  StreamSubscription<bool>? _premiumStatusSubscription;

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  DiagnosticoEntity? get diagnostico => _diagnostico;
  DiagnosticoHive? get diagnosticoHive => _diagnosticoHive; // Compatibilidade
  Map<String, String> get diagnosticoData => _diagnosticoData;
  bool get isFavorited => _isFavorited;
  bool get isPremium => _isPremium;
  bool get isSharingContent => _isSharingContent;

  /// Carrega os dados do diagnóstico usando modelo unificado
  Future<void> loadDiagnosticoData(String diagnosticoId) async {
    _setLoadingState(true);

    try {
      // Tenta primeiro através do repository Clean Architecture
      final result = await _diagnosticosRepository.getById(diagnosticoId);

      await result.fold(
        (failure) async {
          // Em caso de falha, tenta fallback
          throw Exception('Erro no repository Clean Architecture: $failure');
        },
        (diagnosticoEntity) async {
          if (diagnosticoEntity != null) {
            _diagnostico = diagnosticoEntity;

            // Fallback para buscar dados Hive para compatibilidade de UI
            final diagnosticoHive = await _hiveRepository.getByIdOrObjectId(diagnosticoId);
            _diagnosticoHive = diagnosticoHive;
            _diagnosticoData =
                diagnosticoHive != null
                    ? await diagnosticoHive.toDataMap()
                    : <String, String>{};

            _setLoadingState(false);
          } else {
            final result = await _hiveRepository.getAll();
            final totalDiagnosticos = result.isSuccess ? result.data!.length : 0;
            _setErrorState(
              totalDiagnosticos == 0
                  ? 'Base de dados vazia. Nenhum diagnóstico foi carregado. Verifique se o aplicativo foi inicializado corretamente ou tente resincronizar os dados.'
                  : 'Diagnóstico com ID "$diagnosticoId" não encontrado. Existem $totalDiagnosticos diagnósticos na base de dados local.',
            );
          }
        },
      );
    } catch (e) {
      // Fallback para método antigo em caso de erro
      try {
        final diagnosticoHive = await _hiveRepository.getByIdOrObjectId(diagnosticoId);
        if (diagnosticoHive != null) {
          _diagnostico = DiagnosticoMapper.fromHive(diagnosticoHive);
          _diagnosticoHive = diagnosticoHive;
          _diagnosticoData = await diagnosticoHive.toDataMap();
          _setLoadingState(false);
        } else {
          _setErrorState('Diagnóstico não encontrado: $diagnosticoId');
        }
      } catch (fallbackError) {
        _setErrorState(
          'Erro ao acessar dados locais: $fallbackError. Tente reiniciar o aplicativo ou resincronizar os dados.',
        );
      }
    }
  }

  /// Carrega o status de premium do usuário
  Future<void> loadPremiumStatus() async {
    try {
      final premium = await _premiumService.isPremiumUser();
      _isPremium = premium;
      notifyListeners();
      debugPrint('🔍 DetalheDiagnostico: Premium status loaded = $premium');

      // Configura listener para mudanças automáticas
      _setupPremiumStatusListener();
    } catch (e) {
      // Em caso de erro, manter como não premium
      _isPremium = false;
      notifyListeners();
    }
  }

  /// Configura listener para mudanças automáticas no status premium
  void _setupPremiumStatusListener() {
    _premiumStatusSubscription?.cancel();
    _premiumStatusSubscription = PremiumStatusNotifier
        .instance
        .premiumStatusStream
        .listen((isPremium) {
          debugPrint(
            '📱 DetalheDiagnostico: Received premium status change = $isPremium',
          );
          _isPremium = isPremium;
          notifyListeners();
        });
  }

  /// Carrega o estado de favorito usando sistema simplificado consistente
  Future<void> loadFavoritoState(String diagnosticoId) async {
    try {
      _isFavorited = await _favoritosProvider.isFavorito(
        'diagnostico',
        diagnosticoId,
      );
    } catch (e) {
      // Fallback para repository direto em caso de erro
      _isFavorited = await _favoritosRepository.isFavorito(
        'diagnosticos',
        diagnosticoId,
      );
    }
    notifyListeners();
  }

  /// Alterna o estado de favorito usando sistema simplificado consistente
  Future<bool> toggleFavorito(
    String diagnosticoId,
    Map<String, String> itemData,
  ) async {
    final wasAlreadyFavorited = _isFavorited;

    // Atualiza UI otimisticamente
    _isFavorited = !wasAlreadyFavorited;
    notifyListeners();

    try {
      // Usa o sistema simplificado de favoritos
      final success = await _favoritosProvider.toggleFavorito(
        'diagnostico',
        diagnosticoId,
      );

      if (!success) {
        // Revert on failure
        _isFavorited = wasAlreadyFavorited;
        notifyListeners();
        return false;
      }

      return true;
    } catch (e) {
      // Fallback para sistema antigo em caso de erro
      try {
        final success =
            wasAlreadyFavorited
                ? await _favoritosRepository.removeFavorito(
                  'diagnosticos',
                  diagnosticoId,
                )
                : await _favoritosRepository.addFavorito(
                  'diagnosticos',
                  diagnosticoId,
                  itemData,
                );

        if (!success) {
          _isFavorited = wasAlreadyFavorited;
          notifyListeners();
          return false;
        }

        return true;
      } catch (fallbackError) {
        // Revert on error
        _isFavorited = wasAlreadyFavorited;
        notifyListeners();
        return false;
      }
    }
  }

  /// Cria texto para compartilhamento
  String buildShareText(
    String diagnosticoId,
    String nomeDefensivo,
    String nomePraga,
    String cultura,
  ) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('🔬 DIAGNÓSTICO RECEITUAGRO');
    buffer.writeln('═' * 30);
    buffer.writeln();

    // Informações básicas
    buffer.writeln('📋 INFORMAÇÕES GERAIS');
    buffer.writeln('• Defensivo: $nomeDefensivo');
    buffer.writeln('• Praga: $nomePraga');
    buffer.writeln('• Cultura: $cultura');
    buffer.writeln();

    // Ingrediente ativo e classificações
    if (_diagnosticoData['ingredienteAtivo']?.isNotEmpty ?? false) {
      buffer.writeln('🧪 INGREDIENTE ATIVO');
      buffer.writeln('• ${_diagnosticoData['ingredienteAtivo']}');
      buffer.writeln();
    }

    buffer.writeln('⚠️ CLASSIFICAÇÕES');
    buffer.writeln('• Toxicológica: ${_diagnosticoData['toxico'] ?? 'N/A'}');
    buffer.writeln(
      '• Ambiental: ${_diagnosticoData['classAmbiental'] ?? 'N/A'}',
    );
    buffer.writeln(
      '• Agronômica: ${_diagnosticoData['classeAgronomica'] ?? 'N/A'}',
    );
    buffer.writeln();

    // Detalhes técnicos
    buffer.writeln('🔧 DETALHES TÉCNICOS');
    if (_diagnosticoData['formulacao']?.isNotEmpty ?? false) {
      buffer.writeln('• Formulação: ${_diagnosticoData['formulacao']}');
    }
    if (_diagnosticoData['modoAcao']?.isNotEmpty ?? false) {
      buffer.writeln('• Modo de Ação: ${_diagnosticoData['modoAcao']}');
    }
    if (_diagnosticoData['mapa']?.isNotEmpty ?? false) {
      buffer.writeln('• Registro MAPA: ${_diagnosticoData['mapa']}');
    }
    buffer.writeln();

    // Aplicação
    buffer.writeln('💧 INSTRUÇÕES DE APLICAÇÃO');
    if (_diagnosticoData['dosagem']?.isNotEmpty ?? false) {
      buffer.writeln('• Dosagem: ${_diagnosticoData['dosagem']}');
    }
    if (_diagnosticoData['vazaoTerrestre']?.isNotEmpty ?? false) {
      buffer.writeln(
        '• Vazão Terrestre: ${_diagnosticoData['vazaoTerrestre']}',
      );
    }
    if (_diagnosticoData['vazaoAerea']?.isNotEmpty ?? false) {
      buffer.writeln('• Vazão Aérea: ${_diagnosticoData['vazaoAerea']}');
    }
    if (_diagnosticoData['intervaloAplicacao']?.isNotEmpty ?? false) {
      buffer.writeln(
        '• Intervalo de Aplicação: ${_diagnosticoData['intervaloAplicacao']}',
      );
    }
    if (_diagnosticoData['intervaloSeguranca']?.isNotEmpty ?? false) {
      buffer.writeln(
        '• Intervalo de Segurança: ${_diagnosticoData['intervaloSeguranca']}',
      );
    }
    buffer.writeln();

    // Tecnologia se disponível
    if (_diagnosticoData['tecnologia']?.isNotEmpty ?? false) {
      buffer.writeln('🎯 TECNOLOGIA DE APLICAÇÃO');
      buffer.writeln(_diagnosticoData['tecnologia']);
      buffer.writeln();
    }

    // Footer
    buffer.writeln('═' * 30);
    buffer.writeln('📱 Gerado pelo ReceitaAgro');
    buffer.writeln('Sua ferramenta de diagnóstico agrícola');

    return buffer.toString();
  }

  /// Copia texto para área de transferência
  Future<bool> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Define estado de loading
  void _setLoadingState(bool loading) {
    _isLoading = loading;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Define estado de erro
  void _setErrorState(String message) {
    _isLoading = false;
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  /// Reinicia dados para nova consulta
  void reset() {
    _isLoading = false;
    _hasError = false;
    _errorMessage = null;
    _diagnostico = null;
    _diagnosticoData = {};
    _isFavorited = false;
    _isSharingContent = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _premiumStatusSubscription?.cancel();
    super.dispose();
  }
}
