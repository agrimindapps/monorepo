// Project imports:
import '../../../../models/medicoes_models.dart';
import '../interfaces/repository_interface.dart';
import '../interfaces/service_interface.dart';
import '../repository/resultados_pluviometro_repository.dart';
import '../services/pluviometria_mockup_generator.dart';
import '../services/pluviometria_processor.dart';
import '../services/pluviometria_statistics_calculator.dart';
import '../services/validation_utils.dart';
import '../widgets/pluviometria_models.dart';

/// Localizador de serviços para dependency injection
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  static ServiceLocator get instance => _instance;

  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};
  final Map<Type, dynamic> _singletons = {};
  bool _isInitialized = false;

  /// Registra uma instância singleton
  void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
  }

  /// Registra uma factory para criação de instâncias
  void registerFactory<T>(T Function() factory) {
    _services[T] = factory;
  }

  /// Registra uma implementação para uma interface
  void registerImplementation<TInterface, TImplementation extends TInterface>(
    TImplementation Function() factory,
  ) {
    _services[TInterface] = factory;
  }

  /// Obtém uma instância do serviço
  T get<T>() {
    // Garante que as dependências estão registradas
    if (!_isInitialized) {
      ServiceLocatorConfig.setupDependencies();
      _isInitialized = true;
    }

    // Verifica se existe um singleton registrado
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }

    // Verifica se existe uma factory registrada
    if (_services.containsKey(T)) {
      final factory = _services[T] as T Function();
      return factory();
    }

    throw Exception('Serviço $T não registrado');
  }

  /// Verifica se um serviço está registrado
  bool isRegistered<T>() {
    return _singletons.containsKey(T) || _services.containsKey(T);
  }

  /// Remove um serviço registrado
  void unregister<T>() {
    _singletons.remove(T);
    _services.remove(T);
  }

  /// Limpa todos os serviços registrados
  void clear() {
    _singletons.clear();
    _services.clear();
  }
}

/// Implementação adaptadora para conectar classes existentes às interfaces
class PluviometriaProcessorAdapter implements IPluviometriaProcessor {
  @override
  List<DadoPluviometrico> processarDadosAnuais(
      List<Medicoes> medicoes, int ano) {
    return PluviometriaProcessor.processarDadosAnuais(medicoes, ano);
  }

  @override
  List<DadoPluviometrico> processarDadosMensais(
      List<Medicoes> medicoes, int ano, int mes) {
    return PluviometriaProcessor.processarDadosMensais(medicoes, ano, mes);
  }

  @override
  List<DadoComparativo> processarDadosComparativos(
    List<Medicoes> medicoes,
    int ano,
    String tipoVisualizacao,
    int mesSelecionado,
  ) {
    return PluviometriaProcessor.processarDadosComparativos(
        medicoes, ano, tipoVisualizacao, mesSelecionado);
  }

  @override
  Map<String, double> agruparMedicoesPorPeriodo(
      List<Medicoes> medicoes, int ano, int? mes) {
    return PluviometriaProcessor.agruparMedicoesPorPeriodo(medicoes, ano, mes);
  }
}

class MockupGeneratorAdapter implements IMockupGenerator {
  @override
  List<DadoPluviometrico> gerarDadosMockupAnual() {
    return PluviometriaMockupGenerator.gerarDadosMockupAnual();
  }

  @override
  List<DadoPluviometrico> gerarDadosMockupMensal(int ano, int mes) {
    return PluviometriaMockupGenerator.gerarDadosMockupMensal(ano, mes);
  }

  @override
  List<DadoComparativo> gerarDadosComparativosMockup(
    String tipoVisualizacao,
    int ano,
    int mesSelecionado,
  ) {
    return PluviometriaMockupGenerator.gerarDadosComparativosMockup(
        tipoVisualizacao, ano, mesSelecionado);
  }

  @override
  EstatisticasPluviometria gerarEstatisticasMockup(
      String tipoVisualizacao, int ano, int mes) {
    return PluviometriaMockupGenerator.gerarEstatisticasMockup(
        tipoVisualizacao, ano, mes);
  }
}

class StatisticsCalculatorAdapter implements IStatisticsCalculator {
  @override
  EstatisticasPluviometria calcularEstatisticas(
    List<Medicoes> medicoes,
    String tipoVisualizacao,
    int ano,
    int mes,
  ) {
    return PluviometriaStatisticsCalculator.calcularEstatisticas(
        medicoes, tipoVisualizacao, ano, mes);
  }

  @override
  Map<String, double> calcularEstatisticasComparativas(
    List<Medicoes> medicoes,
    int anoAtual,
    int anoAnterior,
  ) {
    return PluviometriaStatisticsCalculator.calcularEstatisticasComparativas(
        medicoes, anoAtual, anoAnterior);
  }

  @override
  Map<String, dynamic> calcularTendencia(List<Medicoes> medicoes, int anoBase) {
    return PluviometriaStatisticsCalculator.calcularTendencia(
        medicoes, anoBase);
  }
}

class ValidationServiceAdapter implements IValidationService {
  @override
  Map<String, dynamic> validateAndSanitizeInput({
    required List<Medicoes> medicoes,
    required int ano,
    required int mes,
    String? tipoVisualizacao,
  }) {
    return ValidationUtils.validateAndSanitizeInput(
      medicoes: medicoes,
      ano: ano,
      mes: mes,
      tipoVisualizacao: tipoVisualizacao,
    );
  }

  @override
  bool validateMedicao(Medicoes medicao) {
    return ValidationUtils.validateMedicao(medicao).isValid;
  }

  @override
  String sanitizeString(String input) {
    return ValidationUtils.sanitizeString(input);
  }
}

/// Configuração padrão do ServiceLocator
class ServiceLocatorConfig {
  static void setupDependencies() {
    final serviceLocator = ServiceLocator.instance;

    // Registrar implementações das interfaces
    serviceLocator.registerImplementation<IResultadosPluviometroRepository,
        ResultadosPluviometroRepository>(
      () => ResultadosPluviometroRepository(),
    );

    serviceLocator.registerImplementation<IPluviometriaProcessor,
        PluviometriaProcessorAdapter>(
      () => PluviometriaProcessorAdapter(),
    );

    serviceLocator
        .registerImplementation<IMockupGenerator, MockupGeneratorAdapter>(
      () => MockupGeneratorAdapter(),
    );

    serviceLocator.registerImplementation<IStatisticsCalculator,
        StatisticsCalculatorAdapter>(
      () => StatisticsCalculatorAdapter(),
    );

    serviceLocator
        .registerImplementation<IValidationService, ValidationServiceAdapter>(
      () => ValidationServiceAdapter(),
    );
  }
}
